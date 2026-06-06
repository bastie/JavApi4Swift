/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Type-safe Swift enum for `BorderLayout` placement constraints.
  ///
  /// Use instead of the raw `String` constants when calling
  /// `Container.add(_:constraint:)` or `BorderLayout.addLayoutComponent(_:_:)`.
  ///
  /// ```swift
  /// frame.add(toolbar, constraint: .north)
  /// frame.add(canvas,  constraint: .center)
  /// ```
  public enum BorderLayoutConstraint: String {
    case north      = "North"
    case south      = "South"
    case east       = "East"
    case west       = "West"
    case center     = "Center"
    case pageStart  = "First"
    case pageEnd    = "Last"
    case lineStart  = "Before"
    case lineEnd    = "After"
  }
}
