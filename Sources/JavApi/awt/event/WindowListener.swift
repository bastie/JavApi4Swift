/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  @MainActor
  public protocol WindowListener: java.util.EventListener {
    func windowOpened     (_ e: java.awt.event.WindowEvent)
    func windowClosing    (_ e: java.awt.event.WindowEvent)
    func windowClosed     (_ e: java.awt.event.WindowEvent)
    func windowIconified  (_ e: java.awt.event.WindowEvent)
    func windowDeiconified(_ e: java.awt.event.WindowEvent)
    func windowActivated  (_ e: java.awt.event.WindowEvent)
    func windowDeactivated(_ e: java.awt.event.WindowEvent)
  }
}
