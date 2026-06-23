/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  
  /// `Closeable` type in Java
  /// - Since: Java 1.0
  public protocol Closeable {
    
    /// Close the stream
    /// - Since: Java 1.0
    func close () throws
    
  }
}
