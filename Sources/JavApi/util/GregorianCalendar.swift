/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  open class GregorianCalendar {
    /* Java
     GregorianCalendar calendar = new GregorianCalendar();
     calendar.set(Calendar.YEAR, 2023);
     calendar.set(Calendar.MONTH, Calendar.NOVEMBER);
     calendar.set(Calendar.DAY_OF_MONTH, 24);
     */
    /* Swift
     let calendar = Calendar.current
     let components = DateComponents(year: 2023, month: 11, day: 24)
     let date = calendar.date(from: components)
     */
    
    internal var dateComponents : DateComponents = DateComponents()
    
    public convenience init (_ happyNewYear : Int, _ newMonth : Int, _ newDayOfMonth : Int) {
      self.init(happyNewYear, newMonth, newDayOfMonth, 0, 0, 0)
    }
    public convenience init (_ happyNewYear : Int, _ newMonth : Int, _ newDayOfMonth : Int, _ newHourOfDay : Int, _ newMinute : Int) {
      self.init(happyNewYear, newMonth, newDayOfMonth, newHourOfDay, newMinute, 0)
    }
    public init (_ happyNewYear : Int, _ newMonth : Int, _ newDayOfMonth : Int, _ newHourOfDay : Int, _ newMinute : Int, _ newSecond : Int) {
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
    
  }
}
