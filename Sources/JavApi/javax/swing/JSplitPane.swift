/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A container that splits its area between two child components with a
  /// draggable divider.
  ///
  /// The two children are referred to as the **left / top** component and the
  /// **right / bottom** component.  The divider position is stored as a pixel
  /// offset from the leading edge.
  ///
  /// ```swift
  /// let split = javax.swing.JSplitPane(
  ///   javax.swing.JSplitPane.HORIZONTAL_SPLIT, leftPanel, rightPanel)
  /// split.setDividerLocation(200)
  /// frame.add(split, java.awt.BorderLayout.CENTER)
  /// ```
  ///
  /// ### Orientation constants
  /// | Constant | Value | Meaning |
  /// |---|---|---|
  /// | `HORIZONTAL_SPLIT` | 1 | Left / right |
  /// | `VERTICAL_SPLIT`   | 0 | Top / bottom |
  ///
  /// - Since: Java 1.1
  @MainActor
  open class JSplitPane: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Constants
    // -------------------------------------------------------------------------

    public static let HORIZONTAL_SPLIT: Int = 1
    public static let VERTICAL_SPLIT:   Int = 0

    public static let DIVIDER_SIZE: Int = 8

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _orientation: Int
    private var _dividerLocation: Int = -1   // -1 = not yet set, use proportional default
    private var _dividerSize: Int = DIVIDER_SIZE
    private var _continuousLayout: Bool = false
    private var _oneTouchExpandable: Bool = false
    private var _resizeWeight: Double = 0.0  // 0.0 = left/top gets none of extra space

    private var _leftComponent:  java.awt.Component? = nil
    private var _rightComponent: java.awt.Component? = nil

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      _orientation = JSplitPane.HORIZONTAL_SPLIT
      super.init()
      updateUI()
    }

    public init(_ newOrientation: Int) {
      _orientation = newOrientation
      super.init()
      updateUI()
    }

    public init(_ newOrientation: Int,
                _ newLeftComponent: java.awt.Component,
                _ newRightComponent: java.awt.Component) {
      _orientation = newOrientation
      super.init()
      setLeftComponent(newLeftComponent)
      setRightComponent(newRightComponent)
      updateUI()
    }

    public init(_ newOrientation: Int,
                _ newContinuousLayout: Bool,
                _ newLeftComponent: java.awt.Component,
                _ newRightComponent: java.awt.Component) {
      _orientation = newOrientation
      _continuousLayout = newContinuousLayout
      super.init()
      setLeftComponent(newLeftComponent)
      setRightComponent(newRightComponent)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "SplitPaneUI" }

    override open func updateUI() {
      if let newUI = javax.swing.UIManager.getUI(self) {
        setUI(newUI)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Orientation
    // -------------------------------------------------------------------------

    public func getOrientation() -> Int { _orientation }

    public func setOrientation(_ orientation: Int) {
      _orientation = orientation
      invalidate()
      repaint()
    }

    public var isHorizontal: Bool { _orientation == JSplitPane.HORIZONTAL_SPLIT }

    // -------------------------------------------------------------------------
    // MARK: Children
    // -------------------------------------------------------------------------

    /// The left (or top) component.
    public func getLeftComponent() -> java.awt.Component? { _leftComponent }
    public func getTopComponent()  -> java.awt.Component? { _leftComponent }

    public func setLeftComponent(_ comp: java.awt.Component?) {
      _leftComponent = comp
      comp?.parent = self
      invalidate()
    }

    public func setTopComponent(_ comp: java.awt.Component?) {
      setLeftComponent(comp)
    }

    /// The right (or bottom) component.
    public func getRightComponent()  -> java.awt.Component? { _rightComponent }
    public func getBottomComponent() -> java.awt.Component? { _rightComponent }

    public func setRightComponent(_ comp: java.awt.Component?) {
      _rightComponent = comp
      comp?.parent = self
      invalidate()
    }

    public func setBottomComponent(_ comp: java.awt.Component?) {
      setRightComponent(comp)
    }

    // -------------------------------------------------------------------------
    // MARK: Divider
    // -------------------------------------------------------------------------

    public func getDividerLocation() -> Int { _dividerLocation }

    public func setDividerLocation(_ location: Int) {
      _dividerLocation = location
      doLayout()
      repaint()
    }

    /// Sets the divider location as a proportion of the total size (0.0–1.0).
    public func setDividerLocation(_ proportionalLocation: Double) {
      let total = isHorizontal ? bounds.width : bounds.height
      let available = max(0, total - _dividerSize)
      _dividerLocation = Int(Double(available) * proportionalLocation)
      doLayout()
      repaint()
    }

    public func getDividerSize() -> Int { _dividerSize }

    public func setDividerSize(_ size: Int) {
      _dividerSize = size
      invalidate()
    }

    public func isContinuousLayout() -> Bool { _continuousLayout }
    public func setContinuousLayout(_ b: Bool) { _continuousLayout = b }

    public func isOneTouchExpandable() -> Bool { _oneTouchExpandable }
    public func setOneTouchExpandable(_ b: Bool) { _oneTouchExpandable = b; repaint() }

    public func getResizeWeight() -> Double { _resizeWeight }
    public func setResizeWeight(_ weight: Double) { _resizeWeight = max(0.0, min(1.0, weight)) }

    // -------------------------------------------------------------------------
    // MARK: Effective divider location (with lazy default)
    // -------------------------------------------------------------------------

    /// Returns the actual divider pixel position, computing a 50/50 split
    /// if `setDividerLocation` has never been called.
    func effectiveDividerLocation() -> Int {
      if _dividerLocation >= 0 { return _dividerLocation }
      let total = isHorizontal ? bounds.width : bounds.height
      return max(0, (total - _dividerSize) / 2)
    }

    // -------------------------------------------------------------------------
    // MARK: Layout
    // -------------------------------------------------------------------------

    override open func doLayout() {
      let w = bounds.width
      let h = bounds.height
      let d = _dividerSize
      let pos = effectiveDividerLocation()

      if isHorizontal {
        let leftW  = max(0, pos)
        let rightX = min(w, pos + d)
        let rightW = max(0, w - rightX)

        _leftComponent?.bounds  = java.awt.Rectangle(0, 0, leftW, h)
        _rightComponent?.bounds = java.awt.Rectangle(rightX, 0, rightW, h)
      } else {
        let topH    = max(0, pos)
        let bottomY = min(h, pos + d)
        let bottomH = max(0, h - bottomY)

        _leftComponent?.bounds  = java.awt.Rectangle(0, 0, w, topH)
        _rightComponent?.bounds = java.awt.Rectangle(0, bottomY, w, bottomH)
      }

      (_leftComponent  as? java.awt.Container)?.doLayout()
      (_rightComponent as? java.awt.Container)?.doLayout()
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      if let ui = getUI() {
        ui.paint(g, on: self)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Mouse — drag divider
    // -------------------------------------------------------------------------

    private var _dragging: Bool = false
    private var _dragStart: Int = 0
    private var _dividerAtDragStart: Int = 0

    override open func processMouseEvent(_ e: java.awt.event.MouseEvent) {
      let coord = isHorizontal ? e.getX() : e.getY()
      let pos   = effectiveDividerLocation()

      switch e.getID() {
      case java.awt.event.MouseEvent.MOUSE_PRESSED:
        let d = _dividerSize
        if coord >= pos && coord < pos + d {
          _dragging = true
          _dragStart = coord
          _dividerAtDragStart = pos
        }

      case java.awt.event.MouseEvent.MOUSE_RELEASED:
        _dragging = false

      case java.awt.event.MouseEvent.MOUSE_DRAGGED:
        if _dragging {
          let delta = coord - _dragStart
          let newPos = max(0, _dividerAtDragStart + delta)
          let total  = isHorizontal ? bounds.width : bounds.height
          let clamped = min(newPos, max(0, total - _dividerSize))
          setDividerLocation(clamped)
        }

      default:
        break
      }
      super.processMouseEvent(e)
    }

    // -------------------------------------------------------------------------
    // MARK: Container — expose children for hit-testing
    // -------------------------------------------------------------------------

    override open func getComponents() -> [java.awt.Component] {
      var result: [java.awt.Component] = []
      if let l = _leftComponent  { result.append(l) }
      if let r = _rightComponent { result.append(r) }
      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size — delegated to UI
    // -------------------------------------------------------------------------

    override open func getPreferredSize() -> java.awt.Dimension {
      if let size = ui?.getPreferredSize(self) { return size }
      return super.getPreferredSize()
    }
  }
}
