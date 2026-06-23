/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// A border that renders a beveled edge effect.
  ///
  /// A bevel border uses four colors (outer highlight, inner highlight, outer
  /// shadow, inner shadow) to produce a raised or lowered 3-D appearance.
  /// When no colors are supplied they are derived from the component's
  /// background.
  ///
  /// Corresponds to `javax.swing.border.BevelBorder`.
  @MainActor
  open class BevelBorder: AbstractBorder {

    /// Raised bevel appearance.
    public static let RAISED  = 0
    /// Lowered bevel appearance.
    public static let LOWERED = 1

    private let bevelType: Int
    private let highlightOuter: java.awt.Color?
    private let highlightInner: java.awt.Color?
    private let shadowOuter:    java.awt.Color?
    private let shadowInner:    java.awt.Color?

    /// Creates a bevel border using the component's background color.
    public convenience init(_ bevelType: Int) {
      self.init(bevelType, nil, nil, nil, nil)
    }

    /// Creates a bevel border with explicit highlight and shadow colors.
    public convenience init(
      _ bevelType: Int,
      _ highlight: java.awt.Color,
      _ shadow: java.awt.Color
    ) {
      self.init(bevelType, highlight.brighter(), highlight, shadow, shadow.brighter())
    }

    /// Creates a bevel border with all four colors specified.
    public init(
      _ bevelType: Int,
      _ highlightOuter: java.awt.Color?,
      _ highlightInner: java.awt.Color?,
      _ shadowOuter:    java.awt.Color?,
      _ shadowInner:    java.awt.Color?
    ) {
      self.bevelType      = bevelType
      self.highlightOuter = highlightOuter
      self.highlightInner = highlightInner
      self.shadowOuter    = shadowOuter
      self.shadowInner    = shadowInner
    }

    public func getBevelType()       -> Int                  { bevelType }
    public func getHighlightOuterColor() -> java.awt.Color? { highlightOuter }
    public func getHighlightInnerColor() -> java.awt.Color? { highlightInner }
    public func getShadowOuterColor()    -> java.awt.Color? { shadowOuter }
    public func getShadowInnerColor()    -> java.awt.Color? { shadowInner }

    override open func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {
      let bg = component.getBackground()
      let hiO = highlightOuter ?? bg.brighter().brighter()
      let hiI = highlightInner ?? bg.brighter()
      let shO = shadowOuter    ?? bg.darker().darker()
      let shI = shadowInner    ?? bg.darker()

      let outerHi: java.awt.Color
      let outerSh: java.awt.Color
      let innerHi: java.awt.Color
      let innerSh: java.awt.Color

      if bevelType == BevelBorder.RAISED {
        outerHi = hiO; outerSh = shO
        innerHi = hiI; innerSh = shI
      } else {
        outerHi = shO; outerSh = hiO
        innerHi = shI; innerSh = hiI
      }

      let old = g.getColor()

      // Outer top + left
      g.setColor(outerHi)
      g.drawLine(x, y, x + width - 2, y)
      g.drawLine(x, y, x, y + height - 2)

      // Outer bottom + right
      g.setColor(outerSh)
      g.drawLine(x + width - 1, y, x + width - 1, y + height - 1)
      g.drawLine(x, y + height - 1, x + width - 1, y + height - 1)

      // Inner top + left
      g.setColor(innerHi)
      g.drawLine(x + 1, y + 1, x + width - 3, y + 1)
      g.drawLine(x + 1, y + 1, x + 1, y + height - 3)

      // Inner bottom + right
      g.setColor(innerSh)
      g.drawLine(x + width - 2, y + 1, x + width - 2, y + height - 2)
      g.drawLine(x + 1, y + height - 2, x + width - 2, y + height - 2)

      g.setColor(old)
    }

    override open func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      java.awt.Insets(2, 2, 2, 2)
    }

    override open var isBorderOpaque: Bool { true }
  }
}
