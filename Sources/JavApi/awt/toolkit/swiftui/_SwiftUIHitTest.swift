/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import Foundation

/// CGPoint-convenience wrapper around the platform-independent `_AWTHitTest`.
@MainActor
enum _SwiftUIHitTest {

  /// Recursively find the deepest visible component that contains `point`.
  /// `point` is in the coordinate system of `root` (i.e. the Frame).
  static func find(at point: CGPoint, in root: java.awt.Component) -> java.awt.Component? {
    _AWTHitTest.find(x: Int(point.x), y: Int(point.y), in: root)
  }

  /// React to a click on the given component with correct local coordinates.
  static func dispatch(click component: java.awt.Component, localX: Int, localY: Int) {
    _AWTHitTest.dispatch(click: component, x: localX, y: localY)
  }

  /// Convenience overload without coordinates (uses component centre).
  static func dispatch(click component: java.awt.Component) {
    _AWTHitTest.dispatch(click: component)
  }

  /// Find the hit component and its local coordinates in one step.
  static func findWithLocal(at point: CGPoint, in root: java.awt.Component) -> (java.awt.Component, Int, Int)? {
    _AWTHitTest.findWithLocal(x: Int(point.x), y: Int(point.y), in: root)
  }
}
#endif
