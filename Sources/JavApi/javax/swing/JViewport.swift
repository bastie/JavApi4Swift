/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The "window" through which a `JScrollPane` displays its view —
  /// mirrors `javax.swing.JViewport`.
  ///
  /// `JViewport` holds exactly one *view* component.  Its `viewPosition`
  /// controls which part of the (potentially larger) view is visible.
  /// `JScrollPane` keeps the viewport's `bounds` equal to the visible
  /// content area and updates `viewPosition` as the user scrolls.
  ///
  /// ```swift
  /// let vp = javax.swing.JViewport()
  /// vp.setView(myBigPanel)
  /// vp.setViewPosition(java.awt.Point(0, 50))
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JViewport: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: View
    // -------------------------------------------------------------------------

    private var _view: java.awt.Component?

    /// The single child component shown through this viewport.
    public func getView() -> java.awt.Component? { _view }

    public func setView(_ view: java.awt.Component?) {
      if let old = _view { remove(old) }
      _view = view
      if let v = view { add(v) }
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: View position  (scroll offset)
    // -------------------------------------------------------------------------

    private var _viewPosition: java.awt.Point = java.awt.Point(0, 0)

    /// The coordinates (within the view) that correspond to the top-left
    /// corner of the viewport.
    public func getViewPosition() -> java.awt.Point { _viewPosition }

    public func setViewPosition(_ p: java.awt.Point) {
      _viewPosition = clampedPosition(p)
      repaint()
    }

    private func clampedPosition(_ p: java.awt.Point) -> java.awt.Point {
      guard let v = _view else { return java.awt.Point(0, 0) }
      let maxX = max(0, v.bounds.width  - bounds.width)
      let maxY = max(0, v.bounds.height - bounds.height)
      return java.awt.Point(
        max(0, min(p.x, maxX)),
        max(0, min(p.y, maxY))
      )
    }

    // -------------------------------------------------------------------------
    // MARK: View size helpers
    // -------------------------------------------------------------------------

    /// The preferred size of the view (or zero if no view).
    public func getViewSize() -> java.awt.Dimension {
      guard let v = _view else { return java.awt.Dimension(0, 0) }
      return v.getPreferredSize()
    }

    /// The visible rectangle within the view's coordinate space.
    public func getViewRect() -> java.awt.Rectangle {
      java.awt.Rectangle(_viewPosition.x, _viewPosition.y,
                         bounds.width, bounds.height)
    }

    // -------------------------------------------------------------------------
    // MARK: Scroll convenience
    // -------------------------------------------------------------------------

    /// Scrolls so that `rect` (in view coordinates) is visible.
    public func scrollRectToVisible(_ rect: java.awt.Rectangle) {
      var px = _viewPosition.x
      var py = _viewPosition.y
      if rect.x < px { px = rect.x }
      else if rect.x + rect.width > px + bounds.width {
        px = rect.x + rect.width - bounds.width
      }
      if rect.y < py { py = rect.y }
      else if rect.y + rect.height > py + bounds.height {
        py = rect.y + rect.height - bounds.height
      }
      setViewPosition(java.awt.Point(px, py))
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func doLayout() {
      guard let view = _view else { return }
      // Give the view its preferred size (at least as large as the viewport),
      // positioned at (0, 0) in the viewport's local coordinate space.
      let ps = view.getPreferredSize()
      let vw = max(bounds.width,  ps.width)
      let vh = max(bounds.height, ps.height)
      view.bounds = java.awt.Rectangle(0, 0, vw, vh)
    }

    override open func paint(_ g: java.awt.Graphics) {
      // The Graphics context is already translated to this component's origin,
      // so local coordinates start at (0, 0) — do NOT use bounds.x / bounds.y.
      let w = bounds.width, h = bounds.height

      // Background
      g.setColor(background)
      g.fillRect(0, 0, w, h)

      guard let view = _view else { return }

      // Clip to viewport area (local coords), then shift by the scroll offset
      // so that view-coordinate (viewPosition.x, viewPosition.y) maps to (0, 0).
      g.save()
      g.clipRect(0, 0, w, h)
      g.translate(-_viewPosition.x, -_viewPosition.y)
      view.paint(g)
      g.restore()
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize() -> java.awt.Dimension {
      _view?.getPreferredSize() ?? java.awt.Dimension(0, 0)
    }

    override open func dispose() {
      _view = nil
      super.dispose()
    }
  }
}
