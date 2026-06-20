/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Robot implementation for macOS using CoreGraphics and ScreenCaptureKit.
///
/// Mouse and keyboard events are posted via `CGEvent`.
/// Pixel colour (`getPixelColor`) uses ScreenCaptureKit (macOS 14+) and
/// requires the Screen Recording permission to be granted at runtime.

#if canImport(AppKit)
import AppKit
import CoreGraphics
import ScreenCaptureKit

extension java.awt.Robot {

  public func _mouseMove(_ x: Int, _ y: Int) {
    let point = CGPoint(x: x, y: y)
    let event = CGEvent(mouseEventSource: nil,
                        mouseType: .mouseMoved,
                        mouseCursorPosition: point,
                        mouseButton: .left)
    event?.post(tap: .cghidEventTap)
  }

  public func _mousePress(_ buttons: Int) {
    let point = _currentMouseLocation()
    if buttons & java.awt.event.InputEvent.BUTTON1_MASK != 0 {
      CGEvent(mouseEventSource: nil,
              mouseType: .leftMouseDown,
              mouseCursorPosition: point,
              mouseButton: .left)?.post(tap: .cghidEventTap)
    }
    if buttons & java.awt.event.InputEvent.BUTTON2_MASK != 0 {
      CGEvent(mouseEventSource: nil,
              mouseType: .otherMouseDown,
              mouseCursorPosition: point,
              mouseButton: .center)?.post(tap: .cghidEventTap)
    }
    if buttons & java.awt.event.InputEvent.BUTTON3_MASK != 0 {
      CGEvent(mouseEventSource: nil,
              mouseType: .rightMouseDown,
              mouseCursorPosition: point,
              mouseButton: .right)?.post(tap: .cghidEventTap)
    }
  }

  public func _mouseRelease(_ buttons: Int) {
    let point = _currentMouseLocation()
    if buttons & java.awt.event.InputEvent.BUTTON1_MASK != 0 {
      CGEvent(mouseEventSource: nil,
              mouseType: .leftMouseUp,
              mouseCursorPosition: point,
              mouseButton: .left)?.post(tap: .cghidEventTap)
    }
    if buttons & java.awt.event.InputEvent.BUTTON2_MASK != 0 {
      CGEvent(mouseEventSource: nil,
              mouseType: .otherMouseUp,
              mouseCursorPosition: point,
              mouseButton: .center)?.post(tap: .cghidEventTap)
    }
    if buttons & java.awt.event.InputEvent.BUTTON3_MASK != 0 {
      CGEvent(mouseEventSource: nil,
              mouseType: .rightMouseUp,
              mouseCursorPosition: point,
              mouseButton: .right)?.post(tap: .cghidEventTap)
    }
  }

  public func _mouseWheel(_ wheelAmt: Int) {
    let event = CGEvent(scrollWheelEvent2Source: nil,
                        units: .line,
                        wheelCount: 1,
                        wheel1: Int32(-wheelAmt),
                        wheel2: 0,
                        wheel3: 0)
    event?.post(tap: .cghidEventTap)
  }

  public func _keyPress(_ keycode: Int) {
    if let cgKey = _vkToCGKeyCode(keycode) {
      CGEvent(keyboardEventSource: nil, virtualKey: cgKey, keyDown: true)?
        .post(tap: .cghidEventTap)
    }
  }

  public func _keyRelease(_ keycode: Int) {
    if let cgKey = _vkToCGKeyCode(keycode) {
      CGEvent(keyboardEventSource: nil, virtualKey: cgKey, keyDown: false)?
        .post(tap: .cghidEventTap)
    }
  }

  public func _getPixelColor(_ x: Int, _ y: Int) -> java.awt.Color {
    // CGDisplayCreateImage is unavailable on macOS 14+ — use ScreenCaptureKit.
    // Task.detached runs on Swift's cooperative thread pool (not main actor).
    // DispatchSemaphore bridges the async result back to this synchronous call.
    // Screen Recording permission is required at runtime.
    nonisolated(unsafe) var result = java.awt.Color.BLACK
    let sema = DispatchSemaphore(value: 0)

    Task.detached {
      defer { sema.signal() }
      do {
        let content = try await SCShareableContent.current
        guard let display = content.displays.first else { return }
        let filter = SCContentFilter(display: display,
                                     excludingApplications: [],
                                     exceptingWindows: [])
        let config = SCStreamConfiguration()
        config.sourceRect = CGRect(x: x, y: y, width: 1, height: 1)
        config.width  = 1
        config.height = 1
        let image = try await SCScreenshotManager.captureImage(
          contentFilter: filter, configuration: config)
        guard let provider = image.dataProvider,
              let data     = provider.data,
              let ptr      = CFDataGetBytePtr(data),
              image.bitsPerComponent == 8 else { return }
        // Pixel layout on macOS: BGRA
        result = java.awt.Color(Int(ptr[2]), Int(ptr[1]), Int(ptr[0]), Int(ptr[3]))
      } catch {
        // Permission denied or no display — keep BLACK
      }
    }
    sema.wait()
    return result
  }

  public func _waitForIdle() {
    // Flush the event queue synchronously on the main run loop
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
  }

  // =========================================================================
  // MARK: - Helpers (private)
  // =========================================================================

  private func _currentMouseLocation() -> CGPoint {
    let loc = NSEvent.mouseLocation
    // NSEvent uses bottom-left origin; CGEvent uses top-left
    let screenH = NSScreen.main?.frame.height ?? 0
    return CGPoint(x: loc.x, y: screenH - loc.y)
  }

  /// Maps Java `KeyEvent.VK_*` constants to macOS `CGKeyCode`.
  ///
  /// Only the most common keys are mapped here; extend as needed.
  private func _vkToCGKeyCode(_ vk: Int) -> CGKeyCode? {
    // Key codes from /System/Library/Frameworks/Carbon.framework
    let table: [Int: CGKeyCode] = [
      java.awt.event.KeyEvent.VK_A: 0x00,
      java.awt.event.KeyEvent.VK_S: 0x01,
      java.awt.event.KeyEvent.VK_D: 0x02,
      java.awt.event.KeyEvent.VK_F: 0x03,
      java.awt.event.KeyEvent.VK_H: 0x04,
      java.awt.event.KeyEvent.VK_G: 0x05,
      java.awt.event.KeyEvent.VK_Z: 0x06,
      java.awt.event.KeyEvent.VK_X: 0x07,
      java.awt.event.KeyEvent.VK_C: 0x08,
      java.awt.event.KeyEvent.VK_V: 0x09,
      java.awt.event.KeyEvent.VK_B: 0x0B,
      java.awt.event.KeyEvent.VK_Q: 0x0C,
      java.awt.event.KeyEvent.VK_W: 0x0D,
      java.awt.event.KeyEvent.VK_E: 0x0E,
      java.awt.event.KeyEvent.VK_R: 0x0F,
      java.awt.event.KeyEvent.VK_Y: 0x10,
      java.awt.event.KeyEvent.VK_T: 0x11,
      java.awt.event.KeyEvent.VK_1: 0x12,
      java.awt.event.KeyEvent.VK_2: 0x13,
      java.awt.event.KeyEvent.VK_3: 0x14,
      java.awt.event.KeyEvent.VK_4: 0x15,
      java.awt.event.KeyEvent.VK_6: 0x16,
      java.awt.event.KeyEvent.VK_5: 0x17,
      java.awt.event.KeyEvent.VK_EQUALS: 0x18,
      java.awt.event.KeyEvent.VK_9: 0x19,
      java.awt.event.KeyEvent.VK_7: 0x1A,
      java.awt.event.KeyEvent.VK_MINUS: 0x1B,
      java.awt.event.KeyEvent.VK_8: 0x1C,
      java.awt.event.KeyEvent.VK_0: 0x1D,
      java.awt.event.KeyEvent.VK_CLOSE_BRACKET: 0x1E,
      java.awt.event.KeyEvent.VK_O: 0x1F,
      java.awt.event.KeyEvent.VK_U: 0x20,
      java.awt.event.KeyEvent.VK_OPEN_BRACKET: 0x21,
      java.awt.event.KeyEvent.VK_I: 0x22,
      java.awt.event.KeyEvent.VK_P: 0x23,
      java.awt.event.KeyEvent.VK_ENTER: 0x24,
      java.awt.event.KeyEvent.VK_L: 0x25,
      java.awt.event.KeyEvent.VK_J: 0x26,
      java.awt.event.KeyEvent.VK_QUOTE: 0x27,
      java.awt.event.KeyEvent.VK_K: 0x28,
      java.awt.event.KeyEvent.VK_SEMICOLON: 0x29,
      java.awt.event.KeyEvent.VK_BACK_SLASH: 0x2A,
      java.awt.event.KeyEvent.VK_COMMA: 0x2B,
      java.awt.event.KeyEvent.VK_SLASH: 0x2C,
      java.awt.event.KeyEvent.VK_N: 0x2D,
      java.awt.event.KeyEvent.VK_M: 0x2E,
      java.awt.event.KeyEvent.VK_PERIOD: 0x2F,
      java.awt.event.KeyEvent.VK_TAB: 0x30,
      java.awt.event.KeyEvent.VK_SPACE: 0x31,
      java.awt.event.KeyEvent.VK_BACK_QUOTE: 0x32,
      java.awt.event.KeyEvent.VK_BACK_SPACE: 0x33,
      java.awt.event.KeyEvent.VK_ESCAPE: 0x35,
      java.awt.event.KeyEvent.VK_META: 0x37,
      java.awt.event.KeyEvent.VK_SHIFT: 0x38,
      java.awt.event.KeyEvent.VK_CAPS_LOCK: 0x39,
      java.awt.event.KeyEvent.VK_ALT: 0x3A,
      java.awt.event.KeyEvent.VK_CONTROL: 0x3B,
      java.awt.event.KeyEvent.VK_F1: 0x7A,
      java.awt.event.KeyEvent.VK_F2: 0x78,
      java.awt.event.KeyEvent.VK_F3: 0x63,
      java.awt.event.KeyEvent.VK_F4: 0x76,
      java.awt.event.KeyEvent.VK_F5: 0x60,
      java.awt.event.KeyEvent.VK_F6: 0x61,
      java.awt.event.KeyEvent.VK_F7: 0x62,
      java.awt.event.KeyEvent.VK_F8: 0x64,
      java.awt.event.KeyEvent.VK_F9: 0x65,
      java.awt.event.KeyEvent.VK_F10: 0x6D,
      java.awt.event.KeyEvent.VK_F11: 0x67,
      java.awt.event.KeyEvent.VK_F12: 0x6F,
      java.awt.event.KeyEvent.VK_DELETE: 0x75,
      java.awt.event.KeyEvent.VK_HOME: 0x73,
      java.awt.event.KeyEvent.VK_END: 0x77,
      java.awt.event.KeyEvent.VK_PAGE_UP: 0x74,
      java.awt.event.KeyEvent.VK_PAGE_DOWN: 0x79,
      java.awt.event.KeyEvent.VK_LEFT: 0x7B,
      java.awt.event.KeyEvent.VK_RIGHT: 0x7C,
      java.awt.event.KeyEvent.VK_DOWN: 0x7D,
      java.awt.event.KeyEvent.VK_UP: 0x7E,
    ]
    return table[vk]
  }
}
#endif
