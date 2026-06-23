/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// A no-op base class for `Border` implementations.
  ///
  /// Provides default (empty) implementations of all `Border` methods so that
  /// subclasses only need to override what they actually customise.
  ///
  /// Corresponds to `javax.swing.border.AbstractBorder`.
  @MainActor
  open class AbstractBorder: Border {

    public init() {}

    /// Default implementation — does nothing.
    open func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {}

    /// Default implementation — returns zero insets.
    open func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      java.awt.Insets(0, 0, 0, 0)
    }

    /// Default implementation — returns `false`.
    open var isBorderOpaque: Bool { false }
  }
}
