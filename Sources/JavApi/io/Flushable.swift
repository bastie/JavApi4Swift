/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  /// Flushable Java type
  /// - Since: Java 1.0
  public protocol Flushable {
    
    /// Close the stream
    /// - Since: Java 1.0
    func flush () throws
  }
}
