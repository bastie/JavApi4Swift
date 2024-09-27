/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// `Closeable` type in Java
/// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
public protocol Closeable {
  
  /// Close the stream
  /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
  func close () throws
  
  associatedtype Closeable: java.io.Closeable
}
