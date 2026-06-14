/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A top-level menu entry shown in a `JMenuBar`.
  ///
  /// In the full Swing implementation `JMenu` extends `JMenuItem` and opens a
  /// `JPopupMenu` when clicked.  This stub provides only the label and the
  /// `JComponent` infrastructure needed for `BasicMenuBarUI` to paint the
  /// menu-bar titles.  `JPopupMenu` support will be added in a later step.
  ///
  @MainActor
  open class JMenu: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// The text label shown in the menu bar.
    public var text: String

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "") {
      self.text = text
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getText() -> String      { text }
    public func setText(_ t: String)     { text = t; invalidate() }
  }
}
