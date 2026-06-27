/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  public protocol ScreenSleepListener : SystemEventListener{
    
    func screenAboutToSleep(_ e: ScreenSleepEvent)
    func screenAwoke (_ e: ScreenSleepEvent)
  }
}
