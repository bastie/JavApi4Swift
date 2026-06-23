/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  // TODO: with Java 1.4 also implements WindowFocusListener, WindowStateListener
  /// - Since: Java 1.1
  @MainActor
  open class WindowAdapter : WindowListener {
    open func windowOpened     (_ e: java.awt.event.WindowEvent){}
    open func windowClosing    (_ e: java.awt.event.WindowEvent){}
    open func windowClosed     (_ e: java.awt.event.WindowEvent){}
    open func windowIconified  (_ e: java.awt.event.WindowEvent){}
    open func windowDeiconified(_ e: java.awt.event.WindowEvent){}
    open func windowActivated  (_ e: java.awt.event.WindowEvent){}
    open func windowDeactivated(_ e: java.awt.event.WindowEvent){}
  }
}
