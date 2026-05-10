/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class BootstrapMethodError : LinkageError, @unchecked Sendable {
  
  public override init () {
    super.init()
  }
  
  public override init (_ message: String) {
    super.init(message)
  }
  
  public override init (_ newMessage : String, _ newCause : Throwable) {
    super.init(newMessage, newCause)
  }
  
  public init (_ newCause : Throwable) {
    super.init("BootstrapMethodError", newCause)
  }
}
