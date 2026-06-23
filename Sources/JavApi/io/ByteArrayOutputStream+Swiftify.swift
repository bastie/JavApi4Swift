/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io.ByteArrayOutputStream {

  /// Returns the buffer contents as a `Foundation.Data` value.
  ///
  /// ```swift
  /// let out = java.io.ByteArrayOutputStream()
  /// try out.write(contentsOf: someData)
  /// let data: Data = out.toData()
  /// ```
  public func toData() -> Data {
    return Data(buf[0..<count])
  }

  /// Appends all bytes from a `Foundation.Data` value.
  ///
  /// - Parameter data: The data to append.
  public func write(contentsOf data: Data) throws {
    try write([UInt8](data), 0, data.count)
  }

}

extension java.io.ByteArrayOutputStream : CustomStringConvertible {
  /// `CustomStringConvertible` support — delegates to ``toString()``.
  public var description: String {
    return toString()
  }
}
