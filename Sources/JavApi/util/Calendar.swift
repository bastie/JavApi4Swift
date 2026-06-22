/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  /// Abstract Java type
  ///
  open class Calendar {
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

    // MARK: - Field constants (Java 1.1, matching java.util.Calendar integer values)

    public static let ERA                  = 0
    public static let YEAR                 = 1
    public static let MONTH                = 2
    public static let WEEK_OF_YEAR         = 3
    public static let WEEK_OF_MONTH        = 4
    /// Alias for ``DAY_OF_MONTH``
    public static let DATE                 = 5
    public static let DAY_OF_MONTH         = 5
    public static let DAY_OF_YEAR          = 6
    public static let DAY_OF_WEEK          = 7
    public static let DAY_OF_WEEK_IN_MONTH = 8
    public static let AM_PM                = 9
    public static let HOUR                 = 10
    public static let HOUR_OF_DAY          = 11
    public static let MINUTE               = 12
    public static let SECOND               = 13
    public static let MILLISECOND          = 14
    public static let ZONE_OFFSET          = 15
    public static let DST_OFFSET           = 16
    public static let FIELD_COUNT          = 17

    // MARK: - Day-of-week constants
    public static let SUNDAY    = 1
    public static let MONDAY    = 2
    public static let TUESDAY   = 3
    public static let WEDNESDAY = 4
    public static let THURSDAY  = 5
    public static let FRIDAY    = 6
    public static let SATURDAY  = 7

    // MARK: - Month constants (0-based, matching Java)
    public static let JANUARY   = 0
    public static let FEBRUARY  = 1
    public static let MARCH     = 2
    public static let APRIL     = 3
    public static let MAY       = 4
    public static let JUNE      = 5
    public static let JULY      = 6
    public static let AUGUST    = 7
    public static let SEPTEMBER = 8
    public static let OCTOBER   = 9
    public static let NOVEMBER  = 10
    public static let DECEMBER  = 11
    /// 13th month used in some lunar calendars
    public static let UNDECIMBER = 12

    // MARK: - AM/PM constants
    public static let AM = 0
    public static let PM = 1

    // MARK: - Era constants
    public static let BC = 0
    public static let AD = 1

    // MARK: - Factory

    /// Returns a `GregorianCalendar` for the default locale, initialised to the current time.
    public static func getInstance() -> java.util.Calendar {
      return java.util.GregorianCalendar()
    }

    /// Returns a `GregorianCalendar` for the given locale, initialised to the current time.
    public static func getInstance(_ locale: java.util.Locale) -> java.util.Calendar {
      return java.util.GregorianCalendar()
    }

    // MARK: - get / set

    open func get (_ field : Int) throws -> Int {
      switch field {
      case java.util.Calendar.ERA:
        return self.dateComponents.era ?? 1
      case java.util.Calendar.YEAR:
        return self.dateComponents.year ?? 1975
      case java.util.Calendar.MONTH:
        // Java months are 0-based; Foundation months are 1-based
        return (self.dateComponents.month ?? 1) - 1
      case java.util.Calendar.WEEK_OF_YEAR:
        return self.dateComponents.weekOfYear ?? 1
      case java.util.Calendar.WEEK_OF_MONTH:
        return self.dateComponents.weekOfMonth ?? 1
      case java.util.Calendar.DAY_OF_MONTH: // also DATE = 5
        return self.dateComponents.day ?? 1
      case java.util.Calendar.DAY_OF_YEAR:
        // Compute day-of-year by counting days from Jan 1 of the same year
        let cal = Foundation.Calendar(identifier: .gregorian)
        if let year = self.dateComponents.year,
           let month = self.dateComponents.month,
           let day = self.dateComponents.day {
          var startComps = Foundation.DateComponents()
          startComps.year = year; startComps.month = 1; startComps.day = 1
          var targetComps = Foundation.DateComponents()
          targetComps.year = year; targetComps.month = month; targetComps.day = day
          if let startDate = cal.date(from: startComps),
             let targetDate = cal.date(from: targetComps) {
            return (cal.dateComponents([.day], from: startDate, to: targetDate).day ?? 0) + 1
          }
        }
        return 1
      case java.util.Calendar.DAY_OF_WEEK:
        return self.dateComponents.weekday ?? 1
      case java.util.Calendar.DAY_OF_WEEK_IN_MONTH:
        return self.dateComponents.weekdayOrdinal ?? 1
      case java.util.Calendar.AM_PM:
        if let hour = self.dateComponents.hour {
          return hour < 12 ? java.util.Calendar.AM : java.util.Calendar.PM
        }
        return java.util.Calendar.AM
      case java.util.Calendar.HOUR:
        if let hour = self.dateComponents.hour {
          return hour % 12
        }
        return 0
      case java.util.Calendar.HOUR_OF_DAY:
        return self.dateComponents.hour ?? 0
      case java.util.Calendar.MINUTE:
        return self.dateComponents.minute ?? 0
      case java.util.Calendar.SECOND:
        return self.dateComponents.second ?? 0
      case java.util.Calendar.MILLISECOND:
        if let nano = self.dateComponents.nanosecond {
          return nano / 1_000_000
        }
        return 0
      case java.util.Calendar.ZONE_OFFSET:
        // Raw offset = total offset minus DST; approximate using current date
        if let tz = self.dateComponents.timeZone {
          let now = Foundation.Date()
          let totalMs = tz.secondsFromGMT(for: now) * 1000
          let dstMs = Int(tz.daylightSavingTimeOffset(for: now)) * 1000
          return totalMs - dstMs
        }
        return 0
      case java.util.Calendar.DST_OFFSET:
        if let tz = self.dateComponents.timeZone {
          let now = Foundation.Date()
          return Int(tz.daylightSavingTimeOffset(for: now)) * 1000
        }
        return 0
      default :
        throw ArrayIndexOutOfBoundsException("specific field \(field) is out of range or not implemented")
      }
    }

    open func set(_ field: Int, _ value: Int) {
      switch field {
      case java.util.Calendar.ERA:
        self.dateComponents.era = value
      case java.util.Calendar.YEAR:
        self.dateComponents.year = value
      case java.util.Calendar.MONTH:
        // Java months are 0-based; Foundation months are 1-based
        self.dateComponents.month = value + 1
      case java.util.Calendar.WEEK_OF_YEAR:
        self.dateComponents.weekOfYear = value
      case java.util.Calendar.WEEK_OF_MONTH:
        self.dateComponents.weekOfMonth = value
      case java.util.Calendar.DAY_OF_MONTH: // also DATE = 5
        self.dateComponents.day = value
      case java.util.Calendar.DAY_OF_WEEK:
        self.dateComponents.weekday = value
      case java.util.Calendar.DAY_OF_WEEK_IN_MONTH:
        self.dateComponents.weekdayOrdinal = value
      case java.util.Calendar.HOUR:
        if let current = self.dateComponents.hour {
          self.dateComponents.hour = (current / 12) * 12 + value % 12
        } else {
          self.dateComponents.hour = value % 12
        }
      case java.util.Calendar.HOUR_OF_DAY:
        self.dateComponents.hour = value
      case java.util.Calendar.MINUTE:
        self.dateComponents.minute = value
      case java.util.Calendar.SECOND:
        self.dateComponents.second = value
      case java.util.Calendar.MILLISECOND:
        self.dateComponents.nanosecond = value * 1_000_000
      default:
        break // unsupported field silently ignored, matching Java behaviour
      }
    }

    public func get (what : java.util.Calendar.DateComponents) -> Int {
      return try! self.get(what.rawValue)
    }

    public func setTime (_ newDate :java.util.Date) {
      self.setTime(from: newDate.delegate)
    }

    open func getTime() -> java.util.Date {
      fatalError("subclass must implement getTime()")
    }

  }
}
