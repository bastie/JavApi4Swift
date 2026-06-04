/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// Swiftify friendly extension
extension Checksum {
  
  /// Update the checksum with given byte
  /// - Parameter byteValue: for update
  public func update (with byteValue: UInt8) {
    self.update([byteValue])
  }
  /// Update the checksum with given bytes
  /// - Parameter data: bytes for update
  public func update (with data: Data) {
    self.update([UInt8](data))
  }
}

// developer friedly extension in result of Java use int type for byte at many positions
extension Checksum {
  
  public func update (_ b : Int) {
    self.update([UInt8(b)])
  }
}
