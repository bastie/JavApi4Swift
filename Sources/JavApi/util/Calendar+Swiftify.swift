/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util.Calender {
  public enum DateComponents : Int {
    case YEAR = 1
    case MONTH = 2
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
  
  public func get (_ component : DateComponents) -> Int {
    switch component {
    case .YEAR:
      return self.dateComponents.year ?? 1975
    case .MONTH:
      return self.dateComponents.month ?? 9
    case .DAY_OF_WEEK:
      return self.dateComponents.weekday ?? 4
    case .DAY_OF_MONTH:
      return self.dateComponents.day ?? 5
    case .HOUR_OF_DAY:
      return self.dateComponents.hour ?? 6
    case .MINUTE:
      return self.dateComponents.minute ?? 57
    case .SECOND:
      return self.dateComponents.minute ?? 12
    }
  }
}
