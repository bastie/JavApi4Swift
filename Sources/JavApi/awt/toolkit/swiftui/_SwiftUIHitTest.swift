/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import Foundation

/// Hit-testing and click-dispatch for the AWT component tree.
@MainActor
enum _SwiftUIHitTest {

  // ---------------------------------------------------------------------------
  // MARK: Hit test
  // ---------------------------------------------------------------------------

  /// Recursively find the deepest visible component that contains `point`.
  /// `point` is in the coordinate system of `root` (i.e. the Frame).
  static func find(at point: CGPoint, in root: java.awt.Component) -> java.awt.Component? {
    let b = root.bounds
    let rect = CGRect(x: b.x, y: b.y, width: b.width, height: b.height)
    guard root.visible, rect.contains(point) else { return nil }

    // ScrollPane: translate hit-point into child's coordinate space
    if let sp = root as? java.awt.ScrollPane {
      let vp = sp.getViewportSize()
      let vpRect = CGRect(x: CGFloat(b.x), y: CGFloat(b.y),
                          width: CGFloat(vp.width), height: CGFloat(vp.height))
      if vpRect.contains(point), let child = sp.getChild() {
        let childPoint = CGPoint(x: point.x + CGFloat(sp.scrollX),
                                 y: point.y + CGFloat(sp.scrollY))
        if let hit = find(at: childPoint, in: child) { return hit }
      }
      return root  // scrollbar strip or empty viewport
    }

    // Depth-first: check children first (last added = visually on top)
    if let container = root as? java.awt.Container {
      for child in container.getComponents().reversed() {
        if let hit = find(at: point, in: child) { return hit }
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
        // Radio button: only select, never deselect
        cb.setState(true)
      } else {
        cb.setState(!cb.getState())
      }

    case let tf as java.awt.TextField:
      _ = tf   // focus already set in mouseDown; no extra click action needed

    case let ta as java.awt.TextArea:
      _ = ta   // handled via mouseDown / mouseDragged in _SwiftUINativeCanvas

    case let sb as java.awt.Scrollbar:
      _ = sb   // handled via mouseDown / mouseDragged in _SwiftUINativeCanvas

    case let sp as java.awt.ScrollPane:
      _ = sp   // scrollbar strips handled via mouseDown / mouseDragged in _SwiftUINativeCanvas

    case let ch as java.awt.Choice:
      _ = ch   // popup toggle handled via mouseDown in _SwiftUINativeCanvas

    case let list as java.awt.List:
      _ = list // selection and scrollbar drag handled via mouseDown in _SwiftUINativeCanvas

    default:
      // Fire a generic mouse-clicked event so custom Components can react
      let b = component.bounds
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
#endif
