/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Gemeinsame Basisklasse aller Menü-Komponenten — mirrors `java.awt.MenuComponent`.
  @MainActor
  open class MenuComponent {

    public var font: java.awt.Font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    public private(set) var name: String = ""

    public init() {}

    public func getName() -> String      { name }
    public func setName(_ n: String)     { name = n }
    public func getFont() -> java.awt.Font  { font }
    public func setFont(_ f: java.awt.Font) { font = f }

    /// Entfernt diese Komponente aus ihrem übergeordneten Menü (Stub).
    open func removeNotify() {}
  }
}
