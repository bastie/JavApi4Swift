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
    public static let LEFT   = LabelAlignment.LEFT.rawValue
    /// Align text centred within the label.
    public static let CENTER = LabelAlignment.CENTER.rawValue
    /// Align text to the right edge of the label.
    public static let RIGHT  = LabelAlignment.RIGHT.rawValue

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
    public init(_ text: String, _ alignment: Int) throws {
      guard [0, 1, 2].contains(alignment) else {
        throw IllegalArgumentException("Illegal alignment: \(alignment)")
      }
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

    public func getAlignment() -> Int {
      _alignment
    }

    public func setAlignment(_ alignment: Int) throws {
      guard [0, 1, 2].contains(alignment) else {
        throw IllegalArgumentException("Illegal alignment: \(alignment)")
      }
      _alignment = alignment
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    /// Returns a size computed from the label text so LayoutManagers (e.g.
    /// `GridBagLayout`) can allocate an appropriate cell without the caller
    /// having to invoke `setPreferredSize`.  An explicit `setPreferredSize`
    /// call still takes precedence.
    override public func getPreferredSize() -> java.awt.Dimension {
      if let explicit = _preferredSize { return explicit }
      let fm = getFontMetrics(font)
      let w  = fm.stringWidth(_text) + 8   // 4px pad each side
      let h  = fm.getHeight() + 4
      return java.awt.Dimension(max(4, w), max(4, h))
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      // Paint in LOCAL coordinates (0,0) — Container.paint() has already
      // translated the graphics context to this component's origin.
      let x = 0, y = 0, w = bounds.width, h = bounds.height

      // Background
      g.setColor(background)
      g.fillRect(x, y, w, h)

      guard !_text.isEmpty, w > 0, h > 0 else { return }

      let fm  = g.getFontMetrics(font)
      let tw  = fm.stringWidth(_text)
      let ty  = y + (h - fm.getHeight()) / 2 + fm.getAscent()
      let pad = 2

      let tx: Int
      switch _alignment {
      case Label.RIGHT:
        tx = x + w - tw - pad
      case Label.CENTER:
        tx = tw < w ? x + (w - tw) / 2 : x + pad
      default: // LEFT
        tx = x + pad
      }

      g.save()
      g.clipRect(x, y, w, h)
      g.setColor(foreground)
      g.drawString(_text, tx, ty)
      g.restore()
    }
  }
}
