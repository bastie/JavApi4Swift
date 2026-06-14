/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The default implementation of `BoundedRangeModel`.
  ///
  /// All four properties (`minimum`, `maximum`, `value`, `extent`) clamp to
  /// maintain the invariant `minimum ≤ value ≤ value+extent ≤ maximum`.
  /// A single `ChangeEvent` is fired after every change (or once after
  /// `setRangeProperties`).
  ///
  /// ## Example
  ///
  /// ```swift
  /// let model = javax.swing.DefaultBoundedRangeModel(value: 50, extent: 0, minimum: 0, maximum: 100)
  /// model.value   // 50
  /// model.maximum // 100
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultBoundedRangeModel: javax.swing.BoundedRangeModel {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var _minimum:          Int  = 0
    private var _maximum:          Int  = 100
    private var _value:            Int  = 0
    private var _extent:           Int  = 0
    private var _valueIsAdjusting: Bool = false

    private var listeners: [javax.swing.event.ChangeListener] = []

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a model with the given initial values.
    ///
    /// Values are clamped to satisfy the invariant on construction.
    public init(value: Int = 0, extent: Int = 0, minimum: Int = 0, maximum: Int = 100) {
      _minimum = minimum
      _maximum = max(minimum, maximum)
      _extent  = max(0, extent)
      _value   = min(max(value, _minimum), _maximum - _extent)
    }

    // -------------------------------------------------------------------------
    // MARK: BoundedRangeModel
    // -------------------------------------------------------------------------

    open var minimum: Int {
      get { _minimum }
      set {
        let clamped = min(newValue, _maximum - _extent)
        guard clamped != _minimum else { return }
        _minimum = clamped
        _value   = max(_value, _minimum)
        fireStateChanged()
      }
    }

    open var maximum: Int {
      get { _maximum }
      set {
        let clamped = max(newValue, _minimum)
        guard clamped != _maximum else { return }
        _maximum = clamped
        _extent  = min(_extent, _maximum - _value)
        fireStateChanged()
      }
    }

    open var value: Int {
      get { _value }
      set {
        let clamped = min(max(newValue, _minimum), _maximum - _extent)
        guard clamped != _value else { return }
        _value = clamped
        fireStateChanged()
      }
    }

    open var extent: Int {
      get { _extent }
      set {
        let clamped = min(max(newValue, 0), _maximum - _value)
        guard clamped != _extent else { return }
        _extent = clamped
        fireStateChanged()
      }
    }

    open var valueIsAdjusting: Bool {
      get { _valueIsAdjusting }
      set {
        guard newValue != _valueIsAdjusting else { return }
        _valueIsAdjusting = newValue
        fireStateChanged()
      }
    }

    /// Sets all four range properties atomically, firing one `ChangeEvent`.
    open func setRangeProperties(value: Int, extent: Int, minimum: Int, maximum: Int, adjusting: Bool) {
      _minimum          = minimum
      _maximum          = max(minimum, maximum)
      _extent           = min(max(extent, 0), _maximum - minimum)
      _value            = min(max(value, _minimum), _maximum - _extent)
      _valueIsAdjusting = adjusting
      fireStateChanged()
    }

    open func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      listeners.append(l)
    }

    open func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Fire
    // -------------------------------------------------------------------------

    open func fireStateChanged() {
      let e = javax.swing.event.ChangeEvent(self)
      for l in listeners { l.stateChanged(e) }
    }
  }
}
