/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  public protocol AppHiddenListener : SystemEventListener {
    
    func appHidden(_ e: AppHiddenEvent)
    func appUnhidden(_ e: AppHiddenEvent)
  }
}
