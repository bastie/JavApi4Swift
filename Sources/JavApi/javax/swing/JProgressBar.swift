/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A component that displays progress towards a goal — mirrors
  /// `javax.swing.JProgressBar`.
  ///
  /// In *determinate* mode the bar fills proportionally to `(value - min) /
  /// (max - min)`.  In *indeterminate* mode it shows an animation indicating
  /// that work is ongoing but the completion time is unknown.
  ///
  /// The state is held by a `BoundedRangeModel`; a `ChangeEvent` is fired
  /// whenever the value changes.
  ///
  /// ```swift
  /// let bar = javax.swing.JProgressBar(0, 100)
  /// bar.setValue(42)
  /// bar.setStringPainted(true)
  /// panel.add(bar)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JProgressBar: javax.swing.JComponent, javax.swing.SwingConstants {

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var model: javax.swing.BoundedRangeModel

    // -------------------------------------------------------------------------
    // MARK: Orientation
    // -------------------------------------------------------------------------

    private var _orientation: Int

    // -------------------------------------------------------------------------
    // MARK: Display options
    // -------------------------------------------------------------------------

    private var _stringPainted: Bool  = false
    private var _string:        String? = nil
    private var _indeterminate: Bool  = false
    private var _borderPainted: Bool  = true

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var changeListeners: [javax.swing.event.ChangeListener] = []

    private class _ModelBridge: javax.swing.event.ChangeListener {
      weak var bar: JProgressBar?
      init(_ bar: JProgressBar) { self.bar = bar }
      func stateChanged(_ e: javax.swing.event.ChangeEvent) {
        bar?.fireChange()
      }
    }
    private var bridge: _ModelBridge?

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates a horizontal progress bar with range `[0, 100]`.
    public convenience override init() {
      self.init(JProgressBar.HORIZONTAL, 0, 100)
    }

    /// Creates a horizontal progress bar with the given range.
    public convenience init(_ min: Int, _ max: Int) {
      self.init(JProgressBar.HORIZONTAL, min, max)
    }

    /// Creates a progress bar with the given orientation and range.
    ///
    /// - Parameters:
    ///   - orient: `SwingConstants.HORIZONTAL` or `SwingConstants.VERTICAL`.
    ///   - min:    Minimum value.
    ///   - max:    Maximum value.
    public init(_ orient: Int, _ min: Int, _ max: Int) {
      self._orientation = orient
      self.model = javax.swing.DefaultBoundedRangeModel(value: min, extent: 0, minimum: min, maximum: max)
      super.init()
      let b = _ModelBridge(self)
      self.bridge = b
      model.addChangeListener(b)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "ProgressBarUI" }

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

    open func getValue() -> Int  { model.getValue() }
    open func getMinimum() -> Int { model.getMinimum() }
    open func getMaximum() -> Int { model.getMaximum() }

    open func setValue(_ n: Int) {
      let clamped = max(model.getMinimum(), min(model.getMaximum(), n))
      model.setValue(clamped)
      repaint()
    }

    open func setMinimum(_ n: Int) {
      model.setMinimum(n)
      repaint()
    }

    open func setMaximum(_ n: Int) {
      model.setMaximum(n)
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: String painting
    // -------------------------------------------------------------------------

    /// Whether the progress string is painted over the bar.
    open func isStringPainted() -> Bool { _stringPainted }

    open func setStringPainted(_ b: Bool) {
      _stringPainted = b
      repaint()
    }

    /// The custom string displayed over the bar (default: percentage).
    open func getString() -> String {
      if let s = _string { return s }
      let pct = percentComplete()
      return "\(Int(pct * 100)) %"
    }

    open func setString(_ s: String?) {
      _string = s
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Border
    // -------------------------------------------------------------------------

    open func isBorderPainted() -> Bool { _borderPainted }
    open func setBorderPainted(_ b: Bool) { _borderPainted = b; repaint() }

    // -------------------------------------------------------------------------
    // MARK: Indeterminate mode
    // -------------------------------------------------------------------------

    open func isIndeterminate() -> Bool { _indeterminate }

    open func setIndeterminate(_ b: Bool) {
      _indeterminate = b
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Percentage
    // -------------------------------------------------------------------------

    /// Returns the fraction of progress completed, in the range [0.0, 1.0].
    open func percentComplete() -> Double {
      let range = model.getMaximum() - model.getMinimum()
      guard range > 0 else { return 0 }
      return Double(model.getValue() - model.getMinimum()) / Double(range)
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
