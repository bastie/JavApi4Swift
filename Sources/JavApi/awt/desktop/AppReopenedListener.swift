/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  public protocol AppReopenedListener : SystemEventListener {
    
    func appReopened(_ e: AppReopenedEvent)
  }
}
