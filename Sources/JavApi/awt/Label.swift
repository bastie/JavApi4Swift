/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A single line of read-only text — mirrors `java.awt.Label`.
  ///
  /// Label is a leaf component (no children). Use it to caption other
  /// components or display static information in a form.
  ///
  /// ```swift
  /// let lbl = java.awt.Label("Name:", java.awt.Label.RIGHT)
  /// lbl.bounds = java.awt.Rectangle(0, 0, 80, 24)
  /// panel.add(lbl)
  /// ```
  open class Label: Component {

    // -------------------------------------------------------------------------
    // MARK: Alignment constants  (Java API names)
    // -------------------------------------------------------------------------

    /// Align text to the left edge of the label.
    public static let LEFT   = 0
    /// Align text centred within the label.
    public static let CENTER = 1
    /// Align text to the right edge of the label.
    public static let RIGHT  = 2

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    private var _text:      String
    private var _alignment: Int

    // -------------------------------------------------------------------------
    // MARK: Constructors  (Java API)
    // -------------------------------------------------------------------------

    /// Creates an empty label with left alignment.
    public override init() {
      _text      = ""
      _alignment = Label.LEFT
      super.init()
    }

    /// Creates a label with the given text and left alignment.
    public init(_ text: String) {
      _text      = text
      _alignment = Label.LEFT
      super.init()
    }

    /// Creates a label with the given text and alignment.
    ///
    /// - Parameters:
    ///   - text:      The text to display.
    ///   - alignment: `Label.LEFT`, `Label.CENTER`, or `Label.RIGHT`.
    public init(_ text: String, _ alignment: Int) {
      _text      = text
      _alignment = alignment
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors  (Java API)
    // -------------------------------------------------------------------------

    public func getText() -> String { _text }

    public func setText(_ text: String) {
      _text = text
      repaint()
    }

    public func getAlignment() -> Int { _alignment }

    public func setAlignment(_ alignment: Int) {
      _alignment = alignment
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height

      // Background
      g.setColor(background)
      g.fillRect(x, y, w, h)

      guard !_text.isEmpty else { return }

      let fm  = getFontMetrics(font)
      let tw  = fm.stringWidth(_text)
      let ty  = y + (h - fm.getHeight()) / 2 + fm.getAscent()
      let pad = 2

      let tx: Int
      switch _alignment {
      case Label.RIGHT:
        tx = x + w - tw - pad
      case Label.CENTER:
        tx = x + (w - tw) / 2
      default: // LEFT
        tx = x + pad
      }

      g.setColor(foreground)
      g.drawString(_text, tx, ty)
    }
  }
}
