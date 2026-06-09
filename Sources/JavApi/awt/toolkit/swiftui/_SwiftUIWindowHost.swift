// SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
// SPDX-License-Identifier: MIT
//
// _SwiftUIWindowHost ist die Brücke zwischen der plattformunabhängigen
// java.awt.Frame-API und dem nativen SwiftUI/AppKit-Fenstersystem.
//
// Architekturprinzip:
//   Frame.setVisible(true)
//       → _SwiftUIWindowHost.shared.show(frame)
//           → publiziert Frame via @Published
//               → AWTHostingWindow (SwiftUI Scene / NSWindow) reagiert
//                   → _SwiftUICanvasView rendert Component.paint(Graphics)
//
// Plattformunterstützung:
//   macOS  — NSWindow + SwiftUI Canvas (vollständig)
//   iOS    — UIWindow + SwiftUI Canvas  (vollständig)
//   Linux  — Stub (kein nativer Fenstermanager; für headless-Tests)


#if canImport(SwiftUI)
import SwiftUI

// =============================================================================
// _SwiftUIWindowHost  (Singleton — AppKit/UIKit-agnostisch)
// =============================================================================

/// Singleton-Brücke zwischen `Java.awt.Frame` und dem nativen Fenstersystem.
///
/// ### Integration in die App
///
/// **Option A — SwiftUI App (empfohlen)**
/// ```swift
/// @main struct MyApp: App {
///   var body: some Scene {
///     _SwiftUIHostingScene()          // registriert alle Frame-Fenster
///   }
/// }
/// ```
///
/// **Option B — AppDelegate-basiert (macOS)**
/// ```swift
/// _SwiftUIWindowHost.shared.install(in: NSApplication.shared)
/// ```
///
/// Danach kann portierter Java-Code unverändert laufen:
/// ```swift
/// let frame = Java.awt.Frame("Hallo Welt")
/// frame.setSize(640, 480)
/// frame.add(MyPanel())
/// frame.setVisible(true)   // öffnet ein echtes macOS/iOS-Fenster
/// ```
@MainActor
public final class _SwiftUIWindowHost: ObservableObject, Sendable {
  
  // ---------------------------------------------------------------------------
  // MARK: Singleton
  // ---------------------------------------------------------------------------
  
  /// Singleton instance
  public static let shared = _SwiftUIWindowHost()
  /// private constructor
  private init() {}
  
  // ---------------------------------------------------------------------------
  // MARK: State
  // ---------------------------------------------------------------------------
  
  /// all ordered visible windows
  @Published public private(set) var visibleFrames: [java.awt.Window] = []

  /// Interner Zugriff ohne Lock — nur auf Main-Thread aufrufen.
  private var frameRegistry: [ObjectIdentifier: java.awt.Window] = [:]

  // ---------------------------------------------------------------------------
  // MARK: Fenster-Lebenszyklusverwaltung
  // ---------------------------------------------------------------------------

  /// Make `window` visible, called by `Window.setVisible(true)`.
  /// - Parameter window: the `java.awt.Window` to make visible
  public func show(_ window: java.awt.Window) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let id = ObjectIdentifier(window)
      guard self.frameRegistry[id] == nil else { return }   // Duplikatschutz
      self.frameRegistry[id] = window
      self.visibleFrames.append(window)
    }
  }

  /// Hide `window`, called by  `Window.setVisible(false)` / `dispose()`.
  /// - Parameter window: the `java.awt.Window` to hide
  public func hide(_ window: java.awt.Window) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let id = ObjectIdentifier(window)
      self.frameRegistry.removeValue(forKey: id)
      self.visibleFrames.removeAll { ObjectIdentifier($0) == id }
    }
  }
}

#endif   // canImport(SwiftUI)

