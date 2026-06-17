/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Base class for all Swing components.
  ///
  /// `JComponent` extends `java.awt.Container` and adds the Swing-specific
  /// infrastructure that every lightweight component needs:
  ///
  /// - A **UI delegate** (`ComponentUI`) that paints the component and handles
  ///   input on behalf of the active Look & Feel.
  /// - An **opacity** flag — opaque components fill their entire bounds before
  ///   `paintComponent` is called; non-opaque components allow the parent to
  ///   show through.
  /// - A **border** (stub — `Border` not yet implemented).
  /// - `paintComponent(_:)` — the hook subclasses override for custom drawing,
  ///   called by the L&F delegate's `update(_:on:)`.
  ///
  /// ## Paint call chain
  ///
  /// ```
  /// JComponent.paint(g)           ← called by AWT repaint machinery
  ///   └── ui.update(g, self)      ← ComponentUI fills background if opaque
  ///         └── ui.paint(g, self) ← ComponentUI draws the widget
  ///   └── paintComponent(g)       ← subclass hook (custom drawing)
  ///   └── paintChildren(g)        ← paints child components
  /// ```
  ///
  @MainActor
  open class JComponent: java.awt.Container {

    // -------------------------------------------------------------------------
    // MARK: UI Delegate
    // -------------------------------------------------------------------------

    /// The Look & Feel delegate responsible for painting this component.
    ///
    /// Set by `updateUI()`.  Subclasses call `setUI(_:)` from their own
    /// `updateUI()` implementation after fetching the delegate from `UIManager`.
    public override init() {
      super.init()
    }

    public var ui: javax.swing.plaf.ComponentUI? = nil

    /// Returns the current UI delegate.
    public func getUI() -> javax.swing.plaf.ComponentUI? { ui }

    /// Installs a new UI delegate, uninstalling the previous one first.
    public func setUI(_ newUI: javax.swing.plaf.ComponentUI) {
      ui?.uninstallUI(self)
      ui = newUI
      newUI.installUI(self)
      invalidate()
    }

    /// Returns the UIDefaults key used to look up the UI delegate class.
    /// Subclasses override this to return e.g. `"ButtonUI"`, `"ListUI"`, etc.
    open func getUIClassID() -> String { "ComponentUI" }

    /// Fetches and installs the UI delegate for this component from `UIManager`.
    ///
    /// Subclasses may override this; the base implementation asks `UIManager`
    /// for the appropriate delegate and installs it if found.
    open func updateUI() {
      if let newUI = javax.swing.UIManager.getUI(self) {
        setUI(newUI)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Opacity
    // -------------------------------------------------------------------------

    // -------------------------------------------------------------------------
    // MARK: Tooltip
    // -------------------------------------------------------------------------

    private var _toolTipText: String? = nil

    /// Sets the tooltip text shown when the mouse hovers over this component.
    ///
    /// - Note: Rendering support depends on the platform canvas.  The text is
    ///   stored here so it is available when the canvas layer adds hover support.
    public func setToolTipText(_ text: String?) { _toolTipText = text }

    /// Returns the tooltip text, or `nil` if none is set.
    public func getToolTipText() -> String? { _toolTipText }

    // -------------------------------------------------------------------------
    // MARK: Opaque
    // -------------------------------------------------------------------------

    private var _opaque: Bool = false

    /// Whether this component fills its entire bounds before painting.
    ///
    /// When `true`, the L&F delegate fills the background with
    /// `getBackground()` in `ComponentUI.update(_:on:)`.
    /// When `false`, the parent's background shows through.
    public func isOpaque() -> Bool { _opaque }
    public func setOpaque(_ opaque: Bool) { _opaque = opaque }

    // -------------------------------------------------------------------------
    // MARK: Background / Foreground  (delegates to AWT Component)
    // -------------------------------------------------------------------------

    public func getBackground() -> java.awt.Color { background }
    public func setBackground(_ color: java.awt.Color) { background = color }

    public func getForeground() -> java.awt.Color { foreground }
    public func setForeground(_ color: java.awt.Color) { foreground = color }

    // -------------------------------------------------------------------------
    // MARK: Paint hook
    // -------------------------------------------------------------------------

    /// Override this method to draw custom content.
    ///
    /// Called after the L&F delegate has filled the background (if opaque).
    /// The graphics context's clip is already set to this component's bounds.
    open func paintComponent(_ g: java.awt.Graphics) {}

    /// Paints this component: background via the L&F delegate, then the
    /// subclass hook, then all children.
    override open func paint(_ g: java.awt.Graphics) {
      if let ui {
        ui.update(g, self)
      } else if isOpaque() {
        // No UI delegate but opaque — fill background directly.
        g.setColor(background)
        g.fillRect(0, 0, bounds.width, bounds.height)
      }
      paintComponent(g)
      paintChildren(g)
    }

    /// Paints all visible child components, translating the graphics context
    /// to each child's origin so the child can paint at (0,0).
    open func paintChildren(_ g: java.awt.Graphics) {
      for child in children where child.visible {
        let dx = child.bounds.x
        let dy = child.bounds.y
        g.save()
        g.clipRect(dx, dy, child.bounds.width, child.bounds.height)
        g.translate(dx, dy)
        child.paint(g)
        g.restore()
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Size hints (delegate to UI)
    // -------------------------------------------------------------------------

    override open func getPreferredSize() -> java.awt.Dimension {
      if let d = ui?.getPreferredSize(_ : self) { return d }
      return super.getPreferredSize()
    }

    override open func getMinimumSize() -> java.awt.Dimension {
      if let d = ui?.getMinimumSize(_ : self) { return d }
      return super.getMinimumSize()
    }

    override open func getMaximumSize() -> java.awt.Dimension {
      if let d = ui?.getMaximumSize(_ : self) { return d }
      return super.getMaximumSize()
    }
  }
}
