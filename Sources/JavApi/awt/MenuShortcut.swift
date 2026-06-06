/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Tastaturkürzel für einen `MenuItem` — mirrors `java.awt.MenuShortcut`.
  public struct MenuShortcut: Equatable {

    /// Der Tastaturcode (entspricht `java.awt.event.KeyEvent`-Konstanten).
    public let key: Int
    /// `true` wenn Shift zusätzlich zur Modifier-Taste gedrückt werden muss.
    public let usesShift: Bool

    public init(_ key: Int, usesShift: Bool = false) {
      self.key       = key
      self.usesShift = usesShift
    }

    public func getKey() -> Int          { key }
    public func usesShiftModifier() -> Bool { usesShift }
  }
}
