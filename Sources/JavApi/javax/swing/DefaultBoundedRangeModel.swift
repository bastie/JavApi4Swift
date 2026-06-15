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
  /// model.getValue()   // 50
  /// model.getMaximum() // 100
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

    public init(value: Int = 0, extent: Int = 0, minimum: Int = 0, maximum: Int = 100) {
      _minimum = minimum
      _maximum = max(minimum, maximum)
      _extent  = max(0, extent)
      _value   = min(max(value, _minimum), _maximum - _extent)
    }

    // -------------------------------------------------------------------------
    // MARK: BoundedRangeModel — getters
    // -------------------------------------------------------------------------

    open func getMinimum() -> Int { _minimum }
    open func getMaximum() -> Int { _maximum }
    open func getValue()   -> Int { _value }
    open func getExtent()  -> Int { _extent }
    open func getValueIsAdjusting() -> Bool { _valueIsAdjusting }

    // -------------------------------------------------------------------------
    // MARK: BoundedRangeModel — setters
    // -------------------------------------------------------------------------

    open func setMinimum(_ newMinimum: Int) {
      guard newMinimum != _minimum else { return }
      _minimum = newMinimum
      _value   = max(_value, _minimum)
      _extent  = min(_extent, _maximum - _value)
      fireStateChanged()
    }

    open func setMaximum(_ newMaximum: Int) {
      guard newMaximum != _maximum else { return }
      _maximum = max(newMaximum, _minimum)
      _extent  = min(_extent, _maximum - _value)
      fireStateChanged()
    }

    open func setValue(_ newValue: Int) {
      let clamped = min(max(newValue, _minimum), _maximum - _extent)
      guard clamped != _value else { return }
      _value = clamped
      fireStateChanged()
    }

    open func setExtent(_ newExtent: Int) {
      let clamped = min(max(newExtent, 0), _maximum - _value)
      guard clamped != _extent else { return }
      _extent = clamped
      fireStateChanged()
    }

    open func setValueIsAdjusting(_ b: Bool) {
      guard b != _valueIsAdjusting else { return }
      _valueIsAdjusting = b
      fireStateChanged()
    }

    /// Sets all four range properties atomically, firing one `ChangeEvent`.
    open func setRangeProperties(value newValue: Int,
                                 extent newExtent: Int,
                                 minimum newMin: Int,
                                 maximum newMax: Int,
                                 adjusting b: Bool) {
      _minimum          = newMin
      _maximum          = max(newMin, newMax)
      _extent           = min(max(newExtent, 0), _maximum - newMin)
      _value            = min(max(newValue, _minimum), _maximum - _extent)
      _valueIsAdjusting = b
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
