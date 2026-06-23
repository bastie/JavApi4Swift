/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// An exception that provides information on a database access error or
  /// other errors.
  ///
  /// Mirrors `java.sql.SQLException` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  open class SQLException : Exception, @unchecked Sendable {

    private let sqlState : String?
    private let vendorCode : Int

    public override init() {
      self.sqlState = nil
      self.vendorCode = 0
      super.init()
    }

    public override init(_ message: String) {
      self.sqlState = nil
      self.vendorCode = 0
      super.init(message)
    }

    public init(_ message: String, _ sqlState: String) {
      self.sqlState = sqlState
      self.vendorCode = 0
      super.init(message)
    }

    public init(_ message: String, _ sqlState: String, _ vendorCode: Int) {
      self.sqlState = sqlState
      self.vendorCode = vendorCode
      super.init(message)
    }

    public override init(_ newMessage: String, _ newCause: Throwable) {
      self.sqlState = nil
      self.vendorCode = 0
      super.init(newMessage, newCause)
    }

    public override init(_ newCause: Throwable) {
      self.sqlState = nil
      self.vendorCode = 0
      super.init(newCause)
    }

    /// Returns the SQLState identifier or `nil`.
    open func getSQLState() -> String? { return sqlState }

    /// Returns the vendor-specific exception code.
    open func getErrorCode() -> Int { return vendorCode }
  }
}
