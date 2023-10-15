/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension ByteBuffer {
  
  /// Return the underlying byte buffer as Data
  /// - Returns byte buffer
  public func array () -> Data {
    return Data (self.content)
  }
}
