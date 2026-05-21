// SPDX-License-Identifier: Apache-2.0
//
// AWTWindowHost.swift
// JavApi⁴Swift
//
// Copyright 2025 Sebastian Ritter and contributors.
// Licensed under the Apache License, Version 2.0.
//
// AWTWindowHost ist die Brücke zwischen der plattformunabhängigen
// java.awt.Frame-API und dem nativen SwiftUI/AppKit-Fenstersystem.
//
// Architekturprinzip:
//   Frame.setVisible(true)
//       → AWTWindowHost.shared.show(frame)
//           → publiziert Frame via @Published
//               → AWTHostingWindow (SwiftUI Scene / NSWindow) reagiert
//                   → AWTCanvasView rendert Component.paint(Graphics)
//
// Plattformunterstützung:
//   macOS  — NSWindow + SwiftUI Canvas (vollständig)
//   iOS    — UIWindow + SwiftUI Canvas  (vollständig)
//   Linux  — Stub (kein nativer Fenstermanager; für headless-Tests)

import Foundation

#if canImport(SwiftUI)
import SwiftUI

// =============================================================================
// MARK: - AWTWindowHost  (Singleton — AppKit/UIKit-agnostisch)
// =============================================================================

/// Singleton-Brücke zwischen `Java.awt.Frame` und dem nativen Fenstersystem.
///
/// ### Integration in die App
///
/// **Option A — SwiftUI App (empfohlen)**
/// ```swift
/// @main struct MyApp: App {
///   var body: some Scene {
///     AWTHostingScene()          // registriert alle Frame-Fenster
///   }
/// }
/// ```
///
/// **Option B — AppDelegate-basiert (macOS)**
/// ```swift
/// AWTWindowHost.shared.install(in: NSApplication.shared)
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
public final class AWTWindowHost: ObservableObject, Sendable {
  
  // ---------------------------------------------------------------------------
  // MARK: Singleton
  // ---------------------------------------------------------------------------
  
  public static let shared = AWTWindowHost()
  private init() {}
  
  // ---------------------------------------------------------------------------
  // MARK: State
  // ---------------------------------------------------------------------------
  
  /// Alle aktuell sichtbaren Frames, in Anzeigereihenfolge.
  @Published public private(set) var visibleFrames: [java.awt.Frame] = []
  
  /// Interner Zugriff ohne Lock — nur auf Main-Thread aufrufen.
  private var frameRegistry: [ObjectIdentifier: java.awt.Frame] = [:]
  
  // ---------------------------------------------------------------------------
  // MARK: Frame-Lebenszyklusverwaltung
  // ---------------------------------------------------------------------------
  
  /// Macht `frame` sichtbar. Wird von `Frame.setVisible(true)` aufgerufen.
  public func show(_ frame: java.awt.Frame) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let id = ObjectIdentifier(frame)
      guard self.frameRegistry[id] == nil else { return }   // Duplikatschutz
      self.frameRegistry[id] = frame
      self.visibleFrames.append(frame)
    }
  }
  
  /// Versteckt `frame`. Wird von `Frame.setVisible(false)` / `dispose()` aufgerufen.
  public func hide(_ frame: java.awt.Frame) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let id = ObjectIdentifier(frame)
      self.frameRegistry.removeValue(forKey: id)
      self.visibleFrames.removeAll { ObjectIdentifier($0) == id }
    }
  }
}

// =============================================================================
// MARK: - AWTCanvasView  (rendert einen java.awt.Component via SwiftUI Canvas)
// =============================================================================

/// SwiftUI-View, das einen `Java.awt.Component` durch Aufruf von
/// `paint(Graphics)` zeichnet.
///
/// Die SwiftUI `Canvas` stellt einen `CGContext` bereit; daraus wird eine
/// `Java.awt.Graphics2D`-Instanz gebaut und an `component.paint` übergeben.
struct AWTCanvasView: View {
  
  /// Die zu rendernde AWT-Komponente.
  let component: java.awt.Component
  
  var body: some View {
    _AWTCanvasViewRepresentable(component: component)
      .frame(
        width:  CGFloat(component.bounds.width),
        height: CGFloat(component.bounds.height))
  }
}

// ---------------------------------------------------------------------------
// MARK: ViewRepresentable-Brücke (macOS / iOS)
// ---------------------------------------------------------------------------

#if os(macOS)
import AppKit

private struct _AWTCanvasViewRepresentable: NSViewRepresentable {
  
  let component: java.awt.Component
  
  func makeNSView(context: Context) -> _AWTNativeCanvas {
    let v = _AWTNativeCanvas()
    v.component = component
    return v
  }
  
  func updateNSView(_ nsView: _AWTNativeCanvas, context: Context) {
    nsView.component = component
    nsView.needsDisplay = true
  }
}

/// Natives NSView, das `component.paint(g)` in `draw(_:)` aufruft.
final class _AWTNativeCanvas: NSView {
  
  var component: java.awt.Component?
  
  override func draw(_ dirtyRect: NSRect) {
    guard let component,
          let cgContext = NSGraphicsContext.current?.cgContext else { return }
    // Koordinatensystem: AppKit hat Y-Achse nach oben, AWT nach unten.
    // Spiegeln damit paint()-Code portlos funktioniert.
    cgContext.saveGState()
    cgContext.translateBy(x: 0, y: bounds.height)
    cgContext.scaleBy(x: 1, y: -1)
    
    let g = java.awt.Graphics2D(cgContext)
    component.paint(g)
    
    cgContext.restoreGState()
  }
}

#elseif os(iOS) || os(tvOS)
import UIKit

private struct _AWTCanvasViewRepresentable: UIViewRepresentable {
  
  let component: java.awt.Component
  
  func makeUIView(context: Context) -> _AWTNativeCanvas {
    let v = _AWTNativeCanvas()
    v.component = component
    return v
  }
  
  func updateUIView(_ uiView: _AWTNativeCanvas, context: Context) {
    uiView.component = component
    uiView.setNeedsDisplay()
  }
}

/// Natives UIView, das `component.paint(g)` in `draw(_:)` aufruft.
final class _AWTNativeCanvas: UIView {
  
  var component: java.awt.Component?
  
  override func draw(_ rect: CGRect) {
    guard let component,
          let cgContext = UIGraphicsGetCurrentContext() else { return }
    // UIKit: Y-Achse bereits nach unten — kein Flip nötig.
    let g = java.awt.Graphics2D(cgContext)
    component.paint(g)
  }
}

#else
// ---------------------------------------------------------------------------
// MARK: Linux / headless stub
// ---------------------------------------------------------------------------

private struct _AWTCanvasViewRepresentable: View {
  let component: java.awt.Component
  var body: some View { EmptyView() }
}

#endif   // os(macOS) / os(iOS) / else


// =============================================================================
// MARK: - AWTFrameWindow  (ein Fenster pro java.awt.Frame)
// =============================================================================

/// SwiftUI-View, das einen einzelnen `Java.awt.Frame` als vollständiges
/// Fenster darstellt — Titelzeile + Inhalt.
struct AWTFrameWindow: View {
  
  @ObservedObject var host = AWTWindowHost.shared
  let frame: java.awt.Frame
  
  var body: some View {
    VStack(spacing: 0) {
      
      // Titelzeile (auf Plattformen ohne native Fensterchrome)
      HStack {
        Text(frame.title)
          .font(.headline)
          .padding(.horizontal, 8)
        Spacer()
        Button("✕") { AWTWindowHost.shared.hide(frame) }
          .padding(.trailing, 8)
      }
      .frame(height: 28)
      .background(Color(white: 0.85))
      
      // Zeichenfläche
      AWTCanvasView(component: frame)
    }
    .frame(
      width:  CGFloat(frame.bounds.width),
      height: CGFloat(frame.bounds.height + 28))
    // Hintergrundfarbe aus frame.background
    .background(
      Color(
        red:   frame.background.red,
        green: frame.background.green,
        blue:  frame.background.blue))
  }
}

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

// ---------------------------------------------------------------------------
// MARK: AWTMultiWindowView  (zeigt alle sichtbaren Frames)
// ---------------------------------------------------------------------------

/// Root-View, die alle aktuell sichtbaren `Java.awt.Frame`-Instanzen rendert.
///
/// Auf macOS erscheint jedes Frame als überlappbares Panel innerhalb des
/// SwiftUI-Fensters.  Für echte separate NSWindow-Instanzen kann
/// `AWTWindowHost` mit AppKit erweitert werden (siehe `openNewWindow`).
struct AWTMultiWindowView: View {
  
  @EnvironmentObject var host: AWTWindowHost
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      if host.visibleFrames.isEmpty {
        Text("Kein AWT-Fenster sichtbar")
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ForEach(host.visibleFrames, id: \.title) { frame in
          AWTFrameWindow(frame: frame)
            .offset(
              x: CGFloat(frame.bounds.x),
              y: CGFloat(frame.bounds.y))
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(white: 0.95))
  }
}

// =============================================================================
// MARK: - macOS: Echte separate NSWindow-Instanzen (optional)
// =============================================================================

#if os(macOS)
import AppKit

extension AWTWindowHost {
  
  /// Öffnet `frame` als eigenständiges `NSWindow` (statt als SwiftUI-Panel).
  ///
  /// Rufe dies statt `show(_:)` auf, wenn du echte separate Fenster
  /// mit nativem macOS-Chrome möchtest:
  /// ```swift
  /// AWTWindowHost.shared.openNewWindow(for: frame)
  /// ```
  @MainActor
  public func openNewWindow(for frame: java.awt.Frame) {
    let hostingView = NSHostingView(
      rootView: AWTFrameWindow(frame: frame)
        .environmentObject(self))
    
    let window = NSWindow(
      contentRect: NSRect(
        x: frame.bounds.x, y: frame.bounds.y,
        width: frame.bounds.width, height: frame.bounds.height + 28),
      styleMask: [.titled, .closable, .resizable, .miniaturizable],
      backing: .buffered,
      defer: false)
    
    window.title = frame.title
    window.contentView = hostingView
    window.isReleasedWhenClosed = false
    window.makeKeyAndOrderFront(nil)
    
    // Schließen-Button → Frame.setVisible(false)
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification,
      object: window,
      queue: .main) { [weak self] _ in
        guard let self else { return }
        Task { @MainActor in
          self.hide(frame)
        }
      }
  }
}
#endif   // os(macOS)

#endif   // canImport(SwiftUI)

