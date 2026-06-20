/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Manages the display of text highlights in a `JTextComponent` — mirrors
  /// `javax.swing.text.Highlighter` from Java 1.2 / JFC 1.0.
  ///
  /// A `Highlighter` paints coloured regions behind selected or marked text.
  /// The default implementation (`DefaultHighlighter`) is installed
  /// automatically by `JTextComponent`.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let highlighter = textPane.getHighlighter()
  /// let tag = try highlighter?.addHighlight(5, 10, DefaultHighlighter.DefaultPainter)
  /// // later:
  /// highlighter?.removeHighlight(tag)
  /// ```
  ///
  /// > Note: In Java `HighlightPainter` and `Highlight` are nested interfaces
  /// > inside `Highlighter`. In Swift they are top-level types in
  /// > `javax.swing.text` — use `javax.swing.text.HighlightPainter` and
  /// > `javax.swing.text.Highlight`.
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  public protocol Highlighter: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Java-compatible nested-type aliases
    // -------------------------------------------------------------------------
    // Swift forbids nested protocols, so HighlightPainter and Highlight live
    // as top-level types in javax.swing.text.  The typealiases below restore
    // the Java-style dot notation: Highlighter.HighlightPainter,
    // Highlighter.Highlight — any code that references these names compiles
    // identically to the Java source.
    typealias HighlightPainter = javax.swing.text.HighlightPainter
    typealias Highlight        = javax.swing.text.Highlight

    // -------------------------------------------------------------------------
    // MARK: Lifecycle
    // -------------------------------------------------------------------------

    /// Called by the text component when this highlighter is installed.
    func install(_ c: javax.swing.text.JTextComponent)

    /// Called by the text component when this highlighter is removed.
    func deinstall(_ c: javax.swing.text.JTextComponent)

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    /// Renders all highlights onto `g` for the given text component.
    func paint(_ g: java.awt.Graphics)

    // -------------------------------------------------------------------------
    // MARK: Highlight management
    // -------------------------------------------------------------------------

    /// Adds a highlight over `[p0, p1)` using `painter` and returns an
    /// opaque tag that can be used to modify or remove the highlight later.
    ///
    /// - Throws: `BadLocationException` if the range is out of bounds.
    @discardableResult
    func addHighlight(_ p0: Int, _ p1: Int,
                      _ painter: any javax.swing.text.HighlightPainter) throws -> AnyObject

    /// Removes the highlight identified by `tag`.
    func removeHighlight(_ tag: AnyObject)

    /// Removes all highlights.
    func removeAllHighlights()

    /// Changes the highlight identified by `tag` to cover `[p0, p1)`.
    ///
    /// - Throws: `BadLocationException` if the range is out of bounds.
    func changeHighlight(_ tag: AnyObject, _ p0: Int, _ p1: Int) throws

    /// Returns all currently installed highlights.
    func getHighlights() -> [any javax.swing.text.Highlight]
  }
}
