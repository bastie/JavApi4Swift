/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Base class for all Swing button components.
  ///
  /// `AbstractButton` extends `JComponent` and provides the shared
  /// infrastructure for `JButton`, `JToggleButton`, `JMenuItem`, and their
  /// subclasses:
  ///
  /// - Text label and icon
  /// - `ButtonModel` (state: armed, pressed, rollover, selected, enabled)
  /// - `ActionListener`, `ItemListener`, `ChangeListener` management
  /// - `doClick()` for programmatic activation
  /// - Mouse-event → model-state mapping
  ///
  /// Subclasses set `text` and call `updateUI()` from their own initialisers.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class AbstractButton: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Text & icon
    // -------------------------------------------------------------------------

    private var _text: String = ""
    private var _icon: javax.swing.Icon? = nil
    private var _hideActionText: Bool = false

    public func getText() -> String         { _hideActionText ? "" : _text }
    public func setText(_ t: String)        { _text = t; invalidate() }

    public func getIcon() -> javax.swing.Icon?          { _icon }
    public func setIcon(_ icon: javax.swing.Icon?)      { _icon = icon; invalidate() }

    public func isHideActionText() -> Bool              { _hideActionText }
    public func setHideActionText(_ hide: Bool)         { _hideActionText = hide; invalidate() }

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var _model: javax.swing.ButtonModel = javax.swing.DefaultButtonModel()

    public func getModel() -> javax.swing.ButtonModel   { _model }
    public func setModel(_ model: javax.swing.ButtonModel) {
      // detach old model's change listener
      if let bridge = _modelBridge { _model.removeChangeListener(bridge) }
      _model = model
      if let bridge = _modelBridge { _model.addChangeListener(bridge) }
    }

    // Convenience passthroughs used by subclasses and UI delegates
    public func isSelected() -> Bool    { _model.isSelected() }
    public func setSelected(_ b: Bool)  { _model.setSelected(b) }
    public override func isEnabled() -> Bool     { _model.isEnabled() }

    // -------------------------------------------------------------------------
    // MARK: Model → ChangeListener bridge (fires ItemEvent + repaint)
    // -------------------------------------------------------------------------

    private class _ModelBridge: javax.swing.event.ChangeListener {
      weak var btn: AbstractButton?
      init(_ btn: AbstractButton) { self.btn = btn }
      func stateChanged(_ e: javax.swing.event.ChangeEvent) {
        btn?.modelStateChanged()
      }
    }
    private var _modelBridge: _ModelBridge?

    private func modelStateChanged() {
      fireStateChanged()
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var _actionListeners:  [java.awt.event.ActionListener] = []
    private var _itemListeners:    [java.awt.event.ItemListener]   = []
    private var _changeListeners:  [javax.swing.event.ChangeListener] = []

    public func addActionListener(_ l: java.awt.event.ActionListener) {
      _actionListeners.append(l)
    }
    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      _actionListeners.removeAll { $0 === l }
    }
    /// Convenience closure overload.
    public func addActionListener(_ handler: @escaping (java.awt.event.ActionEvent) -> Void) {
      _actionListeners.append(_SwingClosureActionListener(handler))
    }

    public func addItemListener(_ l: java.awt.event.ItemListener) {
      _itemListeners.append(l)
    }
    public func removeItemListener(_ l: java.awt.event.ItemListener) {
      _itemListeners.removeAll { $0 === l }
    }

    public func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      _changeListeners.append(l)
    }
    public func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      _changeListeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Fire helpers
    // -------------------------------------------------------------------------

    open func fireActionPerformed(_ command: String? = nil) {
      let cmd = command ?? _model.getActionCommand() ?? _text
      let e = java.awt.event.ActionEvent(
        self, java.awt.event.ActionEvent.ACTION_PERFORMED, cmd)
      for l in _actionListeners { l.actionPerformed(e) }
    }

    open func fireItemStateChanged(_ stateChange: Int) {
      let e = java.awt.event.ItemEvent(
        self,
        java.awt.event.ItemEvent.ITEM_STATE_CHANGED,
        self,
        stateChange)
      for l in _itemListeners { l.itemStateChanged(e) }
    }

    open func fireStateChanged() {
      let e = javax.swing.event.ChangeEvent(self)
      for l in _changeListeners { l.stateChanged(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: doClick
    // -------------------------------------------------------------------------

    /// Programmatically clicks the button, firing ActionListeners.
    open func doClick() {
      fireActionPerformed()
    }

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      _setup()
    }

    /// Designated initialiser used by subclasses.
    public init(_ text: String, _ icon: javax.swing.Icon? = nil) {
      super.init()
      _text = text
      _icon = icon
      _setup()
    }

    private func _setup() {
      let bridge = _ModelBridge(self)
      _modelBridge = bridge
      _model.addChangeListener(bridge)
    }

    // -------------------------------------------------------------------------
    // MARK: Mouse → model state
    // -------------------------------------------------------------------------

    override open func processMouseEvent(_ e: java.awt.event.MouseEvent) {
      switch e.getID() {
      case java.awt.event.MouseEvent.MOUSE_PRESSED:
        _model.setArmed(true)
        _model.setPressed(true)
      case java.awt.event.MouseEvent.MOUSE_RELEASED:
        _model.setPressed(false)
        _model.setArmed(false)
      case java.awt.event.MouseEvent.MOUSE_CLICKED:
        if _model.isEnabled() {
          buttonClicked()
        }
      case java.awt.event.MouseEvent.MOUSE_ENTERED:
        _model.setRollover(true)
      case java.awt.event.MouseEvent.MOUSE_EXITED:
        _model.setRollover(false)
        _model.setArmed(false)
      default: break
      }
      repaint()
      super.processMouseEvent(e)
    }

    /// Called when a confirmed click occurs. Subclasses override to implement
    /// toggle behaviour (`JToggleButton`) or menu behaviour (`JMenuItem`).
    open func buttonClicked() {
      fireActionPerformed()
    }

    // -------------------------------------------------------------------------
    // MARK: Dispose
    // -------------------------------------------------------------------------

    override open func dispose() {
      _actionListeners.removeAll()
      _itemListeners.removeAll()
      _changeListeners.removeAll()
      _modelBridge = nil
      super.dispose()
    }
  }
}
