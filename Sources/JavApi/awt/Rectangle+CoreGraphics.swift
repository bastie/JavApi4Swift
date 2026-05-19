/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics
#endif

extension java.awt.Rectangle {
#if canImport(CoreGraphics)
  /// Converts to a `CGRect`.
  public var cgRect: CGRect {
    CGRect(x: x, y: y, width: width, height: height)
  }
  
  /// Creates a `Rectangle` from a `CGRect` (rounded to nearest integer).
  public convenience init(_ rect: CGRect) {
    self.init(Int(rect.origin.x), Int(rect.origin.y),
              Int(rect.width),    Int(rect.height))
  }
#endif

}
