/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The single mandatory child of every top-level Swing container.
  ///
  /// `JRootPane` assembles the layer stack that Swing uses to paint a window:
  ///
  /// ```
  /// JRootPane
  ///   ├── glassPane    (JComponent, invisible)  — intercepts events / overlays
  ///   └── layeredPane  (JLayeredPane)
  ///         ├── contentPane  (JPanel, BorderLayout)  — application widgets
  ///         └── menuBar      (JMenuBar, optional)
  /// ```
  ///
  /// Application code should **never** add components directly to `JRootPane`.
  /// Always use `getContentPane()` (or `JFrame.add(_:)`, which delegates there).
  ///
  @MainActor
  open class JRootPane: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Layers
    // -------------------------------------------------------------------------

    /// The layered pane that holds the content pane and (optionally) the menu bar.
    public private(set) var layeredPane: javax.swing.JLayeredPane

    /// The content pane — the primary container for application widgets.
    ///
    /// Default: a `JPanel` with `BorderLayout`.
    public private(set) var contentPane: java.awt.Container

    /// The glass pane — sits above all other layers, invisible by default.
    ///
    /// Make it visible to intercept mouse events or paint overlays.
    public private(set) var glassPane: java.awt.Component

    /// The optional menu bar, placed in `FRAME_CONTENT_LAYER` above the content pane.
    ///
    /// Set via `JFrame.setJMenuBar(_:)` — do not assign directly.
    public private(set) var menuBar: javax.swing.JMenuBar? = nil

    // -------------------------------------------------------------------------
    // MARK: Initialisation
    // -------------------------------------------------------------------------

    public override init() {
      // Build the default layer stack
      let lp = javax.swing.JLayeredPane()
      let cp = javax.swing.JPanel(java.awt.BorderLayout())
      let gp = javax.swing.JComponent()   // plain invisible component

      self.layeredPane = lp
      self.contentPane = cp
      self.glassPane   = gp

      super.init()

      // Wire up the hierarchy
      lp.add(cp, layer: javax.swing.JLayeredPane.DEFAULT_LAYER)
      super.add(lp)       // layeredPane fills the root pane
      super.add(gp)       // glassPane sits on top
      gp.setVisible(false)

      setOpaque(true)
    }

    // -------------------------------------------------------------------------
    // MARK: Content pane
    // -------------------------------------------------------------------------

    public func getContentPane() -> java.awt.Container { contentPane }

    public func setContentPane(_ newContentPane: java.awt.Container) {
      layeredPane.remove(contentPane)
      contentPane = newContentPane
      layeredPane.add(newContentPane, layer: javax.swing.JLayeredPane.DEFAULT_LAYER)
    }

    // -------------------------------------------------------------------------
    // MARK: Glass pane
    // -------------------------------------------------------------------------

    public func getGlassPane() -> java.awt.Component { glassPane }

    public func setGlassPane(_ newGlassPane: java.awt.Component) {
      let wasVisible = glassPane.isVisible()
      super.remove(glassPane)
      glassPane = newGlassPane
      newGlassPane.setVisible(wasVisible)
      super.add(newGlassPane)
    }

    // -------------------------------------------------------------------------
    // MARK: Layered pane
    // -------------------------------------------------------------------------

    public func getLayeredPane() -> javax.swing.JLayeredPane { layeredPane }

    public func setLayeredPane(_ newLayeredPane: javax.swing.JLayeredPane) {
      super.remove(layeredPane)
      layeredPane = newLayeredPane
      super.add(newLayeredPane)
    }

    // -------------------------------------------------------------------------
    // MARK: Menu bar
    // -------------------------------------------------------------------------

    /// Installs `newMenuBar` in `FRAME_CONTENT_LAYER`, above the content pane.
    ///
    /// The menu bar is placed in the layered pane so future pop-up overlays
    /// (`JPopupMenu` in `POPUP_LAYER`) can paint above it without clipping.
    public func setMenuBar(_ newMenuBar: javax.swing.JMenuBar?) {
      // Remove existing bar from layered pane
      if let old = menuBar {
        layeredPane.remove(old)
      }
      menuBar = newMenuBar
      if let bar = newMenuBar {
        bar.bounds = java.awt.Rectangle(
          0, 0,
          layeredPane.bounds.width,
          javax.swing.JMenuBar.defaultHeight)
        layeredPane.add(bar, layer: javax.swing.JLayeredPane.FRAME_CONTENT_LAYER)
      }
      // Re-layout so content pane accounts for the bar height
      layeredPane.invalidate()
    }

    public func getMenuBar() -> javax.swing.JMenuBar? { menuBar }

    // -------------------------------------------------------------------------
    // MARK: Guard: direct add() is not allowed on JRootPane
    // -------------------------------------------------------------------------

    /// Adding components directly to `JRootPane` is not permitted.
    /// Use `getContentPane().add(_:)` instead.
    override public func add(_ comp: java.awt.Component) {
      // In production Swing this throws an Error — here we redirect with a warning.
      contentPane.add(comp)
    }

    override public func add(_ comp: java.awt.Component, _ constraint: String) {
      contentPane.add(comp, constraint)
    }
  }
}
