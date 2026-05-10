/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class AssertionError : JError, @unchecked Sendable {
  
  public override init () {
    super.init()
  }
  
  public init (_ message: Bool) {
    super.init("\(message)")
  }
  
  public init (_ message: Character) {
    super.init("\(message)")
  }
  
  public init (_ message: Double) {
    super.init("\(message)")
  }
  
  public init (_ message: Float) {
    super.init("\(message)")
  }
  
  public init (_ message: Int) {
    super.init("\(message)")
  }

  public init (_ message: Long) {
    super.init("\(message)")
  }
  
  public init (_ message: AnyObject) {
    super.init("\(message)")
  }

  public override init (_ newMessage : String, _ newCause : Throwable?) {
    super.init(newMessage)
    if let cause = newCause {
      do {
        try self.initCause(cause)
      }
      catch _ {}
    }
  }
  
}
