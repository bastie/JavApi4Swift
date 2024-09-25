/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  open class Date {
    
    internal var delegate : Foundation.Date
    public init () {
      self.delegate = Foundation.Date.now
    }
    
    /// Create a new ``java.util.Date`` instance at 1. Januar 1970
    /// - Parameters:
    /// - Parameter millisecondsSince1970 milliseconds since 1970
    /// - Note: In result of Swift works with seconds instead of milliseconds the milliseconds part are ignored
    /// - Since: JavaApi &gt; 0.17.0 (Java 1.0)
    public convenience init(_ millisecondsSince1970: Int64) {
      self.init()
      let secondsSince1970 = millisecondsSince1970 / 1000
      let interval = TimeInterval(secondsSince1970)
      delegate = Foundation.Date(timeIntervalSince1970: interval)
    }
    
    /// time in milliseconds since 1. January 1970
    /// - Note: In result of Swift works with seconds instead of milliseconds this implementation it returns time in seconds `*` 1000
    /// - Returns: milliseconds since 1. January 1970
    /// - Since: JavaApi &gt; 0.17.0 (Java 1.0)
    open func getTime() -> Int64 {
      return Int64(self.delegate.timeIntervalSince1970) * 1000
    }
    
    /// set the ``Date`` object with the new milliseconds relative to 1. January 1970
    /// - Parameters:
    /// - Parameter millisecondsSince1970 milliseconds since 1970
    /// - Note: In result of Swift works with seconds instead of milliseconds the milliseconds part are ignored
    /// - Since: JavaApi &gt; 0.17.0 (Java 1.0)
    open func setTime(_ millisecondsSince1970: Int64) {
      let secondsSince1970 = millisecondsSince1970 / 1000
      let interval = TimeInterval(secondsSince1970)
      self.delegate = Foundation.Date(timeIntervalSince1970: interval)
    }
    
    open func toString() -> String {
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
