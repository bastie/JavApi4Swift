/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  public final class OptionalDataException : ObjectStreamException, @unchecked Sendable {

    public var length : Int = -1
    public var eof : Bool = false
    
    public override init () {
      super.init()
    }
  }
}
