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

  /// Recursively find the deepest visible component that contains `(x, y)`,
  /// and return the click coordinates in that component's **local** space.
  ///
  /// `x` and `y` are in the **parent's** coordinate system on entry — i.e. when
  /// called from outside pass window-local coordinates; the recursion translates
  /// into each child's local space automatically.
  ///
  /// Returns `(component, localX, localY)` so callers always have the correct
  /// local coordinates without having to walk the bounds chain themselves.
  static func findWithLocal(x: Int, y: Int, in root: java.awt.Component) -> (java.awt.Component, Int, Int)? {
    let b = root.bounds
    guard root.visible,
          x >= b.x, x < b.x + b.width,
          y >= b.y, y < b.y + b.height
    else { return nil }

    let lx = x - b.x
    let ly = y - b.y

    if let sp = root as? java.awt.ScrollPane {
      let vp = sp.getViewportSize()
      if lx < vp.width, ly < vp.height, let child = sp.getChild() {
        let childX = lx + sp.scrollX
        let childY = ly + sp.scrollY
        if let hit = findWithLocal(x: childX, y: childY, in: child) { return hit }
      }
      return (root, lx, ly)
    }

    if let container = root as? java.awt.Container {
      for child in container.getComponents().reversed() {
        if let hit = findWithLocal(x: lx, y: ly, in: child) { return hit }
      }
    }
    return (root, lx, ly)
  }

  /// Recursively find the deepest visible component that contains `(x, y)`.
  ///
  /// `x` and `y` are in the **parent's** coordinate system on entry — i.e. when
  /// called from outside pass window-local coordinates; the recursion translates
  /// into each child's local space automatically.
  ///
  /// For the root call the window-level component (JFrame / JDialog / Frame) has
  /// its own bounds at (0,0,w,h), so the initial `x,y` are already "inside" it.
  static func find(x: Int, y: Int, in root: java.awt.Component) -> java.awt.Component? {
    findWithLocal(x: x, y: y, in: root).map { $0.0 }
  }

  // ---------------------------------------------------------------------------
  // MARK: Dispatch
  // ---------------------------------------------------------------------------

  /// React to a click on the given component.
  ///
  /// `x` and `y` are the click position in the **component's** local coordinate
  /// system.  Pass the window-relative hit point minus the component's own
  /// origin to get the correct local coordinates.
  static func dispatch(click component: java.awt.Component, x: Int, y: Int) {
    switch component {
    case let btn as javax.swing.JButton:
      btn.doClick()

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
      // Fire a generic mouse-clicked event with the real local coordinates.
      let e = java.awt.event.MouseEvent(
        component,
        java.awt.event.MouseEvent.MOUSE_CLICKED,
        0, 0, x, y, 1, false)
      component.processMouseEvent(e)
    }
  }

  /// Convenience overload — derives local coordinates from the window-relative
  /// hit point and the component's own bounds origin.
  static func dispatch(click component: java.awt.Component) {
    let b = component.bounds
    dispatch(click: component, x: b.width / 2, y: b.height / 2)
  }
}
