/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  
  open class InterruptedIOException : IOException, @unchecked Sendable {
    
    public var bytesTransferred : Int = 0
    
    public override init () {
      super.init()
    }
    
    public override init (_ message: String) {
      super.init(message)
    }
  }
}
