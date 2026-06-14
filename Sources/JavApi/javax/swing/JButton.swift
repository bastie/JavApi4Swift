/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A push button with a text label.
  ///
  /// `JButton` is the standard Swing push button.  Clicking it fires all
  /// registered `ActionListener` closures.  The visual appearance is delegated
  /// to `BasicButtonUI`.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let btn = javax.swing.JButton("OK")
  /// btn.addActionListener { _ in dialog.setVisible(false) }
  /// panel.add(btn)
  /// ```
  ///
  @MainActor
  open class JButton: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var text: String
    /// `true` while the mouse button is held down over this button.
    internal var isPressed: Bool = false
    /// `true` while the mouse cursor is over this button.
    internal var isRollover: Bool = false

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "") {
      self.text = text
      super.init()
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func updateUI() {
      setUI(javax.swing.plaf.basic.BasicButtonUI())
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getText() -> String         { text }
    public func setText(_ t: String)        { text = t; invalidate() }

    // -------------------------------------------------------------------------
    // MARK: Mouse state tracking
    // -------------------------------------------------------------------------

    override open func processMouseEvent(_ e: java.awt.event.MouseEvent) {
      switch e.getID() {
      case java.awt.event.MouseEvent.MOUSE_PRESSED:
        isPressed = true
        repaint()
      case java.awt.event.MouseEvent.MOUSE_RELEASED:
        isPressed = false
        repaint()
      case java.awt.event.MouseEvent.MOUSE_ENTERED:
        isRollover = true
        repaint()
      case java.awt.event.MouseEvent.MOUSE_EXITED:
        isRollover = false
        repaint()
      default: break
      }
      super.processMouseEvent(e)
    }

    // -------------------------------------------------------------------------
    // MARK: ActionListener
    // -------------------------------------------------------------------------

    private var actionListeners: [(java.awt.event.ActionEvent) -> Void] = []

    public func addActionListener(_ listener: @escaping (java.awt.event.ActionEvent) -> Void) {
      actionListeners.append(listener)
    }

    public func removeActionListeners() {
      actionListeners.removeAll()
    }

    /// Programmatically fires an `ACTION_PERFORMED` event.
    public func doClick() {
      let event = java.awt.event.ActionEvent(self, java.awt.event.ActionEvent.ACTION_PERFORMED, text)
      for listener in actionListeners { listener(event) }
    }
  }
}
