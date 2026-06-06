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

    /// Current horizontal scroll offset (read-only; use `setScrollPosition`).
    public var scrollX: Int { _scrollX }
    /// Current vertical scroll offset (read-only; use `setScrollPosition`).
    public var scrollY: Int { _scrollY }

    // -------------------------------------------------------------------------
    // MARK: Scrollbar drag state  (used by AWTWindowHost)
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
    func maxScroll() -> (x: Int, y: Int) {
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
        return child.bounds.width > bounds.width
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Scrollbar geometry  (used by AWTWindowHost for hit-testing)
    // -------------------------------------------------------------------------

    /// Track rect of the vertical scrollbar (nil if not shown).
    public func vScrollbarRect() -> java.awt.Rectangle? {
      guard needsVScrollbar else { return nil }
      let trackH = bounds.height - (needsHScrollbar ? scrollbarSize : 0)
      return java.awt.Rectangle(bounds.x + bounds.width - scrollbarSize,
                                bounds.y, scrollbarSize, trackH)
    }

    /// Track rect of the horizontal scrollbar (nil if not shown).
    public func hScrollbarRect() -> java.awt.Rectangle? {
      guard needsHScrollbar else { return nil }
      let trackW = bounds.width - (needsVScrollbar ? scrollbarSize : 0)
      return java.awt.Rectangle(bounds.x,
                                bounds.y + bounds.height - scrollbarSize,
                                trackW, scrollbarSize)
    }

    /// Thumb rect of the vertical scrollbar (nil if not scrollable).
    public func vThumbRect() -> java.awt.Rectangle? {
      guard let track = vScrollbarRect() else { return nil }
      let (_, maxY) = maxScroll()
      guard maxY > 0, let childH = children.first?.bounds.height, childH > 0 else { return nil }
      let thumbH = max(16, track.height * track.height / childH)
      let thumbY = track.y + (track.height - thumbH) * _scrollY / maxY
      return java.awt.Rectangle(track.x, thumbY, track.width, thumbH)
    }

    /// Thumb rect of the horizontal scrollbar (nil if not scrollable).
    public func hThumbRect() -> java.awt.Rectangle? {
      guard let track = hScrollbarRect() else { return nil }
      let (maxX, _) = maxScroll()
      guard maxX > 0, let childW = children.first?.bounds.width, childW > 0 else { return nil }
      let thumbW = max(16, track.width * track.width / childW)
      let thumbX = track.x + (track.width - thumbW) * _scrollX / maxX
      return java.awt.Rectangle(thumbX, track.y, thumbW, track.height)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height
      let vp = getViewportSize()

      // Background
      g.setColor(background)
      g.fillRect(x, y, w, h)

      // ── Child — clipped to viewport, translated by scroll offset ───────────
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
        if let thumb = vThumbRect() {
          drawThumb(g, thumb)
        }
      }

      // ── Horizontal scrollbar ───────────────────────────────────────────────
      if let hTrack = hScrollbarRect() {
        g.setColor(java.awt.SystemColor.scrollbar)
        g.fillRect(hTrack.x, hTrack.y, hTrack.width, hTrack.height)
        if let thumb = hThumbRect() {
          drawThumb(g, thumb)
        }
      }

      // ── Corner fill (intersection of both scrollbars) ──────────────────────
      if needsVScrollbar && needsHScrollbar {
        g.setColor(java.awt.SystemColor.control)
        g.fillRect(x + w - scrollbarSize, y + h - scrollbarSize,
                   scrollbarSize, scrollbarSize)
      }

      // ── Border ─────────────────────────────────────────────────────────────
      g.setColor(java.awt.Color(0x88, 0x88, 0x88))
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)
    }

    private func drawThumb(_ g: java.awt.Graphics, _ t: java.awt.Rectangle) {
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(t.x, t.y, t.width, t.height)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(t.x,            t.y,            t.x + t.width - 1, t.y)
      g.drawLine(t.x,            t.y,            t.x,               t.y + t.height - 1)
      g.drawLine(t.x + t.width-1, t.y,           t.x + t.width - 1, t.y + t.height - 1)
      g.drawLine(t.x,            t.y + t.height-1, t.x + t.width - 1, t.y + t.height - 1)
    }
  }
}
