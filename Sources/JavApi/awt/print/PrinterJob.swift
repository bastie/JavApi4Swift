/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(AppKit) && os(macOS)
import AppKit
import CoreGraphics
#endif

extension java.awt.print {

  /// Controls the printing process — mirrors `java.awt.print.PrinterJob`.
  ///
  /// Obtain an instance via the static factory `getPrinterJob()`, configure
  /// it with `setPrintable(_:)` or `setPageable(_:)`, optionally show a print
  /// dialog, then call `print()` to render the job.
  ///
  /// ### Minimal usage
  /// ```swift
  /// let job = java.awt.print.PrinterJob.getPrinterJob()
  /// job.setPrintable(myPrintable)
  /// if job.printDialog() {
  ///   try job.print()
  /// }
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class PrinterJob {

    // -------------------------------------------------------------------------
    // MARK: - Factory
    // -------------------------------------------------------------------------

    /// Returns the platform's `PrinterJob` implementation.
    ///
    /// On macOS this returns a CoreGraphics-backed PDF printer that opens
    /// in the system PDF viewer. On all other platforms a headless stub is
    /// returned.
    ///
    /// - Since: Java 1.2
    public static func getPrinterJob() -> PrinterJob {
#if canImport(AppKit) && os(macOS)
      return _CoreGraphicsPrinterJob()
#else
      return PrinterJob()          // headless stub
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: - Job configuration
    // -------------------------------------------------------------------------

    /// The human-readable job name displayed in the print queue.
    public var jobName: String = "JavApi Print Job"

    private var _printable: (any Printable)?
    private var _pageable:  (any Pageable)?
    private var _pageFormat: PageFormat = PageFormat()

    /// Configures the job to use a single `Printable` renderer for all pages.
    public func setPrintable(_ printable: any Printable) {
      _printable  = printable
      _pageable   = nil
    }

    /// Configures the job with a single `Printable` and explicit `PageFormat`.
    public func setPrintable(_ printable: any Printable,
                             _ pageFormat: PageFormat) {
      _printable   = printable
      _pageFormat  = pageFormat
      _pageable    = nil
    }

    /// Configures the job with a `Pageable` document (multiple pages / formats).
    public func setPageable(_ pageable: any Pageable) {
      _pageable   = pageable
      _printable  = nil
    }

    /// Returns a copy of the default `PageFormat` for this job.
    public func defaultPage() -> PageFormat { _pageFormat.clone() }

    /// Returns a validated copy of the given `PageFormat`
    /// (stub — returns unchanged copy).
    public func validatePage(_ pageFormat: PageFormat) -> PageFormat {
      pageFormat.clone()
    }

    // -------------------------------------------------------------------------
    // MARK: - Dialog
    // -------------------------------------------------------------------------

    /// Displays a native print dialog.
    ///
    /// - Returns: `true` if the user confirmed, `false` if they cancelled.
    ///
    /// The base implementation always returns `true` (headless / no dialog).
    open func printDialog() -> Bool { true }

    // -------------------------------------------------------------------------
    // MARK: - Printing
    // -------------------------------------------------------------------------

    /// Renders and submits the print job.
    ///
    /// - Throws: `PrinterException` on error.
    open func print() throws {
      // Base (headless) implementation: iterate and discard output.
      if let pageable = _pageable {
        let count = pageable.getNumberOfPages()
        let limit = count == UNKNOWN_NUMBER_OF_PAGES ? Int.max : count
        for i in 0 ..< limit {
          guard let pf = try? pageable.getPageFormat(i),
                let pr = try? pageable.getPrintable(i) else { break }
          let result = pr.print(java.awt.Graphics(), pf, i)
          if result == java.awt.print._PrintableNoOp.NO_SUCH_PAGE { break }
        }
      } else if let printable = _printable {
        var page = 0
        while true {
          let result = printable.print(java.awt.Graphics(), _pageFormat, page)
          if result == java.awt.print._PrintableNoOp.NO_SUCH_PAGE { break }
          page += 1
        }
      }
    }

    /// Cancels an in-progress print job.
    open func cancel() {}

    /// Returns `true` if the job has been cancelled.
    open func isCancelled() -> Bool { false }

    // -------------------------------------------------------------------------
    // MARK: - Init
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: - Internal helpers for subclasses
    // -------------------------------------------------------------------------

    /// Resolved `Printable` for page `index` (from either Printable or Pageable).
    internal func resolvePrintable(for index: Int) -> (any Printable)? {
      if let pag = _pageable {
        return try? pag.getPrintable(index)
      }
      return _printable
    }

    /// Resolved `PageFormat` for page `index`.
    internal func resolvePageFormat(for index: Int) -> PageFormat {
      if let pag = _pageable {
        return (try? pag.getPageFormat(index)) ?? _pageFormat
      }
      return _pageFormat
    }
  }
}

// =============================================================================
// MARK: - macOS CoreGraphics implementation
// =============================================================================

#if canImport(AppKit) && os(macOS)
extension java.awt.print {

  /// macOS-specific `PrinterJob` that renders each page into a CoreGraphics
  /// PDF context and opens the result in the system PDF viewer.
  @MainActor
  final class _CoreGraphicsPrinterJob: PrinterJob {

    // -------------------------------------------------------------------------
    // MARK: - Dialog
    // -------------------------------------------------------------------------

    override func printDialog() -> Bool {
      // NSPrintPanel requires an NSPrintInfo / NSPrintOperation context which
      // is tightly coupled to NSView. Show a simple confirmation alert instead.
      let alert = NSAlert()
      alert.messageText     = "Print"
      alert.informativeText = "Print job: \"\(jobName)\"\n\nClick Print to proceed."
      alert.addButton(withTitle: "Print")
      alert.addButton(withTitle: "Cancel")
      return alert.runModal() == .alertFirstButtonReturn
    }

    // -------------------------------------------------------------------------
    // MARK: - Printing
    // -------------------------------------------------------------------------

    override func print() throws {
      let pageFormat = resolvePageFormat(for: 0)

      let pdfData = NSMutableData()
      var mediaBox = CGRect(x: 0, y: 0,
                            width: pageFormat.getWidth(),
                            height: pageFormat.getHeight())

      guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
            let ctx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
        throw PrinterException("Failed to create PDF context")
      }

      var pageIndex = 0
      while true {
        guard let printable = resolvePrintable(for: pageIndex) else { break }
        let pf = resolvePageFormat(for: pageIndex)

        let pH = pf.getHeight()
        ctx.beginPDFPage(nil)

        // Flip to top-left origin (Java convention)
        ctx.saveGState()
        ctx.translateBy(x: 0, y: CGFloat(pH))
        ctx.scaleBy(x: 1.0, y: -1.0)

        let g = java.awt.Graphics2D(ctx)
        let result = printable.print(g, pf, pageIndex)

        ctx.restoreGState()
        ctx.endPDFPage()

        if result == java.awt.print._PrintableNoOp.NO_SUCH_PAGE { break }
        pageIndex += 1

        // Safety: avoid runaway loops when total pages unknown
        if pageIndex > 9_999 { break }
      }

      ctx.closePDF()

      // Write PDF to temp file and open in Preview / default PDF viewer
      let tmp = FileManager.default.temporaryDirectory
        .appendingPathComponent("JavApi4Swift_print_\(Int(Date().timeIntervalSince1970)).pdf")
      do {
        try pdfData.write(to: tmp, options: .atomic)
        NSWorkspace.shared.open(tmp)
      } catch {
        throw PrinterIOException(java.io.IOException(error.localizedDescription))
      }
    }
  }
}
#endif
