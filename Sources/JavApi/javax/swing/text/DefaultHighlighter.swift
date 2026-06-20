/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Default implementation of `Highlighter` — mirrors
  /// `javax.swing.text.DefaultHighlighter` from Java 1.2 / JFC 1.0.
  ///
  /// `DefaultHighlighter` paints coloured bands behind text regions.
  /// It is installed automatically by `JTextComponent`.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let h = textPane.getHighlighter() as? javax.swing.text.DefaultHighlighter
  /// let tag = try h?.addHighlight(0, 5, javax.swing.text.DefaultHighlighter.DefaultPainter)
  /// h?.removeHighlight(tag)
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class DefaultHighlighter: javax.swing.text.Highlighter {

    // -------------------------------------------------------------------------
    // MARK: DefaultPainter singleton
    // -------------------------------------------------------------------------

    /// The default `HighlightPainter` — paints a semi-transparent blue band.
    public static let DefaultPainter: any javax.swing.text.HighlightPainter =
      _DefaultHighlightPainter(java.awt.Color(173, 214, 255))  // macOS selection blue

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var _highlights: [_HighlightEntry] = []
    private weak var _component: javax.swing.text.JTextComponent?

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Highlighter — lifecycle
    // -------------------------------------------------------------------------

    open func install(_ c: javax.swing.text.JTextComponent) {
      _component = c
      _highlights.removeAll()
    }

    open func deinstall(_ c: javax.swing.text.JTextComponent) {
      _highlights.removeAll()
      _component = nil
    }

    // -------------------------------------------------------------------------
    // MARK: Highlighter — painting
    // -------------------------------------------------------------------------

    open func paint(_ g: java.awt.Graphics) {
      guard let comp = _component else { return }
      for entry in _highlights {
        entry.painter.paint(g, entry.p0, entry.p1, comp.bounds, comp)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Highlighter — management
    // -------------------------------------------------------------------------

    @discardableResult
    open func addHighlight(_ p0: Int, _ p1: Int,
                           _ painter: any javax.swing.text.HighlightPainter) throws -> AnyObject {
      guard let comp = _component else {
        throw javax.swing.text.BadLocationException("no component installed", p0)
      }
      let len = comp.getDocument().getLength()
      guard p0 >= 0, p1 >= p0, p1 <= len else {
        throw javax.swing.text.BadLocationException(
          "addHighlight: p0=\(p0) p1=\(p1) length=\(len)", p0)
      }
      let entry = _HighlightEntry(p0: p0, p1: p1, painter: painter)
      _highlights.append(entry)
      comp.repaint()
      return entry
    }

    open func removeHighlight(_ tag: AnyObject) {
      _highlights.removeAll { $0 === tag }
      _component?.repaint()
    }

    open func removeAllHighlights() {
      _highlights.removeAll()
      _component?.repaint()
    }

    open func changeHighlight(_ tag: AnyObject, _ p0: Int, _ p1: Int) throws {
      guard let entry = _highlights.first(where: { $0 === tag }) else { return }
      guard let comp = _component else { return }
      let len = comp.getDocument().getLength()
      guard p0 >= 0, p1 >= p0, p1 <= len else {
        throw javax.swing.text.BadLocationException(
          "changeHighlight: p0=\(p0) p1=\(p1) length=\(len)", p0)
      }
      entry.p0 = p0
      entry.p1 = p1
      comp.repaint()
    }

    open func getHighlights() -> [any javax.swing.text.Highlight] {
      _highlights
    }
  }
}

// -----------------------------------------------------------------------------
// MARK: Internal helpers
// -----------------------------------------------------------------------------

/// Mutable storage for one installed highlight.
@MainActor
private final class _HighlightEntry: javax.swing.text.Highlight {
  var p0: Int
  var p1: Int
  let painter: any javax.swing.text.HighlightPainter

  init(p0: Int, p1: Int, painter: any javax.swing.text.HighlightPainter) {
    self.p0 = p0; self.p1 = p1; self.painter = painter
  }

  func getStartOffset() -> Int { p0 }
  func getEndOffset()   -> Int { p1 }
  func getPainter() -> any javax.swing.text.HighlightPainter { painter }
}

/// Paints a solid colour band from p0 to p1.
@MainActor
private final class _DefaultHighlightPainter: javax.swing.text.HighlightPainter {
  private let color: java.awt.Color

  init(_ color: java.awt.Color) { self.color = color }

  func paint(_ g: java.awt.Graphics,
             _ p0: Int, _ p1: Int,
             _ bounds: java.awt.Shape,
             _ c: javax.swing.text.JTextComponent) {
    guard p0 < p1 else { return }
    let b = c.bounds
    guard b.width > 0, b.height > 0 else { return }
    let fm    = java.awt.FontMetrics.make(for: c.font)
    let lineH = fm.getHeight()
    if let text = try? c.getDocument().getText(0, c.getDocument().getLength()) {
      let chars = Array(text)
      var row0 = 0
      for i in 0..<min(p0, chars.count) { if chars[i] == "\n" { row0 += 1 } }
      var row1 = row0
      for i in p0..<min(p1, chars.count) { if chars[i] == "\n" { row1 += 1 } }
      g.save()
      g.setColor(color)
      for row in row0...row1 {
        g.fillRect(b.x, b.y + row * lineH, b.width, lineH)
      }
      g.restore()
    }
  }
}
