/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.toolkit {

  /// Internal protocol that platform extensions of `java.awt.Robot` must implement.
  ///
  /// Each platform file (`_Robot+AppKit.swift`, `_Robot+X11.swift`, …) provides
  /// exactly one implementation, guarded by `#if canImport(…)` / `#if os(…)`.
  @MainActor
  public protocol RobotProvider {
    /// Move mouse pointer to absolute screen coordinates.
    func _mouseMove(_ x: Int, _ y: Int)
    /// Press mouse button(s) — `buttons` uses `InputEvent.BUTTON*_MASK`.
    func _mousePress(_ buttons: Int)
    /// Release mouse button(s).
    func _mouseRelease(_ buttons: Int)
    /// Rotate the mouse scroll wheel.
    func _mouseWheel(_ wheelAmt: Int)
    /// Press a key — `keycode` uses `KeyEvent.VK_*` constants.
    func _keyPress(_ keycode: Int)
    /// Release a key.
    func _keyRelease(_ keycode: Int)
    /// Return the colour of the pixel at the given screen coordinates.
    func _getPixelColor(_ x: Int, _ y: Int) -> java.awt.Color
    /// Block until all pending input events have been processed.
    func _waitForIdle()
  }
}
