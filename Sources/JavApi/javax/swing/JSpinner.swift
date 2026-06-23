/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A single-line text field with two small arrow buttons that lets the user
  /// select a value from an ordered sequence — mirrors `javax.swing.JSpinner`.
  ///
  /// ```swift
  /// let spinner = javax.swing.JSpinner(javax.swing.SpinnerNumberModel(0, 0, 100, 1))
  /// spinner.addChangeListener(myChangeListener)
  /// ```
  ///
  /// - Since: Java 1.4
  @MainActor
  open class JSpinner: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var _model: any javax.swing.SpinnerModel

    private class _ModelBridge: javax.swing.event.ChangeListener {
      weak var spinner: JSpinner?
      init(_ spinner: JSpinner) { self.spinner = spinner }
      func stateChanged(_ e: javax.swing.event.ChangeEvent) {
        spinner?.repaint()
        spinner?._fireStateChanged()
      }
    }
    private var _modelBridge: _ModelBridge?

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var _changeListeners: [javax.swing.event.ChangeListener] = []

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a `JSpinner` with a `SpinnerNumberModel` (0…100, step 1).
    public override init() {
      _model = javax.swing.SpinnerNumberModel(0, 0, 100, 1)
      super.init()
      _setup()
    }

    /// Creates a `JSpinner` backed by `model`.
    public init(_ model: any javax.swing.SpinnerModel) {
      _model = model
      super.init()
      _setup()
    }

    private func _setup() {
      let b = _ModelBridge(self)
      _modelBridge = b
      _model.addChangeListener(b)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Model access
    // -------------------------------------------------------------------------

    public func getModel() -> any javax.swing.SpinnerModel { _model }

    public func setModel(_ model: any javax.swing.SpinnerModel) {
      if let b = _modelBridge { _model.removeChangeListener(b) }
      _model = model
      _setup()
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Value
    // -------------------------------------------------------------------------

    public func getValue() -> Any? { _model.getValue() }

    public func setValue(_ value: Any?) {
      _model.setValue(value)
      repaint()
    }

    public func getNextValue()     -> Any? { _model.getNextValue()     }
    public func getPreviousValue() -> Any? { _model.getPreviousValue() }

    // -------------------------------------------------------------------------
    // MARK: Change listeners
    // -------------------------------------------------------------------------

    public func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      _changeListeners.append(l)
    }

    public func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      _changeListeners.removeAll { $0 === l }
    }

    private func _fireStateChanged() {
      guard !_changeListeners.isEmpty else { return }
      let e = javax.swing.event.ChangeEvent(self)
      for l in _changeListeners { l.stateChanged(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — delegates to UI, inline fallback
    // -------------------------------------------------------------------------

    // paint() is intentionally NOT overridden here.
    // JComponent.paint() → ui.update() → ui.paint(g, on: self) (BasicSpinnerUI).
    // Fallback when no UI delegate is installed:

    override open func paintComponent(_ g: java.awt.Graphics) {
      guard ui == nil else { return }
      let w    = bounds.width, h = bounds.height
      let fm   = java.awt.FontMetrics.make(for: font)
      let btnW = h

      g.setColor(java.awt.SystemColor.window)
      g.fillRect(0, 0, w - btnW, h)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(0,         0,   w-btnW-1, 0)
      g.drawLine(0,         0,   0,         h-1)
      g.drawLine(w-btnW-1,  0,   w-btnW-1, h-1)
      g.drawLine(0,         h-1, w-btnW-1, h-1)

      let label: String
      if let d = _model.getValue() as? Double, d.truncatingRemainder(dividingBy: 1) == 0 {
        label = String(Int(d))
      } else {
        label = _model.getValue().map { "\($0)" } ?? ""
      }
      g.setColor(java.awt.SystemColor.windowText)
      g.drawString(label, 4, fm.getAscent() + (h - fm.getHeight()) / 2)

      let halfH = h / 2
      _drawArrowButton(g, x: w-btnW, y: 0,     w: btnW, h: halfH,   up: true)
      _drawArrowButton(g, x: w-btnW, y: halfH, w: btnW, h: h-halfH, up: false)
    }

    internal func _drawArrowButton(_ g: java.awt.Graphics, x: Int, y: Int, w: Int, h: Int, up: Bool) {
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(x, y, w, h)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)

      // Arrow glyph
      g.setColor(java.awt.SystemColor.controlText)
      let cx = x + w / 2
      let cy = y + h / 2
      for i in 0...2 {
        if up {
          g.drawLine(cx - i, cy + i, cx + i, cy + i)
        } else {
          g.drawLine(cx - i, cy - i, cx + i, cy - i)
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "SpinnerUI" }

    override open func getPreferredSize() -> java.awt.Dimension {
      if let d = getUI()?.getPreferredSize(self) { return d }
      let fm = java.awt.FontMetrics.make(for: font)
      return java.awt.Dimension(80, fm.getHeight() + 8)
    }

    override open func dispose() {
      _changeListeners.removeAll()
      super.dispose()
    }
  }
}
