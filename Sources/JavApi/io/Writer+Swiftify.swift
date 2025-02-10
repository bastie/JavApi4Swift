/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io.Writer {
  public func write(_ intWert : Int) throws {
    if let unicodeScalar = UnicodeScalar(intWert) {
      let character = Character(unicodeScalar)
      try self.write(character)
    }
    else {
      throw java.io.Throwable.IOException("integer \(intWert) cannot be converted to a character")
    }
  }
}
