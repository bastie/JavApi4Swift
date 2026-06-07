/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation

#if canImport(SwiftUI)
import SwiftUI

// =============================================================================
// MARK: - AWTFrameWindow  (ein Fenster pro java.awt.Window)
// =============================================================================

/// SwiftUI-View, das ein `java.awt.Window` als vollständiges Fenster darstellt
/// — Titelzeile (falls `Frame`) + Inhalt.
public struct AWTFrameWindow: View {
  
  @ObservedObject var host = AWTWindowHost.shared
  public let window: java.awt.Window
  
  /// Rückwärtskompatibel: nimmt weiterhin einen Frame an.
  public init(frame: java.awt.Frame) {
    self.window = frame
  }
  
  public init(window: java.awt.Window) {
    self.window = window
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      
      // Titelzeile (auf Plattformen ohne native Fensterchrome)
      HStack {
        Text((window as? java.awt.Frame)?.title ?? "")
          .font(.headline)
          .padding(.horizontal, 8)
        Spacer()
        Button("✕") { AWTWindowHost.shared.hide(window) }
          .padding(.trailing, 8)
      }
      .frame(height: 28)
      .background(Color(white: 0.85))
      
      // Zeichenfläche
      AWTCanvasView(component: window)
    }
    .frame(
      width:  CGFloat(window.bounds.width),
      height: CGFloat(window.bounds.height + 28))
    .background(
      Color(
        red:   window.background.red,
        green: window.background.green,
        blue:  window.background.blue))
  }
}
#endif
