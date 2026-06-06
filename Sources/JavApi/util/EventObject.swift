/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util {
  
  open class EventObject : @unchecked Sendable {
    public let source : AnyObject
    
    public init(_ source: AnyObject) {
      // Java throws IllegalArgumentException if source is null, but we can stop this issue over non optional parameter type
      self.source = source
    }
    
    public func getSource() -> AnyObject {
      return source
    }
  }
  
}
