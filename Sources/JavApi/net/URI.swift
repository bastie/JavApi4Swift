/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.net {
  
  public final class URI : ComparableJ {
    
    // TODO: implement this stub
    
    public func compareTo(_ other: java.net.URI?) throws -> Int {
      if self < other! {
        return -1
      }
      else if self > other! {
        return 1
      }
      return 0
    }
    
    public typealias ComparableJ = URI
    
    
    public static func < (lhs: URI, rhs: URI) -> Bool {
      return lhs.toString().compare(rhs.toString()) == .orderedAscending
    }
    
    
    public static func == (lhs: URI, rhs: URI) -> Bool {
      return lhs.toString() ==  rhs.toString()
    }

    public func toString() -> String {
      fatalError("not yet implemented")
    }
  }
}
