/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Headless Robot fallback for platforms without programmatic input support:
/// iOS, tvOS, visionOS, watchOS, Android, WASM.
///
/// All methods are no-ops; `_getPixelColor` returns black.
/// The `Robot()` initialiser in `Robot.swift` would ideally throw
/// `HeadlessException` on these platforms — callers should check
/// `GraphicsEnvironment.isHeadless()` before constructing a `Robot`.

#if !canImport(AppKit) && !os(Linux) && !os(FreeBSD) && !canImport(WinSDK)

extension java.awt.Robot {

  public func _mouseMove(_ x: Int, _ y: Int) {
    // headless — no-op
  }

  public func _mousePress(_ buttons: Int) {
    // headless — no-op
  }

  public func _mouseRelease(_ buttons: Int) {
    // headless — no-op
  }

  public func _mouseWheel(_ wheelAmt: Int) {
    // headless — no-op
  }

  public func _keyPress(_ keycode: Int) {
    // headless — no-op
  }

  public func _keyRelease(_ keycode: Int) {
    // headless — no-op
  }

  public func _getPixelColor(_ x: Int, _ y: Int) -> java.awt.Color {
    return java.awt.Color.BLACK
  }

  public func _waitForIdle() {
    // headless — no-op
  }
}

#endif
