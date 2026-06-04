/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  open class InvalidObjectException : ObjectStreamException, @unchecked Sendable {
    
    public override init (_ message: String) {
      super.init(message)
    }
    
    public override init (_ newMessage : String, _ newCause : Throwable) {
      super.init(newMessage, newCause)
    }
  }
}
