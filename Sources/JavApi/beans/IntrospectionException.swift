/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Thrown when an exception occurs during introspection.
  ///
  /// - Since: Java 1.1
  open class IntrospectionException: Exception, @unchecked Sendable {

    public override init(_ message: String) {
      super.init(message)
    }
  }
}
