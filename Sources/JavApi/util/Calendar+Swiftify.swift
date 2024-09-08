/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util.Calender {
  public enum DateComponents : Int {
    case YEAR = 1
    case DAY_OF_WEEK = 7
    case DAY_OF_MONTH = 8
    case HOUR_OF_DAY = 11
    case MINUTE = 12
    case SECOND = 13
  }
  
  public func setTime (from newDate: Foundation.Date) {
    let calendar = Foundation.Calendar(identifier: .gregorian)
    var components : Foundation.DateComponents
    if #available(macOS 14, *) /* .isLeapMonth */{
      components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekdayOrdinal, .weekday, .weekOfYear, .weekOfMonth, .timeZone, .quarter, .nanosecond, .isLeapMonth, .era], from: newDate )
    } else {
      components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekdayOrdinal, .weekday, .weekOfYear, .weekOfMonth, .timeZone, .quarter, .nanosecond, .era], from: newDate)
    }
    self.dateComponents = components
  }
}
