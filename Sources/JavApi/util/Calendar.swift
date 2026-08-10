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

    /// Tracks which fields have been explicitly cleared via ``clear()`` or ``clear(_:)``.
    /// A cleared field is considered "unset" until ``set(_:_:)`` is called for it again.
    /// Note: explicitly typed as `Swift.Set` to avoid ambiguity with `java.util.Set`.
    internal var _clearedFields: Swift.Set<Int> = []

    /// First day of the week. Default is ``SUNDAY`` (= 1), matching Java's default for
    /// most locales. Use ``setFirstDayOfWeek(_:)`` to override.
    private var _firstDayOfWeek: Int = java.util.Calendar.SUNDAY

    /// Whether this calendar is in lenient mode. In lenient mode, field values
    /// outside their normal ranges are accepted and normalised. Default is `true`.
    private var _lenient: Bool = true

    /// Preserves the Java-side timezone ID across Foundation normalisation.
    ///
    /// Foundation maps "UTC" → "GMT"; storing the original ID here lets
    /// `getTimeZone()` return the ID the caller actually passed to `setTimeZone()`.
    private var _javaTimeZoneID: String? = nil

    /// The minimum number of days required in the first week of the year.
    /// Default is `1`, matching Java's default.
    private var _minimalDaysInFirstWeek: Int = 1

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
      _clearedFields.remove(field)
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

    open func setTime (_ newDate :java.util.Date) {
      self.setTime(from: newDate.delegate)
    }

    open func getTime() -> java.util.Date {
      preconditionFailure("\(type(of: self)).getTime() not implemented")
    }

    // MARK: - Factory (Java 1.1 / Java 1.2)

    /// Returns a calendar for the given time zone, initialised to the current time.
    ///
    /// - Since: Java 1.1
    public static func getInstance(_ zone: any java.util.TimeZone) -> java.util.Calendar {
      let gc = GregorianCalendar()
      let cal = Foundation.Calendar(identifier: .gregorian)
      let components = cal.dateComponents(in: zone.delegate,
                                          from: Foundation.Date())
      gc.dateComponents = components
      return gc
    }

    /// Returns a calendar for the given time zone and locale, initialised to the current time.
    ///
    /// - Since: Java 1.1
    public static func getInstance(_ zone: any java.util.TimeZone,
                                   _ locale: java.util.Locale) -> java.util.Calendar {
      return getInstance(zone)  // locale ignored in this Foundation-backed implementation
    }

    /// Returns all locales for which `getInstance` has a dedicated calendar implementation.
    ///
    /// Delegates to `Foundation.Locale.availableIdentifiers`.
    ///
    /// - Since: Java 1.1
    public static func getAvailableLocales() -> [java.util.Locale] {
      Foundation.Locale.availableIdentifiers.map { java.util.Locale($0) }
    }

    // MARK: - Millisecond epoch (Java 1.2)

    /// Returns the time value of this calendar in milliseconds since the epoch
    /// (1970-01-01 00:00:00.000 UTC).
    ///
    /// Equivalent to `getTime().getTime()`.
    ///
    /// - Since: Java 1.2
    open func getTimeInMillis() -> Int64 {
      getTime().getTime()
    }

    /// Sets this calendar to the given time, expressed as milliseconds since the epoch.
    ///
    /// All fields are recomputed from the new time value.
    ///
    /// - Parameter millis: Milliseconds since 1970-01-01 00:00:00.000 UTC.
    /// - Since: Java 1.2
    open func setTimeInMillis(_ millis: Int64) {
      let date = Foundation.Date(timeIntervalSince1970: Double(millis) / 1000.0)
      setTime(from: date)
      _clearedFields.removeAll()
    }

    // MARK: - Field range queries (Java 1.2)

    /// Returns the minimum value for the given field, across all possible time values.
    ///
    /// For `GregorianCalendar`, `getGreatestMinimum(field)` == `getMinimum(field)`.
    ///
    /// - Since: Java 1.2
    open func getMinimum(_ field: Int) -> Int { _fieldMin(field) }

    /// Returns the greatest minimum value, i.e. the largest minimum the field
    /// could have for any date. For Gregorian, equals `getMinimum`.
    ///
    /// - Since: Java 1.2
    open func getGreatestMinimum(_ field: Int) -> Int { _fieldMin(field) }

    /// Returns the maximum value for the given field, across all possible time values.
    ///
    /// Example: `getMaximum(DAY_OF_MONTH)` = 31.
    ///
    /// - Since: Java 1.2
    open func getMaximum(_ field: Int) -> Int { _fieldMax(field) }

    /// Returns the least maximum value, i.e. the smallest maximum the field could
    /// take for some date.
    ///
    /// Example: `getLeastMaximum(DAY_OF_MONTH)` = 28 (February in non-leap years).
    ///
    /// - Since: Java 1.2
    open func getLeastMaximum(_ field: Int) -> Int { _fieldLeastMax(field) }

    // MARK: - Field range helpers (internal, override in subclasses if needed)

    internal func _fieldMin(_ field: Int) -> Int {
      switch field {
      case java.util.Calendar.ERA:                  return 0
      case java.util.Calendar.YEAR:                 return 1
      case java.util.Calendar.MONTH:                return 0      // JANUARY
      case java.util.Calendar.WEEK_OF_YEAR:         return 1
      case java.util.Calendar.WEEK_OF_MONTH:        return 0
      case java.util.Calendar.DAY_OF_MONTH:         return 1
      case java.util.Calendar.DAY_OF_YEAR:          return 1
      case java.util.Calendar.DAY_OF_WEEK:          return 1      // SUNDAY
      case java.util.Calendar.DAY_OF_WEEK_IN_MONTH: return -1
      case java.util.Calendar.AM_PM:                return 0      // AM
      case java.util.Calendar.HOUR:                 return 0
      case java.util.Calendar.HOUR_OF_DAY:          return 0
      case java.util.Calendar.MINUTE:               return 0
      case java.util.Calendar.SECOND:               return 0
      case java.util.Calendar.MILLISECOND:          return 0
      case java.util.Calendar.ZONE_OFFSET:          return -12 * 3_600_000
      case java.util.Calendar.DST_OFFSET:           return 0
      default:                                      return 0
      }
    }

    internal func _fieldMax(_ field: Int) -> Int {
      switch field {
      case java.util.Calendar.ERA:                  return 1
      case java.util.Calendar.YEAR:                 return 292_278_994
      case java.util.Calendar.MONTH:                return 11     // DECEMBER
      case java.util.Calendar.WEEK_OF_YEAR:         return 53
      case java.util.Calendar.WEEK_OF_MONTH:        return 6
      case java.util.Calendar.DAY_OF_MONTH:         return 31
      case java.util.Calendar.DAY_OF_YEAR:          return 366
      case java.util.Calendar.DAY_OF_WEEK:          return 7      // SATURDAY
      case java.util.Calendar.DAY_OF_WEEK_IN_MONTH: return 5
      case java.util.Calendar.AM_PM:                return 1      // PM
      case java.util.Calendar.HOUR:                 return 11
      case java.util.Calendar.HOUR_OF_DAY:          return 23
      case java.util.Calendar.MINUTE:               return 59
      case java.util.Calendar.SECOND:               return 59
      case java.util.Calendar.MILLISECOND:          return 999
      case java.util.Calendar.ZONE_OFFSET:          return 14 * 3_600_000
      case java.util.Calendar.DST_OFFSET:           return 2 * 3_600_000
      default:                                      return 0
      }
    }

    internal func _fieldLeastMax(_ field: Int) -> Int {
      switch field {
      case java.util.Calendar.DAY_OF_MONTH:         return 28  // Feb (non-leap)
      case java.util.Calendar.DAY_OF_YEAR:          return 365 // non-leap year
      case java.util.Calendar.WEEK_OF_YEAR:         return 52  // some years have only 52
      case java.util.Calendar.WEEK_OF_MONTH:        return 4
      case java.util.Calendar.DAY_OF_WEEK_IN_MONTH: return 4
      default:                                      return _fieldMax(field)
      }
    }

    // MARK: - TimeZone (Java 1.1)

    /// Returns the time zone of this calendar.
    ///
    /// Falls back to the system default if no time zone is stored in the
    /// backing `DateComponents`.
    ///
    /// - Since: Java 1.1
    open func getTimeZone() -> any java.util.TimeZone {
      if let tz = dateComponents.timeZone {
        // Use the Java-side ID when available: Foundation normalises "UTC" → "GMT",
        // so _javaTimeZoneID preserves whatever the caller originally passed.
        let id = _javaTimeZoneID ?? tz.identifier
        return java.util.SimpleTimeZone(tz.secondsFromGMT() * 1000, id)
      }
      // Cannot call static protocol method on existential type; build directly.
      let systemTZ = Foundation.TimeZone.current
      return java.util.SimpleTimeZone(systemTZ.secondsFromGMT() * 1000, systemTZ.identifier)
    }

    /// Sets the time zone of this calendar.
    ///
    /// The underlying instant (millisecond value) is preserved; all field
    /// values are recomputed in the new time zone.
    ///
    /// - Parameter value: The new time zone.
    /// - Since: Java 1.1
    open func setTimeZone(_ value: any java.util.TimeZone) {
      let millis = getTimeInMillis()
      let instant = Foundation.Date(timeIntervalSince1970: Double(millis) / 1000.0)
      let cal = Foundation.Calendar(identifier: .gregorian)
      dateComponents = cal.dateComponents(in: value.delegate, from: instant)
      // Preserve the Java timezone ID so getTimeZone() can return it unchanged.
      // Foundation normalises "UTC" → "GMT"; _javaTimeZoneID keeps the original.
      _javaTimeZoneID = value.getID()
    }

    // MARK: - getActualMinimum / getActualMaximum (Java 1.2)

    /// Returns the minimum value that the given field can take for the
    /// **current** date/time value of this calendar.
    ///
    /// For most fields this equals ``getMinimum(_:)``.
    ///
    /// - Since: Java 1.2
    open func getActualMinimum(_ field: Int) -> Int {
      // In the Gregorian calendar, field minimums do not depend on the
      // current date (e.g. DAY_OF_MONTH minimum is always 1).
      return _fieldMin(field)
    }

    /// Returns the maximum value that the given field can take for the
    /// **current** date/time value of this calendar.
    ///
    /// - DAY_OF_MONTH: the number of days in the current month.
    /// - DAY_OF_YEAR: 366 for leap years, 365 otherwise.
    /// - WEEK_OF_YEAR: 52 or 53 depending on the year.
    /// - All other fields: same as ``getMaximum(_:)``.
    ///
    /// - Since: Java 1.2
    open func getActualMaximum(_ field: Int) -> Int {
      let cal = Foundation.Calendar(identifier: .gregorian)
      switch field {
      case java.util.Calendar.DAY_OF_MONTH:
        if let year  = dateComponents.year,
           let month = dateComponents.month,
           let refDate = cal.date(from: Foundation.DateComponents(year: year, month: month)) {
          return cal.range(of: .day, in: .month, for: refDate)?.count ?? 31
        }
        return 31

      case java.util.Calendar.DAY_OF_YEAR:
        if let year = dateComponents.year {
          return (java.util.GregorianCalendar().isLeapYear(year)) ? 366 : 365
        }
        return 365

      case java.util.Calendar.WEEK_OF_YEAR:
        // December 28 always falls in the last week of the ISO year.
        if let year = dateComponents.year,
           let dec28 = cal.date(from: Foundation.DateComponents(year: year, month: 12, day: 28)) {
          return cal.component(.weekOfYear, from: dec28)
        }
        return 52

      case java.util.Calendar.WEEK_OF_MONTH:
        if let year  = dateComponents.year,
           let month = dateComponents.month,
           let lastDay = cal.date(from: Foundation.DateComponents(year: year, month: month + 1, day: 0)) {
          return cal.component(.weekOfMonth, from: lastDay)
        }
        return 5

      default:
        return _fieldMax(field)
      }
    }

    // MARK: - Comparison (Java 1.1 / Java 5)

    /// Returns `true` if this `Calendar` represents a time before `when`.
    ///
    /// - Parameter when: A `Calendar` instance to compare against.
    /// - Returns: `true` if this calendar's time is strictly before `when`'s time;
    ///   `false` if `when` is not a `Calendar` or is not earlier.
    /// - Since: Java 1.1
    open func before(_ when: Any?) -> Bool {
      guard let other = when as? java.util.Calendar else { return false }
      return getTime().getTime() < other.getTime().getTime()
    }

    /// Returns `true` if this `Calendar` represents a time after `when`.
    ///
    /// - Parameter when: A `Calendar` instance to compare against.
    /// - Since: Java 1.1
    open func after(_ when: Any?) -> Bool {
      guard let other = when as? java.util.Calendar else { return false }
      return getTime().getTime() > other.getTime().getTime()
    }

    /// Compares the time values (milliseconds from the epoch) of two calendars.
    ///
    /// - Returns: A negative value if this calendar is earlier, `0` if equal,
    ///   positive if later.
    /// - Since: Java 5
    open func compareTo(_ anotherCalendar: java.util.Calendar) -> Int {
      let t1 = getTime().getTime()
      let t2 = anotherCalendar.getTime().getTime()
      return t1 < t2 ? -1 : t1 > t2 ? 1 : 0
    }

    // MARK: - Clone (Java 1.1)

    /// Returns a copy of this calendar with identical field values.
    ///
    /// - Since: Java 1.1
    open func clone() -> java.util.Calendar {
      let copy = GregorianCalendar()
      copy.dateComponents           = self.dateComponents
      copy._clearedFields           = self._clearedFields
      copy._firstDayOfWeek          = self._firstDayOfWeek
      copy._lenient                 = self._lenient
      copy._minimalDaysInFirstWeek  = self._minimalDaysInFirstWeek
      return copy
    }

    // MARK: - First-day-of-week (Java 1.1)

    /// Returns the first day of the week.
    ///
    /// The default is ``SUNDAY`` for most Java locales.
    ///
    /// - Since: Java 1.1
    open func getFirstDayOfWeek() -> Int { _firstDayOfWeek }

    /// Sets the first day of the week.
    ///
    /// - Parameter value: One of the day-of-week constants
    ///   (``SUNDAY`` … ``SATURDAY``).
    /// - Since: Java 1.1
    open func setFirstDayOfWeek(_ value: Int) { _firstDayOfWeek = value }

    // MARK: - Lenient mode (Java 1.1)

    /// Returns `true` if this calendar is in lenient mode.
    ///
    /// In lenient mode, fields outside their normal ranges are accepted and
    /// normalised (e.g. MONTH = 13 rolls over to January of the next year).
    ///
    /// - Since: Java 1.1
    open func isLenient() -> Bool { _lenient }

    /// Enables or disables lenient mode.
    ///
    /// - Since: Java 1.1
    open func setLenient(_ lenient: Bool) { _lenient = lenient }

    // MARK: - Minimal days in first week (Java 1.1)

    /// Returns the minimum number of days required in the first week of the year.
    ///
    /// - Since: Java 1.1
    open func getMinimalDaysInFirstWeek() -> Int { _minimalDaysInFirstWeek }

    /// Sets the minimum number of days required in the first week of the year.
    ///
    /// - Since: Java 1.1
    open func setMinimalDaysInFirstWeek(_ value: Int) { _minimalDaysInFirstWeek = value }

    // MARK: - add / roll (Java 1.1)

    /// Adds or subtracts the specified amount to the given calendar field, with
    /// carry-over to larger fields.
    ///
    /// Example: adding 1 to `MONTH` on January 31 yields March 3 (or March 2
    /// in a leap year), matching Java's lenient normalisation via Foundation.
    ///
    /// - Parameters:
    ///   - field: A `java.util.Calendar` field constant.
    ///   - amount: The signed amount to add.
    /// - Since: Java 1.1
    open func add(_ field: Int, _ amount: Int) {
      guard amount != 0 else { return }
      let cal = Foundation.Calendar(identifier: .gregorian)
      guard let baseDate = cal.date(from: dateComponents) else { return }

      var delta = Foundation.DateComponents()
      switch field {
      case java.util.Calendar.ERA:
        let currentEra = dateComponents.era ?? 1
        dateComponents.era = (amount % 2 == 0) ? currentEra : (currentEra == 1 ? 0 : 1)
        return
      case java.util.Calendar.YEAR:         delta.year       = amount
      case java.util.Calendar.MONTH:        delta.month      = amount
      case java.util.Calendar.WEEK_OF_YEAR,
           java.util.Calendar.WEEK_OF_MONTH: delta.weekOfYear = amount
      case java.util.Calendar.DAY_OF_MONTH,
           java.util.Calendar.DAY_OF_YEAR,
           java.util.Calendar.DAY_OF_WEEK,
           java.util.Calendar.DAY_OF_WEEK_IN_MONTH: delta.day = amount
      case java.util.Calendar.HOUR,
           java.util.Calendar.HOUR_OF_DAY:  delta.hour       = amount
      case java.util.Calendar.MINUTE:       delta.minute     = amount
      case java.util.Calendar.SECOND:       delta.second     = amount
      case java.util.Calendar.MILLISECOND:  delta.nanosecond = amount * 1_000_000
      default: return
      }

      guard let newDate = cal.date(byAdding: delta, to: baseDate) else { return }
      let tz = dateComponents.timeZone ?? Foundation.TimeZone.current
      // dateComponents(_:in:from:) does not exist; set timeZone on the calendar instead.
      var calTZ = Foundation.Calendar(identifier: .gregorian)
      calTZ.timeZone = tz
      let comps: Foundation.DateComponents
      if #available(macOS 14, *) {
        comps = calTZ.dateComponents(
          [.era, .year, .month, .day, .hour, .minute, .second,
           .nanosecond, .weekday, .weekdayOrdinal, .weekOfYear,
           .weekOfMonth, .timeZone, .quarter, .isLeapMonth], from: newDate)
      } else {
        comps = calTZ.dateComponents(
          [.era, .year, .month, .day, .hour, .minute, .second,
           .nanosecond, .weekday, .weekdayOrdinal, .weekOfYear,
           .weekOfMonth, .timeZone, .quarter], from: newDate)
      }
      dateComponents = comps
      _clearedFields.removeAll()
    }

    /// Adds or subtracts 1 to the given field **without** carrying over to
    /// larger fields.
    ///
    /// - Parameter up: `true` to increment by 1, `false` to decrement by 1.
    /// - Since: Java 1.1
    open func roll(_ field: Int, _ up: Bool) {
      roll(field, up ? 1 : -1)
    }

    /// Adds or subtracts `amount` to the given field without carrying over
    /// to larger fields.
    ///
    /// The field wraps within its ``getActualMinimum(_:)`` …
    /// ``getActualMaximum(_:)`` range.
    ///
    /// - Since: Java 1.1
    open func roll(_ field: Int, _ amount: Int) {
      guard amount != 0 else { return }
      let min   = getActualMinimum(field)
      let max   = getActualMaximum(field)
      let range = max - min + 1
      guard range > 0 else { return }
      let current: Int
      do    { current = try get(field) }
      catch { return }
      let newValue = min + ((current - min + amount) % range + range) % range
      set(field, newValue)
    }

    // MARK: - isSet / clear (Java 1.1)

    /// Returns `true` if the given field has been set and not subsequently cleared.
    ///
    /// A field is "unset" after ``clear()`` or ``clear(_:)`` and "set" again after
    /// a call to ``set(_:_:)``.
    ///
    /// - Parameter field: A `java.util.Calendar` field constant.
    /// - Since: Java 1.1
    open func isSet(_ field: Int) -> Bool {
      guard field >= 0 && field < java.util.Calendar.FIELD_COUNT else { return false }
      return !_clearedFields.contains(field)
    }

    /// Unsets all fields and resets the calendar to the epoch
    /// (1970-01-01 00:00:00.000 UTC).
    ///
    /// - Since: Java 1.1
    open func clear() {
      var epoch = Foundation.DateComponents()
      epoch.era = 1; epoch.year = 1970; epoch.month = 1; epoch.day = 1
      epoch.hour = 0; epoch.minute = 0; epoch.second = 0; epoch.nanosecond = 0
      dateComponents = epoch
      _clearedFields = Swift.Set<Int>(0..<java.util.Calendar.FIELD_COUNT)
    }

    /// Unsets the given field, resetting it to its minimum value.
    ///
    /// The field is considered "unset" (``isSet(_:)`` returns `false`) until
    /// ``set(_:_:)`` is called for it again.
    ///
    /// - Parameter field: A `java.util.Calendar` field constant.
    /// - Since: Java 1.1
    open func clear(_ field: Int) {
      _clearedFields.insert(field)
      switch field {
      case java.util.Calendar.ERA:                dateComponents.era = nil
      case java.util.Calendar.YEAR:               dateComponents.year = nil
      case java.util.Calendar.MONTH:              dateComponents.month = nil
      case java.util.Calendar.WEEK_OF_YEAR:       dateComponents.weekOfYear = nil
      case java.util.Calendar.WEEK_OF_MONTH:      dateComponents.weekOfMonth = nil
      case java.util.Calendar.DAY_OF_MONTH:       dateComponents.day = nil
      case java.util.Calendar.DAY_OF_YEAR:        break  // computed, not stored directly
      case java.util.Calendar.DAY_OF_WEEK:        dateComponents.weekday = nil
      case java.util.Calendar.DAY_OF_WEEK_IN_MONTH: dateComponents.weekdayOrdinal = nil
      case java.util.Calendar.HOUR,
           java.util.Calendar.HOUR_OF_DAY:        dateComponents.hour = nil
      case java.util.Calendar.MINUTE:             dateComponents.minute = nil
      case java.util.Calendar.SECOND:             dateComponents.second = nil
      case java.util.Calendar.MILLISECOND:        dateComponents.nanosecond = nil
      default:                                    break
      }
    }

  }
}
