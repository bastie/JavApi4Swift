/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// A border that fills its insets with a solid color or a tiled icon.
  ///
  /// This implementation supports the solid-color variant.  The icon-tiling
  /// variant is accepted in the constructor but falls back to a transparent fill
  /// until `Icon` painting is fully supported.
  ///
  /// Corresponds to `javax.swing.border.MatteBorder`.
  @MainActor
  open class MatteBorder: EmptyBorder {

    private let matteColor: java.awt.Color?
    private let tileIcon: (any javax.swing.Icon)?

    /// Creates a matte border with a solid color and uniform inset.
    public convenience init(_ matteInset: Int, _ color: java.awt.Color) {
      self.init(matteInset, matteInset, matteInset, matteInset, color)
    }

    /// Creates a matte border with a solid color and individual insets.
    public init(_ top: Int, _ left: Int, _ bottom: Int, _ right: Int, _ color: java.awt.Color) {
      self.matteColor = color
      self.tileIcon   = nil
      super.init(top, left, bottom, right)
    }

    /// Creates a matte border tiled with an icon and uniform inset.
    public convenience init(_ matteInset: Int, _ tileIcon: any javax.swing.Icon) {
      self.init(matteInset, matteInset, matteInset, matteInset, tileIcon)
    }

    /// Creates a matte border tiled with an icon and individual insets.
    public init(_ top: Int, _ left: Int, _ bottom: Int, _ right: Int, _ tileIcon: any javax.swing.Icon) {
      self.matteColor = nil
      self.tileIcon   = tileIcon
      super.init(top, left, bottom, right)
    }

    public func getMatteColor() -> java.awt.Color? { matteColor }
    public func getTileIcon()   -> (any javax.swing.Icon)? { tileIcon }

    override open func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {
      guard let color = matteColor else { return }  // icon tiling not yet supported
      let insets = getBorderInsets(component)
      let old = g.getColor()
      g.setColor(color)
      // top
      g.fillRect(x, y, width, insets.top)
      // bottom
      g.fillRect(x, y + height - insets.bottom, width, insets.bottom)
      // left
      g.fillRect(x, y + insets.top, insets.left, height - insets.top - insets.bottom)
      // right
      g.fillRect(
        x + width - insets.right,
        y + insets.top,
        insets.right,
        height - insets.top - insets.bottom
      )
      g.setColor(old)
    }

    override open var isBorderOpaque: Bool { matteColor != nil }
  }
}
