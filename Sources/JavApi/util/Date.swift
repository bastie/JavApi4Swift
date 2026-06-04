/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  open class Date {
    
    internal var delegate : Foundation.Date
    public init () {
      self.delegate = Foundation.Date.now
    }
    
    /// Create a new `java.util.Date` instance at 1. Januar 1970
    /// - Parameter millisecondsSince1970: milliseconds since 1970
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
    
    /// set the ``Date`` object with the new seconds relative to 1. January 1970
    /// - Parameter millisecondsSince1970: milliseconds since 1970
    /// - Note: In result of Swift works with seconds instead of milliseconds the milliseconds part are ignored
    /// - Since: JavaApi &gt; 0.17.0 (Java 1.0)
    open func setTime(_ millisecondsSince1970: Int64) {
      let secondsSince1970 = millisecondsSince1970 / 1000
      let interval = TimeInterval(secondsSince1970)
      self.delegate = Foundation.Date(timeIntervalSince1970: interval)
    }
    
    open func toString() -> String {
      return description
    }

    /// Returns true if this date is after the given date.
    /// - Since: JavaApi (Java 1.0)
    open func after(_ when: java.util.Date) -> Bool {
      return self.delegate > when.delegate
    }

    /// Returns true if this date is before the given date.
    /// - Since: JavaApi (Java 1.0)
    /// - Returns true if date is before given date.
    open func before(_ when: java.util.Date) -> Bool {
      return self.delegate < when.delegate
    }

    /// Returns true if this date equals the given date.
    /// - Since: JavaApi (Java 1.0)
    open func equals(_ other: java.util.Date?) -> Bool {
      guard let other else { return false }
      return self.delegate == other.delegate
    }

    /// Returns the day of the month (1–31).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func getDate() -> Int {
      return Foundation.Calendar.current.component(.day, from: delegate)
    }

    /// Returns the day of the week (0 = Sunday, 1 = Monday, ..., 6 = Saturday).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func getDay() -> Int {
      // Foundation: 1 = Sunday, 2 = Monday, ..., 7 = Saturday → shift by -1
      return Foundation.Calendar.current.component(.weekday, from: delegate) - 1
    }

    /// Returns the month (0 = January, ..., 11 = December).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func getMonth() -> Int {
      return Foundation.Calendar.current.component(.month, from: delegate) - 1
    }

    /// Returns the year minus 1900.
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func getYear() -> Int {
      return Foundation.Calendar.current.component(.year, from: delegate) - 1900
    }

    /// Returns the hour of the day (0–23).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func getHours() -> Int {
      return Foundation.Calendar.current.component(.hour, from: delegate)
    }

    /// Returns the minutes (0–59).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func getMinutes() -> Int {
      return Foundation.Calendar.current.component(.minute, from: delegate)
    }

    /// Returns the seconds (0–61, where 60 and 61 are for leap seconds).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func getSeconds() -> Int {
      return Foundation.Calendar.current.component(.second, from: delegate)
    }

    /// Sets the day of the month (1–31).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func setDate(_ date: Int) {
      delegate = mutating(.day, to: date)
    }

    /// Sets the month (0 = January, ..., 11 = December).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func setMonth(_ month: Int) {
      delegate = mutating(.month, to: month + 1)
    }

    /// Sets the year (year - 1900, e.g. 124 for 2024).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func setYear(_ year: Int) {
      delegate = mutating(.year, to: year + 1900)
    }

    /// Sets the hour of the day (0–23).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func setHours(_ hours: Int) {
      delegate = mutating(.hour, to: hours)
    }

    /// Sets the minutes (0–59).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func setMinutes(_ minutes: Int) {
      delegate = mutating(.minute, to: minutes)
    }

    /// Sets the seconds (0–59).
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func setSeconds(_ seconds: Int) {
      delegate = mutating(.second, to: seconds)
    }

    /// Returns the offset of the local time zone from UTC in minutes.
    ///
    /// A positive value means the local time zone is east of UTC.
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    open func getTimezoneOffset() -> Int {
      let secondsFromGMT = Foundation.TimeZone.current.secondsFromGMT(for: delegate)
      return -(secondsFromGMT / 60)
    }

    /// Returns a string representation of this date in GMT format.
    ///
    /// Format: `d mon yyyy hh:mm:ss GMT`
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use DateFormat instead")
    open func toGMTString() -> String {
      let fmt = DateFormatter()
      fmt.locale = Locale("en_US_POSIX").delegate
      fmt.timeZone = Foundation.TimeZone(secondsFromGMT: 0)
      fmt.dateFormat = "d MMM yyyy HH:mm:ss 'GMT'"
      return fmt.string(from: delegate)
    }

    /// Returns a string representation of this date in the local locale format.
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use DateFormat instead")
    open func toLocaleString() -> String {
      let fmt = DateFormatter()
      fmt.dateStyle = .medium
      fmt.timeStyle = .medium
      return fmt.string(from: delegate)
    }

    /// Parses a date string and returns the milliseconds since epoch.
    ///
    /// - Parameter s: A date string in a format recognised by `DateFormatter`.
    /// - Returns: Milliseconds since 1 January 1970 UTC, or -1 on parse failure.
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use DateFormat instead")
    public static func parse(_ s: String) -> Int64 {
      let fmt = DateFormatter()
      fmt.locale = Locale("en_US_POSIX").delegate
      for format in ["EEE, d MMM yyyy HH:mm:ss zzz",
                     "d MMM yyyy HH:mm:ss zzz",
                     "yyyy-MM-dd HH:mm:ss",
                     "yyyy-MM-dd"] {
        fmt.dateFormat = format
        if let d = fmt.date(from: s) {
          return Int64(d.timeIntervalSince1970) * 1000
        }
      }
      return -1
    }

    /// Returns the UTC milliseconds for the given date/time components.
    ///
    /// - Parameters:
    ///   - year: Year minus 1900 (e.g. 124 for 2024).
    ///   - month: Month 0–11.
    ///   - date: Day of month 1–31.
    ///   - hrs: Hours 0–23.
    ///   - min: Minutes 0–59.
    ///   - sec: Seconds 0–59.
    /// - Returns: Milliseconds since 1 January 1970 UTC.
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use Calendar instead")
    public static func UTC(_ year: Int, _ month: Int, _ date: Int,
                           _ hrs: Int, _ min: Int, _ sec: Int) -> Int64 {
      var cal = Foundation.Calendar(identifier: .gregorian)
      cal.timeZone = Foundation.TimeZone(secondsFromGMT: 0)!
      let components = DateComponents(year: year + 1900, month: month + 1, day: date,
                                      hour: hrs, minute: min, second: sec)
      guard let d = cal.date(from: components) else { return -1 }
      return Int64(d.timeIntervalSince1970) * 1000
    }

    // MARK: - Private helper

    /// Returns a new `Foundation.Date` with one calendar component replaced.
    private func mutating(_ component: Foundation.Calendar.Component, to value: Int) -> Foundation.Date {
      var cal = Foundation.Calendar.current
      cal.timeZone = Foundation.TimeZone.current
      var comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: delegate)
      switch component {
      case .day:    comps.day    = value
      case .month:  comps.month  = value
      case .year:   comps.year   = value
      case .hour:   comps.hour   = value
      case .minute: comps.minute = value
      case .second: comps.second = value
      default: break
      }
      return cal.date(from: comps) ?? delegate
    }

    /// Constructor to create a Date instance with GregorianCalendar to implement GregorianCalendar.getTime
    internal init (_ gregorianCalendar : java.util.GregorianCalendar) {
      let userCalendar = Foundation.Calendar(identifier: .gregorian)
      self.delegate = userCalendar.date(from: gregorianCalendar.dateComponents)!
    }
    
  }
}
