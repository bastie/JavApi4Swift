/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A check box — mirrors `javax.swing.JCheckBox`.
  ///
  /// Clicking toggles the selected state and draws a check mark (✓) when
  /// selected.  `JCheckBox` extends `JToggleButton` and inherits its toggle
  /// behaviour.
  ///
  /// ```swift
  /// let cb = javax.swing.JCheckBox("Enable notifications", selected: true)
  /// cb.addItemListener(myListener)
  /// panel.add(cb)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JCheckBox: javax.swing.JToggleButton {

    override open func getUIClassID() -> String { "CheckBoxUI" }

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
  }
}
