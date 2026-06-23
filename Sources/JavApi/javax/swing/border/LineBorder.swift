/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// A border that draws a solid line of a given color and thickness.
  ///
  /// Corresponds to `javax.swing.border.LineBorder`.
  @MainActor
  open class LineBorder: AbstractBorder {

    private let lineColor: java.awt.Color
    private let thickness: Int
    private let roundedCorners: Bool

    /// Creates a 1-pixel-thick line border with the given color.
    public convenience init(_ color: java.awt.Color) {
      self.init(color, 1, false)
    }

    /// Creates a line border with the given color and thickness.
    public convenience init(_ color: java.awt.Color, _ thickness: Int) {
      self.init(color, thickness, false)
    }

    /// Creates a line border with optional rounded corners.
    public init(_ color: java.awt.Color, _ thickness: Int, _ roundedCorners: Bool) {
      self.lineColor = color
      self.thickness = thickness
      self.roundedCorners = roundedCorners
    }

    /// Returns the line color.
    public func getLineColor() -> java.awt.Color { lineColor }

    /// Returns the line thickness in pixels.
    public func getThickness() -> Int { thickness }

    /// Returns whether the corners are rounded.
    public func getRoundedCorners() -> Bool { roundedCorners }

    override open func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {
      let oldColor = g.getColor()
      g.setColor(lineColor)
      // Java uses arcWidth/arcHeight of 10 for rounded LineBorder corners.
      let arc = roundedCorners ? max(10, thickness * 4) : 0
      for i in 0..<thickness {
        if roundedCorners {
          g.drawRoundRect(x + i, y + i, width - i * 2 - 1, height - i * 2 - 1, arc, arc)
        } else {
          g.drawRect(x + i, y + i, width - i * 2 - 1, height - i * 2 - 1)
        }
      }
      g.setColor(oldColor)
    }

    override open func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      java.awt.Insets(thickness, thickness, thickness, thickness)
    }

    override open var isBorderOpaque: Bool { true }
  }
}
