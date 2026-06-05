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
    public var font: java.awt.Font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)

    /// Entspricht java.awt.Component.paint(Graphics g)
    open func paint(_ g: java.awt.Graphics) { }

    /// Wird vom SwiftUI-Host aufgerufen
    open func repaint() {
      // Signal an den Host-View → setNeedsDisplay equivalent
    }

    /// Returns font metrics for this component's current font.
    public func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: f)
    }
  }
}
