/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics

extension java.awt {
  
  /// java.awt.Graphics2D — mapped auf CGContext
  public class Graphics {
    internal var cgContext: CGContext
    
    internal init(_ context: CGContext) {
      self.cgContext = context
    }
    
    // Farbe setzen
    public func setColor(_ color: java.awt.Color) {
      cgContext.setFillColor(
        CGColor(red: color.red, green: color.green,
                blue: color.blue, alpha: color.alpha))
      cgContext.setStrokeColor(
        CGColor(red: color.red, green: color.green,
                blue: color.blue, alpha: color.alpha))
    }
    
    // Rechteck füllen
    open func fillRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.fill(CGRect(x: x, y: y, width: width, height: height))
    }
    
    // Rechteck zeichnen (nur Rand)
    open func drawRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.stroke(CGRect(x: x, y: y, width: width, height: height))
    }
    
    // Linie zeichnen
    open func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
      cgContext.move(to: CGPoint(x: x1, y: y1))
      cgContext.addLine(to: CGPoint(x: x2, y: y2))
      cgContext.strokePath()
    }
    
    // Oval füllen
    open func fillOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.fillEllipse(in: CGRect(x: x, y: y, width: width, height: height))
    }
    
    // String zeichnen (vereinfacht)
    open func drawString(_ str: String, _ x: Int, _ y: Int) {
      // CoreText für korrekte Textdarstellung
      // (vollständige Impl. erfordert CTFont + CTLine)
    }
  }
}
#else // Non-Apple OSs
extension java.awt {
  public protocol CGContext {
  }
  public class Graphics {
    internal var cgContext: CGContext
    
    internal init(_ context: CGContext) {
      self.cgContext = context
    }
    
    // Farbe setzen
    public func setColor(_ color: java.awt.Color) {
    }
    
    // Rechteck füllen
    open func fillRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
    }
    
    // Rechteck zeichnen (nur Rand)
    open func drawRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
    }
    
    // Linie zeichnen
    open func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
    }
    
    // Oval füllen
    open func fillOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
    }
    
    // String zeichnen (vereinfacht)
    open func drawString(_ str: String, _ x: Int, _ y: Int) {
    }
  }
}
#endif
