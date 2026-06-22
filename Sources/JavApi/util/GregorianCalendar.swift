/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// The Gregorian calendar is the calendar used in not too less parts of the world.
  ///
  /// Port of `java.util.GregorianCalendar` to Swift.
  ///
  /// ## Sample for port Java to Swift without [JavApi⁴Swift](https://github.com/bastie/JavApi4Swift)
  ///
  /// ```Java
  /// GregorianCalendar calendar = new GregorianCalendar();
  /// calendar.set(Calendar.YEAR, 2023);
  /// calendar.set(Calendar.MONTH, Calendar.NOVEMBER);
  /// calendar.set(Calendar.DAY_OF_MONTH, 24);
  /// ```
  ///
  /// ```Swift
  /// let calendar = Foundation.Calendar.current
  /// let components = DateComponents(year: 2023, month: 11, day: 24)
  /// let date = calendar.date(from: components)
  /// ```
  /// ⚔️
  ///
  open class GregorianCalendar : java.util.Calendar {

    // Constructor to init ``Foundation.DateComponents`` with all fields
    public override init () {
      super.init()
    }

    public convenience init (_ happyNewYear : Int, _ newMonth : Int, _ newDayOfMonth : Int) {
      self.init(happyNewYear, newMonth, newDayOfMonth, 0, 0, 0)
    }
    public convenience init (_ happyNewYear : Int, _ newMonth : Int, _ newDayOfMonth : Int, _ newHourOfDay : Int, _ newMinute : Int) {
      self.init(happyNewYear, newMonth, newDayOfMonth, newHourOfDay, newMinute, 0)
    }
    public convenience init (_ happyNewYear : Int, _ newMonth : Int, _ newDayOfMonth : Int, _ newHourOfDay : Int, _ newMinute : Int, _ newSecond : Int) {
      self.init()
      dateComponents.year = happyNewYear
      // Java months are 0-based; Foundation months are 1-based
      dateComponents.month = newMonth + 1
      dateComponents.day = newDayOfMonth
      dateComponents.hour = newHourOfDay
      dateComponents.minute = newMinute
      dateComponents.second = newSecond
    }

    open override func getTime () -> java.util.Date {
      let javaDate = java.util.Date(self)
      return javaDate
    }

    open func isLeapYear(_ year: Int) -> Bool {
      return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

    /// Returns the value of the given `java.util.Calendar` field.
    /// - Note: Delegates to the base class implementation which covers all Java 1.1 fields.
    open override func get (_ field : Int) throws -> Int {
      switch field {
      case Calendar.SECOND:
        return dateComponents.second ?? 0
      case Calendar.MINUTE:
        return dateComponents.minute ?? 0
      case Calendar.HOUR_OF_DAY:
        return dateComponents.hour ?? 0
      case Calendar.HOUR:
        return (dateComponents.hour ?? 0) % 12
      case Calendar.YEAR:
        return dateComponents.year ?? 1970
      case Calendar.MONTH:
        // Java months are 0-based; Foundation months are 1-based
        return (dateComponents.month ?? 1) - 1
      case Calendar.DAY_OF_MONTH:   // = DATE = 5
        return dateComponents.day ?? 1
      case Calendar.DAY_OF_WEEK:
        return dateComponents.weekday ?? 1
      case Calendar.WEEK_OF_YEAR:
        return dateComponents.weekOfYear ?? 1
      case Calendar.WEEK_OF_MONTH:
        return dateComponents.weekOfMonth ?? 1
      case Calendar.DAY_OF_WEEK_IN_MONTH:
        return dateComponents.weekdayOrdinal ?? 1
      case Calendar.AM_PM:
        return (dateComponents.hour ?? 0) < 12 ? Calendar.AM : Calendar.PM
      case Calendar.MILLISECOND:
        return (dateComponents.nanosecond ?? 0) / 1_000_000
      case Calendar.ERA:
        return dateComponents.era ?? Calendar.AD
      default:
        throw ArrayIndexOutOfBoundsException("the specified field \(field) is out of range or not implemented")
      }
    }
  }
}
