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
  /// Listener management and `fireStateChanged()` are inherited from
  /// `AbstractSpinnerModel`.
  ///
  /// ## Example
  ///
  /// ```swift
  /// // Integer spinner 0–100, start 50, step 5
  /// let model = javax.swing.SpinnerNumberModel(50.0, 0.0, 100.0, 5.0)
  /// model.getNextValue()     // 55.0
  /// model.getPreviousValue() // 45.0
  /// ```
  ///
  /// - Since: Java 1.4 / JFC 1.0
  @MainActor
  open class SpinnerNumberModel: javax.swing.AbstractSpinnerModel {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    private var _value:    Double
    private var _minimum:  Double?
    private var _maximum:  Double?
    private var _stepSize: Double

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
    public init(_ value: Double = 0, _ minimum: Double? = nil, _ maximum: Double? = nil, _ stepSize: Double = 1) {
      _value    = value
      _minimum  = minimum
      _maximum  = maximum
      _stepSize = stepSize
      super.init()
    }

    /// Creates an integer-style model (all values are whole numbers).
    public init(_ value: Int, _ minimum: Int, _ maximum: Int, _ stepSize: Int = 1) {
      _value    = Double(value)
      _minimum  = Double(minimum)
      _maximum  = Double(maximum)
      _stepSize = Double(stepSize)
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: AbstractSpinnerModel overrides
    // -------------------------------------------------------------------------

    override open func getValue() -> Any? { _value }

    override open func setValue(_ value: Any?) {
      guard let v = value as? Double else { return }
      guard v != _value else { return }
      _value = v
      fireStateChanged()
    }

    override open func getNextValue() -> Any? {
      let next = _value + _stepSize
      if let max = _maximum, next > max { return nil }
      return next
    }

    override open func getPreviousValue() -> Any? {
      let prev = _value - _stepSize
      if let min = _minimum, prev < min { return nil }
      return prev
    }

    // -------------------------------------------------------------------------
    // MARK: Typed accessors
    // -------------------------------------------------------------------------

    /// Returns the current value as a `Double`.
    ///
    /// In Java, `getNumber()` returns `Number`; here we use `Double` as the
    /// canonical numeric type. Use `getIntValue()` for integer values.
    open func getNumber() -> Double { _value }

    /// Returns the current value as an `Int` (truncated).
    open func getIntValue() -> Int { Int(_value) }

    /// Sets the current value from a `Double`.
    open func setNumber(_ value: Double) { setValue(value) }

    /// Sets the current value from an `Int`.
    open func setNumber(_ value: Int) { setValue(Double(value)) }

    /// Returns the minimum bound, or `nil` if unbounded.
    open func getMinimum() -> Double? { _minimum }
    open func setMinimum(_ min: Double?) { _minimum = min }

    /// Returns the maximum bound, or `nil` if unbounded.
    open func getMaximum() -> Double? { _maximum }
    open func setMaximum(_ max: Double?) { _maximum = max }

    /// Returns the step size.
    open func getStepSize() -> Double { _stepSize }
    open func setStepSize(_ step: Double) { _stepSize = step }
  }
}
