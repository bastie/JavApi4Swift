/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A `SpinnerModel` for numeric values within an optional bounded range.
  ///
  /// The model stores a `Double` value internally, but `getValue()` and
  /// `setValue(_:)` use `Any?` for `SpinnerModel` conformance.
  /// Use the typed accessors `getNumber()` / `setNumber(_:)` in Swift code.
  ///
  /// ## Example
  ///
  /// ```swift
  /// // Integer spinner 0–100, start 50, step 5
  /// let model = javax.swing.SpinnerNumberModel(value: 50.0, minimum: 0.0, maximum: 100.0, stepSize: 5.0)
  /// model.getNextValue()     // 55.0
  /// model.getPreviousValue() // 45.0
  /// ```
  ///
  /// - Since: Java 1.4
  @MainActor
  open class SpinnerNumberModel: javax.swing.SpinnerModel {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    private var _value:    Double
    private var _minimum:  Double?
    private var _maximum:  Double?
    private var _stepSize: Double

    private var listeners: [javax.swing.event.ChangeListener] = []

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a model with optional bounds.
    ///
    /// - Parameters:
    ///   - value:    Initial value.
    ///   - minimum:  Lower bound, or `nil` for unbounded.
    ///   - maximum:  Upper bound, or `nil` for unbounded.
    ///   - stepSize: Amount added/subtracted per step (must be > 0).
    public init(value: Double = 0, minimum: Double? = nil, maximum: Double? = nil, stepSize: Double = 1) {
      _value    = value
      _minimum  = minimum
      _maximum  = maximum
      _stepSize = stepSize
    }

    /// Creates an integer-style model (all values are whole numbers).
    public convenience init(value: Int, minimum: Int, maximum: Int, stepSize: Int = 1) {
      self.init(value: Double(value),
                minimum: Double(minimum),
                maximum: Double(maximum),
                stepSize: Double(stepSize))
    }

    // -------------------------------------------------------------------------
    // MARK: SpinnerModel
    // -------------------------------------------------------------------------

    open func getValue() -> Any? { _value }

    open func setValue(_ value: Any?) {
      guard let v = value as? Double else { return }
      guard v != _value else { return }
      _value = v
      fireStateChanged()
    }

    open func getNextValue() -> Any? {
      let next = _value + _stepSize
      if let max = _maximum, next > max { return nil }
      return next
    }

    open func getPreviousValue() -> Any? {
      let prev = _value - _stepSize
      if let min = _minimum, prev < min { return nil }
      return prev
    }

    open func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      listeners.append(l)
    }

    open func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Typed accessors
    // -------------------------------------------------------------------------

    /// Returns the current value as a `Double`.
    open func getNumber() -> Double { _value }

    /// Sets the current value from a `Double`.
    open func setNumber(_ value: Double) { setValue(value) }

    /// Returns the minimum bound, or `nil` if unbounded.
    open func getMinimum() -> Double? { _minimum }
    open func setMinimum(_ min: Double?) { _minimum = min }

    /// Returns the maximum bound, or `nil` if unbounded.
    open func getMaximum() -> Double? { _maximum }
    open func setMaximum(_ max: Double?) { _maximum = max }

    /// Returns the step size.
    open func getStepSize() -> Double { _stepSize }
    open func setStepSize(_ step: Double) { _stepSize = step }

    // -------------------------------------------------------------------------
    // MARK: Fire
    // -------------------------------------------------------------------------

    open func fireStateChanged() {
      let e = javax.swing.event.ChangeEvent(self)
      for l in listeners { l.stateChanged(e) }
    }
  }
}
