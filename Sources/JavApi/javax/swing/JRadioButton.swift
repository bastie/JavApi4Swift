/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A radio button — mirrors `javax.swing.JRadioButton`.
  ///
  /// Radio buttons are typically used inside a `ButtonGroup` so that selecting
  /// one deselects all others.  `JRadioButton` extends `JToggleButton` and
  /// renders as a circle with a filled dot when selected.
  ///
  /// ```swift
  /// let group = javax.swing.ButtonGroup()
  /// let rb1 = javax.swing.JRadioButton("Option A", selected: true)
  /// let rb2 = javax.swing.JRadioButton("Option B")
  /// group.add(rb1)
  /// group.add(rb2)
  /// panel.add(rb1)
  /// panel.add(rb2)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JRadioButton: javax.swing.JToggleButton {

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      updateUI()
    }

    public override init(_ text: String, _ selected: Bool = false) {
      super.init(text, selected)
      updateUI()
    }

    public override init(_ icon: javax.swing.Icon, _ selected: Bool = false) {
      super.init(icon, selected)
      updateUI()
    }

    public override init(_ text: String, _ icon: javax.swing.Icon, _ selected: Bool = false) {
      super.init(text, icon, selected)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Radio behaviour — never deselect on click
    // -------------------------------------------------------------------------

    /// Radio buttons may only be selected, never deselected by clicking.
    /// Deselection happens implicitly when another button in the same
    /// `ButtonGroup` is selected.
    override open func buttonClicked() {
      guard !isSelected() else { return }
      setSelected(true)
      fireActionPerformed()
      fireItemStateChanged(java.awt.event.ItemEvent.SELECTED)
    }
  }
}
