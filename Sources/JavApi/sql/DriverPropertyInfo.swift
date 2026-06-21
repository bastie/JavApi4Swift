/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// Driver properties for a connection to a database.
  ///
  /// Mirrors `java.sql.DriverPropertyInfo` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  public final class DriverPropertyInfo {
    public var name: String
    public var value: String?
    public var required: Bool = false
    public var description: String?
    public var choices: [String]?

    public init(_ name: String, _ value: String?) {
      self.name = name
      self.value = value
    }
  }
}
