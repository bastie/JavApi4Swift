/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Flushable Java type
public protocol Flushable {
  
  /// Close the stream
  func flush () throws
  
  associatedtype Flushable: java.io.Flushable
}
