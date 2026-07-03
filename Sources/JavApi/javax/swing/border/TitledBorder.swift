/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// A border that paints a title string above (or around) another border.
  ///
  /// The title can be positioned at the top or bottom of the border, and
  /// justified to the left, center, or right.  When no inner border is given
  /// an `EtchedBorder` is used as the default.
  ///
  /// Corresponds to `javax.swing.border.TitledBorder`.
  @MainActor
  open class TitledBorder: AbstractBorder {

    // ── Title justification constants ────────────────────────────────────────
    public static let DEFAULT_JUSTIFICATION = 0
    public static let LEFT                  = 1
    public static let CENTER                = 2
    public static let RIGHT                 = 3
    public static let LEADING               = 4
    public static let TRAILING              = 5

    // ── Title position constants ─────────────────────────────────────────────
    public static let DEFAULT_POSITION = 0
    public static let ABOVE_TOP        = 1
    public static let TOP              = 2
    public static let BELOW_TOP        = 3
    public static let ABOVE_BOTTOM     = 4
    public static let BOTTOM           = 5
    public static let BELOW_BOTTOM     = 6

    /// Vertical padding between the title text and the border line.
    private static let TEXT_SPACING = 2
    /// Horizontal inset for the title text within the border.
    private static let TEXT_INSET_H = 5

    // ── Properties ───────────────────────────────────────────────────────────

    private var title: String
    private var border: (any Border)?
    private var titlePosition:     Int
    private var titleJustification: Int
    private var titleFont: java.awt.Font?
    private var titleColor: java.awt.Color?

    // ── Initialisierung ───────────────────────────────────────────────────────

    public convenience init(_ title: String) {
      self.init(nil, title, Self.DEFAULT_JUSTIFICATION, Self.DEFAULT_POSITION, nil, nil)
    }

    public convenience init(_ border: (any Border)?) {
      self.init(border, "", Self.DEFAULT_JUSTIFICATION, Self.DEFAULT_POSITION, nil, nil)
    }

    public convenience init(_ border: (any Border)?, _ title: String) {
      self.init(border, title, Self.DEFAULT_JUSTIFICATION, Self.DEFAULT_POSITION, nil, nil)
    }

    public convenience init(
      _ border: (any Border)?,
      _ title: String,
      _ titleJustification: Int,
      _ titlePosition: Int
    ) {
      self.init(border, title, titleJustification, titlePosition, nil, nil)
    }

    public convenience init(
      _ border: (any Border)?,
      _ title: String,
      _ titleJustification: Int,
      _ titlePosition: Int,
      _ titleFont: java.awt.Font?
    ) {
      self.init(border, title, titleJustification, titlePosition, titleFont, nil)
    }

    public init(
      _ border: (any Border)?,
      _ title: String,
      _ titleJustification: Int,
      _ titlePosition: Int,
      _ titleFont: java.awt.Font?,
      _ titleColor: java.awt.Color?
    ) {
      self.border              = border
      self.title               = title
      self.titleJustification  = titleJustification
      self.titlePosition       = titlePosition
      self.titleFont           = titleFont
      self.titleColor          = titleColor
    }

    // ── Accessors ─────────────────────────────────────────────────────────────

    public func getTitle()               -> String            { title }
    public func getBorder()              -> (any Border)?     { border }
    public func getTitlePosition()       -> Int               { titlePosition }
    public func getTitleJustification()  -> Int               { titleJustification }
    public func getTitleFont()           -> java.awt.Font?    { titleFont }
    public func getTitleColor()          -> java.awt.Color?   { titleColor }

    public func setTitle(_ title: String)                         { self.title = title }
    public func setBorder(_ border: (any Border)?)                { self.border = border }
    public func setTitlePosition(_ pos: Int)                      { titlePosition = pos }
    public func setTitleJustification(_ just: Int)                { titleJustification = just }
    public func setTitleFont(_ font: java.awt.Font?)              { titleFont = font }
    public func setTitleColor(_ color: java.awt.Color?)           { titleColor = color }

    // ── Border painting ───────────────────────────────────────────────────────

    override open func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {
      let innerBorder = border ?? EtchedBorder()
      let font  = titleFont ?? component.font
      let color = titleColor ?? component.getForegroundColor()

      // Measure the title text
      let fm        = g.getFontMetrics(font)
      let textH     = fm.getHeight()
      let textW     = fm.stringWidth(title)
      let halfTextH = textH / 2

      // Paint the inner border shifted down by half the text height so the
      // border line passes through the middle of the title string.
      let borderY      = y + halfTextH
      let borderHeight = height - halfTextH

      innerBorder.paintBorder(component, g, x, borderY, width, borderHeight)

      // Determine horizontal position of the title
      let textX: Int
      switch titleJustification {
      case TitledBorder.CENTER:
        textX = x + (width - textW) / 2
      case TitledBorder.RIGHT, TitledBorder.TRAILING:
        textX = x + width - textW - TitledBorder.TEXT_INSET_H
      default: // LEFT / LEADING / DEFAULT
        textX = x + TitledBorder.TEXT_INSET_H
      }

      // Clear the gap in the border line behind the text
      let old = g.getColor()
      g.setColor(component.getBackground())
      g.fillRect(textX - 2, y, textW + 4, textH)

      // Draw title text
      g.setColor(color)
      g.setFont(font)
      g.drawString(title, textX, y + fm.getAscent())

      g.setColor(old)
    }

    override open func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      let innerBorder = border ?? EtchedBorder()
      let inner = innerBorder.getBorderInsets(component)
      let font  = titleFont ?? component.font
      // Use real FontMetrics for an accurate title height instead of point-size.
      let fm    = java.awt.FontMetrics.make(for: font)
      let textH = fm.getHeight() + TitledBorder.TEXT_SPACING * 2
      return java.awt.Insets(
        inner.top + textH,
        inner.left   + TitledBorder.TEXT_INSET_H,
        inner.bottom + TitledBorder.TEXT_SPACING,
        inner.right  + TitledBorder.TEXT_INSET_H
      )
    }

    override open var isBorderOpaque: Bool { false }
  }
}
