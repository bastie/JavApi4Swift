/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  open class NotActiveException : ObjectStreamException, @unchecked Sendable {
    
    public override init () {
      super.init()
    }
    
    public override init (_ message: String) {
      super.init(message)
    }
  }
}
