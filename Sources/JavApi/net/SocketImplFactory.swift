/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// Interface for socket implementation factories.
  ///
  /// Java 1.0 `java.net.SocketImplFactory`. Implement this protocol and
  /// register the factory via `Socket/setSocketImplFactory(_:)` or
  /// `ServerSocket/setSocketFactory(_:)` to provide custom `SocketImpl`
  /// instances.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public protocol SocketImplFactory: Sendable {

    /// Creates a new ``SocketImpl`` instance.
    ///
    /// - Returns: A new ``SocketImpl``.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    func createSocketImpl() -> java.net.SocketImpl
  }
}
