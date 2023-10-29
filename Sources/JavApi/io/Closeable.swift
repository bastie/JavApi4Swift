/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// `Closeable` type in Java
public protocol Closeable {
  
  /// Close the stream
  func close () throws
  
  associatedtype Closeable: java.io.Closeable
}
