/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  /// Abstract Java type
  ///
  open class Calender {
    internal var dateComponents : Foundation.DateComponents = Foundation.DateComponents()

    public init (){
      let calendar = Foundation.Calendar(identifier: .gregorian)
      let now = Foundation.Date()
      var components : Foundation.DateComponents
      if #available(macOS 14, *) /* .isLeapMonth */{
        components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekdayOrdinal, .weekday, .weekOfYear, .weekOfMonth, .timeZone, .quarter, .nanosecond, .isLeapMonth, .era], from:now)
      } else {
        components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekdayOrdinal, .weekday, .weekOfYear, .weekOfMonth, .timeZone, .quarter, .nanosecond, .era], from:now)
      }
      self.dateComponents = components
    }
    
    public static let SECOND = 13
    public static let MINUTE = 12
    public static let HOUR_OF_DAY = 11
    public static let YEAR = 1
    public static let DAY_OF_MONTH = 8
    public static let DAY_OF_WEEK = 7
    
    open func get (_ field : Int) throws -> Int {
      throw java.lang.Throwable.UnsupportedOperationException("Calendar is a abstract type, use subtypes like GregorianCalendar")
    }
    
    public func setTime (_ newDate :java.util.Date) {
      self.setTime(from: newDate.delegate)
    }
    
  }
}
