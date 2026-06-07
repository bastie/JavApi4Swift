/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation

#if canImport(SwiftUI)
import SwiftUI

// =============================================================================
// MARK: - AWTHostingScene  (SwiftUI App-Integration)
// =============================================================================

/// Eine SwiftUI `Scene`, die automatisch für jeden sichtbaren `Java.awt.Frame`
/// ein Fenster öffnet.
///
/// Einbindung in die App:
/// ```swift
/// @main struct MyApp: App {
///   var body: some Scene {
///     AWTHostingScene()
///   }
/// }
/// ```
public struct AWTHostingScene: Scene {
  
  @StateObject private var host = AWTWindowHost.shared
  
  public init() {}
  
  public var body: some Scene {
#if os(macOS)
    // Auf macOS öffnet jedes Frame als eigenes Fenster.
    WindowGroup("AWT") {
      AWTMultiWindowView()
        .environmentObject(host)
    }
#else
    // Auf iOS zeigen wir alle Frames gestapelt in einem einzigen Window.
    WindowGroup {
      AWTMultiWindowView()
        .environmentObject(host)
    }
#endif
  }
}

#endif
