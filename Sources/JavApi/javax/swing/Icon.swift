/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A fixed-size picture that can be painted by a component.
  ///
  /// This is the Swing `javax.swing.Icon` interface.
  /// Use `ImageIcon` for image-backed icons.
  @MainActor
  public protocol Icon: AnyObject {
    /// Paints the icon at `(x, y)` in the given graphics context.
    func paintIcon(_ c: java.awt.Component?, _ g: java.awt.Graphics, _ x: Int, _ y: Int)
    /// The icon's fixed width in pixels.
    func getIconWidth() -> Int
    /// The icon's fixed height in pixels.
    func getIconHeight() -> Int
  }
}
