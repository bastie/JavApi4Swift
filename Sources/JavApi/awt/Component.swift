/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  
  /// Basisklasse für alle AWT-Komponenten.
  /// paint(Graphics) entspricht draw(_:) in SwiftUI.
  @MainActor
  open class Component {
    public var background: java.awt.Color = .white
    public var foreground: java.awt.Color = .black
    public var bounds: java.awt.Rectangle = .zero
    
    /// Entspricht java.awt.Component.paint(Graphics g)
    open func paint(_ g: java.awt.Graphics) { }
    
    /// Wird vom SwiftUI-Host aufgerufen
    open func repaint() {
      // Signal an den Host-View → setNeedsDisplay equivalent
    }
  }
}
