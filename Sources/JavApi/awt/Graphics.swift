/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics
#if canImport(CoreText)
import CoreText
#endif

extension java.awt {

  /// java.awt.Graphics — mapped auf CGContext
  public class Graphics {
    internal var cgContext: CGContext

    public var font: java.awt.Font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)

    internal init(_ context: CGContext) {
      self.cgContext = context
    }

    // -------------------------------------------------------------------------
    // MARK: Font & FontMetrics
    // -------------------------------------------------------------------------

    public func setFont(_ f: java.awt.Font) { font = f }
    public func getFont() -> java.awt.Font  { font     }

    public func getFontMetrics() -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: font)
    }
    public func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: f)
    }

    // -------------------------------------------------------------------------
    // MARK: Color
    // -------------------------------------------------------------------------

    public func setColor(_ color: java.awt.Color) {
      cgContext.setFillColor(
        CGColor(red: color.red, green: color.green,
                blue: color.blue, alpha: color.alpha))
      cgContext.setStrokeColor(
        CGColor(red: color.red, green: color.green,
                blue: color.blue, alpha: color.alpha))
    }

    // -------------------------------------------------------------------------
    // MARK: Shapes
    // -------------------------------------------------------------------------

    open func fillRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.fill(CGRect(x: x, y: y, width: width, height: height))
    }

    open func drawRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.stroke(CGRect(x: x, y: y, width: width, height: height))
    }

    open func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
      cgContext.move(to: CGPoint(x: x1, y: y1))
      cgContext.addLine(to: CGPoint(x: x2, y: y2))
      cgContext.strokePath()
    }

    open func fillOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.fillEllipse(in: CGRect(x: x, y: y, width: width, height: height))
    }

    // -------------------------------------------------------------------------
    // MARK: Text
    // -------------------------------------------------------------------------

    open func drawString(_ str: String, _ x: Int, _ y: Int) {
#if canImport(CoreText)
      let cfName = font.platformName as CFString
      let ctFont  = CTFontCreateWithName(cfName, CGFloat(font.size), nil)
      let attrs   = [kCTFontAttributeName: ctFont,
                     kCTForegroundColorFromContextAttributeName: true] as CFDictionary
      guard let attrStr = CFAttributedStringCreate(kCFAllocatorDefault, str as CFString, attrs) else { return }
      let line = CTLineCreateWithAttributedString(attrStr)
      // AWT baseline: y is distance from top; CoreGraphics baseline: distance from bottom.
      // The CGContext is already flipped in _AWTNativeCanvas (macOS) / draw(_:) (iOS),
      // so we can use y directly as the baseline position.
      cgContext.textPosition = CGPoint(x: CGFloat(x), y: CGFloat(y))
      CTLineDraw(line, cgContext)
#endif
    }
  }
}

#else // Non-Apple OSs

extension java.awt {
  public protocol CGContext {}

  public class Graphics {
    internal var cgContext: CGContext
    public var font: java.awt.Font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)

    internal init(_ context: CGContext) {
      self.cgContext = context
    }

    public func setFont(_ f: java.awt.Font) { font = f }
    public func getFont() -> java.awt.Font  { font     }

    public func getFontMetrics() -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: font)
    }
    public func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: f)
    }

    public func setColor(_ color: java.awt.Color) {}
    open func fillRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func drawRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {}
    open func fillOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func drawString(_ str: String, _ x: Int, _ y: Int) {}
  }
}
#endif
