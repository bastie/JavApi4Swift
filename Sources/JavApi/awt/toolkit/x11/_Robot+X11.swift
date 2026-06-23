/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Robot implementation for Linux / FreeBSD using the X11 XTest extension.
///
/// Current status:
/// - glibc systems (Debian, Ubuntu, Fedora): stub — TODO implement via dlopen/XTest
/// - MUSL systems (Alpine): same stub
///
/// Required: `libXtst` (XTest extension) and `libX11`.
/// Implement analogous to X11Toolkit: dlopen at runtime so the binary
/// compiles even on systems without X11 headers.

#if os(Linux) || os(FreeBSD)

extension java.awt.Robot {

  public func _mouseMove(_ x: Int, _ y: Int) {
    // TODO: XTestFakeMotionEvent(display, -1, x, y, CurrentTime)
  }

  public func _mousePress(_ buttons: Int) {
    // TODO: XTestFakeButtonEvent(display, xButton, True, CurrentTime)
  }

  public func _mouseRelease(_ buttons: Int) {
    // TODO: XTestFakeButtonEvent(display, xButton, False, CurrentTime)
  }

  public func _mouseWheel(_ wheelAmt: Int) {
    // TODO: XTestFakeButtonEvent for button 4 (up) / button 5 (down)
  }

  public func _keyPress(_ keycode: Int) {
    // TODO: XTestFakeKeyEvent(display, XKeysymToKeycode(display, keysym), True, CurrentTime)
  }

  public func _keyRelease(_ keycode: Int) {
    // TODO: XTestFakeKeyEvent(display, XKeysymToKeycode(display, keysym), False, CurrentTime)
  }

  public func _getPixelColor(_ x: Int, _ y: Int) -> java.awt.Color {
    // TODO: XGetImage(display, root, x, y, 1, 1, AllPlanes, ZPixmap) + XGetPixel
    return java.awt.Color.BLACK
  }

  public func _waitForIdle() {
    // TODO: XSync(display, False)
  }
}

#endif
