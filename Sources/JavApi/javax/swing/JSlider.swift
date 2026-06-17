/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A component that lets the user select a value by sliding a thumb within
  /// a bounded interval — mirrors `javax.swing.JSlider`.
  ///
  /// The state is held by a `BoundedRangeModel`.  Optionally, major and minor
  /// tick marks and value labels can be painted.
  ///
  /// ```swift
  /// let slider = javax.swing.JSlider(0, 100, 50)
  /// slider.setMajorTickSpacing(25)
  /// slider.setMinorTickSpacing(5)
  /// slider.setPaintTicks(true)
  /// slider.setPaintLabels(true)
  /// slider.addChangeListener(myListener)
  /// panel.add(slider)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JSlider: javax.swing.JComponent, javax.swing.SwingConstants {

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var model: javax.swing.BoundedRangeModel

    // -------------------------------------------------------------------------
    // MARK: Orientation
    // -------------------------------------------------------------------------

    private var _orientation: Int

    // -------------------------------------------------------------------------
    // MARK: Tick / label options
    // -------------------------------------------------------------------------

    private var _majorTickSpacing: Int  = 0
    private var _minorTickSpacing: Int  = 0
    private var _paintTicks:       Bool = false
    private var _paintLabels:      Bool = false
    private var _paintTrack:       Bool = true
    private var _snapToTicks:      Bool = false
    private var _inverted:         Bool = false

    /// Custom label table: maps integer values to `java.awt.Component` labels.
    private var _labelTable: [Int: java.awt.Component] = [:]

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var changeListeners: [javax.swing.event.ChangeListener] = []

    private class _ModelBridge: javax.swing.event.ChangeListener {
      weak var slider: JSlider?
      init(_ slider: JSlider) { self.slider = slider }
      func stateChanged(_ e: javax.swing.event.ChangeEvent) {
        slider?.fireChange()
      }
    }
    private var bridge: _ModelBridge?

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates a horizontal slider with range `[0, 100]` and initial value `50`.
    public convenience override init() {
      self.init(JSlider.HORIZONTAL, 0, 100, 50)
    }

    /// Creates a horizontal slider with the given range and initial value.
    public convenience init(_ min: Int, _ max: Int, _ value: Int) {
      self.init(JSlider.HORIZONTAL, min, max, value)
    }

    /// Creates a slider with the given orientation and range.
    ///
    /// - Parameters:
    ///   - orientation: `SwingConstants.HORIZONTAL` or `SwingConstants.VERTICAL`.
    ///   - min:         Minimum value.
    ///   - max:         Maximum value.
    ///   - value:       Initial value.
    public init(_ orientation: Int, _ min: Int, _ max: Int, _ value: Int) {
      self._orientation = orientation
      self.model = javax.swing.DefaultBoundedRangeModel(
        value: value, extent: 0, minimum: min, maximum: max)
      super.init()
      let b = _ModelBridge(self)
      self.bridge = b
      model.addChangeListener(b)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "SliderUI" }

    override open func updateUI() {
      super.updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Orientation
    // -------------------------------------------------------------------------

    open func getOrientation() -> Int { _orientation }

    open func setOrientation(_ orientation: Int) {
      _orientation = orientation
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Value / range — delegate to model
    // -------------------------------------------------------------------------

    open func getValue()   -> Int { model.getValue() }
    open func getMinimum() -> Int { model.getMinimum() }
    open func getMaximum() -> Int { model.getMaximum() }

    open func setValue(_ n: Int) {
      let clamped = max(model.getMinimum(), min(model.getMaximum(), n))
      model.setValue(clamped)
      repaint()
    }

    open func setMinimum(_ n: Int) { model.setMinimum(n); repaint() }
    open func setMaximum(_ n: Int) { model.setMaximum(n); repaint() }

    open func getValueIsAdjusting() -> Bool { model.getValueIsAdjusting() }
    open func setValueIsAdjusting(_ b: Bool) { model.setValueIsAdjusting(b) }

    // -------------------------------------------------------------------------
    // MARK: Tick marks
    // -------------------------------------------------------------------------

    open func getMajorTickSpacing() -> Int { _majorTickSpacing }
    open func setMajorTickSpacing(_ n: Int) { _majorTickSpacing = n; repaint() }

    open func getMinorTickSpacing() -> Int { _minorTickSpacing }
    open func setMinorTickSpacing(_ n: Int) { _minorTickSpacing = n; repaint() }

    open func getPaintTicks() -> Bool { _paintTicks }
    open func setPaintTicks(_ b: Bool) { _paintTicks = b; repaint() }

    open func getPaintLabels() -> Bool { _paintLabels }
    open func setPaintLabels(_ b: Bool) { _paintLabels = b; repaint() }

    open func getPaintTrack() -> Bool { _paintTrack }
    open func setPaintTrack(_ b: Bool) { _paintTrack = b; repaint() }

    open func getSnapToTicks() -> Bool { _snapToTicks }
    open func setSnapToTicks(_ b: Bool) { _snapToTicks = b }

    open func getInverted() -> Bool { _inverted }
    open func setInverted(_ b: Bool) { _inverted = b; repaint() }

    // -------------------------------------------------------------------------
    // MARK: Label table
    // -------------------------------------------------------------------------

    open func getLabelTable() -> [Int: java.awt.Component] { _labelTable }
    open func setLabelTable(_ table: [Int: java.awt.Component]) {
      _labelTable = table
      repaint()
    }

    /// Creates a standard label table for the current tick spacing.
    ///
    /// Returns a dictionary mapping every `majorTickSpacing`-th value to a
    /// `JLabel` showing that value.
    open func createStandardLabels(_ increment: Int) -> [Int: java.awt.Component] {
      var table: [Int: java.awt.Component] = [:]
      guard increment > 0 else { return table }
      var v = model.getMinimum()
      while v <= model.getMaximum() {
        table[v] = javax.swing.JLabel("\(v)")
        v += increment
      }
      return table
    }

    // -------------------------------------------------------------------------
    // MARK: Model access
    // -------------------------------------------------------------------------

    open func getModel() -> javax.swing.BoundedRangeModel { model }

    open func setModel(_ newModel: javax.swing.BoundedRangeModel) {
      if let b = bridge { model.removeChangeListener(b) }
      model = newModel
      let b = _ModelBridge(self)
      bridge = b
      model.addChangeListener(b)
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: ChangeListener management
    // -------------------------------------------------------------------------

    open func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      changeListeners.append(l)
    }

    open func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      changeListeners.removeAll { $0 === l }
    }

    private func fireChange() {
      let e = javax.swing.event.ChangeEvent(self)
      for l in changeListeners { l.stateChanged(e) }
    }
  }
}
