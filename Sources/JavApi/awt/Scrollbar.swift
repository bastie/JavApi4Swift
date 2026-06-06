/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A scroll-bar component — mirrors `java.awt.Scrollbar`.
  ///
  /// Supports both horizontal and vertical orientations. The visible range
  /// (`visibleAmount`) and the total range (`minimum` … `maximum`) define how
  /// large the thumb is relative to the track.
  open class Scrollbar: Component {

    // -------------------------------------------------------------------------
    // MARK: Orientation constants
    // -------------------------------------------------------------------------

    /// Horizontal scroll bar.
    public static let HORIZONTAL = 0
    /// Vertical scroll bar.
    public static let VERTICAL   = 1

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    public var orientation:    Int = Scrollbar.VERTICAL
    public var minimum:        Int = 0
    public var maximum:        Int = 100
    public var visibleAmount:  Int = 10
    public var unitIncrement:  Int = 1
    public var blockIncrement: Int = 10

    private var _value: Int = 0

    public var value: Int {
      get { _value }
      set { _value = clampedValue(newValue) }
    }

    private func clampedValue(_ v: Int) -> Int {
      max(minimum, min(maximum - visibleAmount, v))
    }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var adjustmentListeners: [java.awt.event.AdjustmentListener] = []

    public func addAdjustmentListener(_ l: java.awt.event.AdjustmentListener) {
      adjustmentListeners.append(l)
    }
    public func removeAdjustmentListener(_ l: java.awt.event.AdjustmentListener) {
      adjustmentListeners.removeAll { $0 === l }
    }

    internal func fireAdjustment(type: Int, isAdjusting: Bool = false) {
      let e = java.awt.event.AdjustmentEvent(
        self,
        java.awt.event.AdjustmentEvent.ADJUSTMENT_VALUE_CHANGED,
        type,
        _value,
        isAdjusting: isAdjusting)
      adjustmentListeners.forEach { $0.adjustmentValueChanged(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
    }

    public init(_ orientation: Int) {
      self.orientation = orientation
      super.init()
    }

    public init(_ orientation: Int,
                value: Int,
                visible: Int,
                minimum: Int,
                maximum: Int) {
      self.orientation   = orientation
      self.minimum       = minimum
      self.maximum       = maximum
      self.visibleAmount = visible
      super.init()
      self._value = clampedValue(value)
    }

    // -------------------------------------------------------------------------
    // MARK: Java API accessors
    // -------------------------------------------------------------------------

    public func getValue() -> Int         { _value }
    public func setValue(_ v: Int) {
      let clamped = clampedValue(v)
      if clamped != _value {
        _value = clamped
        fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK)
      }
    }

    public func getMinimum() -> Int       { minimum }
    public func setMinimum(_ v: Int)      { minimum = v; _value = clampedValue(_value) }
    public func getMaximum() -> Int       { maximum }
    public func setMaximum(_ v: Int)      { maximum = v; _value = clampedValue(_value) }
    public func getVisibleAmount() -> Int { visibleAmount }
    public func setVisibleAmount(_ v: Int){ visibleAmount = v; _value = clampedValue(_value) }
    public func getUnitIncrement() -> Int { unitIncrement }
    public func setUnitIncrement(_ v: Int){ unitIncrement = v }
    public func getBlockIncrement() -> Int{ blockIncrement }
    public func setBlockIncrement(_ v: Int){ blockIncrement = v }
    public func getOrientation() -> Int   { orientation }

    // -------------------------------------------------------------------------
    // MARK: Button / Thumb geometry
    // -------------------------------------------------------------------------

    /// Size of the arrow buttons at each end of the scrollbar.
    public var buttonSize: Int { orientation == Scrollbar.VERTICAL ? bounds.width : bounds.height }

    /// Rectangle of the decrement (▲/◀) button.
    public func decrementButtonRect() -> java.awt.Rectangle {
      let bs = buttonSize
      return orientation == Scrollbar.VERTICAL
        ? java.awt.Rectangle(bounds.x, bounds.y, bounds.width, bs)
        : java.awt.Rectangle(bounds.x, bounds.y, bs, bounds.height)
    }

    /// Rectangle of the increment (▼/▶) button.
    public func incrementButtonRect() -> java.awt.Rectangle {
      let bs = buttonSize
      return orientation == Scrollbar.VERTICAL
        ? java.awt.Rectangle(bounds.x, bounds.y + bounds.height - bs, bounds.width, bs)
        : java.awt.Rectangle(bounds.x + bounds.width - bs, bounds.y, bs, bounds.height)
    }

    /// Returns the rectangle of the scroll thumb within the track area.
    public func thumbRect() -> java.awt.Rectangle {
      let x = bounds.x, y = bounds.y
      let w = bounds.width, h = bounds.height
      let bs = buttonSize
      let range = max(1, maximum - minimum)
      if orientation == Scrollbar.VERTICAL {
        let trackH = h - 2 * bs
        let thumbH = max(12, trackH * visibleAmount / range)
        let thumbY = y + bs + (trackH - thumbH) * (_value - minimum) / max(1, range - visibleAmount)
        return java.awt.Rectangle(x, thumbY, w, thumbH)
      } else {
        let trackW = w - 2 * bs
        let thumbW = max(12, trackW * visibleAmount / range)
        let thumbX = x + bs + (trackW - thumbW) * (_value - minimum) / max(1, range - visibleAmount)
        return java.awt.Rectangle(thumbX, y, thumbW, h)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Drag state  (used by platform bridge)
    // -------------------------------------------------------------------------

    /// `true` while the user is dragging the thumb.
    var isDragging:      Bool = false
    /// The screen coordinate (y for VERTICAL, x for HORIZONTAL) where drag started.
    var dragStartCoord:  Int  = 0
    /// The scrollbar value at the start of the drag.
    var dragStartValue:  Int  = 0

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height

      // Track background
      g.setColor(java.awt.SystemColor.scrollbar)
      g.fillRect(x, y, w, h)

      // Thumb
      let tr = thumbRect()
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(tr.x, tr.y, tr.width, tr.height)

      // Thumb border
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(tr.x,              tr.y,               tr.x + tr.width - 1, tr.y)
      g.drawLine(tr.x,              tr.y,               tr.x,                tr.y + tr.height - 1)
      g.drawLine(tr.x + tr.width-1, tr.y,               tr.x + tr.width - 1, tr.y + tr.height - 1)
      g.drawLine(tr.x,              tr.y + tr.height-1,  tr.x + tr.width - 1, tr.y + tr.height - 1)

      // Arrow buttons
      let db = decrementButtonRect()
      let ib = incrementButtonRect()
      drawArrowButton(g, rect: db, decrement: true)
      drawArrowButton(g, rect: ib, decrement: false)

      // Outer border
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)
    }

    /// Draws one arrow button (filled rect + triangle).
    private func drawArrowButton(_ g: java.awt.Graphics, rect r: java.awt.Rectangle, decrement: Bool) {
      // Button background
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(r.x, r.y, r.width, r.height)
      // Button border
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(r.x,            r.y,            r.x + r.width - 1, r.y)
      g.drawLine(r.x,            r.y,            r.x,               r.y + r.height - 1)
      g.drawLine(r.x + r.width-1, r.y,           r.x + r.width - 1, r.y + r.height - 1)
      g.drawLine(r.x,            r.y + r.height-1, r.x + r.width - 1, r.y + r.height - 1)
      // Triangle arrow
      g.setColor(java.awt.SystemColor.controlText)
      let cx = r.x + r.width / 2
      let cy = r.y + r.height / 2
      let vert = orientation == Scrollbar.VERTICAL
      // Draw a small 3-row triangle
      if vert {
        // ▲ or ▼
        let tip = decrement ? cy - 2 : cy + 2
        let base = decrement ? cy + 2 : cy - 2
        for row in 0...2 {
          let dy = decrement ? base - row : base + row
          g.drawLine(cx - row, dy, cx + row, dy)
        }
        let _ = tip  // suppress warning
      } else {
        // ◀ or ▶
        let tip = decrement ? cx - 2 : cx + 2
        let base = decrement ? cx + 2 : cx - 2
        for col in 0...2 {
          let dx = decrement ? base - col : base + col
          g.drawLine(dx, cy - col, dx, cy + col)
        }
        let _ = tip  // suppress warning
      }
    }
  }
}
