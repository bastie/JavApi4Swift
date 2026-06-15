/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A scrollable container — mirrors `javax.swing.JScrollPane`.
  ///
  /// `JScrollPane` wraps any component in a `JViewport` and adds
  /// horizontal / vertical `JScrollBar`s as needed.  The scroll bars
  /// are kept in sync with the viewport's `viewPosition`.
  ///
  /// ```swift
  /// let table = javax.swing.JTable(myModel)
  /// let scroll = javax.swing.JScrollPane(table)
  /// frame.add(scroll, java.awt.BorderLayout.CENTER)
  /// ```
  ///
  /// ### Scrollbar policies
  /// | Constant | Meaning |
  /// |---|---|
  /// | `VERTICAL_SCROLLBAR_AS_NEEDED` | Show only when content is taller than viewport |
  /// | `VERTICAL_SCROLLBAR_ALWAYS` | Always show |
  /// | `VERTICAL_SCROLLBAR_NEVER` | Never show |
  /// | `HORIZONTAL_SCROLLBAR_AS_NEEDED` | Show only when content is wider |
  /// | `HORIZONTAL_SCROLLBAR_ALWAYS` | Always show |
  /// | `HORIZONTAL_SCROLLBAR_NEVER` | Never show |
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JScrollPane: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Policy constants
    // -------------------------------------------------------------------------

    public static let VERTICAL_SCROLLBAR_AS_NEEDED: Int   = 20
    public static let VERTICAL_SCROLLBAR_NEVER: Int       = 21
    public static let VERTICAL_SCROLLBAR_ALWAYS: Int      = 22

    public static let HORIZONTAL_SCROLLBAR_AS_NEEDED: Int = 30
    public static let HORIZONTAL_SCROLLBAR_NEVER: Int     = 31
    public static let HORIZONTAL_SCROLLBAR_ALWAYS: Int    = 32

    // -------------------------------------------------------------------------
    // MARK: Sub-components
    // -------------------------------------------------------------------------

    private let viewport:  javax.swing.JViewport   = javax.swing.JViewport()
    private let vScrollBar: javax.swing.JScrollBar = javax.swing.JScrollBar(JScrollBar.VERTICAL)
    private let hScrollBar: javax.swing.JScrollBar = javax.swing.JScrollBar(JScrollBar.HORIZONTAL)

    public func getViewport()   -> javax.swing.JViewport   { viewport }
    public func getVerticalScrollBar()   -> javax.swing.JScrollBar { vScrollBar }
    public func getHorizontalScrollBar() -> javax.swing.JScrollBar { hScrollBar }

    // -------------------------------------------------------------------------
    // MARK: Policies
    // -------------------------------------------------------------------------

    private var _vPolicy: Int
    private var _hPolicy: Int

    public func getVerticalScrollBarPolicy() -> Int   { _vPolicy }
    public func setVerticalScrollBarPolicy(_ p: Int)  { _vPolicy = p; doLayout(); repaint() }

    public func getHorizontalScrollBarPolicy() -> Int  { _hPolicy }
    public func setHorizontalScrollBarPolicy(_ p: Int) { _hPolicy = p; doLayout(); repaint() }

    // -------------------------------------------------------------------------
    // MARK: Scrollbar visibility helpers
    // -------------------------------------------------------------------------

    /// Width / height of the scrollbar strip.
    public let scrollbarThickness: Int = 16

    private var showVBar: Bool {
      switch _vPolicy {
      case JScrollPane.VERTICAL_SCROLLBAR_ALWAYS: return true
      case JScrollPane.VERTICAL_SCROLLBAR_NEVER:  return false
      default:
        guard let v = viewport.getView() else { return false }
        return v.getPreferredSize().height > bounds.height
      }
    }

    private var showHBar: Bool {
      switch _hPolicy {
      case JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS: return true
      case JScrollPane.HORIZONTAL_SCROLLBAR_NEVER:  return false
      default:
        guard let v = viewport.getView() else { return false }
        let availW = bounds.width - (showVBar ? scrollbarThickness : 0)
        return v.getPreferredSize().width > availW
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public override init() {
      _vPolicy = JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED
      _hPolicy = JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED
      super.init()
      _connectScrollBars()
    }

    public init(_ view: java.awt.Component) {
      _vPolicy = JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED
      _hPolicy = JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED
      super.init()
      _connectScrollBars()
      viewport.setView(view)
    }

    public init(_ view: java.awt.Component, _ vsbPolicy: Int, _ hsbPolicy: Int) {
      _vPolicy = vsbPolicy
      _hPolicy = hsbPolicy
      super.init()
      _connectScrollBars()
      viewport.setView(view)
    }

    // -------------------------------------------------------------------------
    // MARK: View shortcut
    // -------------------------------------------------------------------------

    public func getView() -> java.awt.Component?    { viewport.getView() }
    public func setViewportView(_ v: java.awt.Component?) { viewport.setView(v) }

    // -------------------------------------------------------------------------
    // MARK: Scroll-bar → viewport synchronisation
    // -------------------------------------------------------------------------

    private class _VListener: java.awt.event.AdjustmentListener {
      weak var pane: JScrollPane?
      init(_ p: JScrollPane) { pane = p }
      func adjustmentValueChanged(_ e: java.awt.event.AdjustmentEvent) {
        guard let p = pane else { return }
        let cur = p.viewport.getViewPosition()
        p.viewport.setViewPosition(java.awt.Point(cur.x, e.value))
      }
    }

    private class _HListener: java.awt.event.AdjustmentListener {
      weak var pane: JScrollPane?
      init(_ p: JScrollPane) { pane = p }
      func adjustmentValueChanged(_ e: java.awt.event.AdjustmentEvent) {
        guard let p = pane else { return }
        let cur = p.viewport.getViewPosition()
        p.viewport.setViewPosition(java.awt.Point(e.value, cur.y))
      }
    }

    private var _vListener: _VListener?
    private var _hListener: _HListener?

    private func _connectScrollBars() {
      let vl = _VListener(self); _vListener = vl; vScrollBar.addAdjustmentListener(vl)
      let hl = _HListener(self); _hListener = hl; hScrollBar.addAdjustmentListener(hl)
    }

    // -------------------------------------------------------------------------
    // MARK: Layout
    // -------------------------------------------------------------------------

    override open func doLayout() {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height
      let t = scrollbarThickness

      let vb = showVBar
      let hb = showHBar

      let vpW = w - (vb ? t : 0)
      let vpH = h - (hb ? t : 0)

      // Viewport
      viewport.bounds = java.awt.Rectangle(x, y, max(0, vpW), max(0, vpH))

      // Vertical scrollbar
      vScrollBar.bounds = java.awt.Rectangle(x + vpW, y, t, max(0, vpH))
      vScrollBar.visible = vb
      if vb, let view = viewport.getView() {
        let viewH  = view.getPreferredSize().height
        let extent = max(1, vpH)
        let maxVal = max(extent, viewH)
        vScrollBar.setMinimum(0)
        vScrollBar.setMaximum(maxVal)
        vScrollBar.setVisibleAmount(extent)
        vScrollBar.setValue(viewport.getViewPosition().y)
      }

      // Horizontal scrollbar
      hScrollBar.bounds = java.awt.Rectangle(x, y + vpH, max(0, vpW), t)
      hScrollBar.visible = hb
      if hb, let view = viewport.getView() {
        let viewW  = view.getPreferredSize().width
        let extent = max(1, vpW)
        let maxVal = max(extent, viewW)
        hScrollBar.setMinimum(0)
        hScrollBar.setMaximum(maxVal)
        hScrollBar.setVisibleAmount(extent)
        hScrollBar.setValue(viewport.getViewPosition().x)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      doLayout()

      // Viewport
      viewport.paint(g)

      // Scroll bars (only when visible)
      if showVBar { vScrollBar.paint(g) }
      if showHBar { hScrollBar.paint(g) }

      // Corner fill
      if showVBar && showHBar {
        let cx = bounds.x + bounds.width  - scrollbarThickness
        let cy = bounds.y + bounds.height - scrollbarThickness
        g.setColor(java.awt.SystemColor.control)
        g.fillRect(cx, cy, scrollbarThickness, scrollbarThickness)
      }

      // Border
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height
      g.setColor(java.awt.SystemColor.windowBorder)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)
    }

    // -------------------------------------------------------------------------
    // MARK: Hit-test: expose sub-components to _AWTHitTest
    // -------------------------------------------------------------------------

    override open func getComponents() -> [java.awt.Component] {
      var result: [java.awt.Component] = [viewport]
      if showVBar { result.append(vScrollBar) }
      if showHBar { result.append(hScrollBar) }
      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize() -> java.awt.Dimension {
      let vs = viewport.getPreferredSize()
      let t  = scrollbarThickness
      return java.awt.Dimension(vs.width + t, vs.height + t)
    }

    override open func dispose() {
      _vListener = nil
      _hListener = nil
      super.dispose()
    }
  }
}
