/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// The Gregorian calendar is the calendar used in not too less parts of the world.
  ///
  /// Port of ``java.util.GregorianCalendar`` to Swift.
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
  open class GregorianCalendar : java.util.Calender {
    
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
      dateComponents.month = newMonth
      dateComponents.day = newDayOfMonth
      dateComponents.hour = newHourOfDay
      dateComponents.minute = newMinute
      dateComponents.second = newSecond
    }
    
    open func getTime () -> java.util.Date {
      let javaDate = java.util.Date(self)
      return javaDate
    }
    
    /// Returns the value of given ``java.util.Calendar`` field
    /// - Returns ``Int`` value of expected field or throws exception
    /// - Note: Can throw a hidden Java runtime Exception. Use Swift DateComponents or secure extension function `get (_ java.util.Calendar.DateComponets`
    open override func get (_ field : Int) throws -> Int {
      switch field {
      case Calender.SECOND :
        return dateComponents.second!
      case Calender.MINUTE :
        return dateComponents.minute!
      case Calender.HOUR_OF_DAY :
        return dateComponents.hour!
      case Calender.YEAR :
        return dateComponents.year!
      case Calender.DAY_OF_MONTH :
        return dateComponents.month!
      case Calender.DAY_OF_WEEK :
        return dateComponents.weekday!
      default :
        throw java.lang.Throwable.ArrayIndexOutOfBoundsException(field, "if the specified field is out of range or not implemented")
      }
    }
  }
}
