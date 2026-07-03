/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// ---------------------------------------------------------------------------
// MARK: - JListSelectionMode namespace
// ---------------------------------------------------------------------------

extension javax.swing {

  /// Selection mode constants for `JList` — extracted from the generic class
  /// because Swift does not allow static stored properties in generic types.
  public enum JListSelectionMode {
    public static let SINGLE_SELECTION:            Int = 0
    public static let SINGLE_INTERVAL_SELECTION:   Int = 1
    public static let MULTIPLE_INTERVAL_SELECTION: Int = 2
  }

  // ---------------------------------------------------------------------------
  // MARK: - JList
  // ---------------------------------------------------------------------------

  /// A component that displays a list of objects and allows the user to select
  /// one or more items — mirrors `javax.swing.JList<E>`.
  ///
  /// ```swift
  /// let model = javax.swing.DefaultListModel<String>()
  /// model.addElement("Apple")
  /// model.addElement("Banana")
  /// let list = javax.swing.JList(model: model)
  /// list.addListSelectionListener(myListener)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JList<E>: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Selection mode constants (computed — no stored statics in generics)
    // -------------------------------------------------------------------------

    public static var SINGLE_SELECTION:            Int { javax.swing.JListSelectionMode.SINGLE_SELECTION }
    public static var SINGLE_INTERVAL_SELECTION:   Int { javax.swing.JListSelectionMode.SINGLE_INTERVAL_SELECTION }
    public static var MULTIPLE_INTERVAL_SELECTION: Int { javax.swing.JListSelectionMode.MULTIPLE_INTERVAL_SELECTION }

    // -------------------------------------------------------------------------
    // MARK: Model  (any ListModel<E> — Swift 5.7+ primary associated type)
    // -------------------------------------------------------------------------

    private var _model: any javax.swing.ListModel<E>

    private class _ModelBridge: javax.swing.event.ListDataListener {
      weak var list: JList?
      init(_ list: JList) { self.list = list }
      func intervalAdded(_ e: javax.swing.event.ListDataEvent)   { list?.repaint() }
      func intervalRemoved(_ e: javax.swing.event.ListDataEvent) { list?.repaint() }
      func contentsChanged(_ e: javax.swing.event.ListDataEvent) { list?.repaint() }
    }
    private var _modelBridge: _ModelBridge?

    // -------------------------------------------------------------------------
    // MARK: Selection model
    // -------------------------------------------------------------------------

    private var _selectionModel: javax.swing.ListSelectionModel

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _fixedCellHeight: Int = -1   // -1 = auto (derived from font)
    private var _visibleRowCount: Int = 8
    private var _selectionListeners: [javax.swing.event.ListSelectionListener] = []
    internal var _hoverIdx: Int = -1

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    public override init() {
      _model = javax.swing.DefaultListModel<E>()
      _selectionModel = javax.swing.DefaultListSelectionModel()
      super.init()
      _setupBridge()
    }

    public init(_ model: any javax.swing.ListModel<E>) {
      _model = model
      _selectionModel = javax.swing.DefaultListSelectionModel()
      super.init()
      _setupBridge()
    }

    public init(_ items: [E]) {
      let m = javax.swing.DefaultListModel<E>()
      for item in items { m.addElement(item) }
      _model = m
      _selectionModel = javax.swing.DefaultListSelectionModel()
      super.init()
      _setupBridge()
    }

    private func _setupBridge() {
      let b = _ModelBridge(self)
      _modelBridge = b
      _model.addListDataListener(b)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Model access
    // -------------------------------------------------------------------------

    public func getModel() -> any javax.swing.ListModel<E> { _model }

    public func setModel(_ model: any javax.swing.ListModel<E>) {
      if let b = _modelBridge { _model.removeListDataListener(b) }
      _model = model
      _setupBridge()
      _selectionModel.clearSelection()
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Selection model
    // -------------------------------------------------------------------------

    public func getSelectionModel() -> javax.swing.ListSelectionModel { _selectionModel }

    public func setSelectionModel(_ sm: javax.swing.ListSelectionModel) {
      _selectionModel = sm
      repaint()
    }

    public func getSelectionMode() -> Int { _selectionModel.getSelectionMode() }

    public func setSelectionMode(_ mode: Int) {
      _selectionModel.setSelectionMode(mode)
    }

    // -------------------------------------------------------------------------
    // MARK: Selection access
    // -------------------------------------------------------------------------

    public func getSelectedIndex() -> Int { _selectionModel.getMinSelectionIndex() }

    public func setSelectedIndex(_ index: Int) {
      _selectionModel.setSelectionInterval(index, index)
      repaint()
    }

    public func getSelectedIndices() -> [Int] {
      let min = _selectionModel.getMinSelectionIndex()
      let max = _selectionModel.getMaxSelectionIndex()
      guard min >= 0 else { return [] }
      return (min...max).filter { _selectionModel.isSelectedIndex($0) }
    }

    public func setSelectedIndices(_ indices: [Int]) {
      _selectionModel.clearSelection()
      for i in indices { _selectionModel.addSelectionInterval(i, i) }
      repaint()
    }

    public func getSelectedValue() -> E? {
      let idx = getSelectedIndex()
      guard idx >= 0 && idx < _model.getSize() else { return nil }
      return _model.getElementAt(idx)
    }

    public func getSelectedValuesList() -> [E] {
      getSelectedIndices().compactMap { idx in
        guard idx < _model.getSize() else { return nil }
        return _model.getElementAt(idx)
      }
    }

    public func clearSelection() { _selectionModel.clearSelection(); repaint() }
    public func isSelectionEmpty() -> Bool { _selectionModel.isSelectionEmpty() }

    public func isSelectedIndex(_ index: Int) -> Bool {
      _selectionModel.isSelectedIndex(index)
    }

    // -------------------------------------------------------------------------
    // MARK: Cell geometry
    // -------------------------------------------------------------------------

    /// Returns the effective row height — either the explicitly set value or
    /// a font-derived default (`fontHeight + 4`).
    public func getFixedCellHeight() -> Int {
      _fixedCellHeight > 0
        ? _fixedCellHeight
        : java.awt.FontMetrics.make(for: font).getHeight() + 4
    }
    /// Sets a fixed row height.  Pass `-1` to restore the font-derived default.
    public func setFixedCellHeight(_ h: Int) { _fixedCellHeight = h; repaint() }

    public func getVisibleRowCount() -> Int { _visibleRowCount }
    public func setVisibleRowCount(_ n: Int) { _visibleRowCount = n }

    public func locationToIndex(_ px: Int, _ py: Int) -> Int {
      let row = (py - bounds.y) / getFixedCellHeight()
      return (row >= 0 && row < _model.getSize()) ? row : -1
    }

    // -------------------------------------------------------------------------
    // MARK: Selection listeners
    // -------------------------------------------------------------------------

    public func addListSelectionListener(_ l: javax.swing.event.ListSelectionListener) {
      _selectionListeners.append(l)
      _selectionModel.addListSelectionListener(l)
    }

    public func removeListSelectionListener(_ l: javax.swing.event.ListSelectionListener) {
      _selectionListeners.removeAll { $0 === l }
      _selectionModel.removeListSelectionListener(l)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — delegates to UI, inline fallback
    // -------------------------------------------------------------------------

    // paint() is intentionally NOT overridden here.
    // JComponent.paint() → ui.update() → ui.paint(g, on: self) (BasicListUI).
    // Fallback when no UI delegate is installed:

    override open func paintComponent(_ g: java.awt.Graphics) {
      guard ui == nil else { return }
      let w    = bounds.width, h = bounds.height
      let rowH = getFixedCellHeight()
      let fm   = java.awt.FontMetrics.make(for: font)

      g.setColor(java.awt.SystemColor.window)
      g.fillRect(0, 0, w, h)

      for i in 0 ..< _model.getSize() {
        let rowY = i * rowH

        if _selectionModel.isSelectedIndex(i) {
          g.setColor(java.awt.SystemColor.textHighlight)
          g.fillRect(0, rowY, w, rowH)
          g.setColor(java.awt.SystemColor.textHighlightText)
        } else {
          g.setColor(java.awt.SystemColor.windowText)
        }

        let label = "\(_model.getElementAt(i))"
        g.drawString(label, 4, rowY + fm.getAscent() + 2)
      }

      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(0,   0,   w-1, 0)
      g.drawLine(0,   0,   0,   h-1)
      g.drawLine(w-1, 0,   w-1, h-1)
      g.drawLine(0,   h-1, w-1, h-1)
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "ListUI" }

    override open func getPreferredSize() -> java.awt.Dimension {
      if let d = getUI()?.getPreferredSize(self) { return d }
      // Fallback: font-driven row height, actual item count
      let fm   = java.awt.FontMetrics.make(for: font)
      let rowH = fm.getHeight() + 4
      return java.awt.Dimension(150, max(1, _model.getSize()) * rowH)
    }

    override open func dispose() {
      _selectionListeners.removeAll()
      super.dispose()
    }
  }
}
