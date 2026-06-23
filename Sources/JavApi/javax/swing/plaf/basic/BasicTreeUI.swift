/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JTree`.
  ///
  /// Renders each visible node by calling `TreeCellRenderer.getTreeCellRendererComponent`
  /// and painting the returned `Component` as a stamp — it is never added to
  /// the component hierarchy.  This mirrors Java Swing's design and allows
  /// custom renderers (including `JPanel` composites) to be used.
  ///
  /// Layout per row:
  /// ```
  /// [indent * depth] [handle] [renderer-component]
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicTreeUI: javax.swing.plaf.ComponentUI {

    // ── Layout constants ──────────────────────────────────────────────────────
    private let indentWidth = 16   // px per depth level
    private let handleSize  = 8    // expand/collapse triangle bounding box
    private let handlePad   = 4    // space between handle and renderer

    // ── Row cache: built during paint, used for hit-testing ──────────────────
    /// Each entry: (node, rowY, rowH, handleX — nil when leaf/hidden)
    private struct RowEntry {
      let node:    AnyObject
      let y:       Int
      let height:  Int
      let handleX: Int?   // x-origin of the expand handle, nil = no handle
    }
    private var _rowCache: [RowEntry] = []

    // ── Factory ───────────────────────────────────────────────────────────────

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicTreeUI()
    }

    // ── Preferred size ────────────────────────────────────────────────────────

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let tree  = component as? javax.swing.JTree,
            let model = tree.getModel(),
            let root  = model.getRoot() else {
        return java.awt.Dimension(0, 0)
      }
      let rowH = tree.getRowHeight()
      var totalRows = 0
      var maxW      = 0
      _measureSubtree(model: model, node: root, tree: tree,
                      depth: 0, showRoot: tree.isRootVisible(),
                      rowH: rowH, totalRows: &totalRows, maxW: &maxW)
      // Return actual content size — JScrollPane decides whether to scroll.
      return java.awt.Dimension(max(1, maxW + 8), max(1, totalRows * rowH))
    }

    // ── Paint ─────────────────────────────────────────────────────────────────

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let tree  = component as? javax.swing.JTree,
            let model = tree.getModel(),
            let root  = model.getRoot() else { return }

      let w    = tree.bounds.width
      let h    = tree.bounds.height
      let rowH = tree.getRowHeight()

      // Background
      g.setColor(java.awt.Color.white)
      g.fillRect(0, 0, w, h)

      _rowCache.removeAll(keepingCapacity: true)

      var row = 0
      if tree.isRootVisible() {
        _paintSubtree(g, model: model, node: root, tree: tree,
                      depth: 0, row: &row, rowH: rowH, totalW: w)
      } else {
        let count = model.getChildCount(root)
        for i in 0 ..< count {
          if let child = model.getChild(root, i) {
            _paintSubtree(g, model: model, node: child, tree: tree,
                          depth: 0, row: &row, rowH: rowH, totalW: w)
          }
        }
      }
    }

    // ── Private: paint one node then recurse ──────────────────────────────────

    private func _paintSubtree(_ g: java.awt.Graphics,
                                model: any javax.swing.tree.TreeModel,
                                node: AnyObject,
                                tree: javax.swing.JTree,
                                depth: Int,
                                row: inout Int,
                                rowH: Int,
                                totalW: Int) {
      let rowY       = row * rowH
      let isLeaf     = model.isLeaf(node)
      let isExpanded = tree.isExpanded(node)
      let isSelected = tree.getLastSelectedPathComponent() === node

      // x-offset: leaves at depth d get the same indent as non-leaves so labels align
      let handleOffset = tree.getShowsRootHandles() ? indentWidth : 0
      let baseX        = depth * indentWidth + handleOffset

      // ── Expand/collapse handle ────────────────────────────────────────────
      var handleX: Int? = nil
      if !isLeaf {
        let hx = baseX - indentWidth / 2 - handleSize / 2
        let hy = rowY + (rowH - handleSize) / 2
        _drawTriangle(g, x: hx, y: hy, size: handleSize, expanded: isExpanded)
        handleX = hx
      }

      // ── Renderer component ────────────────────────────────────────────────
      let renderer  = tree.getCellRenderer()
      let renderComp = renderer.getTreeCellRendererComponent(
        tree, node, isSelected, isExpanded, isLeaf, row, false)

      // Give the renderer component its bounds (local to tree)
      let rendererW = max(0, totalW - baseX)
      renderComp.bounds = java.awt.Rectangle(baseX, rowY, rendererW, rowH)

      // If it is a container, lay it out so child-components get bounds too
      (renderComp as? java.awt.Container)?.doLayout()

      // Paint the renderer as a stamp
      g.save()
      g.clipRect(baseX, rowY, rendererW, rowH)
      g.translate(baseX, rowY)
      renderComp.paint(g)
      g.restore()

      // Cache for hit-testing
      _rowCache.append(RowEntry(node: node, y: rowY, height: rowH, handleX: handleX))
      row += 1

      // ── Recurse into children if expanded ─────────────────────────────────
      if !isLeaf && isExpanded {
        let count = model.getChildCount(node)
        for i in 0 ..< count {
          if let child = model.getChild(node, i) {
            _paintSubtree(g, model: model, node: child, tree: tree,
                          depth: depth + 1, row: &row, rowH: rowH, totalW: totalW)
          }
        }
      }
    }

    // ── Hit-test ──────────────────────────────────────────────────────────────

    /// Returns the node at local `(x, y)`, or nil.
    func nodeAtPoint(_ x: Int, _ y: Int, in tree: javax.swing.JTree) -> AnyObject? {
      for entry in _rowCache {
        if y >= entry.y && y < entry.y + entry.height {
          return entry.node
        }
      }
      return nil
    }

    // ── Triangle (expand/collapse handle) ─────────────────────────────────────

    private func _drawTriangle(_ g: java.awt.Graphics, x: Int, y: Int,
                                size: Int, expanded: Bool) {
      g.setColor(java.awt.Color(100, 100, 100))
      if expanded {
        // ▼
        for i in 0 ..< size {
          let lw = size - i
          let lx = x + i / 2
          g.fillRect(lx, y + i, max(1, lw), 1)
        }
      } else {
        // ▶
        for i in 0 ..< size {
          let lh = size - i
          let ly = y + i / 2
          g.fillRect(x + i, ly, 1, max(1, lh))
        }
      }
    }

    // ── Preferred-size measurement ─────────────────────────────────────────────

    private func _measureSubtree(model: any javax.swing.tree.TreeModel,
                                  node: AnyObject,
                                  tree: javax.swing.JTree,
                                  depth: Int,
                                  showRoot: Bool,
                                  rowH: Int,
                                  totalRows: inout Int,
                                  maxW: inout Int) {
      if showRoot {
        totalRows += 1
        // Rough width: indent + label
        let label = _labelFor(node)
        let fm    = java.awt.FontMetrics.make(for: javax.swing.JLabel().font)
        let handleOffset = tree.getShowsRootHandles() ? indentWidth : 0
        let w    = depth * indentWidth + handleOffset + fm.stringWidth(label) + 4
        maxW = max(maxW, w)
      }
      if tree.isExpanded(node) || !showRoot {
        let count = model.getChildCount(node)
        for i in 0 ..< count {
          if let child = model.getChild(node, i) {
            _measureSubtree(model: model, node: child, tree: tree,
                            depth: depth + 1, showRoot: true,
                            rowH: rowH, totalRows: &totalRows, maxW: &maxW)
          }
        }
      }
    }

    private func _labelFor(_ node: AnyObject) -> String {
      if let dmtn = node as? javax.swing.tree.DefaultMutableTreeNode { return dmtn.toString() }
      return "\(node)"
    }
  }
}
