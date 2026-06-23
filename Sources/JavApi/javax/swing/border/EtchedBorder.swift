/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// A border that renders a 3D-like etched line.
  ///
  /// The border uses two colors — a highlight and a shadow — to produce a
  /// sunken (`LOWERED`) or raised (`RAISED`) appearance.  When no colors are
  /// specified the component's background color is used to derive them.
  ///
  /// Corresponds to `javax.swing.border.EtchedBorder`.
  @MainActor
  open class EtchedBorder: AbstractBorder {

    /// Sunken etched appearance.
    public static let LOWERED = 0
    /// Raised etched appearance.
    public static let RAISED  = 1

    private let etchType: Int
    private let highlight: java.awt.Color?
    private let shadow: java.awt.Color?

    /// Creates a lowered etched border using the component's background color.
    public convenience override init() {
      self.init(Self.LOWERED, nil, nil)
    }

    /// Creates an etched border of the given type using the component's
    /// background color.
    public convenience init(_ etchType: Int) {
      self.init(etchType, nil, nil)
    }

    /// Creates an etched border with explicit highlight and shadow colors.
    public convenience init(_ highlight: java.awt.Color, _ shadow: java.awt.Color) {
      self.init(Self.LOWERED, highlight, shadow)
    }

    /// Creates an etched border of the given type with explicit colors.
    public init(_ etchType: Int, _ highlight: java.awt.Color?, _ shadow: java.awt.Color?) {
      self.etchType = etchType
      self.highlight = highlight
      self.shadow = shadow
    }

    public func getEtchType() -> Int { etchType }
    public func getHighlightColor() -> java.awt.Color? { highlight }
    public func getShadowColor() -> java.awt.Color? { shadow }

    override open func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {
      let bg = component.getBackground()
      let hi = highlight ?? bg.brighter()
      let sh = shadow   ?? bg.darker()

      let outerHi: java.awt.Color
      let outerSh: java.awt.Color
      if etchType == EtchedBorder.LOWERED {
        outerHi = sh; outerSh = hi
      } else {
        outerHi = hi; outerSh = sh
      }

      let old = g.getColor()

      // Outer rect
      g.setColor(outerHi)
      g.drawRect(x, y, width - 2, height - 2)

      // Inner rect
      g.setColor(outerSh)
      g.drawRect(x + 1, y + 1, width - 2, height - 2)

      g.setColor(old)
    }

    override open func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      java.awt.Insets(2, 2, 2, 2)
    }

    override open var isBorderOpaque: Bool { false }
  }
}
