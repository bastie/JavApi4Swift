/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Robot implementation for Windows using `SendInput` and `GetDC`/`GetPixel`.
///
/// Current status: stub — TODO implement via WinSDK.
///
/// Required WinSDK functions:
/// - `SendInput` — mouse and keyboard events
/// - `GetDC` / `GetPixel` / `ReleaseDC` — pixel colour query

#if canImport(WinSDK)
import WinSDK

extension java.awt.Robot {

  public func _mouseMove(_ x: Int, _ y: Int) {
    // TODO: SendInput with MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE
    //       Normalise to 0–65535 range: dx = x * 65535 / screenWidth
  }

  public func _mousePress(_ buttons: Int) {
    // TODO: SendInput with MOUSEEVENTF_LEFTDOWN / RIGHTDOWN / MIDDLEDOWN
  }

  public func _mouseRelease(_ buttons: Int) {
    // TODO: SendInput with MOUSEEVENTF_LEFTUP / RIGHTUP / MIDDLEUP
  }

  public func _mouseWheel(_ wheelAmt: Int) {
    // TODO: SendInput with MOUSEEVENTF_WHEEL, dwData = wheelAmt * WHEEL_DELTA
  }

  public func _keyPress(_ keycode: Int) {
    // TODO: SendInput with KEYEVENTF_KEYDOWN, map VK_* to Windows VK_* codes
  }

  public func _keyRelease(_ keycode: Int) {
    // TODO: SendInput with KEYEVENTF_KEYUP
  }

  public func _getPixelColor(_ x: Int, _ y: Int) -> java.awt.Color {
    // TODO: let dc = GetDC(nil); let pixel = GetPixel(dc, x, y); ReleaseDC(nil, dc)
    //       return Color(GetRValue(pixel), GetGValue(pixel), GetBValue(pixel))
    return java.awt.Color.BLACK
  }

  public func _waitForIdle() {
    // TODO: WaitForInputIdle or process message queue
  }
}

#endif
