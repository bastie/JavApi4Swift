/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension javax.swing {

  /// A push button with a text label.
  ///
  /// `JButton` is the standard Swing push button.  Clicking it fires all
  /// registered `ActionListener`s.  The visual appearance is delegated
  /// to `BasicButtonUI`.  State (pressed, rollover, armed, enabled) is
  /// managed by a `ButtonModel` (`DefaultButtonModel` by default).
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let btn = javax.swing.JButton("OK")
  /// btn.addActionListener { _ in dialog.setVisible(false) }
  /// panel.add(btn)
  /// ```
  ///
  @MainActor
  open class JButton: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Text
    // -------------------------------------------------------------------------

    private var text: String

    public func getText() -> String  { text }
    public func setText(_ t: String) { text = t; invalidate() }

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var _model: javax.swing.ButtonModel = javax.swing.DefaultButtonModel()

    public func getModel() -> javax.swing.ButtonModel { _model }

    public func setModel(_ model: javax.swing.ButtonModel) { _model = model }

    /// Convenience: pressed state via model.
    internal var isPressed:  Bool {
      get { _model.isPressed()  }
      set { _model.setPressed(newValue) }
    }
    /// Convenience: rollover state via model.
    internal var isRollover: Bool {
      get { _model.isRollover() }
      set { _model.setRollover(newValue) }
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "") {
      self.text = text
      super.init()
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func updateUI() {
      super.updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Mouse state tracking
    // -------------------------------------------------------------------------

    override open func processMouseEvent(_ e: java.awt.event.MouseEvent) {
      switch e.getID() {
      case java.awt.event.MouseEvent.MOUSE_PRESSED:
        _model.setArmed(true)
        _model.setPressed(true)
        repaint()
      case java.awt.event.MouseEvent.MOUSE_RELEASED:
        _model.setPressed(false)
        _model.setArmed(false)
        repaint()
      case java.awt.event.MouseEvent.MOUSE_ENTERED:
        _model.setRollover(true)
        repaint()
      case java.awt.event.MouseEvent.MOUSE_EXITED:
        _model.setRollover(false)
        _model.setArmed(false)
        repaint()
      default: break
      }
      super.processMouseEvent(e)
    }

    // -------------------------------------------------------------------------
    // MARK: ActionListener
    // -------------------------------------------------------------------------

    private var actionListeners: [java.awt.event.ActionListener] = []

    /// Registers an `ActionListener` object (Java-style).
    public func addActionListener(_ listener: java.awt.event.ActionListener) {
      actionListeners.append(listener)
    }

    /// Convenience overload: wraps a closure in an `ActionListener`.
    public func addActionListener(_ handler: @escaping (java.awt.event.ActionEvent) -> Void) {
      actionListeners.append(_SwingClosureActionListener(handler))
    }

    public func removeActionListeners() {
      actionListeners.removeAll()
    }

    /// Programmatically fires an `ACTION_PERFORMED` event.
    public func doClick() {
      let event = java.awt.event.ActionEvent(self, java.awt.event.ActionEvent.ACTION_PERFORMED, text)
      for listener in actionListeners { listener.actionPerformed(event) }
    }
  }
}
