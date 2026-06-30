/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.print {

  /// Implemented by objects that can render themselves onto a page for printing —
  /// mirrors `java.awt.print.Printable`.
  ///
  /// The single method `print(_:_:_:)` is called by a `PrinterJob` once per page.
  /// It must return either `java.awt.print.PAGE_EXISTS` or `java.awt.print.NO_SUCH_PAGE`.
  ///
  /// ### Example
  /// ```swift
  /// final class MyPage: java.awt.print.Printable {
  ///   func print(_ g: java.awt.Graphics,
  ///              _ pf: java.awt.print.PageFormat,
  ///              _ pageIndex: Int) -> Int {
  ///     guard pageIndex == 0 else { return java.awt.print.NO_SUCH_PAGE }
  ///     g.drawString("Hello, World!", 100, 100)
  ///     return java.awt.print.PAGE_EXISTS
  ///   }
  /// }
  /// ```
  ///
  /// - Since: Java 1.2
  public protocol Printable: AnyObject {

    /// Renders the given page onto `graphics`.
    ///
    /// - Parameters:
    ///   - graphics:   The `Graphics` context to draw into.
    ///   - pageFormat: The orientation and size of the page.
    ///   - pageIndex:  Zero-based page number.
    /// - Returns: `java.awt.print.PAGE_EXISTS` or `java.awt.print.NO_SUCH_PAGE`.
    func print(_ graphics: java.awt.Graphics,
               _ pageFormat: PageFormat,
               _ pageIndex: Int) -> Int
  }
 
  /// Helper class for Printable constants using
  internal class _PrintableNoOp : Printable {
    func print(_ graphics: java.awt.Graphics, _ pageFormat: java.awt.print.PageFormat, _ pageIndex: Int) -> Int {
      return _PrintableNoOp.NO_SUCH_PAGE
    }
    
    
  }
}
extension java.awt.print.Printable {

  public nonisolated(unsafe) static var PAGE_EXISTS : Int { 0 }

  public nonisolated(unsafe) static var NO_SUCH_PAGE: Int { 1 }
  
}
