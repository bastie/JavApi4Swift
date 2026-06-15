/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The model for a `JSpinner`.
  ///
  /// `SpinnerModel` defines a sequence of values that a spinner can step
  /// through.  The current value is returned by `getValue()`; `getNextValue()`
  /// and `getPreviousValue()` return the adjacent values without changing
  /// the current value.  `setValue(_:)` changes the current value and fires
  /// a `ChangeEvent` to all registered listeners.
  ///
  /// - Since: Java 1.4
  @MainActor
  public protocol SpinnerModel: AnyObject {

    /// Returns the current value of the model.
    func getValue() -> Any?

    /// Sets the current value and fires a `ChangeEvent`.
    func setValue(_ value: Any?)

    /// Returns the value that comes after the current value, or `nil` if
    /// the sequence has an upper bound and the current value is at that bound.
    func getNextValue() -> Any?

    /// Returns the value that comes before the current value, or `nil` if
    /// the sequence has a lower bound and the current value is at that bound.
    func getPreviousValue() -> Any?

    /// Registers `l` to receive `ChangeEvent` notifications.
    func addChangeListener(_ l: javax.swing.event.ChangeListener)

    /// Removes `l` from the list of registered listeners.
    func removeChangeListener(_ l: javax.swing.event.ChangeListener)
  }
}
