/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  public final class UserSessionEvent : AppEvent, @unchecked Sendable {
    
    private let reason : UserSessionEvent.Reason
    
    public init(_ reason : UserSessionEvent.Reason) {
      self.reason = reason
      super.init()
    }
    
    public var getReason : UserSessionEvent.Reason {
      return self.reason
    }
    
    
    public enum Reason : java.lang.Enum, @unchecked Sendable {
      public typealias E = Reason
      
      case CONSOLE
      case LOCK
      case REMOTE
      case UNSPECIFIED
      
    }
  }
}
