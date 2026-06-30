/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.print {

  /// A collection of pages with potentially different `PageFormat`s and
  /// `Printable` renderers — mirrors `java.awt.print.Book`.
  ///
  /// `Book` implements `Pageable` and is the standard way to hand a
  /// multi-page, multi-format document to a `PrinterJob`.
  ///
  /// ### Example
  /// ```swift
  /// let book = java.awt.print.Book()
  /// book.append(myPrintable, pageFormat)
  /// let job = java.awt.print.PrinterJob.getPrinterJob()
  /// job.setPageable(book)
  /// try job.print()
  /// ```
  ///
  /// - Since: Java 1.2
  public final class Book: Pageable {

    private struct Entry {
      let printable:  any Printable
      let pageFormat: PageFormat
    }

    private var pages: [Entry] = []

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: - Pageable
    // -------------------------------------------------------------------------

    public func getNumberOfPages() -> Int { pages.count }

    public func getPageFormat(_ pageIndex: Int) throws -> PageFormat {
      guard pageIndex >= 0 && pageIndex < pages.count else {
        throw java.lang.IndexOutOfBoundsException("Page index out of bounds: \(pageIndex)")
      }
      return pages[pageIndex].pageFormat.clone()
    }

    public func getPrintable(_ pageIndex: Int) throws -> any Printable {
      guard pageIndex >= 0 && pageIndex < pages.count else {
        throw java.lang.IndexOutOfBoundsException("Page index out of bounds: \(pageIndex)")
      }
      return pages[pageIndex].printable
    }

    // -------------------------------------------------------------------------
    // MARK: - Mutation
    // -------------------------------------------------------------------------

    /// Appends a single page to the book.
    public func append(_ printable: any Printable, _ pageFormat: PageFormat) {
      pages.append(Entry(printable: printable, pageFormat: pageFormat))
    }

    /// Appends `numPages` pages using the same `Printable` and `PageFormat`.
    public func append(_ printable: any Printable,
                       _ pageFormat: PageFormat,
                       _ numPages: Int) {
      for _ in 0 ..< numPages {
        pages.append(Entry(printable: printable, pageFormat: pageFormat))
      }
    }

    /// Replaces the entry at `pageIndex`.
    public func setPage(_ pageIndex: Int,
                        _ printable: any Printable,
                        _ pageFormat: PageFormat) throws {
      guard pageIndex >= 0 && pageIndex < pages.count else {
        throw java.lang.IndexOutOfBoundsException("Page index out of bounds: \(pageIndex)")
      }
      pages[pageIndex] = Entry(printable: printable, pageFormat: pageFormat)
    }
  }
}
