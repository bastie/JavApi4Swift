/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

// =============================================================================
// MARK: - _SwiftUIHostingScene  (SwiftUI App-Integration)
// =============================================================================

/// Eine SwiftUI `Scene`, die automatisch für jeden sichtbaren `Java.awt.Frame`
/// ein Fenster öffnet.
///
/// Einbindung in die App:
/// ```swift
/// @main struct MyApp: App {
///   var body: some Scene {
///     _SwiftUIHostingScene()
///   }
/// }
/// ```
public struct _SwiftUIHostingScene: Scene {
  
  @StateObject private var host = _SwiftUIWindowHost.shared
  
  public init() {}
  
  public var body: some Scene {
#if os(macOS)
    // Auf macOS öffnet jedes Frame als eigenes Fenster.
    WindowGroup("AWT") {
      _SwiftUIMultiWindowView()
        .environmentObject(host)
    }
#else
    // Auf iOS zeigen wir alle Frames gestapelt in einem einzigen Window.
    WindowGroup {
      _SwiftUIMultiWindowView()
        .environmentObject(host)
    }
#endif
  }
}

#endif
