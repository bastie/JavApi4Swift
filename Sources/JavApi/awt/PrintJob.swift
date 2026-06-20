/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Abstract base class representing a print job.
  ///
  /// Mirrors `java.awt.PrintJob` (Java 1.1 / JFC 1.0).
  ///
  /// Obtain an instance via
  /// ```swift
  /// let job = Toolkit.getDefaultToolkit().getPrintJob(frame, "Title", nil)
  /// ```
  /// then call `getGraphics()` to render each page, `dispose()` the returned
  /// `Graphics` object to finish the page, and `end()` to complete the job.
  ///
  /// ### Typical usage
  /// ```swift
  /// if let job = Toolkit.getDefaultToolkit().getPrintJob(frame, "My Print", nil) {
  ///   let g = job.getGraphics()
  ///   myComponent.print(g)
  ///   g.dispose()
  ///   job.end()
  /// }
  /// ```
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.1)
  @MainActor
  open class PrintJob {

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Page rendering
    // -------------------------------------------------------------------------

    /// Returns a `Graphics` object for rendering the next page.
    ///
    /// Each call starts a new page. Call `Graphics.dispose()` on the returned
    /// object to finish the page and advance to the next one.
    /// Returns `nil` when no more pages can be printed.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func getGraphics() -> java.awt.Graphics? {
      return nil
    }

    // -------------------------------------------------------------------------
    // MARK: Page properties
    // -------------------------------------------------------------------------

    /// Returns the dimensions of the page in pixels.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func getPageDimension() -> java.awt.Dimension {
      return java.awt.Dimension(0, 0)
    }

    /// Returns the resolution of the page in pixels per inch.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func getPageResolution() -> Int {
      return 72
    }

    /// Returns `true` if the last page is printed first.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func lastPageFirst() -> Bool {
      return false
    }

    // -------------------------------------------------------------------------
    // MARK: Job lifecycle
    // -------------------------------------------------------------------------

    /// Ends the print job and releases all associated resources.
    ///
    /// Must be called after all pages have been rendered.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func end() {}

    /// Finalises the print job.
    ///
    /// Calls `end()` if not already done. Mirrors `java.awt.PrintJob.finalize()`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func finalize() {
      end()
    }
  }
}
