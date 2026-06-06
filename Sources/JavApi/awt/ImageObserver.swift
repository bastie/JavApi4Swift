/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Callback für asynchrones Bildladen — mirrors `java.awt.image.ImageObserver`.
  ///
  /// Die Implementierung muss sicherstellen dass `imageUpdate` thread-safe aufgerufen wird.
  /// In der Regel läuft der Callback auf dem Main Thread, da UI-Aktualisierungen
  /// typischerweise dort stattfinden.
  public protocol ImageObserver: AnyObject {
    func imageUpdate(_ img: Image, _ infoflags: Int,
                     _ x: Int, _ y: Int, _ width: Int, _ height: Int) -> Bool
  }
}

extension java.awt.ImageObserver {
  // Flags (als Konstanten nutzbar ohne Instanz)
  public static var WIDTH:      Int { 1 }
  public static var HEIGHT:     Int { 2 }
  public static var PROPERTIES: Int { 4 }
  public static var SOMEBITS:   Int { 8 }
  public static var FRAMEBITS:  Int { 16 }
  public static var ALLBITS:    Int { 32 }
  public static var ERROR:      Int { 64 }
  public static var ABORT:      Int { 128 }
}
