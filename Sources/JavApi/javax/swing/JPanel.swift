/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A generic lightweight container.
  ///
  /// `JPanel` is the standard general-purpose Swing container.  It is used as
  /// the default content pane in `JRootPane` and as a grouping container
  /// wherever components need their own layout manager.
  ///
  /// The default layout manager is `FlowLayout`.
  ///
  /// ```swift
  /// let panel = javax.swing.JPanel(java.awt.BorderLayout())
  /// panel.add(myButton, java.awt.BorderLayout.SOUTH)
  /// ```
  @MainActor
  open class JPanel: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Initialisierung
    // -------------------------------------------------------------------------

    /// Creates a panel with the given layout manager.
    public init(_ layout: java.awt.LayoutManager? = java.awt.FlowLayout()) {
      super.init()
      setLayout(layout)
      setOpaque(true)
    }
  }
}
