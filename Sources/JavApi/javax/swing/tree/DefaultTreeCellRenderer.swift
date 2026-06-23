/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// The default renderer for JTree nodes.
  ///
  /// Returns a configured `JLabel` acting as a stamp — it is never added to
  /// the component hierarchy.  The label text is taken from the node's
  /// `toString()` (for `DefaultMutableTreeNode` this is the user object's
  /// description).
  ///
  /// Custom renderers should subclass this or implement `TreeCellRenderer`
  /// directly and return any `Component` — including `JPanel` composites.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultTreeCellRenderer: javax.swing.JLabel, javax.swing.tree.TreeCellRenderer {

    // Reused stamp label — allocated once, reconfigured per row.
    // Because JTree never adds it to the component hierarchy, this is safe.

    // Selection colours
    open var backgroundSelectionColor:    java.awt.Color = java.awt.Color(184, 207, 229)
    open var backgroundNonSelectionColor: java.awt.Color = java.awt.Color.white
    open var textSelectionColor:          java.awt.Color = java.awt.Color.black
    open var textNonSelectionColor:       java.awt.Color = java.awt.Color.black

    public init() {
      super.init()
      setOpaque(true)
    }

    // -------------------------------------------------------------------------
    // MARK: TreeCellRenderer
    // -------------------------------------------------------------------------

    open func getTreeCellRendererComponent(
      _ tree:     javax.swing.JTree,
      _ value:    AnyObject,
      _ selected: Bool,
      _ expanded: Bool,
      _ leaf:     Bool,
      _ row:      Int,
      _ hasFocus: Bool
    ) -> java.awt.Component {

      // Label text
      let text: String
      if let dmtn = value as? DefaultMutableTreeNode {
        text = dmtn.toString()
      } else {
        text = "\(value)"
      }
      setText(text)

      // Colours
      if selected {
        setBackground(backgroundSelectionColor)
        setForeground(textSelectionColor)
      } else {
        setBackground(backgroundNonSelectionColor)
        setForeground(textNonSelectionColor)
      }

      return self
    }
  }
}
