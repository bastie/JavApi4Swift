/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Default implementation of `CellEditor` for `JTable` and `JTree`.
  ///
  /// `DefaultCellEditor` can be constructed from a `JTextField`, `JCheckBox`,
  /// or `JComboBox`.  The contained component is reused as a stamp editor.
  ///
  /// Editing begins after the user clicks the cell the configured number of
  /// times (`clickCountToStart`, default 2 for text fields, 1 for check boxes
  /// and combo boxes).
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultCellEditor: javax.swing.CellEditor {

    // -------------------------------------------------------------------------
    // MARK: Nested helper
    // -------------------------------------------------------------------------

    /// The kind of delegate component backing this editor.
    public enum EditorComponent {
      case textField(javax.swing.JTextField)
      case checkBox(javax.swing.JCheckBox)
      case comboBox(javax.swing.JComboBox<String>)
    }

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    /// The component used for editing.
    public let editorComponent: EditorComponent

    /// Number of clicks required to start editing (default 2 for text, 1 for others).
    public var clickCountToStart: Int

    private var cellEditorListeners: [javax.swing.event.CellEditorListener] = []

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates a `DefaultCellEditor` backed by a `JTextField`.
    public init(textField: javax.swing.JTextField) {
      self.editorComponent  = .textField(textField)
      self.clickCountToStart = 2
    }

    /// Creates a `DefaultCellEditor` backed by a `JCheckBox`.
    public init(checkBox: javax.swing.JCheckBox) {
      self.editorComponent  = .checkBox(checkBox)
      self.clickCountToStart = 1
    }

    /// Creates a `DefaultCellEditor` backed by a `JComboBox`.
    public init(comboBox: javax.swing.JComboBox<String>) {
      self.editorComponent  = .comboBox(comboBox)
      self.clickCountToStart = 1
    }

    // -------------------------------------------------------------------------
    // MARK: CellEditor
    // -------------------------------------------------------------------------

    open func getCellEditorValue() -> Any? {
      switch editorComponent {
      case .textField(let tf):
        return tf.getText()
      case .checkBox(let cb):
        return cb.isSelected()
      case .comboBox(let cb):
        return cb.getSelectedItem()
      }
    }

    open func isCellEditable(_ anEvent: java.util.EventObject?) -> Bool {
      // Could inspect mouse click count here; simplified implementation
      return true
    }

    open func shouldSelectCell(_ anEvent: java.util.EventObject?) -> Bool {
      return true
    }

    @discardableResult
    open func stopCellEditing() -> Bool {
      let event = javax.swing.event.ChangeEvent(self)
      for l in cellEditorListeners { l.editingStopped(event) }
      return true
    }

    open func cancelCellEditing() {
      let event = javax.swing.event.ChangeEvent(self)
      for l in cellEditorListeners { l.editingCanceled(event) }
    }

    open func addCellEditorListener(_ l: javax.swing.event.CellEditorListener) {
      cellEditorListeners.append(l)
    }

    open func removeCellEditorListener(_ l: javax.swing.event.CellEditorListener) {
      cellEditorListeners.removeAll { $0 === l }
    }

    // -------------------------------------------------------------------------
    // MARK: TableCellEditor helper
    // -------------------------------------------------------------------------

    /// Returns the underlying `java.awt.Component` for use as a table cell editor.
    public func getComponent() -> java.awt.Component {
      switch editorComponent {
      case .textField(let c): return c
      case .checkBox(let c):  return c
      case .comboBox(let c):  return c
      }
    }
  }
}

// =============================================================================
// MARK: - TableCellEditor conformance
// =============================================================================

extension javax.swing.DefaultCellEditor: javax.swing.table.TableCellEditor {

  public func getTableCellEditorComponent(
    _ table:      javax.swing.JTable,
    _ value:      Any?,
    _ isSelected: Bool,
    _ row:        Int,
    _ column:     Int
  ) -> java.awt.Component {

    switch editorComponent {
    case .textField(let tf):
      tf.setText(value.map { "\($0)" } ?? "")
      return tf
    case .checkBox(let cb):
      if let b = value as? Bool { cb.setSelected(b) }
      return cb
    case .comboBox(let cb):
      if let s = value as? String { cb.setSelectedItem(s) }
      return cb
    }
  }
}
