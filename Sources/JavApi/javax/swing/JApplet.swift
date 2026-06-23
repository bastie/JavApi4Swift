/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A Swing applet container — mirrors `javax.swing.JApplet` from JFC 1.0.
  ///
  /// `JApplet` extends `java.applet.Applet` and adds Swing's root-pane
  /// architecture, making it the Swing equivalent of the AWT `Applet`.
  ///
  /// > Note: Java applets were deprecated in Java 9 and removed in Java 17.
  /// > This class exists for JFC 1.0 API completeness.  New code should use
  /// > `JPanel` or `JFrame` instead.
  ///
  /// ## Root pane hierarchy
  ///
  /// ```
  /// JApplet  (embedded in browser / applet runner)
  ///   └── JRootPane
  ///         ├── glassPane    (invisible overlay)
  ///         └── layeredPane  (JLayeredPane)
  ///               └── contentPane  (JPanel, BorderLayout)
  /// ```
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// java.awt.Component
  ///   └── java.awt.Container
  ///         └── java.awt.Panel
  ///               └── java.applet.Applet
  ///                     └── javax.swing.JApplet   ← this class
  /// ```
  ///
  /// - Since: JFC 1.0 / Java 1.2
  @MainActor
  open class JApplet: java.applet.Applet, javax.swing.RootPaneContainer {

    // -------------------------------------------------------------------------
    // MARK: Root pane
    // -------------------------------------------------------------------------

    private var rootPane: javax.swing.JRootPane = javax.swing.JRootPane()
    /// Set to `true` once `init` has finished wiring up the root pane, so
    /// that `setLayout` and `add` overrides can safely delegate to the
    /// content pane instead of the applet itself.
    private var rootPaneReady: Bool = false

    public override init() {
      super.init()
      super.setLayout(java.awt.BorderLayout())
      super.add(rootPane, java.awt.BorderLayout.CENTER)
      rootPaneReady = true
    }

    // -------------------------------------------------------------------------
    // MARK: RootPaneContainer
    // -------------------------------------------------------------------------

    public func getRootPane() -> javax.swing.JRootPane { rootPane }

    public func getContentPane() -> java.awt.Container {
      rootPane.getContentPane()
    }

    public func setContentPane(_ contentPane: java.awt.Container) {
      rootPane.setContentPane(contentPane)
    }

    public func getLayeredPane() -> javax.swing.JLayeredPane {
      rootPane.getLayeredPane()
    }

    public func setLayeredPane(_ layeredPane: javax.swing.JLayeredPane) {
      rootPane.setLayeredPane(layeredPane)
    }

    public func getGlassPane() -> java.awt.Component {
      rootPane.getGlassPane()
    }

    public func setGlassPane(_ glassPane: java.awt.Component) {
      rootPane.setGlassPane(glassPane)
    }

    // -------------------------------------------------------------------------
    // MARK: JMenuBar
    // -------------------------------------------------------------------------

    /// Sets the menu bar for this applet.
    public func setJMenuBar(_ menuBar: javax.swing.JMenuBar?) {
      rootPane.setMenuBar(menuBar)
    }

    /// Returns the menu bar set on this applet, or `nil`.
    public func getJMenuBar() -> javax.swing.JMenuBar? {
      rootPane.getMenuBar()
    }

    // -------------------------------------------------------------------------
    // MARK: Root pane replacement
    // -------------------------------------------------------------------------

    /// Replaces the root pane.  Rarely needed; provided for API completeness.
    public func setRootPane(_ rp: javax.swing.JRootPane) {
      if rootPaneReady {
        super.remove(rootPane)
      }
      super.add(rp, java.awt.BorderLayout.CENTER)
    }

    // -------------------------------------------------------------------------
    // MARK: Container overrides — delegate to content pane
    // -------------------------------------------------------------------------

    /// Adds `comp` to the content pane (not directly to the applet).
    override open func add(_ comp: java.awt.Component) {
      getContentPane().add(comp)
    }

    override open func add(_ comp: java.awt.Component, _ constraints: String) {
      getContentPane().add(comp, constraints)
    }

    override open func setLayout(_ mgr: java.awt.LayoutManager?) {
      // Before rootPane is wired up the super call installs the initial
      // BorderLayout; afterwards delegate to the content pane.
      if rootPaneReady {
        getContentPane().setLayout(mgr)
      } else {
        super.setLayout(mgr)
      }
    }
  }
}
