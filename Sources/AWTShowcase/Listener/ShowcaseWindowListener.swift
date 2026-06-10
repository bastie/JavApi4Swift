/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// WindowListener — gibt Fenster-Lebenszyklusereignisse auf der Konsole aus.
///
/// `windowClosing` wird sowohl durch den roten macOS-Schließen-Button als auch
/// durch `dispose()` ausgelöst. In beiden Fällen wird die App beendet — damit
/// verhält sich der rote Button identisch zum Menüpunkt „Beenden".
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

