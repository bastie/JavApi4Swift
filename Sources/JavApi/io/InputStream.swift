/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  open class InputStream {
    public func read() -> Int {
      fatalError("not yet implemented")
    }
    public func read(_ array : [UInt8], _ offset : Int, _ length : Int) -> Int {
      fatalError("not yet implemented")
    }
  }
}

