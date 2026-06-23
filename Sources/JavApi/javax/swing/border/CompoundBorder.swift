/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// A border composed of two nested borders: an outer and an inner border.
  ///
  /// The outer border is painted first; the inner border is painted inside the
  /// space left by the outer border.  The combined insets are the sum of both.
  ///
  /// Corresponds to `javax.swing.border.CompoundBorder`.
  @MainActor
  open class CompoundBorder: AbstractBorder {

    private let outsideBorder: (any Border)?
    private let insideBorder:  (any Border)?

    /// Creates a compound border without any nested borders.
    public convenience override init() {
      self.init(nil, nil)
    }

    /// Creates a compound border with the given outer and inner borders.
    public init(_ outsideBorder: (any Border)?, _ insideBorder: (any Border)?) {
      self.outsideBorder = outsideBorder
      self.insideBorder  = insideBorder
    }

    public func getOutsideBorder() -> (any Border)? { outsideBorder }
    public func getInsideBorder()  -> (any Border)? { insideBorder }

    override open func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {
      outsideBorder?.paintBorder(component, g, x, y, width, height)

      if let inside = insideBorder {
        let insets = outsideBorder?.getBorderInsets(component) ?? java.awt.Insets(0, 0, 0, 0)
        inside.paintBorder(
          component, g,
          x + insets.left,
          y + insets.top,
          width  - insets.left - insets.right,
          height - insets.top  - insets.bottom
        )
      }
    }

    override open func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      let o = outsideBorder?.getBorderInsets(component) ?? java.awt.Insets(0, 0, 0, 0)
      let i = insideBorder?.getBorderInsets(component)  ?? java.awt.Insets(0, 0, 0, 0)
      return java.awt.Insets(
        o.top    + i.top,
        o.left   + i.left,
        o.bottom + i.bottom,
        o.right  + i.right
      )
    }

    override open var isBorderOpaque: Bool {
      (outsideBorder?.isBorderOpaque ?? false) && (insideBorder?.isBorderOpaque ?? false)
    }
  }
}
