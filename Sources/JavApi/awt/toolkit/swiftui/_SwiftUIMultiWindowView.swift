/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

// ---------------------------------------------------------------------------
// MARK: _SwiftUIMultiWindowView  (zeigt alle sichtbaren Frames)
// ---------------------------------------------------------------------------

/// Root-View, die alle aktuell sichtbaren `java.awt.Window`-Instanzen rendert.
///
/// Auf macOS wird dieser View nicht genutzt — `SwiftUIToolkit` öffnet dort
/// jedes Fenster als eigenes `NSWindow` via `_SwiftUIWindowHost.openNewWindow()`,
/// sodass `visibleFrames` nie befüllt wird.
///
/// Diese View ist für Plattformen ohne natives Multi-Window-Support vorgesehen
/// (iOS, visionOS), wo alle AWT-Fenster als überlappende Panels in einem
/// einzigen SwiftUI-Window dargestellt werden.
///
/// - TODO: Für einen vollständigen virtuellen Desktop fehlen noch:
///   - Drag-to-move (Titelleiste ziehbar per DragGesture)
///   - Z-Order / Fenster per Klick in den Vordergrund bringen
///   - Resize-Griffe an den Fensterrändern
///   - Minimieren / Maximieren innerhalb des Host-Windows
public struct _SwiftUIMultiWindowView: View {
  
  @EnvironmentObject var host: _SwiftUIWindowHost
  
  public init() {}
  
  public var body: some View {
    ZStack(alignment: .topLeading) {
      if host.visibleFrames.isEmpty {
        Text("Kein AWT-Fenster sichtbar")
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ForEach(host.visibleFrames, id: \.objectID) { window in
          _SwiftUIFrameWindow(window: window)
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
