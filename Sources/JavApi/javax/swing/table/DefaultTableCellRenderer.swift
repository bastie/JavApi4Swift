/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// The default renderer for JTable cells.
  ///
  /// Returns a configured `JLabel` as a stamp — never added to the component
  /// hierarchy.  The label text is the cell value's `String` representation.
  ///
  /// Custom renderers should implement `TableCellRenderer` directly and may
  /// return any `Component`, including `JPanel` composites.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultTableCellRenderer: javax.swing.JLabel,
                                       javax.swing.table.TableCellRenderer {

    // Selection / alternate-row colours
    open var selectionBackground:    java.awt.Color = java.awt.Color(184, 207, 229)
    open var selectionForeground:    java.awt.Color = java.awt.Color.black
    open var cellBackground:         java.awt.Color = java.awt.Color.white
    open var alternateRowBackground: java.awt.Color = java.awt.Color(245, 245, 245)
    open var cellForeground:         java.awt.Color = java.awt.Color.black

    public init() {
      super.init()
      setOpaque(true)
    }

    // -------------------------------------------------------------------------
    // MARK: TableCellRenderer
    // -------------------------------------------------------------------------

    open func getTableCellRendererComponent(
      _ table:      javax.swing.JTable,
      _ value:      Any?,
      _ isSelected: Bool,
      _ hasFocus:   Bool,
      _ row:        Int,
      _ column:     Int
    ) -> java.awt.Component {

      // Text
      if let v = value {
        setText("\(v)")
      } else {
        setText("")
      }

      // Colours
      if isSelected {
        setBackground(selectionBackground)
        setForeground(selectionForeground)
      } else {
        setBackground(row % 2 == 0 ? cellBackground : alternateRowBackground)
        setForeground(cellForeground)
      }

      return self
    }
  }
}
