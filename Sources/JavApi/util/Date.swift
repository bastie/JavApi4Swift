/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  open class Date {
    
    internal var delegate : Foundation.Date
    public init () {
      self.delegate = Foundation.Date.now
    }
    
    public func toString() -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEE MMM dd hh:mm:ss zzz yyyy"
      
      let result: String = dateFormatter.string(from: self.delegate)
      return result
    }
    
    /// Constructor to create a Date instance with GregorianCalendar to implement GregorianCalendar.getTime
    internal init (_ gregorianCalendar : java.util.GregorianCalendar) {
      let userCalendar = Calendar(identifier: .gregorian)
      self.delegate = userCalendar.date(from: gregorianCalendar.dateComponents)!
    }
    
  }
}
