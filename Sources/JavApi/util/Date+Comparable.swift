/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util.Date : ComparableJ {
  
  public func compareTo(_ other: java.util.Date?) throws -> Int {
    if let other {
      if self.delegate > other.delegate {
        return 1
      }
      else {
        if self.delegate < other.delegate {
          return -1
        }
        else {
          return 0
        }
      }
    }
    else {
      throw Throwable.NullPointerException()
    }
  }
  

  public typealias Comparable = java.util.Date
  
}
