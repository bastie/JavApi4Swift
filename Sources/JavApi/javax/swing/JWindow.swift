/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A top-level window with no title bar or window decorations.
  ///
  /// `JWindow` is the Swing equivalent of `java.awt.Window`.  It is a
  /// lightweight top-level container that shows on screen without a title bar,
  /// close button, or resize handles.  Common uses are splash screens and
  /// custom floating palettes.
  ///
  /// ## Root pane
  ///
  /// Like all top-level Swing containers, `JWindow` owns a `JRootPane`.
  /// Add your content to the **content pane**, not to the window directly:
  ///
  /// ```swift
  /// let window = javax.swing.JWindow()
  /// window.getContentPane().add(myLabel)
  /// // or equivalently (JWindow.add delegates to the content pane):
  /// window.add(myLabel)
  /// window.setSize(300, 200)
  /// window.setVisible(true)
  /// ```
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// java.awt.Component
  ///   └── java.awt.Container
  ///         └── java.awt.Window
  ///               └── javax.swing.JWindow   ← this class
  /// ```
  ///
  @MainActor
  open class JWindow: java.awt.Window, javax.swing.RootPaneContainer {

    // -------------------------------------------------------------------------
    // MARK: Root pane
    // -------------------------------------------------------------------------

    private let rootPane: javax.swing.JRootPane = javax.swing.JRootPane()

    // -------------------------------------------------------------------------
    // MARK: Initialisierung
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      // Add the root pane as the sole direct child of this window
      super.add(rootPane)
    }

    // -------------------------------------------------------------------------
    // MARK: RootPaneContainer
    // -------------------------------------------------------------------------

    public func getRootPane() -> javax.swing.JRootPane {
      return rootPane
    }

    public func getContentPane() -> java.awt.Container {
      return rootPane.getContentPane()
    }

    public func setContentPane(_ contentPane: java.awt.Container) {
      rootPane.setContentPane(contentPane)
    }

    public func getGlassPane() -> java.awt.Component {
      return rootPane.getGlassPane()
    }

    public func setGlassPane(_ glassPane: java.awt.Component) {
      rootPane.setGlassPane(glassPane)
    }

    public func getLayeredPane() -> javax.swing.JLayeredPane {
      return rootPane.getLayeredPane()
    }

    public func setLayeredPane(_ layeredPane: javax.swing.JLayeredPane) {
      rootPane.setLayeredPane(layeredPane)
    }

    // -------------------------------------------------------------------------
    // MARK: Delegate add() to content pane
    // -------------------------------------------------------------------------

    /// Adds `comp` to the content pane (not directly to the window).
    override public func add(_ comp: java.awt.Component) {
      getContentPane().add(comp)
    }

    override public func add(_ comp: java.awt.Component, _ constraint: String) {
      getContentPane().add(comp, constraint)
    }

    override public func add(_ comp: java.awt.Component, _ constraints: AnyObject?) {
      getContentPane().add(comp, constraints)
    }

    override public func remove(_ comp: java.awt.Component) {
      getContentPane().remove(comp)
    }
  }
}
