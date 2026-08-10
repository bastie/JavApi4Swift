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

    // MARK: - Era constants (Java 1.1, defined here — not in Calendar)
    public static let BC = 0
    public static let AD = 1

    // MARK: - Gregorian change date
    // The date when the Gregorian calendar reform took effect.
    // Default: October 15, 1582 (as in Java's GregorianCalendar).
    // Set to Date(Long.MIN_VALUE) to use a pure Gregorian calendar
    // retroactively, or to Date(Long.MAX_VALUE) for a pure Julian calendar.
    private var _gregorianChange: java.util.Date = {
      // October 15, 1582, 00:00:00 UTC
      var dc = Foundation.DateComponents()
      dc.year = 1582; dc.month = 10; dc.day = 15
      dc.hour = 0; dc.minute = 0; dc.second = 0
      dc.timeZone = Foundation.TimeZone(identifier: "UTC")
      let cal = Foundation.Calendar(identifier: .gregorian)
      let foundationDate = cal.date(from: dc) ?? Foundation.Date(timeIntervalSince1970: -12219292800)
      return java.util.Date(Int64(foundationDate.timeIntervalSince1970) * 1000)
    }()

    // MARK: - Constructors

    // Constructor to init ``Foundation.DateComponents`` with all fields
    public override init () {
      super.init()
    }

    /// Creates a `GregorianCalendar` based on the current time in the given time zone.
    ///
    /// - Since: Java 1.1
    public convenience init(_ zone: any java.util.TimeZone) {
      self.init()
      let cal = Foundation.Calendar(identifier: .gregorian)
      dateComponents = cal.dateComponents(in: zone.delegate, from: Foundation.Date())
    }

    /// Creates a `GregorianCalendar` based on the current time in the given locale.
    ///
    /// The locale affects the first day of the week and minimal days in first week.
    /// In this Foundation-backed implementation, the locale is stored but the
    /// timezone defaults to the system timezone.
    ///
    /// - Since: Java 1.1
    public convenience init(_ locale: java.util.Locale) {
      self.init()
      // Apply locale-specific week settings
      var foundationCal = Foundation.Calendar(identifier: .gregorian)
      foundationCal.locale = locale.delegate
      let now = Foundation.Date()
      dateComponents = foundationCal.dateComponents(
        [.era, .year, .month, .day, .hour, .minute, .second,
         .nanosecond, .weekday, .weekdayOrdinal, .weekOfYear,
         .weekOfMonth, .timeZone, .quarter], from: now)
    }

    /// Creates a `GregorianCalendar` based on the current time in the given time zone and locale.
    ///
    /// - Since: Java 1.1
    public convenience init(_ zone: any java.util.TimeZone, _ locale: java.util.Locale) {
      self.init(zone)
      // locale mainly affects week numbering — we apply it via Foundation
      var foundationCal = Foundation.Calendar(identifier: .gregorian)
      foundationCal.locale = locale.delegate
      let now = Foundation.Date()
      dateComponents = foundationCal.dateComponents(
        in: zone.delegate, from: now)
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

    // MARK: - Gregorian change date (Java 1.1)

    /// Returns the date when the Gregorian calendar change took effect.
    ///
    /// The default is October 15, 1582 — the first day of the Gregorian
    /// calendar in the original Catholic countries.
    ///
    /// - Returns: A `java.util.Date` representing the Gregorian change date.
    /// - Since: Java 1.1
    open func getGregorianChange() -> java.util.Date {
      _gregorianChange
    }

    /// Sets the date when the Gregorian calendar change takes effect.
    ///
    /// Pass `java.util.Date(Int64.min)` to use a pure Gregorian calendar
    /// retroactively (no Julian period), or `java.util.Date(Int64.max)` for
    /// a pure Julian calendar.
    ///
    /// - Parameter date: The Gregorian change date.
    /// - Since: Java 1.1
    open func setGregorianChange(_ date: java.util.Date) {
      _gregorianChange = date
    }

    /// Returns `true` if the given `java.util.Date` is after the Gregorian
    /// change date, meaning the Gregorian calendar applies to it.
    ///
    /// - Since: Java 1.1
    open func isGregorianDate(_ date: java.util.Date) -> Bool {
      date.getTime() >= _gregorianChange.getTime()
    }

    // MARK: - toZonedDateTime (Java 8)

    /// Converts this `GregorianCalendar` to a `java.time.ZonedDateTime`.
    ///
    /// The returned `ZonedDateTime` represents the same point in time and uses
    /// the same time zone as this calendar.
    ///
    /// - Since: Java 8
    open func toZonedDateTime() -> java.time.ZonedDateTime {
      let millis = getTimeInMillis()
      let instant = Foundation.Date(timeIntervalSince1970: Double(millis) / 1000.0)
      let foundationTZ = dateComponents.timeZone ?? Foundation.TimeZone.current
      let clock = java.time.Clock(foundationTZ)
      return java.time.ZonedDateTime(instant, clock: clock)
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
        return dateComponents.era ?? GregorianCalendar.AD
      default:
        throw ArrayIndexOutOfBoundsException("the specified field \(field) is out of range or not implemented")
      }
    }
  }
}
