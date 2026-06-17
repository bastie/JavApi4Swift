/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// A transparent border that occupies space but paints nothing.
  ///
  /// Use `EmptyBorder` (or `BorderFactory.createEmptyBorder`) to add padding
  /// around a component without any visible decoration.
  ///
  /// Corresponds to `javax.swing.border.EmptyBorder`.
  @MainActor
  open class EmptyBorder: AbstractBorder {

    private let top: Int
    private let left: Int
    private let bottom: Int
    private let right: Int

    /// Creates an empty border with uniform insets on all four sides.
    public convenience init(_ inset: Int) {
      self.init(inset, inset, inset, inset)
    }

    /// Creates an empty border with the given insets.
    public init(_ top: Int, _ left: Int, _ bottom: Int, _ right: Int) {
      self.top = top
      self.left = left
      self.bottom = bottom
      self.right = right
    }

    /// Creates an empty border from an `Insets` value.
    public convenience init(_ insets: java.awt.Insets) {
      self.init(insets.top, insets.left, insets.bottom, insets.right)
    }

    /// Does nothing — the border is transparent.
    override open func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {}

    override open func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      java.awt.Insets(top, left, bottom, right)
    }

    /// Always `false` — `EmptyBorder` paints nothing.
    override open var isBorderOpaque: Bool { false }
  }
}
