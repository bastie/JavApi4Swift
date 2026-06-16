/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Entry point for hit-testing and click-dispatch in mixed AWT+Swing component
// trees.  Swing-specific containers (JScrollPane, …) are handled here; all
// pure-AWT cases are delegated to `_AWTHitTest`.
//
// Toolkit backends (SwiftUI, Win32, X11) should call `_SwingHitTest` — never
// `_AWTHitTest` directly.

/// Hit-testing and click-dispatch for mixed AWT + Swing component trees.
///
/// Use this as the single entry point from all toolkit backends.  It intercepts
/// Swing-specific containers before falling through to the AWT implementation.
@MainActor
enum _SwingHitTest {

  // ---------------------------------------------------------------------------
  // MARK: Hit test
  // ---------------------------------------------------------------------------

  /// Recursively find the deepest visible component that contains `(x, y)`,
  /// returning the component and the click coordinates in its **local** space.
  ///
  /// Swing containers that need special coordinate translation (e.g. `JScrollPane`
  /// with scroll offset) are handled here.  All other components are forwarded
  /// to `_AWTHitTest.findWithLocal`.
  static func findWithLocal(x: Int, y: Int, in root: java.awt.Component) -> (java.awt.Component, Int, Int)? {
    let b = root.bounds
    guard root.visible,
          x >= b.x, x < b.x + b.width,
          y >= b.y
    else { return nil }

    let lx = x - b.x
    let ly = y - b.y

    // ── Swing: JScrollPane ──────────────────────────────────────────────────
    if let jsp = root as? javax.swing.JScrollPane {
      // Strict bounds clip — JScrollPane does not allow overflow.
      guard ly < b.height else { return nil }
      let vp  = jsp.getViewport()
      let vpB = vp.bounds   // relative to JScrollPane
      if lx >= vpB.x, lx < vpB.x + vpB.width,
         ly >= vpB.y, ly < vpB.y + vpB.height {
        // Inside viewport — translate into view's scrolled coordinate space.
        let viewPos = vp.getViewPosition()
        let viewX   = lx - vpB.x + viewPos.x
        let viewY   = ly - vpB.y + viewPos.y
        if let view = vp.getView(),
           let hit  = findWithLocal(x: viewX, y: viewY, in: view) {
          return hit
        }
        return (vp, lx - vpB.x, ly - vpB.y)
      }
      // Outside viewport: try scrollbars
      for child in jsp.getComponents().reversed() {
        if child === vp { continue }
        if let hit = findWithLocal(x: lx, y: ly, in: child) { return hit }
      }
      return (root, lx, ly)
    }

    // ── All other components: delegate to _AWTHitTest ───────────────────────
    // Re-call with the same (x, y) in parent space — _AWTHitTest.findWithLocal
    // will subtract b.x/b.y again, which is correct because `root` is still
    // at position (b.x, b.y) in its parent's space.
    return _AWTHitTest.findWithLocal(x: x, y: y, in: root)
  }

  /// Recursively find the deepest visible component that contains `(x, y)`.
  static func find(x: Int, y: Int, in root: java.awt.Component) -> java.awt.Component? {
    findWithLocal(x: x, y: y, in: root).map { $0.0 }
  }

  // ---------------------------------------------------------------------------
  // MARK: Forwarded helpers (unchanged from _AWTHitTest)
  // ---------------------------------------------------------------------------

  static func absoluteOrigin(_ component: java.awt.Component) -> (x: Int, y: Int) {
    _AWTHitTest.absoluteOrigin(component)
  }

  /// Walk the parent chain to find the nearest AWT `ScrollPane`.
  /// For Swing use `nearestJScrollPane(_:)`.
  static func nearestScrollPane(_ component: java.awt.Component?) -> java.awt.ScrollPane? {
    _AWTHitTest.nearestScrollPane(component)
  }

  /// Walk the parent chain to find the nearest `JScrollPane`.
  static func nearestJScrollPane(_ component: java.awt.Component?) -> javax.swing.JScrollPane? {
    var node: java.awt.Component? = component
    while let n = node {
      if let jsp = n as? javax.swing.JScrollPane { return jsp }
      node = n.parent
    }
    return nil
  }

  // ---------------------------------------------------------------------------
  // MARK: Dispatch
  // ---------------------------------------------------------------------------

  /// React to a click on the given component.
  ///
  /// Swing components are handled first; AWT components fall through to
  /// `_AWTHitTest.dispatch(click:x:y:)`.
  static func dispatch(click component: java.awt.Component, x: Int, y: Int) {
    switch component {
    // ── Swing ────────────────────────────────────────────────────────────────
    case let btn as javax.swing.JButton:
      btn.doClick()

    case let tf as javax.swing.text.JTextComponent:
      _ = tf   // focus + caret set in mouseDown; no extra action here

    case let jsp as javax.swing.JScrollPane:
      _ = jsp  // scroll handled via mouseDown / mouseDragged

    // ── AWT ──────────────────────────────────────────────────────────────────
    default:
      _AWTHitTest.dispatch(click: component, x: x, y: y)
    }
  }

  /// Convenience overload — uses the centre of the component as local coords.
  static func dispatch(click component: java.awt.Component) {
    let b = component.bounds
    dispatch(click: component, x: b.width / 2, y: b.height / 2)
  }
}
