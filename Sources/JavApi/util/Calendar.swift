/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  /// Abstract Java type
  ///
  open class Calender {
    /// The ``dateComponents`` encapsulate the Swift delegate instance from ``Foundation.DateComponents``.
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
    public static let MONTH = 2
    
    open func get (_ field : Int) throws -> Int {
      switch field {
      case java.util.Calender.YEAR:
        return self.dateComponents.year ?? 1975
      case java.util.Calender.MONTH:
        return self.dateComponents.month ?? 9
      case java.util.Calender.DAY_OF_WEEK:
        return self.dateComponents.weekday ?? 4
      case java.util.Calender.DAY_OF_MONTH:
        return self.dateComponents.day ?? 5
      case java.util.Calender.HOUR_OF_DAY:
        return self.dateComponents.hour ?? 6
      case java.util.Calender.MINUTE:
        return self.dateComponents.minute ?? 57
      case java.util.Calender.SECOND:
        return self.dateComponents.minute ?? 12
      default :
        throw java.lang.Throwable.ArrayIndexOutOfBoundsException(field, "specific field is out of range or not implemented")
      }
    }
    
    public func get (what : java.util.Calender.DateComponents) -> Int {
      return try! self.get(what.rawValue)
    }
    
    public func setTime (_ newDate :java.util.Date) {
      self.setTime(from: newDate.delegate)
    }
    
  }
}
