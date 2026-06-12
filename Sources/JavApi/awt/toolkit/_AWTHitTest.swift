/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Platform-independent hit-testing and click-dispatch for the AWT component
// tree.  Uses only java.awt types (no CoreGraphics / SwiftUI) so it compiles
// on every platform — including Windows.
//
// _SwiftUIHitTest in the swiftui/ backend wraps these helpers with CGPoint
// convenience overloads for callers that already hold a CGPoint.

/// Hit-testing and click-dispatch for the AWT component tree.
@MainActor
enum _AWTHitTest {

  // ---------------------------------------------------------------------------
  // MARK: Hit test
  // ---------------------------------------------------------------------------

  /// Walk up the parent chain from `component` and return the nearest
  /// `ScrollPane`, or `nil` if none is found.
  ///
  /// Used by mouse-wheel handlers: the hit-test returns the deepest component
  /// (e.g. a Canvas inside a ScrollPane), but scrolling should be applied to
  /// the enclosing pane.
  static func nearestScrollPane(_ component: java.awt.Component?) -> java.awt.ScrollPane? {
    var node: java.awt.Component? = component
    while let n = node {
      if let sp = n as? java.awt.ScrollPane { return sp }
      node = n.parent
    }
    return nil
  }

  /// Recursively find the deepest visible component that contains `(x, y)`.
  /// Coordinates are in the coordinate system of `root` (i.e. the Frame).
  static func find(x: Int, y: Int, in root: java.awt.Component) -> java.awt.Component? {
    let b = root.bounds
    guard root.visible,
          x >= b.x, x < b.x + b.width,
          y >= b.y, y < b.y + b.height
    else { return nil }

    // ScrollPane: translate hit-point into child's coordinate space
    if let sp = root as? java.awt.ScrollPane {
      let vp = sp.getViewportSize()
      let vpMaxX = b.x + vp.width
      let vpMaxY = b.y + vp.height
      if x < vpMaxX, y < vpMaxY, let child = sp.getChild() {
        let childX = x + sp.scrollX
        let childY = y + sp.scrollY
        if let hit = find(x: childX, y: childY, in: child) { return hit }
      }
      return root  // scrollbar strip or empty viewport
    }

    // Depth-first: check children first (last added = visually on top)
    if let container = root as? java.awt.Container {
      for child in container.getComponents().reversed() {
        if let hit = find(x: x, y: y, in: child) { return hit }
      }
    }
    return root
  }

  // ---------------------------------------------------------------------------
  // MARK: Dispatch
  // ---------------------------------------------------------------------------

  /// React to a click on the given component.
  static func dispatch(click component: java.awt.Component) {
    switch component {
    case let btn as java.awt.Button:
      btn.doClick()

    case let cb as java.awt.Checkbox:
      if cb.getCheckboxGroup() != nil {
        cb.setState(true)   // radio button: only select, never deselect
      } else {
        cb.setState(!cb.getState())
      }

    case let tf as java.awt.TextField:
      _ = tf   // focus already set in mouseDown; no extra click action needed

    case let ta as java.awt.TextArea:
      _ = ta   // handled via mouseDown / mouseDragged in the platform canvas

    case let sb as java.awt.Scrollbar:
      _ = sb   // handled via mouseDown / mouseDragged in the platform canvas

    case let sp as java.awt.ScrollPane:
      _ = sp   // scrollbar strips handled via mouseDown / mouseDragged

    case let ch as java.awt.Choice:
      _ = ch   // popup toggle handled via mouseDown in the platform canvas

    case let list as java.awt.List:
      _ = list // selection and scrollbar drag handled via mouseDown

    default:
      // Fire a generic mouse-clicked event so custom Components can react
      let b  = component.bounds
      let cx = b.x + b.width  / 2
      let cy = b.y + b.height / 2
      let e  = java.awt.event.MouseEvent(
        component,
        java.awt.event.MouseEvent.MOUSE_CLICKED,
        0, 0, cx, cy, 1, false)
      component.processMouseEvent(e)
    }
  }
}
