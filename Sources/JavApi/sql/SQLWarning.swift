/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// A warning that provides information on a database access warning.
  ///
  /// Mirrors `java.sql.SQLWarning` (Java 1.1). Warnings are chained via
  /// ``getNextWarning()``.
  ///
  /// - Since: JavaApi (Java 1.1)
  open class SQLWarning : SQLException, @unchecked Sendable {

    private var nextWarning : SQLWarning?

    public override init() { super.init() }
    public override init(_ message: String) { super.init(message) }
    public override init(_ message: String, _ sqlState: String) { super.init(message, sqlState) }
    public override init(_ message: String, _ sqlState: String, _ vendorCode: Int) {
      super.init(message, sqlState, vendorCode)
    }

    open func getNextWarning() -> SQLWarning? { return nextWarning }
    open func setNextWarning(_ w: SQLWarning?) { nextWarning = w }
  }
}
