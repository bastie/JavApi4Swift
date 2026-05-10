/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {
  open class DataFormatException : Exception, @unchecked Sendable {
    
    public override init () {
      super.init()
    }
    
    public override init (_ message: String) {
      super.init(message)
    }
  }
}
