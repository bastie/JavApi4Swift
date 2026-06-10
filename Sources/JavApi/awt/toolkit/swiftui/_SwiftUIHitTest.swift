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

  /// React to a click on the given component.
  static func dispatch(click component: java.awt.Component) {
    _AWTHitTest.dispatch(click: component)
  }
}
#endif
