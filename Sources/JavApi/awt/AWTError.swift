/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Schwerwiegender AWT-Laufzeitfehler — mirrors `java.awt.AWTError`.
  ///
  /// In Java erbt `AWTError` von `java.lang.Error` (unchecked, nicht fangbar im Normalfall).
  /// In Swift wird sie als Klasse modelliert — als Referenztyp analog zu Java-Errors,
  /// und konform zu `Error` für einheitliche Swift-Fehlerbehandlung.
  ///
  /// Typischer Verwendungszweck: fatale interne AWT-Fehler, z.B. wenn der Toolkit
  /// nicht initialisiert werden kann.
  public final class AWTError: java.lang.Error, @unchecked Sendable {

    public override init(_ message: String = "") {
      super.init (message)
    }

  }
}
