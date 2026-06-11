/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// WindowListener that logs all window lifecycle events to the console.
///
/// Implements all WindowListener methods to demonstrate and track window state
/// changes including: open, close, iconify/deiconify, and focus changes.
///
/// The `windowClosing` event is triggered by both the platform close button
/// (red button on macOS, X on Windows) and by calling `dispose()`. In both
/// cases the app terminates via Toolkit.terminate(), so the close button
/// behaves identically to clicking the "Exit" menu item.
@MainActor
final class ShowcaseWindowListener: java.awt.event.WindowListener {
  func windowOpened     (_ e: java.awt.event.WindowEvent) {
    System.out.println ("Window: opened")
  }
  
  func windowClosing    (_ e: java.awt.event.WindowEvent) {
    System.out.println ("Window: closing")
    java.awt.Toolkit.getDefaultToolkit().terminate()
  }
  
  func windowClosed     (_ e: java.awt.event.WindowEvent) {
    System.out.println ("Window: closed")
  }
  
  func windowIconified  (_ e: java.awt.event.WindowEvent) {
    System.out.println ("Window: iconified")
  }
  
  func windowDeiconified(_ e: java.awt.event.WindowEvent) {
    System.out.println ("Window: deiconified")
  }
  
  func windowActivated  (_ e: java.awt.event.WindowEvent) {
    System.out.println ("Window: activated")
  }
  
  func windowDeactivated(_ e: java.awt.event.WindowEvent) {
    System.out.println ("Window: deactivated")
  }
}

