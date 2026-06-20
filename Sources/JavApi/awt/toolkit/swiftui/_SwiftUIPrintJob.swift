/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI) && os(macOS) && canImport(AppKit)
import AppKit
import CoreGraphics

extension java.awt.toolkit.swiftui {

  /// macOS implementation of `java.awt.PrintJob`.
  ///
  /// Renders each page into a CoreGraphics PDF context.
  /// When `end()` is called, the resulting PDF is written to a temporary file
  /// and opened in the system PDF viewer (Preview.app) for printing.
  ///
  /// Coordinate system: the PDF context origin is flipped to top-left so that
  /// Java drawing code matches screen coordinates.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.1)
  @MainActor
  final class _SwiftUIPrintJob: java.awt.PrintJob {

    private let pdfData   = NSMutableData()
    private var pdfCtx    : CGContext?
    private let pageWidth : CGFloat
    private let pageHeight: CGFloat
    private var pageOpen  = false

    init(pageWidth: CGFloat, pageHeight: CGFloat) {
      self.pageWidth  = pageWidth
      self.pageHeight = pageHeight
      super.init()

      var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
      guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else { return }
      pdfCtx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)
    }

    // -------------------------------------------------------------------------
    // MARK: PrintJob API
    // -------------------------------------------------------------------------

    override func getGraphics() -> java.awt.Graphics? {
      guard let ctx = pdfCtx else { return nil }

      // Close previous page if still open
      if pageOpen {
        ctx.endPDFPage()
      }

      ctx.beginPDFPage(nil)
      pageOpen = true

      // Flip coordinate system: Java uses top-left origin, PDF uses bottom-left.
      ctx.saveGState()
      ctx.translateBy(x: 0, y: pageHeight)
      ctx.scaleBy(x: 1.0, y: -1.0)

      return java.awt.Graphics2D(ctx)
    }

    override func getPageDimension() -> java.awt.Dimension {
      return java.awt.Dimension(Int(pageWidth), Int(pageHeight))
    }

    override func getPageResolution() -> Int { 72 }

    override func lastPageFirst() -> Bool { false }

    override func end() {
      guard let ctx = pdfCtx else { return }

      if pageOpen {
        ctx.restoreGState()
        ctx.endPDFPage()
        pageOpen = false
      }
      ctx.closePDF()
      pdfCtx = nil

      // Write PDF to a temporary file and open with the default viewer.
      let tmp = FileManager.default.temporaryDirectory
        .appendingPathComponent("JavApi4Swift_print_\(Int(Date().timeIntervalSince1970)).pdf")
      do {
        try pdfData.write(to: tmp, options: .atomic)
        NSWorkspace.shared.open(tmp)
      } catch {
        // Silent failure: printing not available (e.g. sandboxed without temp access)
      }
    }

    override func finalize() {
      end()
    }
  }
}
#endif
