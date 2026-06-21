/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Implemented by a bean to declare whether it requires a GUI.
  ///
  /// Beans that can operate without a graphical environment implement this
  /// interface so containers can decide whether to provide a display.
  ///
  /// - Since: Java 1.1
  public protocol Visibility {

    /// Returns `true` if the bean absolutely requires a GUI to function.
    func needsGui() -> Bool

    /// Instructs the bean to avoid using its GUI.
    func dontUseGui()

    /// Informs the bean that it is now allowed to use its GUI.
    func okToUseGui()

    /// Returns `true` if the bean is currently avoiding its GUI.
    func isGuiAvailable() -> Bool
  }
}
