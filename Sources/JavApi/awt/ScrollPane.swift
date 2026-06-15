/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A scrollable container that holds exactly one child component —
  /// mirrors `java.awt.ScrollPane`.
  ///
  /// When the child is larger than the visible viewport, scroll bars appear
  /// automatically (or always/never, depending on `scrollbarDisplayPolicy`).
  /// The child's `bounds` describe its **full** (possibly over-size) extent
  /// within the Frame's coordinate space; `ScrollPane.paint()` clips and
  /// translates the `CGContext` so only the current viewport slice is drawn.
  ///
  /// ```swift
  /// let pane = java.awt.ScrollPane()
  /// pane.bounds = java.awt.Rectangle(0, 0, 200, 150)
  ///
  /// let bigCanvas = MyLargeCanvas()
  /// bigCanvas.bounds = java.awt.Rectangle(0, 0, 800, 600)
  /// pane.add(bigCanvas)
  /// ```
  open class ScrollPane: Container {

    // -------------------------------------------------------------------------
    // MARK: Scrollbar-visibility constants
    // -------------------------------------------------------------------------

    /// Show scroll bars only when the child is larger than the viewport.
    public static let SCROLLBARS_AS_NEEDED = 0
    /// Always show both scroll bars.
    public static let SCROLLBARS_ALWAYS    = 1
    /// Never show scroll bars (clip silently).
    public static let SCROLLBARS_NEVER     = 2

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    public var scrollbarDisplayPolicy: Int

    /// Width / height of each scrollbar strip in pixels.
    public let scrollbarSize: Int = 12

    private var _scrollX: Int = 0
    private var _scrollY: Int = 0

    /// Current horizontal scroll offset.
    public var scrollX: Int {
      get { _scrollX }
      set { _scrollX = newValue }
    }
    /// Current vertical scroll offset.
    public var scrollY: Int {
      get { _scrollY }
      set { _scrollY = newValue }
    }

    // -------------------------------------------------------------------------
    // MARK: Scrollbar drag state  (used by _SwiftUIWindowHost)
    // -------------------------------------------------------------------------

    var isDraggingV:       Bool = false
    var isDraggingH:       Bool = false
    var dragStartX:        Int  = 0
    var dragStartY:        Int  = 0
    var dragStartScrollX:  Int  = 0
    var dragStartScrollY:  Int  = 0

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public override init() {
      scrollbarDisplayPolicy = ScrollPane.SCROLLBARS_AS_NEEDED
      super.init()
      setLayout(nil)  // ScrollPane positions its child itself
    }

    public init(_ scrollbarDisplayPolicy: Int) {
      self.scrollbarDisplayPolicy = scrollbarDisplayPolicy
      super.init()
      setLayout(nil)
    }

    // -------------------------------------------------------------------------
    // MARK: Child management  (only one child allowed)
    // -------------------------------------------------------------------------

    public override func add(_ comp: Component) {
      removeAll()
      super.add(comp)
    }

    public func getChild() -> Component? { children.first }

    // -------------------------------------------------------------------------
    // MARK: Scroll position
    // -------------------------------------------------------------------------

    /// Set the scroll position, clamped to the valid range.
    public func setScrollPosition(_ x: Int, _ y: Int) {
      let (maxX, maxY) = maxScroll()
      _scrollX = max(0, min(x, maxX))
      _scrollY = max(0, min(y, maxY))
    }

    public func getScrollPosition() -> java.awt.Point {
      java.awt.Point(_scrollX, _scrollY)
    }

    // -------------------------------------------------------------------------
    // MARK: Viewport / scroll range helpers
    // -------------------------------------------------------------------------

    /// The visible content area (excluding scrollbar strips).
    public func getViewportSize() -> java.awt.Dimension {
      let vW = bounds.width  - (needsVScrollbar ? scrollbarSize : 0)
      let vH = bounds.height - (needsHScrollbar ? scrollbarSize : 0)
      return java.awt.Dimension(max(0, vW), max(0, vH))
    }

    /// Maximum reachable scroll offsets.
    public func maxScroll() -> (x: Int, y: Int) {
      let vp = getViewportSize()
      let cW = children.first?.bounds.width  ?? 0
      let cH = children.first?.bounds.height ?? 0
      return (max(0, cW - vp.width), max(0, cH - vp.height))
    }

    var needsVScrollbar: Bool {
      switch scrollbarDisplayPolicy {
      case ScrollPane.SCROLLBARS_NEVER:  return false
      case ScrollPane.SCROLLBARS_ALWAYS: return true
      default:
        guard let child = children.first else { return false }
        return child.bounds.height > bounds.height
      }
    }

    var needsHScrollbar: Bool {
      switch scrollbarDisplayPolicy {
      case ScrollPane.SCROLLBARS_NEVER:  return false
      case ScrollPane.SCROLLBARS_ALWAYS: return true
      default:
        guard let child = children.first else { return false }
        // Account for vertical scrollbar reducing the effective viewport width
        let effectiveW = bounds.width - (needsVScrollbar ? scrollbarSize : 0)
        return child.bounds.width > effectiveW
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Scrollbar geometry  (used by _SwiftUIWindowHost for hit-testing)
    // -------------------------------------------------------------------------

    /// Full rect of the vertical scrollbar strip — LOCAL coordinates (0,0-based).
    public func vScrollbarRect() -> java.awt.Rectangle? {
      guard needsVScrollbar else { return nil }
      let trackH = bounds.height - (needsHScrollbar ? scrollbarSize : 0)
      return java.awt.Rectangle(bounds.width - scrollbarSize, 0, scrollbarSize, trackH)
    }

    /// Full rect of the horizontal scrollbar strip — LOCAL coordinates.
    public func hScrollbarRect() -> java.awt.Rectangle? {
      guard needsHScrollbar else { return nil }
      let trackW = bounds.width - (needsVScrollbar ? scrollbarSize : 0)
      return java.awt.Rectangle(0, bounds.height - scrollbarSize, trackW, scrollbarSize)
    }

    // Arrow-button rects — LOCAL coordinates
    public func vDecrementButtonRect() -> java.awt.Rectangle? {
      guard let r = vScrollbarRect() else { return nil }
      return java.awt.Rectangle(r.x, r.y, r.width, scrollbarSize)
    }
    public func vIncrementButtonRect() -> java.awt.Rectangle? {
      guard let r = vScrollbarRect() else { return nil }
      return java.awt.Rectangle(r.x, r.y + r.height - scrollbarSize, r.width, scrollbarSize)
    }

    public func hDecrementButtonRect() -> java.awt.Rectangle? {
      guard let r = hScrollbarRect() else { return nil }
      return java.awt.Rectangle(r.x, r.y, scrollbarSize, r.height)
    }
    public func hIncrementButtonRect() -> java.awt.Rectangle? {
      guard let r = hScrollbarRect() else { return nil }
      return java.awt.Rectangle(r.x + r.width - scrollbarSize, r.y, scrollbarSize, r.height)
    }

    /// Thumb rect of the vertical scrollbar — LOCAL coordinates.
    public func vThumbRect() -> java.awt.Rectangle? {
      guard let track = vScrollbarRect() else { return nil }
      let (_, maxY) = maxScroll()
      guard maxY > 0, let childH = children.first?.bounds.height, childH > 0 else { return nil }
      let bs = scrollbarSize
      let usableH = track.height - 2 * bs
      let thumbH  = max(16, usableH * usableH / childH)
      let thumbY  = track.y + bs + (usableH - thumbH) * _scrollY / maxY
      return java.awt.Rectangle(track.x, thumbY, track.width, thumbH)
    }

    /// Thumb rect of the horizontal scrollbar — LOCAL coordinates.
    public func hThumbRect() -> java.awt.Rectangle? {
      guard let track = hScrollbarRect() else { return nil }
      let (maxX, _) = maxScroll()
      guard maxX > 0, let childW = children.first?.bounds.width, childW > 0 else { return nil }
      let bs = scrollbarSize
      let usableW = track.width - 2 * bs
      let thumbW  = max(16, usableW * usableW / childW)
      let thumbX  = track.x + bs + (usableW - thumbW) * _scrollX / maxX
      return java.awt.Rectangle(thumbX, track.y, thumbW, track.height)
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override public func getPreferredSize() -> java.awt.Dimension {
      if let d = _preferredSize { return d }
      // Preferred size = child's preferred size + scrollbars
      if let child = children.first {
        let ps = child.getPreferredSize()
        return java.awt.Dimension(ps.width + scrollbarSize, ps.height + scrollbarSize)
      }
      return java.awt.Dimension(100, 100)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      // Container.paint() translates g to (bounds.x, bounds.y); undo it so
      // All rects (vScrollbarRect etc.) are now LOCAL (0,0-based). Paint directly.
      let x = 0, y = 0, w = bounds.width, h = bounds.height
      let vp = getViewportSize()

      // Background
      g.setColor(background)
      g.fillRect(x, y, w, h)

      // ── Child — clipped to viewport, translated by scroll offset ───────────
      // The child's bounds are (0,0,childW,childH) in child-local space.
      // Translate so child origin lands at (-scrollX, -scrollY) within our local space.
      if let child = children.first {
        g.save()
        g.clipRect(x, y, vp.width, vp.height)
        g.translate(-_scrollX, -_scrollY)
        child.paint(g)
        g.restore()
      }

      // ── Vertical scrollbar ─────────────────────────────────────────────────
      if let vTrack = vScrollbarRect() {
        g.setColor(java.awt.SystemColor.scrollbar)
        g.fillRect(vTrack.x, vTrack.y, vTrack.width, vTrack.height)
        if let thumb = vThumbRect() { drawThumb(g, thumb) }
        if let r = vDecrementButtonRect() { drawScrollArrow(g, rect: r, up: true) }
        if let r = vIncrementButtonRect() { drawScrollArrow(g, rect: r, up: false) }
      }

      // ── Horizontal scrollbar ───────────────────────────────────────────────
      if let hTrack = hScrollbarRect() {
        g.setColor(java.awt.SystemColor.scrollbar)
        g.fillRect(hTrack.x, hTrack.y, hTrack.width, hTrack.height)
        if let thumb = hThumbRect() { drawThumb(g, thumb) }
        if let r = hDecrementButtonRect() { drawScrollArrow(g, rect: r, up: true,  vertical: false) }
        if let r = hIncrementButtonRect() { drawScrollArrow(g, rect: r, up: false, vertical: false) }
      }

      // ── Corner fill ────────────────────────────────────────────────────────
      if needsVScrollbar && needsHScrollbar {
        g.setColor(java.awt.SystemColor.control)
        g.fillRect(w - scrollbarSize, h - scrollbarSize, scrollbarSize, scrollbarSize)
      }

      // ── Border ─────────────────────────────────────────────────────────────
      g.setColor(java.awt.SystemColor.windowBorder)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)
    }

    private func drawThumb(_ g: java.awt.Graphics, _ t: java.awt.Rectangle) {
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(t.x, t.y, t.width, t.height)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(t.x,             t.y,             t.x + t.width - 1, t.y)
      g.drawLine(t.x,             t.y,             t.x,               t.y + t.height - 1)
      g.drawLine(t.x + t.width-1, t.y,             t.x + t.width - 1, t.y + t.height - 1)
      g.drawLine(t.x,             t.y + t.height-1, t.x + t.width - 1, t.y + t.height - 1)
    }

    /// Draws one scrollbar arrow button.
    /// `up` = decrement direction (▲ for vertical, ◀ for horizontal).
    private func drawScrollArrow(_ g: java.awt.Graphics, rect r: java.awt.Rectangle,
                                  up: Bool, vertical: Bool = true) {
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(r.x, r.y, r.width, r.height)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(r.x,             r.y,             r.x + r.width - 1, r.y)
      g.drawLine(r.x,             r.y,             r.x,               r.y + r.height - 1)
      g.drawLine(r.x + r.width-1, r.y,             r.x + r.width - 1, r.y + r.height - 1)
      g.drawLine(r.x,             r.y + r.height-1, r.x + r.width - 1, r.y + r.height - 1)
      // Triangle
      g.setColor(java.awt.SystemColor.controlText)
      let cx = r.x + r.width / 2
      let cy = r.y + r.height / 2
      if vertical {
        // ▲ (up): tip at top (cy-3), base at bottom (cy+1)
        // ▼ (!up): tip at bottom (cy+3), base at top (cy-1)
        for row in 0...3 {
          let dy = up ? (cy - 3 + row) : (cy + 3 - row)
          g.drawLine(cx - row, dy, cx + row, dy)
        }
      } else {
        // ◀ (up/left): tip at left (cx-3), base at right (cx+1)
        // ▶ (!up/right): tip at right (cx+3), base at left (cx-1)
        for col in 0...3 {
          let dx = up ? (cx - 3 + col) : (cx + 3 - col)
          g.drawLine(dx, cy - col, dx, cy + col)
        }
      }
    }
  }
}
