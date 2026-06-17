/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// Describes an object that knows how to paint a border around a Swing
  /// component and report the insets it consumes.
  ///
  /// The equivalent of `javax.swing.border.Border`.
  @MainActor
  public protocol Border: AnyObject {

    /// Paints the border for `component` inside `bounds` using `g`.
    func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    )

    /// Returns the insets of the border.
    ///
    /// The insets describe the space the border occupies on each edge so that
    /// layout managers can leave room for it.
    func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets

    /// Returns `true` if the border is completely opaque.
    ///
    /// An opaque border guarantees it paints every pixel in the region it
    /// occupies; a non-opaque border may leave pixels transparent.
    var isBorderOpaque: Bool { get }
  }
}
