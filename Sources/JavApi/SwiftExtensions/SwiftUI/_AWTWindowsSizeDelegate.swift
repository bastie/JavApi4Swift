/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation

#if canImport(SwiftUI)
import SwiftUI

#if os(macOS)

internal final class _AWTWindowSizeDelegate: NSObject, NSWindowDelegate {
  
  private weak var awtWindow: java.awt.Window?
  
  init(_ awtWindow: java.awt.Window) {
    self.awtWindow = awtWindow
  }
  
  func windowWillClose(_ notification: Notification) {
    guard let awt = awtWindow else { return }
    // WINDOW_CLOSING wird bereits in Window.setVisible(false) gefeuert,
    // aber nur wenn der Schließvorgang von AWT initiiert wurde.
    // Hier fangen wir den nativen X-Button ab.
    Task { @MainActor in
      awt.processWindowEvent(
        java.awt.event.WindowEvent(awt, java.awt.event.WindowEvent.WINDOW_CLOSING))
    }
  }
  
  func windowDidBecomeKey(_ notification: Notification) {
    guard let awt = awtWindow else { return }
    Task { @MainActor in
      awt.processWindowEvent(
        java.awt.event.WindowEvent(awt, java.awt.event.WindowEvent.WINDOW_ACTIVATED))
    }
  }
  
  func windowDidResignKey(_ notification: Notification) {
    guard let awt = awtWindow else { return }
    Task { @MainActor in
      awt.processWindowEvent(
        java.awt.event.WindowEvent(awt, java.awt.event.WindowEvent.WINDOW_DEACTIVATED))
    }
  }
  
  func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
    guard let awt = awtWindow else { return frameSize }
    
    let minAWT = awt.getMinimumSize()
    let maxAWT = awt.getMaximumSize()
    
    // Titelleistenhöhe = Gesamtfenster − Inhaltsbereich
    let titleBarH = sender.frame.height
    - sender.contentRect(forFrameRect: sender.frame).height
    
    var w = frameSize.width
    var h = frameSize.height
    
    // Minimum
    if minAWT.width  > 0 { w = max(w, CGFloat(minAWT.width))  }
    if minAWT.height > 0 { h = max(h, CGFloat(minAWT.height) + titleBarH) }
    
    // Maximum (Int.max bedeutet unbegrenzt)
    if maxAWT.width  < Int.max { w = min(w, CGFloat(maxAWT.width))  }
    if maxAWT.height < Int.max { h = min(h, CGFloat(maxAWT.height) + titleBarH) }
    
    return NSSize(width: w, height: h)
  }
}

#endif
#endif
