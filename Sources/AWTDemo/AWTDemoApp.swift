/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

#if os(macOS)
import AppKit
import SwiftUI

@main
struct AWTDemoApp: App {

  @NSApplicationDelegateAdaptor(AWTDemoDelegate.self) var appDelegate

  var body: some Scene {
    Settings { Text("JavApi⁴Swift AWT Demo").padding() }
  }
}

@MainActor
final class AWTDemoDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)

    let frame = java.awt.Frame("Hallo aus JavApi⁴Swift")
    frame.setSize(480, 320)
    AWTWindowHost.shared.openNewWindow(for: frame)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

#elseif canImport(UIKit)
import SwiftUI

@main
struct AWTDemoApp: App {

  @StateObject private var host = AWTWindowHost.shared

  var body: some Scene {
    WindowGroup {
      AWTMultiWindowView()
        .environmentObject(host)
        .task {
          let frame = java.awt.Frame("Hallo aus JavApi⁴Swift")
          frame.setSize(480, 320)
          frame.setVisible(true)
        }
    }
  }
}

#else
// Linux / headless — kein UI, nur Kompilierbarkeit sicherstellen
import JavApi

@main
struct AWTDemoApp {
  static func main() {
    let frame = java.awt.Frame("Hallo aus JavApi⁴Swift")
    frame.setSize(480, 320)
    frame.setVisible(true)   // → HeadlessToolkit → no-op
    print("AWTDemo: läuft headless, kein Fenster verfügbar.")
  }
}
#endif
