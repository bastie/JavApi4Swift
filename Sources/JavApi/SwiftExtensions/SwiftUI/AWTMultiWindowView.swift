/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation

#if canImport(SwiftUI)
import SwiftUI

// ---------------------------------------------------------------------------
// MARK: AWTMultiWindowView  (zeigt alle sichtbaren Frames)
// ---------------------------------------------------------------------------

/// Root-View, die alle aktuell sichtbaren `java.awt.Window`-Instanzen rendert.
///
/// Auf macOS erscheint jedes Window als überlappbares Panel innerhalb des
/// SwiftUI-Fensters. Für echte separate NSWindow-Instanzen kann
/// `AWTWindowHost` mit AppKit erweitert werden (siehe `openNewWindow`).
public struct AWTMultiWindowView: View {
  
  @EnvironmentObject var host: AWTWindowHost
  
  public init() {}
  
  public var body: some View {
    ZStack(alignment: .topLeading) {
      if host.visibleFrames.isEmpty {
        Text("Kein AWT-Fenster sichtbar")
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ForEach(host.visibleFrames, id: \.objectID) { window in
          AWTFrameWindow(window: window)
            .offset(
              x: CGFloat(window.bounds.x),
              y: CGFloat(window.bounds.y))
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(white: 0.95))
  }
}
#endif
