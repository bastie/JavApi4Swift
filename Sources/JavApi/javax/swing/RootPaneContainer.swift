/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Interface implemented by top-level Swing containers that own a `JRootPane`.
  ///
  /// `JWindow`, `JFrame`, `JDialog`, and `JApplet` all implement this protocol.
  /// It provides a uniform API for accessing the root pane and its layers —
  /// regardless of whether the container is a frame, dialog, or bare window.
  ///
  /// ## Root pane hierarchy
  ///
  /// ```
  /// RootPaneContainer
  ///   └── rootPane        (JRootPane)
  ///         ├── contentPane  (JComponent — typically JPanel with BorderLayout)
  ///         ├── glassPane    (JComponent — invisible overlay)
  ///         └── layeredPane  (JLayeredPane)
  /// ```
  ///
  /// Always add your widgets to the **content pane**, not to the container itself:
  ///
  /// ```swift
  /// let frame = javax.swing.JFrame("Hello")
  /// frame.getContentPane().add(myButton)
  /// // or, since Java 1.5:
  /// frame.add(myButton)   // JFrame delegates add() to the content pane
  /// ```
  ///
  @MainActor
  public protocol RootPaneContainer: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Root pane
    // -------------------------------------------------------------------------

    /// The root pane owned by this container.
    func getRootPane() -> javax.swing.JRootPane

    // -------------------------------------------------------------------------
    // MARK: Content pane
    // -------------------------------------------------------------------------

    /// The content pane — the primary container for the application's widgets.
    ///
    /// The default content pane is a `JPanel` with a `BorderLayout`.
    func getContentPane() -> java.awt.Container
    func setContentPane(_ contentPane: java.awt.Container)

    // -------------------------------------------------------------------------
    // MARK: Glass pane
    // -------------------------------------------------------------------------

    /// The glass pane — an invisible `JComponent` that sits above all other
    /// layers.  Make it visible to intercept mouse events or paint overlays.
    func getGlassPane() -> java.awt.Component
    func setGlassPane(_ glassPane: java.awt.Component)

    // -------------------------------------------------------------------------
    // MARK: Layered pane
    // -------------------------------------------------------------------------

    /// The layered pane — manages Z-ordering of content pane, menu bar, and
    /// pop-up windows within the root pane.
    func getLayeredPane() -> javax.swing.JLayeredPane
    func setLayeredPane(_ layeredPane: javax.swing.JLayeredPane)
  }
}
