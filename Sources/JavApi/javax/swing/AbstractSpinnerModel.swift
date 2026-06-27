/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Abstract base class for `SpinnerModel` implementations.
  ///
  /// `AbstractSpinnerModel` handles `ChangeListener` registration and the
  /// `fireStateChanged()` method so that concrete subclasses only need to
  /// implement `getValue()`, `setValue(_:)`, `getNextValue()`, and
  /// `getPreviousValue()`.
  ///
  /// ## Subclassing
  ///
  /// ```swift
  /// class MySpinnerModel: javax.swing.AbstractSpinnerModel {
  ///   private var value: Int = 0
  ///   override func getValue() -> Any? { value }
  ///   override func setValue(_ v: Any?) {
  ///     guard let n = v as? Int, n != value else { return }
  ///     value = n
  ///     fireStateChanged()
  ///   }
  ///   override func getNextValue() -> Any? { value + 1 }
  ///   override func getPreviousValue() -> Any? { value - 1 }
  /// }
  /// ```
  ///
  /// - Since: Java 1.4
  @MainActor
  open class AbstractSpinnerModel: javax.swing.SpinnerModel {

    // -------------------------------------------------------------------------
    // MARK: Listener management
    // -------------------------------------------------------------------------

    private var changeListeners: [javax.swing.event.ChangeListener] = []

    public init() {}

    /// Registers `l` to receive `ChangeEvent` notifications.
    open func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      changeListeners.append(l)
    }

    /// Removes `l` from the list of registered listeners.
    open func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      changeListeners.removeAll { $0 === (l as AnyObject) }
    }

    /// Returns all currently registered `ChangeListener`s.
    open func getChangeListeners() -> [javax.swing.event.ChangeListener] {
      changeListeners
    }

    // -------------------------------------------------------------------------
    // MARK: Abstract — must be overridden
    // -------------------------------------------------------------------------

    /// Returns the current value of the model.
    open func getValue() -> Any? {
      fatalError("AbstractSpinnerModel.getValue() must be overridden by \(type(of: self))")
    }

    /// Sets the current value and fires a `ChangeEvent`.
    open func setValue(_ value: Any?) {
      fatalError("AbstractSpinnerModel.setValue(_:) must be overridden by \(type(of: self))")
    }

    /// Returns the next value, or `nil` at the upper bound.
    open func getNextValue() -> Any? {
      fatalError("AbstractSpinnerModel.getNextValue() must be overridden by \(type(of: self))")
    }

    /// Returns the previous value, or `nil` at the lower bound.
    open func getPreviousValue() -> Any? {
      fatalError("AbstractSpinnerModel.getPreviousValue() must be overridden by \(type(of: self))")
    }

    // -------------------------------------------------------------------------
    // MARK: Fire helper
    // -------------------------------------------------------------------------

    /// Fires a `ChangeEvent` to all registered listeners.
    ///
    /// Call this from `setValue(_:)` after the model state has changed.
    open func fireStateChanged() {
      guard !changeListeners.isEmpty else { return }
      let e = javax.swing.event.ChangeEvent(self)
      for l in changeListeners { l.stateChanged(e) }
    }
  }
}
