/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  public protocol AboutHandler {
    
    func handleAbout(_ e: java.awt.desktop.AboutEvent)
  }
}
