/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A small popup that displays a short description when the mouse hovers
  /// over a component — mirrors `javax.swing.JToolTip`.
  ///
  /// In Java Swing the tooltip is normally shown automatically by the
  /// `ToolTipManager` singleton when `setToolTipText(_:)` is called on any
  /// `JComponent`.  In JavApi⁴Swift the tooltip text is stored in
  /// `JComponent` and `JToolTip` represents the visual popup widget itself.
  ///
  /// ## Usage (attaching to a component)
  ///
  /// ```swift
  /// button.setToolTipText("Click to open a file")
  /// ```
  ///
  /// ## Usage (constructing manually)
  ///
  /// ```swift
  /// let tip = javax.swing.JToolTip()
  /// tip.setTipText("Saves the current document")
  /// tip.setComponent(saveButton)
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class JToolTip: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _tipText: String? = nil
    private weak var _component: javax.swing.JComponent? = nil

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      setOpaque(true)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Tip text
    // -------------------------------------------------------------------------

    /// Returns the tooltip text displayed in this popup.
    public func getTipText() -> String? { _tipText }

    /// Sets the tooltip text displayed in this popup.
    public func setTipText(_ text: String?) {
      _tipText = text
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Associated component
    // -------------------------------------------------------------------------

    /// Returns the component this tooltip is associated with, or `nil`.
    public func getComponent() -> javax.swing.JComponent? { _component }

    /// Associates this tooltip with a component.
    ///
    /// Setting the component also copies its `toolTipText` into this instance
    /// if no explicit tip text has been set yet.
    public func setComponent(_ component: javax.swing.JComponent?) {
      _component = component
      if _tipText == nil {
        _tipText = component?.getToolTipText()
      }
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "ToolTipUI" }

    override open func updateUI() {
      setUI(javax.swing.UIManager.getUI(self) ?? javax.swing.plaf.basic.BasicToolTipUI())
    }
  }
}
