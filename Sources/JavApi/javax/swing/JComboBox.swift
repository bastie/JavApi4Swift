/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A component that combines a button (or editable text field) with a
  /// drop-down list — mirrors `javax.swing.JComboBox<E>`.
  ///
  /// ```swift
  /// let combo = javax.swing.JComboBox<String>(["Red", "Green", "Blue"])
  /// combo.addActionListener { _ in
  ///   print(combo.getSelectedItem() as? String ?? "")
  /// }
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JComboBox<E>: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Model  (any ComboBoxModel<E> — Swift 5.7+ primary associated type)
    // -------------------------------------------------------------------------

    private var _model: any javax.swing.ComboBoxModel<E>

    private class _ModelListener: javax.swing.event.ListDataListener {
      weak var combo: JComboBox?
      init(_ combo: JComboBox) { self.combo = combo }
      func intervalAdded(_ e: javax.swing.event.ListDataEvent)   { combo?.repaint() }
      func intervalRemoved(_ e: javax.swing.event.ListDataEvent) { combo?.repaint() }
      func contentsChanged(_ e: javax.swing.event.ListDataEvent) { combo?.repaint(); combo?._fireActionEvent() }
    }
    private var _modelListener: _ModelListener?

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _popupVisible:    Bool   = false
    internal var _rolloverIdx:    Int    = -1
    private var _actionListeners: [java.awt.event.ActionListener] = []
    private var _itemListeners:   [java.awt.event.ItemListener]   = []
    private var _actionCommand:   String = "comboBoxChanged"

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    public override init() {
      _model = javax.swing.DefaultComboBoxModel<E>()
      super.init()
      _install(model: _model)
    }

    public init(model: any javax.swing.ComboBoxModel<E>) {
      _model = model
      super.init()
      _install(model: _model)
    }

    public init(_ items: [E]) {
      _model = javax.swing.DefaultComboBoxModel<E>(items)
      super.init()
      _install(model: _model)
    }

    private func _install(model: any javax.swing.ComboBoxModel<E>) {
      let l = _ModelListener(self)
      _modelListener = l
      model.addListDataListener(l)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Model access
    // -------------------------------------------------------------------------

    public func getModel() -> any javax.swing.ComboBoxModel<E> { _model }

    public func setModel(_ model: any javax.swing.ComboBoxModel<E>) {
      if let l = _modelListener { _model.removeListDataListener(l) }
      _model = model
      _install(model: _model)
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Item management (delegates to MutableComboBoxModel)
    // -------------------------------------------------------------------------

    public func addItem(_ item: E) {
      guard let m = _model as? any javax.swing.MutableComboBoxModel<E> else { return }
      m.addElement(item)
    }

    public func insertItemAt(_ item: E, _ index: Int) {
      guard let m = _model as? any javax.swing.MutableComboBoxModel<E> else { return }
      m.insertElementAt(item, index)
    }

    public func removeItem(_ item: E) {
      guard let m = _model as? any javax.swing.MutableComboBoxModel<E> else { return }
      m.removeElement(item)
    }

    public func removeItemAt(_ index: Int) {
      guard let m = _model as? any javax.swing.MutableComboBoxModel<E> else { return }
      m.removeElementAt(index)
    }

    public func removeAllItems() {
      if let m = _model as? javax.swing.DefaultComboBoxModel<E> {
        m.removeAllElements()
      } else if let m = _model as? any javax.swing.MutableComboBoxModel<E> {
        for i in stride(from: m.getSize() - 1, through: 0, by: -1) {
          m.removeElementAt(i)
        }
      }
    }

    public func getItemCount() -> Int { _model.getSize() }

    public func getItemAt(_ index: Int) -> E { _model.getElementAt(index) }

    // -------------------------------------------------------------------------
    // MARK: Selection
    // -------------------------------------------------------------------------

    public func getSelectedItem() -> Any? { _model.getSelectedItem() }

    public func setSelectedItem(_ item: Any?) {
      _model.setSelectedItem(item)
      repaint()
    }

    public func getSelectedIndex() -> Int {
      guard let sel = _model.getSelectedItem() else { return -1 }
      for i in 0 ..< _model.getSize() {
        if let obj = _model.getElementAt(i) as AnyObject?,
           let selObj = sel as AnyObject?,
           obj === selObj { return i }
      }
      return -1
    }

    public func setSelectedIndex(_ index: Int) {
      guard index >= 0 && index < _model.getSize() else { return }
      _model.setSelectedItem(_model.getElementAt(index))
    }

    // -------------------------------------------------------------------------
    // MARK: Popup
    // -------------------------------------------------------------------------

    public func isPopupVisible() -> Bool { _popupVisible }
    public func setPopupVisible(_ visible: Bool) { _popupVisible = visible; repaint() }
    public func showPopup() { setPopupVisible(true)  }
    public func hidePopup() { setPopupVisible(false) }

    // -------------------------------------------------------------------------
    // MARK: Action command
    // -------------------------------------------------------------------------

    public func getActionCommand() -> String { _actionCommand }
    public func setActionCommand(_ cmd: String) { _actionCommand = cmd }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    public func addActionListener(_ l: java.awt.event.ActionListener) {
      _actionListeners.append(l)
    }
    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      _actionListeners.removeAll { $0 === l }
    }

    public func addItemListener(_ l: java.awt.event.ItemListener) {
      _itemListeners.append(l)
    }
    public func removeItemListener(_ l: java.awt.event.ItemListener) {
      _itemListeners.removeAll { $0 === l }
    }

    internal func _fireActionEvent() {
      guard !_actionListeners.isEmpty else { return }
      let e = java.awt.event.ActionEvent(self, java.awt.event.ActionEvent.ACTION_PERFORMED, _actionCommand)
      for l in _actionListeners { l.actionPerformed(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — delegates to UI, inline fallback
    // -------------------------------------------------------------------------

    // paint() is intentionally NOT overridden here.
    // JComponent.paint() calls ui.update(g, on: self) → ui.paint(g, on: self),
    // which is handled by BasicComboBoxUI. The fallback (no UI delegate) is
    // provided via paintComponent below.

    override open func paintComponent(_ g: java.awt.Graphics) {
      // Fallback rendering — only when no UI delegate is installed.
      guard ui == nil else { return }
      let w  = bounds.width, h = bounds.height
      let fm = java.awt.FontMetrics.make(for: font)
      let arrowW = h

      g.setColor(java.awt.SystemColor.window)
      g.fillRect(0, 0, w, h)

      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(0,   0,   w-1, 0)
      g.drawLine(0,   0,   0,   h-1)
      g.drawLine(w-1, 0,   w-1, h-1)
      g.drawLine(0,   h-1, w-1, h-1)

      let arrowX = w - arrowW
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(arrowX + 1, 1, arrowW - 2, h - 2)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(arrowX, 1, arrowX, h - 2)

      g.setColor(java.awt.SystemColor.controlText)
      let cx = arrowX + arrowW / 2
      let cy = h / 2
      for i in 0...3 {
        g.drawLine(cx - i, cy - 2 + i, cx + i, cy - 2 + i)
      }

      if let sel = _model.getSelectedItem() {
        g.setColor(java.awt.SystemColor.windowText)
        g.drawString("\(sel)", 4, fm.getAscent() + (h - fm.getHeight()) / 2)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size — delegates to UI, font fallback
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "ComboBoxUI" }

    override open func getPreferredSize() -> java.awt.Dimension {
      if let d = getUI()?.getPreferredSize(self) { return d }
      let fm = java.awt.FontMetrics.make(for: font)
      return java.awt.Dimension(120, fm.getHeight() + 8)
    }

    override open func dispose() {
      _actionListeners.removeAll()
      _itemListeners.removeAll()
      super.dispose()
    }
  }
}
