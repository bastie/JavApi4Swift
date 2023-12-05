/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  open class Date {
    
    let delegate : Foundation.Date
    public init () {
      self.delegate = Foundation.Date.now
    }
    
    public func toString() -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEE MMM dd hh:mm:ss zzz yyyy"
      
      let result: String = dateFormatter.string(from: self.delegate)
      return result
    }
  }
  
}
