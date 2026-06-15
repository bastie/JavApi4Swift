/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A Swing scroll bar — mirrors `javax.swing.JScrollBar`.
  ///
  /// `JScrollBar` is a `JComponent` (unlike `java.awt.Scrollbar`) and uses a
  /// `BoundedRangeModel` to hold its state.  The *extent* of the model
  /// corresponds to the visible amount (thumb size relative to the range).
  ///
  /// ```swift
  /// let bar = javax.swing.JScrollBar(javax.swing.JScrollBar.VERTICAL)
  /// bar.setMinimum(0)
  /// bar.setMaximum(200)
  /// bar.setValue(50)
  /// bar.setVisibleAmount(20)
  /// bar.addAdjustmentListener(myListener)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JScrollBar: javax.swing.JComponent, javax.swing.SwingConstants {

    // -------------------------------------------------------------------------
    // MARK: Orientation constants
    // -------------------------------------------------------------------------

    /// Horizontal scroll bar (= `SwingConstants.HORIZONTAL` = 0).
    public static let HORIZONTAL: Int = JScrollBar.HORIZONTAL
    /// Vertical scroll bar (= `SwingConstants.VERTICAL` = 1).
    public static let VERTICAL:   Int = JScrollBar.VERTICAL

    // -------------------------------------------------------------------------
    // MARK: Model + orientation
    // -------------------------------------------------------------------------

    private var model:       javax.swing.BoundedRangeModel
    private var _orientation: Int
    private var _unitIncrement:  Int = 1
    private var _blockIncrement: Int = 10

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var adjustmentListeners: [java.awt.event.AdjustmentListener] = []

    private class _ModelBridge: javax.swing.event.ChangeListener {
      weak var bar: JScrollBar?
      init(_ bar: JScrollBar) { self.bar = bar }
      func stateChanged(_ e: javax.swing.event.ChangeEvent) {
        bar?.fireAdjustment()
      }
    }
    private var modelBridge: _ModelBridge?

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public override init() {
      _orientation = JScrollBar.VERTICAL
      model = javax.swing.DefaultBoundedRangeModel(value: 0, extent: 10, minimum: 0, maximum: 100)
      super.init()
      _setup()
    }

    public init(_ orientation: Int) {
      _orientation = orientation
      model = javax.swing.DefaultBoundedRangeModel(value: 0, extent: 10, minimum: 0, maximum: 100)
      super.init()
      _setup()
    }

    public init(_ orientation: Int, _ value: Int, _ extent: Int, _ minimum: Int, _ maximum: Int) {
      _orientation = orientation
      model = javax.swing.DefaultBoundedRangeModel(value: value, extent: extent,
                                                    minimum: minimum, maximum: maximum)
      super.init()
      _setup()
    }

    private func _setup() {
      let bridge = _ModelBridge(self)
      modelBridge = bridge
      model.addChangeListener(bridge)
    }

    // -------------------------------------------------------------------------
    // MARK: Model access
    // -------------------------------------------------------------------------

    public func getModel() -> javax.swing.BoundedRangeModel { model }
    public func setModel(_ newModel: javax.swing.BoundedRangeModel) {
      if let old = modelBridge { model.removeChangeListener(old) }
      model = newModel
      if let bridge = modelBridge { model.addChangeListener(bridge) }
    }

    // -------------------------------------------------------------------------
    // MARK: Java API — value / range
    // -------------------------------------------------------------------------

    public func getValue() -> Int          { model.getValue() }
    public func setValue(_ v: Int)         { model.setValue(v) }

    public func getMinimum() -> Int        { model.getMinimum() }
    public func setMinimum(_ v: Int)       { model.setMinimum(v) }

    public func getMaximum() -> Int        { model.getMaximum() }
    public func setMaximum(_ v: Int)       { model.setMaximum(v) }

    public func getVisibleAmount() -> Int  { model.getExtent() }
    public func setVisibleAmount(_ v: Int) { model.setExtent(v) }

    public func getValueIsAdjusting() -> Bool    { model.getValueIsAdjusting() }
    public func setValueIsAdjusting(_ b: Bool)   { model.setValueIsAdjusting(b) }

    // -------------------------------------------------------------------------
    // MARK: Java API — increments / orientation
    // -------------------------------------------------------------------------

    public func getOrientation() -> Int       { _orientation }
    public func setOrientation(_ o: Int)      { _orientation = o; repaint() }

    public func getUnitIncrement() -> Int     { _unitIncrement }
    public func setUnitIncrement(_ v: Int)    { _unitIncrement = v }
    public func getUnitIncrement(_ direction: Int) -> Int { _unitIncrement }

    public func getBlockIncrement() -> Int    { _blockIncrement }
    public func setBlockIncrement(_ v: Int)   { _blockIncrement = v }
    public func getBlockIncrement(_ direction: Int) -> Int { _blockIncrement }

    // -------------------------------------------------------------------------
    // MARK: Adjustment listeners
    // -------------------------------------------------------------------------

    public func addAdjustmentListener(_ l: java.awt.event.AdjustmentListener) {
      adjustmentListeners.append(l)
    }
    public func removeAdjustmentListener(_ l: java.awt.event.AdjustmentListener) {
      adjustmentListeners.removeAll { $0 === l }
    }

    private func fireAdjustment() {
      let e = java.awt.event.AdjustmentEvent(
        self,
        java.awt.event.AdjustmentEvent.ADJUSTMENT_VALUE_CHANGED,
        java.awt.event.AdjustmentEvent.TRACK,
        model.getValue(),
        isAdjusting: model.getValueIsAdjusting()
      )
      for l in adjustmentListeners { l.adjustmentValueChanged(e) }
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Geometry helpers  (used by BasicScrollBarUI and hit-test)
    // -------------------------------------------------------------------------

    /// Width of the arrow buttons (equals the narrower dimension of the bar).
    public var buttonSize: Int {
      _orientation == JScrollBar.VERTICAL ? bounds.width : bounds.height
    }

    public func decrementButtonRect() -> java.awt.Rectangle {
      let bs = buttonSize
      return _orientation == JScrollBar.VERTICAL
        ? java.awt.Rectangle(bounds.x, bounds.y, bounds.width, bs)
        : java.awt.Rectangle(bounds.x, bounds.y, bs, bounds.height)
    }

    public func incrementButtonRect() -> java.awt.Rectangle {
      let bs = buttonSize
      return _orientation == JScrollBar.VERTICAL
        ? java.awt.Rectangle(bounds.x, bounds.y + bounds.height - bs, bounds.width, bs)
        : java.awt.Rectangle(bounds.x + bounds.width - bs, bounds.y, bs, bounds.height)
    }

    public func thumbRect() -> java.awt.Rectangle {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height
      let bs    = buttonSize
      let min   = model.getMinimum()
      let max   = model.getMaximum()
      let val   = model.getValue()
      let ext   = model.getExtent()
      let range = Math.max(1, max - min)

      if _orientation == JScrollBar.VERTICAL {
        let trackH = h - 2 * bs
        let thumbH = Math.max(12, trackH * ext / range)
        let thumbY = trackH <= thumbH ? y + bs : y + bs + (trackH - thumbH) * (val - min) / Math.max(1, range - ext)
        return java.awt.Rectangle(x, thumbY, w, thumbH)
      } else {
        let trackW = w - 2 * bs
        let thumbW = Math.max(12, trackW * ext / range)
        let thumbX = trackW <= thumbW ? x + bs : x + bs + (trackW - thumbW) * (val - min) / Math.max(1, range - ext)
        return java.awt.Rectangle(thumbX, y, thumbW, h)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Drag state  (used by platform bridges)
    // -------------------------------------------------------------------------

    var isDragging:     Bool = false
    var dragStartCoord: Int  = 0
    var dragStartValue: Int  = 0

    // -------------------------------------------------------------------------
    // MARK: Paint  (delegates to UI, fallback inline)
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      if let ui = getUI() as? javax.swing.plaf.basic.BasicScrollBarUI {
        ui.paint(g, self)
        return
      }
      _paintInline(g)
    }

    /// Inline fallback renderer — same visuals as BasicScrollBarUI.
    private func _paintInline(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height

      // Track
      g.setColor(java.awt.SystemColor.scrollbar)
      g.fillRect(x, y, w, h)

      // Thumb
      let tr = thumbRect()
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(tr.x, tr.y, tr.width, tr.height)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(tr.x,              tr.y,               tr.x + tr.width - 1, tr.y)
      g.drawLine(tr.x,              tr.y,               tr.x,                tr.y + tr.height - 1)
      g.drawLine(tr.x + tr.width-1, tr.y,               tr.x + tr.width - 1, tr.y + tr.height - 1)
      g.drawLine(tr.x,              tr.y + tr.height-1,  tr.x + tr.width - 1, tr.y + tr.height - 1)

      // Arrows
      _drawArrow(g, rect: decrementButtonRect(), decrement: true)
      _drawArrow(g, rect: incrementButtonRect(), decrement: false)

      // Outer border
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)
    }

    internal func _drawArrow(_ g: java.awt.Graphics, rect r: java.awt.Rectangle, decrement: Bool) {
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(r.x, r.y, r.width, r.height)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(r.x,             r.y,             r.x + r.width - 1, r.y)
      g.drawLine(r.x,             r.y,             r.x,               r.y + r.height - 1)
      g.drawLine(r.x + r.width-1, r.y,             r.x + r.width - 1, r.y + r.height - 1)
      g.drawLine(r.x,             r.y + r.height-1, r.x + r.width - 1, r.y + r.height - 1)
      g.setColor(java.awt.SystemColor.controlText)
      let cx = r.x + r.width  / 2
      let cy = r.y + r.height / 2
      if _orientation == JScrollBar.VERTICAL {
        for row in 0...3 {
          let dy = decrement ? (cy - 3 + row) : (cy + 3 - row)
          g.drawLine(cx - row, dy, cx + row, dy)
        }
      } else {
        for col in 0...3 {
          let dx = decrement ? (cx - 3 + col) : (cx + 3 - col)
          g.drawLine(dx, cy - col, dx, cy + col)
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize() -> java.awt.Dimension {
      _orientation == JScrollBar.VERTICAL
        ? java.awt.Dimension(16, 100)
        : java.awt.Dimension(100, 16)
    }

    override open func dispose() {
      adjustmentListeners.removeAll()
      super.dispose()
    }
  }
}
