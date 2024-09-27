/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Flushable Java type
/// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
public protocol Flushable {
  
  /// Close the stream
  /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
  func flush () throws
  
  associatedtype Flushable: java.io.Flushable
}
