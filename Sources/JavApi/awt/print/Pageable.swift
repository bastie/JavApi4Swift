/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.print {

  // ---------------------------------------------------------------------------
  // MARK: - Pageable constant
  //
  // Defined at namespace level to avoid Swift's restriction on static members
  // of protocol metatypes (any P).Type.
  // Usage: java.awt.print.UNKNOWN_NUMBER_OF_PAGES
  // ---------------------------------------------------------------------------

  /// Returned by `getNumberOfPages()` when the total page count is not known.
  /// Mirrors `java.awt.print.Pageable.UNKNOWN_NUMBER_OF_PAGES`.
  public static let UNKNOWN_NUMBER_OF_PAGES: Int = -1

  /// Implemented by objects that represent a set of pages to be printed —
  /// mirrors `java.awt.print.Pageable`.
  ///
  /// A `Pageable` provides the `PrinterJob` with the `PageFormat` and
  /// `Printable` renderer for each page.
  ///
  /// - Since: Java 1.2
  public protocol Pageable: AnyObject {

    /// Returns the total number of pages, or `java.awt.print.UNKNOWN_NUMBER_OF_PAGES`.
    func getNumberOfPages() -> Int

    /// Returns the `PageFormat` for page `pageIndex`.
    ///
    /// - Throws: `IndexOutOfBoundsException` if `pageIndex` is invalid.
    func getPageFormat(_ pageIndex: Int) throws -> PageFormat

    /// Returns the `Printable` renderer for page `pageIndex`.
    ///
    /// - Throws: `IndexOutOfBoundsException` if `pageIndex` is invalid.
    func getPrintable(_ pageIndex: Int) throws -> any Printable
  }
}
