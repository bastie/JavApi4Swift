/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A timer that fires `ActionListener` callbacks on the main actor at a
  /// fixed interval — mirrors `javax.swing.Timer`.
  ///
  /// Unlike `java.util.Timer`, all listeners are called on the **main actor**
  /// (Swift equivalent of Swing's Event Dispatch Thread), so it is safe to
  /// update UI components directly inside `actionPerformed`.
  ///
  /// The internal loop is driven by `Task.sleep`, requiring no Combine or
  /// Foundation `Timer` dependency.
  ///
  /// ```swift
  /// let t = javax.swing.Timer(1000, myListener)
  /// t.start()
  /// // … later …
  /// t.stop()
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class Timer {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _delay:        Int   // milliseconds
    private var _initialDelay: Int?  // nil → use _delay
    private var _repeats:      Bool
    private var _listeners:    [java.awt.event.ActionListener] = []
    private var _task:         Task<Void, Never>?
    private var _isRunning:    Bool = false

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates a timer with the given *delay* (milliseconds) and an initial listener.
    ///
    /// - Parameters:
    ///   - delay: Interval between firings in milliseconds.
    ///   - listener: The first `ActionListener` to register; may be `nil`.
    public init(_ delay: Int, _ listener: java.awt.event.ActionListener?) {
      self._delay   = delay
      self._repeats = true
      if let l = listener {
        _listeners.append(l)
      }
    }

    deinit {
      _task?.cancel()
    }

    // -------------------------------------------------------------------------
    // MARK: Listener management
    // -------------------------------------------------------------------------

    public func addActionListener(_ l: java.awt.event.ActionListener) {
      _listeners.append(l)
    }

    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      _listeners.removeAll { $0 === l }
    }

    public func getActionListeners() -> [java.awt.event.ActionListener] {
      _listeners
    }

    // -------------------------------------------------------------------------
    // MARK: Control
    // -------------------------------------------------------------------------

    /// Starts the timer. Has no effect if already running.
    public func start() {
      guard _task == nil else { return }
      _isRunning = true
      let firstDelay  = _initialDelay ?? _delay
      let repeatDelay = _delay
      let repeats     = _repeats

      _task = Task { @MainActor [weak self] in
        guard let self else { return }
        // Initial delay
        if firstDelay > 0 {
          try? await Task.sleep(nanoseconds: UInt64(firstDelay) * 1_000_000)
        }
        guard !Task.isCancelled else { return }
        self.fire()
        if !repeats {
          self.stop()
          return
        }
        // Repeat loop
        while !Task.isCancelled {
          if repeatDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(repeatDelay) * 1_000_000)
          }
          guard !Task.isCancelled else { break }
          self.fire()
          if !self._repeats { break }
        }
        // Clean up task handle when loop ends naturally
        self._task = nil
        self._isRunning = false
      }
    }

    /// Stops the timer. Has no effect if not running.
    public func stop() {
      _task?.cancel()
      _task = nil
      _isRunning = false
    }

    /// Stops the timer and restarts it, honouring the current `initialDelay`.
    public func restart() {
      stop()
      start()
    }

    /// Returns `true` while the timer is running.
    public func isRunning() -> Bool { _isRunning }

    // -------------------------------------------------------------------------
    // MARK: Configuration
    // -------------------------------------------------------------------------

    /// Delay between firings in milliseconds.
    public func getDelay() -> Int { _delay }
    public func setDelay(_ delay: Int) { _delay = delay }

    /// Delay before the first firing. Defaults to `delay` when not set.
    public func getInitialDelay() -> Int { _initialDelay ?? _delay }
    public func setInitialDelay(_ initialDelay: Int) { _initialDelay = initialDelay }

    /// If `false` the timer fires exactly once and then stops.
    public func isRepeats() -> Bool { _repeats }
    public func setRepeats(_ flag: Bool) { _repeats = flag }

    // -------------------------------------------------------------------------
    // MARK: Convenience closure overload
    // -------------------------------------------------------------------------

    /// Creates a timer whose sole action is the given Swift closure.
    ///
    /// ```swift
    /// let t = javax.swing.Timer(500) { _ in label.setText("tick") }
    /// t.start()
    /// ```
    public convenience init(_ delay: Int,
                            _ handler: @escaping @MainActor (java.awt.event.ActionEvent) -> Void) {
      self.init(delay, _SwingClosureActionListener(handler))
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    private func fire() {
      let event = java.awt.event.ActionEvent(
        self,
        java.awt.event.ActionEvent.ACTION_PERFORMED,
        "timer"
      )
      for listener in _listeners {
        listener.actionPerformed(event)
      }
    }
  }
}
