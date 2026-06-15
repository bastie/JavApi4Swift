/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A toolbar that groups action buttons and separators in a row.
  ///
  /// `JToolBar` is a `JComponent` that lays its children left-to-right
  /// (horizontal orientation, the default) or top-to-bottom (vertical).
  /// It is normally placed in `BorderLayout.NORTH` of a frame's content pane.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let toolbar = javax.swing.JToolBar()
  /// toolbar.add(javax.swing.JButton("New"))
  /// toolbar.addSeparator()
  /// toolbar.add(javax.swing.JButton("Open"))
  /// frame.add(toolbar, java.awt.BorderLayout.NORTH)
  /// ```
  ///
  /// ## Java API orientation constants
  ///
  /// | Constant | Value |
  /// |---|---|
  /// | `HORIZONTAL` | 0 (from `SwingConstants`) |
  /// | `VERTICAL`   | 1 (from `SwingConstants`) |
  ///
  @MainActor
  open class JToolBar: javax.swing.JComponent, javax.swing.SwingConstants {

    // -------------------------------------------------------------------------
    // MARK: Orientation
    // -------------------------------------------------------------------------

    /// The toolbar's orientation: `JToolBar.HORIZONTAL` or `JToolBar.VERTICAL`.
    private var _orientation: Int = JToolBar.HORIZONTAL

    public func getOrientation() -> Int { _orientation }
    public func setOrientation(_ orientation: Int) {
      _orientation = orientation
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Floatable / Rollover
    // -------------------------------------------------------------------------

    /// Whether the toolbar can be dragged out of its container.
    ///
    /// - TODO: Implement `BasicToolBarUI` with `MouseMotionListener` drag-tracking,
    ///   undecorared `JDialog` as floating window, and BorderLayout docking zones.
    ///   Until then floatable is stored but has no visual effect.
    private var _floatable: Bool = true
    public func isFloatable() -> Bool { _floatable }
    public func setFloatable(_ b: Bool) { _floatable = b }

    /// Whether rollover highlighting is enabled.
    private var _rollover: Bool = false
    public func isRollover() -> Bool { _rollover }
    public func setRollover(_ b: Bool) { _rollover = b }

    // -------------------------------------------------------------------------
    // MARK: Children
    // -------------------------------------------------------------------------

    /// All toolbar items in insertion order (buttons and separators).
    private var items: [java.awt.Component] = []

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      setOpaque(true)
      updateUI()
    }

    public init(_ orientation: Int) {
      super.init()
      _orientation = orientation
      setOpaque(true)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func updateUI() {
      super.updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Adding components
    // -------------------------------------------------------------------------

    /// Appends `button` to the toolbar and returns it.
    @discardableResult
    public func add(_ button: javax.swing.JButton) -> javax.swing.JButton {
      items.append(button)
      button.parent = self
      invalidate()
      return button
    }

    /// Appends any component to the toolbar.
    @discardableResult
    public func add(_ comp: java.awt.Component) -> java.awt.Component {
      items.append(comp)
      comp.parent = self
      invalidate()
      return comp
    }

    /// Appends a vertical `JSeparator` of default size (8 px wide).
    public func addSeparator() {
      addSeparator(java.awt.Dimension(8, 8))
    }

    /// Appends a vertical `JSeparator` whose preferred size matches `size`.
    public func addSeparator(_ size: java.awt.Dimension) {
      let sep = javax.swing.JSeparator(javax.swing.JSeparator.VERTICAL)
      sep.setPreferredSize(size)
      items.append(sep)
      sep.parent = self
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Item access
    // -------------------------------------------------------------------------

    public func getComponentAtIndex(_ index: Int) -> java.awt.Component? {
      guard index >= 0 && index < items.count else { return nil }
      return items[index]
    }

    public func getComponentIndex(_ comp: java.awt.Component) -> Int {
      items.firstIndex { $0 === comp } ?? -1
    }

    public override func getComponentCount() -> Int { items.count }

    /// Returns all items (for the UI delegate).
    public func getItems() -> [java.awt.Component] { items }

    /// Overrides `Container.getComponents()` so the AWT hit-test walker
    /// can find toolbar children (they are stored in `items`, not `children`).
    public override func getComponents() -> [java.awt.Component] { items }

    // -------------------------------------------------------------------------
    // MARK: Layout & preferred size
    // -------------------------------------------------------------------------

    override public func getPreferredSize() -> java.awt.Dimension {
      let pad = 4
      var totalW = pad, totalH = 0, maxH = 0, maxW = 0
      for item in items {
        let ps = item.getPreferredSize()
        if _orientation == JToolBar.HORIZONTAL {
          totalW += ps.width + pad
          maxH = Swift.max(maxH, ps.height)
        } else {
          totalH += ps.height + pad
          maxW = Swift.max(maxW, ps.width)
        }
      }
      if _orientation == JToolBar.HORIZONTAL {
        return java.awt.Dimension(totalW, maxH + pad * 2)
      } else {
        return java.awt.Dimension(maxW + pad * 2, totalH)
      }
    }

    override public func doLayout() {
      let pad = 4
      if _orientation == JToolBar.HORIZONTAL {
        var x = pad
        let y = pad
        let h = bounds.height - pad * 2
        for item in items {
          let w = item.getPreferredSize().width
          item.bounds = java.awt.Rectangle(x, y, w, Swift.max(h, 1))
          x += w + pad
        }
      } else {
        let x = pad
        var y = pad
        let w = bounds.width - pad * 2
        for item in items {
          let h = item.getPreferredSize().height
          item.bounds = java.awt.Rectangle(x, y, Swift.max(w, 1), h)
          y += h + pad
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      // Background
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(0, 0, bounds.width, bounds.height)

      // Bottom border line (when horizontal)
      if _orientation == JToolBar.HORIZONTAL {
        g.setColor(java.awt.SystemColor.controlShadow)
        g.drawLine(0, bounds.height - 1, bounds.width - 1, bounds.height - 1)
      }

      doLayout()

      // Paint children
      for item in items {
        guard item.isVisible() else { continue }
        let dx = item.bounds.x
        let dy = item.bounds.y
        g.translate(dx, dy)
        item.paint(g)
        g.translate(-dx, -dy)
      }
    }
  }
}

