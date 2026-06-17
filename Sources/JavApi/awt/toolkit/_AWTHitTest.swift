/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Platform-independent hit-testing and click-dispatch for the **AWT** component
// tree (`java.awt.*` only).  Uses no CoreGraphics / SwiftUI and compiles on
// every platform — including Windows.
//
// For mixed AWT+Swing component trees use `_SwingHitTest` as the entry point —
// it handles Swing-specific containers (JScrollPane, …) and delegates to
// `_AWTHitTest` for everything else.
//
// `_SwiftUIHitTest` in the swiftui/ backend wraps `_SwingHitTest` with CGPoint
// convenience overloads for callers that already hold a CGPoint.

/// Hit-testing and click-dispatch for the pure-AWT component tree.
///
/// Do **not** call this directly from toolkit backends — use `_SwingHitTest`
/// instead so that Swing containers are handled correctly.
@MainActor
enum _AWTHitTest {

  // ---------------------------------------------------------------------------
  // MARK: Swing recursion hook
  // ---------------------------------------------------------------------------

  /// Optional callback that re-enters the Swing-aware hit-test for child
  /// components.  `_SwingHitTest` installs this once at startup so that
  /// Swing-specific containers (e.g. `JScrollPane` with a scroll offset) are
  /// handled correctly **even when reached through a plain AWT container**
  /// such as `JTabbedPane` or `JSplitPane`.
  ///
  /// Without this hook the container recursion below would call
  /// `_AWTHitTest.findWithLocal` directly and lose all Swing awareness from
  /// that point downwards — see the type-level comment ("Do not call this
  /// directly … use `_SwingHitTest`").
  ///
  /// Write-once at startup, read-only afterwards — therefore
  /// `nonisolated(unsafe)` is safe (see Java2Swift.md, "static variables and
  /// Swift 6 concurrency").
  nonisolated(unsafe)
  static var swingRecurse:
    (@MainActor (_ x: Int, _ y: Int, _ root: java.awt.Component)
      -> (java.awt.Component, Int, Int)?)? = nil

  /// Recurse into a child component, preferring the Swing-aware path when the
  /// hook is installed; falls back to the pure-AWT recursion otherwise.
  private static func recurse(_ x: Int, _ y: Int, _ root: java.awt.Component)
    -> (java.awt.Component, Int, Int)? {
    if let hook = swingRecurse { return hook(x, y, root) }
    return findWithLocal(x: x, y: y, in: root)
  }

  // ---------------------------------------------------------------------------
  // MARK: Hit test
  // ---------------------------------------------------------------------------

  /// Walk up the parent chain from `component` and return the nearest
  /// `ScrollPane`, or `nil` if none is found.
  ///
  /// Used by mouse-wheel handlers: the hit-test returns the deepest component
  /// (e.g. a Canvas inside a ScrollPane), but scrolling should be applied to
  /// the enclosing pane.
  /// Walk the parent chain to compute the frame-absolute origin of `component`.
  /// Returns the sum of all `bounds.x/y` values from root down to `component`.
  static func absoluteOrigin(_ component: java.awt.Component) -> (x: Int, y: Int) {
    var x = component.bounds.x
    var y = component.bounds.y
    var p = component.parent
    while let parent = p {
      x += parent.bounds.x
      y += parent.bounds.y
      p = parent.parent
    }
    return (x, y)
  }

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
          y >= b.y
    else { return nil }

    // Leaf components require a strict upper-bound check.
    // Containers (except ScrollPane) allow children to overflow their declared
    // height — FlowLayout may wrap into a second row that exceeds bounds.height
    // if the container's preferred-size was computed before the width was known.
    let lx = x - b.x
    let ly = y - b.y

    if let sp = root as? java.awt.ScrollPane {
      // ScrollPane: strict bounds check (clips content)
      guard ly < b.height else { return nil }
      let vp = sp.getViewportSize()
      if lx < vp.width, ly < vp.height, let child = sp.getChild() {
        let childX = lx + sp.scrollX
        let childY = ly + sp.scrollY
        if let hit = recurse(childX, childY, child) { return hit }
      }
      return (root, lx, ly)
    }

    if let container = root as? java.awt.Container {
      // For containers: try children first (they may lie below bounds.height).
      // Use `recurse` so that Swing-specific containers nested below a plain
      // AWT container (e.g. a JScrollPane inside a JSplitPane inside a
      // JTabbedPane) regain their Swing-aware coordinate handling.
      for child in container.getComponents().reversed() {
        if let hit = recurse(lx, ly, child) { return hit }
      }
      // Only claim the container itself if the click is within its own bounds.
      guard ly < b.height else { return nil }
      return (root, lx, ly)
    }

    // Leaf: strict check
    guard ly < b.height else { return nil }
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
  /// Dispatch a click for **AWT** components only.
  ///
  /// Swing components are not handled here — use `_SwingHitTest.dispatch(click:x:y:)`
  /// which handles Swing types first and falls through to this method.
  static func dispatch(click component: java.awt.Component, x: Int, y: Int) {
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
