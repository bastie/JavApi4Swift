/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Groups a set of buttons so that at most one is selected at a time —
  /// mirrors `javax.swing.ButtonGroup`.
  ///
  /// Typically used with `JRadioButton`, but works with any `AbstractButton`.
  /// When one button in the group is selected, `ButtonGroup` deselects all
  /// others automatically via an `ItemListener`.
  ///
  /// ```swift
  /// let group = javax.swing.ButtonGroup()
  /// group.add(rb1)
  /// group.add(rb2)
  /// group.add(rb3)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  public class ButtonGroup {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var buttons: [javax.swing.AbstractButton] = []

    /// The currently selected button model, or `nil` if none is selected.
    private weak var _selection: javax.swing.AbstractButton? = nil

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Manage buttons
    // -------------------------------------------------------------------------

    public func add(_ button: javax.swing.AbstractButton) {
      buttons.append(button)
      let listener = _GroupItemListener(group: self, button: button)
      button.addItemListener(listener)
      // If this button is already selected, make it the group selection
      if button.isSelected() {
        if _selection == nil {
          _selection = button
        } else {
          // Another button is already selected — deselect this one
          button.setSelected(false)
        }
      }
    }

    public func remove(_ button: javax.swing.AbstractButton) {
      buttons.removeAll { $0 === button }
      if _selection === button { _selection = nil }
    }

    public func getElements() -> [javax.swing.AbstractButton] { buttons }

    public func getSelection() -> javax.swing.ButtonModel? {
      _selection?.getModel()
    }

    public func isSelected(_ model: javax.swing.ButtonModel) -> Bool {
      _selection?.getModel() === model
    }

    public func setSelected(_ model: javax.swing.ButtonModel, _ selected: Bool) {
      if selected {
        // Deselect all others
        for btn in buttons {
          if btn.getModel() !== model {
            btn.setSelected(false)
          }
        }
        _selection = buttons.first { $0.getModel() === model }
      } else {
        if _selection?.getModel() === model { _selection = nil }
      }
    }

    public func getButtonCount() -> Int { buttons.count }
    public func clearSelection() {
      buttons.forEach { $0.setSelected(false) }
      _selection = nil
    }

    // -------------------------------------------------------------------------
    // MARK: Internal — ItemListener installed on each button
    // -------------------------------------------------------------------------

    private class _GroupItemListener: java.awt.event.ItemListener {
      weak var group: ButtonGroup?
      weak var button: javax.swing.AbstractButton?

      init(group: ButtonGroup, button: javax.swing.AbstractButton) {
        self.group  = group
        self.button = button
      }

      func itemStateChanged(_ e: java.awt.event.ItemEvent) {
        guard let group = group, let button = button else { return }
        if e.getStateChange() == java.awt.event.ItemEvent.SELECTED {
          group.setSelected(button.getModel(), true)
        }
      }
    }
  }
}
