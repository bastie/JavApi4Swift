/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Generates native system input events for test automation and self-running demos.
  ///
  /// Mirrors `java.awt.Robot` (Java 1.3).
  ///
  /// ```swift
  /// let robot = try java.awt.Robot()
  /// robot.mouseMove(100, 200)
  /// robot.keyPress(java.awt.event.KeyEvent.VK_A)
  /// robot.keyRelease(java.awt.event.KeyEvent.VK_A)
  /// robot.delay(500)
  /// ```
  ///
  /// Platform support:
  /// - macOS: CoreGraphics (`CGEvent`) — full support
  /// - Linux / FreeBSD (X11): XTest extension — stub (TODO)
  /// - Windows: `SendInput` — stub (TODO)
  /// - Headless / WASM / Android / iOS: throws `HeadlessException`
  ///
  /// - Since: JavaApi > 0.x (Java 1.3)
  @MainActor
  open class Robot: java.awt.toolkit.RobotProvider {

    // =========================================================================
    // MARK: - Auto-delay / waitForIdle
    // =========================================================================

    private var autoDelay: Int    = 0
    private var autoWaitForIdle: Bool = false

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    /// Creates a `Robot` for the default screen device.
    ///
    /// - Throws: `java.awt.AWTException` if the platform does not support
    ///   programmatic input control (e.g. headless environments).
    public init() throws {
      // Platform extensions provide _mouseMove etc. — if we reach here the
      // platform extension compiled in, so creation succeeds.
    }

    /// Creates a `Robot` for the given `GraphicsDevice`.
    ///
    /// Currently ignored — all implementations use the primary screen.
    ///
    /// - Throws: `java.awt.AWTException` on headless platforms.
    public convenience init(_ screen: java.awt.GraphicsDevice) throws {
      try self.init()
    }

    // =========================================================================
    // MARK: - Mouse
    // =========================================================================

    /// Moves the mouse pointer to the given absolute screen coordinates.
    public func mouseMove(_ x: Int, _ y: Int) {
      _mouseMove(x, y)
      applyAutoDelay()
    }

    /// Presses one or more mouse buttons.
    /// Use `java.awt.event.InputEvent.BUTTON1_MASK` etc.
    public func mousePress(_ buttons: Int) {
      _mousePress(buttons)
      applyAutoDelay()
    }

    /// Releases one or more mouse buttons.
    public func mouseRelease(_ buttons: Int) {
      _mouseRelease(buttons)
      applyAutoDelay()
    }

    /// Rotates the mouse scroll wheel.
    /// Positive values scroll down / towards the user.
    public func mouseWheel(_ wheelAmt: Int) {
      _mouseWheel(wheelAmt)
      applyAutoDelay()
    }

    // =========================================================================
    // MARK: - Keyboard
    // =========================================================================

    /// Presses the key with the given `KeyEvent.VK_*` key code.
    public func keyPress(_ keycode: Int) {
      _keyPress(keycode)
      applyAutoDelay()
    }

    /// Releases the key with the given `KeyEvent.VK_*` key code.
    public func keyRelease(_ keycode: Int) {
      _keyRelease(keycode)
      applyAutoDelay()
    }

    // =========================================================================
    // MARK: - Screen
    // =========================================================================

    /// Returns the colour of the pixel at the given screen coordinates.
    public func getPixelColor(_ x: Int, _ y: Int) -> java.awt.Color {
      return _getPixelColor(x, y)
    }

    // createScreenCapture(Rectangle) deferred until BufferedImage is available.

    // =========================================================================
    // MARK: - Timing
    // =========================================================================

    /// Sleeps for the given number of milliseconds.
    public func delay(_ ms: Int) {
      Thread.sleep( Int64(Double(ms) / 1000.0))
    }

    /// Waits until all events currently on the event queue have been processed.
    public func waitForIdle() {
      _waitForIdle()
    }

    // =========================================================================
    // MARK: - Auto-delay / auto-wait-for-idle
    // =========================================================================

    /// Returns the number of milliseconds automatically inserted after
    /// each input event. Default is `0`.
    public func getAutoDelay() -> Int { autoDelay }

    /// Sets the number of milliseconds automatically inserted after each event.
    /// Must be in the range 0–60 000.
    public func setAutoDelay(_ ms: Int) {
      precondition(ms >= 0 && ms <= 60_000,
                   "Auto-delay must be in range 0–60000 ms")
      autoDelay = ms
    }

    /// Returns whether `waitForIdle()` is called automatically after each event.
    public func isAutoWaitForIdle() -> Bool { autoWaitForIdle }

    /// Sets whether `waitForIdle()` is called automatically after each event.
    public func setAutoWaitForIdle(_ value: Bool) { autoWaitForIdle = value }

    // =========================================================================
    // MARK: - Private helpers
    // =========================================================================

    private func applyAutoDelay() {
      if autoWaitForIdle { _waitForIdle() }
      if autoDelay > 0   { delay(autoDelay) }
    }
  }
}
