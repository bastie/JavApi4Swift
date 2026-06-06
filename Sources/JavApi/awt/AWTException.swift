/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Geprüfte Ausnahme für AWT-Fehler — mirrors `java.awt.AWTException`.
  ///
  /// In Java ist `AWTException` eine checked Exception (erbt von `java.lang.Exception`).
  /// In Swift wird sie als `struct` modelliert, das dem `Error`-Protokoll entspricht,
  /// so dass sie mit `throw` und `try` verwendet werden kann.
  public class AWTException: java.lang.Exception, @unchecked Sendable {

    public override init(_ message: String = "") {
      super.init(message)
    }
  }
}
