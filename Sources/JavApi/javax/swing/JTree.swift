/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A component that displays hierarchical data as a tree.
  ///
  /// `JTree` renders a `TreeModel` and manages expand/collapse state for each
  /// node.  Step 1: non-editable, expandable nodes, single selection.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JTree: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var _model: (any javax.swing.tree.TreeModel)?

    open func getModel() -> (any javax.swing.tree.TreeModel)? { _model }
    open func setModel(_ model: (any javax.swing.tree.TreeModel)?) {
      _model = model
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Expand / collapse state
    // -------------------------------------------------------------------------

    /// Set of node-object identifiers (ObjectIdentifier) that are expanded.
    internal var _expandedNodes: Set<ObjectIdentifier> = []

    open func isExpanded(_ node: AnyObject) -> Bool {
      _expandedNodes.contains(ObjectIdentifier(node))
    }

    open func expandNode(_ node: AnyObject) {
      _expandedNodes.insert(ObjectIdentifier(node))
      repaint()
    }

    open func collapseNode(_ node: AnyObject) {
      _expandedNodes.remove(ObjectIdentifier(node))
      repaint()
    }

    open func toggleNode(_ node: AnyObject) {
      if isExpanded(node) { collapseNode(node) } else { expandNode(node) }
    }

    // -------------------------------------------------------------------------
    // MARK: Selection (single node + TreeSelectionModel)
    // -------------------------------------------------------------------------

    private var _selectedNode: AnyObject?
    private var _selectionModel: (any javax.swing.tree.TreeSelectionModel)?
    private var _treeSelectionListeners: [javax.swing.event.TreeSelectionListener] = []

    open func getLastSelectedPathComponent() -> AnyObject? { _selectedNode }
    open func setSelectedNode(_ node: AnyObject?) {
      _selectedNode = node
      repaint()
    }

    open func getSelectionModel() -> (any javax.swing.tree.TreeSelectionModel)? {
      _selectionModel
    }
    open func setSelectionModel(_ model: (any javax.swing.tree.TreeSelectionModel)?) {
      _selectionModel = model
    }

    open func addTreeSelectionListener(_ l: javax.swing.event.TreeSelectionListener) {
      _treeSelectionListeners.append(l)
      _selectionModel?.addTreeSelectionListener(l)
    }
    open func removeTreeSelectionListener(_ l: javax.swing.event.TreeSelectionListener) {
      _treeSelectionListeners.removeAll { $0 === (l as AnyObject) }
      _selectionModel?.removeTreeSelectionListener(l)
    }

    // -------------------------------------------------------------------------
    // MARK: Row height
    // -------------------------------------------------------------------------

    private var _rowHeight: Int = 20
    open func getRowHeight() -> Int { _rowHeight }
    open func setRowHeight(_ h: Int) { _rowHeight = h }

    // -------------------------------------------------------------------------
    // MARK: Show root
    // -------------------------------------------------------------------------

    private var _showsRootHandles: Bool = true
    open func getShowsRootHandles() -> Bool { _showsRootHandles }
    open func setShowsRootHandles(_ v: Bool) { _showsRootHandles = v }

    private var _rootVisible: Bool = true
    open func isRootVisible() -> Bool { _rootVisible }
    open func setRootVisible(_ v: Bool) { _rootVisible = v }

    // -------------------------------------------------------------------------
    // MARK: Cell renderer
    // -------------------------------------------------------------------------

    private var _cellRenderer: (any javax.swing.tree.TreeCellRenderer) =
      javax.swing.tree.DefaultTreeCellRenderer()

    open func getCellRenderer() -> any javax.swing.tree.TreeCellRenderer { _cellRenderer }
    open func setCellRenderer(_ r: any javax.swing.tree.TreeCellRenderer) {
      _cellRenderer = r
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    public override convenience init() {
      self.init(nil as (any javax.swing.tree.TreeModel)?)
    }

    public init(_ model: (any javax.swing.tree.TreeModel)?) {
      super.init()
      _model = model
      // Expand root by default
      if let root = model?.getRoot() {
        _expandedNodes.insert(ObjectIdentifier(root))
      }
      updateUI()
    }

    /// Convenience: build a JTree from a root TreeNode.
    public convenience init(_ root: any javax.swing.tree.TreeNode) {
      self.init(javax.swing.tree.DefaultTreeModel(root))
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    open override func getUIClassID() -> String { "TreeUI" }

    open override func updateUI() {
      if let factory = javax.swing.UIManager.getUI(self) {
        ui = factory
      }
    }



    // -------------------------------------------------------------------------
    // MARK: Hit-test: node at point (used by mouse handler in UI delegate)
    // -------------------------------------------------------------------------

    /// Returns the node visible at `(x, y)` in local coordinates, or nil.
    open func getNodeAtPoint(_ x: Int, _ y: Int) -> AnyObject? {
      guard let ui = ui as? javax.swing.plaf.basic.BasicTreeUI else { return nil }
      return ui.nodeAtPoint(x, y, in: self)
    }

    // -------------------------------------------------------------------------
    // MARK: Mouse
    // -------------------------------------------------------------------------

    open override func processMouseEvent(_ e: java.awt.event.MouseEvent) {
      if e.getID() == java.awt.event.MouseEvent.MOUSE_CLICKED {
        if let node = getNodeAtPoint(e.getX(), e.getY()) {
          let isLeaf = _model?.isLeaf(node) ?? true
          if !isLeaf {
            toggleNode(node)
          }
          setSelectedNode(node)
        }
      }
    }
  }
}
