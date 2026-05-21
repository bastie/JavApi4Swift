/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.security {
  open class NoSuchAlgorithmException : GeneralSecurityException, @unchecked Sendable {
    
    public override init () {
      super.init()
    }
    
    public override init (_ message: String) {
      super.init(message)
    }
    
    public override init (_ newMessage : String, _ newCause : Throwable) {
      super.init(newMessage, newCause)
    }
    
    public override init (_ newCause : Throwable) {
      super.init(newCause)
    }
  }
}
