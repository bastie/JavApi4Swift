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
    
    /// Create a new ``java.util.Date`` instance at 1. Januar 1970
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

    /// Constructor to create a Date instance with GregorianCalendar to implement GregorianCalendar.getTime
    internal init (_ gregorianCalendar : java.util.GregorianCalendar) {
      let userCalendar = Foundation.Calendar(identifier: .gregorian)
      self.delegate = userCalendar.date(from: gregorianCalendar.dateComponents)!
    }
    
  }
}
