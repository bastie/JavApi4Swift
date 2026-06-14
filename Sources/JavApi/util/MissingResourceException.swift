/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Thrown when a resource bundle or a named resource cannot be found.
  ///
  /// - Since: Java 1.1
  open class MissingResourceException : RuntimeException, @unchecked Sendable {

    private let className : String
    private let key : String

    public init(_ message: String, _ className: String, _ key: String) {
      self.className = className
      self.key = key
      super.init(message)
    }

    /// Returns the key that could not be found.
    public func getKey() -> String {
      return self.key
    }

    /// Returns the class name of the bundle that was searched.
    public func getClassName() -> String {
      return self.className
    }
  }
}
