/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  
  /// - Since: Java 1.6
  open class IOError : java.lang.Error, @unchecked Sendable {
    
    public override init (_ newCause : Throwable) {
      super.init(newCause)
    }
    
    internal override init (_ message: String) {
      super.init(message)
    }
  }
}
