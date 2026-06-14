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

    /// Installs a new UI delegate, uninstalling the previous one first.
    public func setUI(_ newUI: javax.swing.plaf.ComponentUI) {
      ui?.uninstallUI(self)
      ui = newUI
      newUI.installUI(self)
      invalidate()
    }

    /// Fetches and installs the UI delegate for this component from `UIManager`.
    ///
    /// Subclasses must override this and call `setUI(UIManager.getUI(self))`.
    /// The base implementation is a no-op (no delegate is installed).
    open func updateUI() {}

    // -------------------------------------------------------------------------
    // MARK: Opacity
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
    public func getForeground() -> java.awt.Color { foreground }

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
        ui.update(g, on: self)
      }
      paintComponent(g)
      paintChildren(g)
    }

    /// Paints all visible child components.
    open func paintChildren(_ g: java.awt.Graphics) {
      for child in children where child.visible {
        child.paint(g)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Size hints (delegate to UI)
    // -------------------------------------------------------------------------

    override open func getPreferredSize() -> java.awt.Dimension {
      if let d = ui?.getPreferredSize(of: self) { return d }
      return super.getPreferredSize()
    }

    override open func getMinimumSize() -> java.awt.Dimension {
      if let d = ui?.getMinimumSize(of: self) { return d }
      return super.getMinimumSize()
    }

    override open func getMaximumSize() -> java.awt.Dimension {
      if let d = ui?.getMaximumSize(of: self) { return d }
      return super.getMaximumSize()
    }
  }
}
