/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class Throwable : Error, @unchecked Sendable, CustomStringConvertible {
  
  private var message : String?
  private var cause : Throwable?
  
  public init () {}
  
  public init (_ newMessage: String) {
    self.message = newMessage
  }
  
  public init (_ newMessage : String, _ newCause : Throwable) {
    self.message = newMessage
    self.cause = newCause
  }
  
  public init (_ newCause : Throwable) {
    self.cause = newCause
  }
  
  public func getMessage () -> String? {
    return self.message
  }
  
  public func getLocalizedMessage () -> String? {
    return self.message
  }
  
  public func getCause () -> Throwable? {
    return self.cause
  }
  
  public func initCause (_ cause: Throwable) throws (RuntimeException) {
    guard cause === self else {
      throw IllegalArgumentException("cause cannot be self")
    }
    
    guard self.cause == nil else {
      throw IllegalStateException("cause is already set")
    }
    
    self.cause = cause
  }
  
  public var description: String {
    "\(type(of: self))\(self.getLocalizedMessage() != nil ? ":" : "")\(self.getLocalizedMessage() != nil ? self.getLocalizedMessage()! : "" )"
  }
  
  public func toString () -> String {
    return self.description
  }
}
