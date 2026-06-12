/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// Interface for URL stream handler factories.
  ///
  /// Java 1.0 `java.net.URLStreamHandlerFactory`. Implement this protocol and
  /// register the factory via `URL/setURLStreamHandlerFactory(_:)` to
  /// provide custom ``URLStreamHandler`` instances for specific protocols.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public protocol URLStreamHandlerFactory: Sendable {

    /// Returns a ``URLStreamHandler`` for the given protocol, or `nil` if this
    /// factory does not handle that protocol.
    ///
    /// - Parameter `protocol`: A protocol string such as `"http"` or `"ftp"`.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    func createURLStreamHandler(_ `protocol`: String) -> java.net.URLStreamHandler?
  }
}
