/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

#if canImport(AppKit)
@preconcurrency import AppKit

/// Provides custom diagonal resize cursors that AppKit does not include natively.
///
/// Cursors are rendered once via CoreGraphics and cached as singletons.
@MainActor
enum _SwiftUIDiagonalCursor {

  /// NE ↗︎ / SW ↙︎ diagonal resize cursor (cached).
  static let neSwCursor: NSCursor = makeDiagonalCursor(angle: .pi / 4)

  /// NW ↖︎ / SE ↘︎ diagonal resize cursor (cached).
  static let nwSeCursor: NSCursor = makeDiagonalCursor(angle: -.pi / 4)

  // ---------------------------------------------------------------------------
  // MARK: - Drawing

  /// Draws a double-headed arrow at `angle` radians (0 = pointing right)
  /// into a 24×24 NSImage and returns an NSCursor with a centred hot spot.
  private static func makeDiagonalCursor(angle: CGFloat) -> NSCursor {
    let size: CGFloat = 24
    let half = size / 2
    let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
      guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

      let arrowLen: CGFloat = 9   // distance from centre to tip
      let headLen:  CGFloat = 5   // arrowhead arm length
      let headAngle: CGFloat = .pi * 0.35

      // Draw both arrow directions (angle and angle + π)
      for dir in [angle, angle + .pi] {
        let tx = half + arrowLen * cos(dir)
        let ty = half + arrowLen * sin(dir)

        // Shaft
        ctx.move(to: CGPoint(x: half, y: half))
        ctx.addLine(to: CGPoint(x: tx, y: ty))

        // Arrowhead arms
        for side in [-1.0, 1.0] as [CGFloat] {
          let armAngle = dir + .pi + side * headAngle
          ctx.move(to: CGPoint(x: tx, y: ty))
          ctx.addLine(to: CGPoint(
            x: tx + headLen * cos(armAngle),
            y: ty + headLen * sin(armAngle)))
        }
      }

      // White halo for visibility on dark and light backgrounds
      ctx.setStrokeColor(NSColor.white.cgColor)
      ctx.setLineWidth(3)
      ctx.setLineCap(.round)
      ctx.strokePath()

      // Redraw in black on top
      for dir in [angle, angle + .pi] {
        let tx = half + arrowLen * cos(dir)
        let ty = half + arrowLen * sin(dir)
        ctx.move(to: CGPoint(x: half, y: half))
        ctx.addLine(to: CGPoint(x: tx, y: ty))
        for side in [-1.0, 1.0] as [CGFloat] {
          let armAngle = dir + .pi + side * headAngle
          ctx.move(to: CGPoint(x: tx, y: ty))
          ctx.addLine(to: CGPoint(
            x: tx + headLen * cos(armAngle),
            y: ty + headLen * sin(armAngle)))
        }
      }
      ctx.setStrokeColor(NSColor.black.cgColor)
      ctx.setLineWidth(1.5)
      ctx.strokePath()

      return true
    }
    return NSCursor(image: image, hotSpot: NSPoint(x: half, y: half))
  }
}
#endif   // canImport(AppKit)
#endif   // canImport(SwiftUI)
