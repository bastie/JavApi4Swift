/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  /// Java-like `SimpleTimeZone` — a concrete `TimeZone` subclass for Gregorian calendars.
  ///
  /// Delegates to `Foundation.TimeZone` internally.
  ///
  /// > Warning: `SimpleTimeZone` was deprecated in Java 26 for eventual removal.
  /// > Prefer `java.time.ZoneId` / `ZonedDateTime` for new code.
  ///
  /// - Since: Java 1.1
  public class SimpleTimeZone : TimeZone {
    public var delegate: Foundation.TimeZone
    
    /// The Java-visible timezone ID — preserved exactly as passed by the caller.
    ///
    /// Foundation may normalize certain IDs (e.g. "UTC" → identifier "GMT"), so we
    /// keep the original string separately to honour the Java contract:
    /// `TimeZone.getTimeZone(id).getID() == id`.
    private let javaID: String
    
    // MARK: - Constructors
    
    /// Creates a `SimpleTimeZone` with a fixed UTC offset and a timezone identifier.
    ///
    /// - Parameters:
    ///   - rawOffset: The UTC offset in milliseconds (e.g. `3600000` for UTC+1).
    ///   - id: A timezone identifier string (e.g. `"Europe/Berlin"`). When a known
    ///     IANA identifier is given, Foundation resolves it and DST rules are handled
    ///     by the platform. The `rawOffset` is used as a fallback when the identifier
    ///     is unknown.
    public init(_ rawOffset: Int, _ id: String) {
      self.javaID = id
      if let tz = Foundation.TimeZone(identifier: id) {
        self.delegate = tz
      } else {
        // Fall back to a fixed offset (rawOffset is in milliseconds)
        self.delegate = Foundation.TimeZone(secondsFromGMT: rawOffset / 1000) ?? .current
      }
    }
    
    /// Creates a `SimpleTimeZone` with explicit DST transition rules.
    ///
    /// The DST parameters are accepted for API compatibility with Java 1.1 but
    /// DST logic is fully handled by `Foundation.TimeZone` via the `id` identifier.
    ///
    /// - Parameters:
    ///   - rawOffset: UTC offset in milliseconds.
    ///   - id: IANA timezone identifier.
    ///   - startMonth: Month DST starts (0 = January). Accepted but unused.
    ///   - startDay: Day-of-week-in-month DST starts. Accepted but unused.
    ///   - startDayOfWeek: Day of week DST starts. Accepted but unused.
    ///   - startTime: Wall-clock time (ms) DST starts. Accepted but unused.
    ///   - endMonth: Month DST ends. Accepted but unused.
    ///   - endDay: Day-of-week-in-month DST ends. Accepted but unused.
    ///   - endDayOfWeek: Day of week DST ends. Accepted but unused.
    ///   - endTime: Wall-clock time (ms) DST ends. Accepted but unused.
    public init(
      _ rawOffset: Int, _ id: String,
      _ startMonth: Int, _ startDay: Int, _ startDayOfWeek: Int, _ startTime: Int,
      _ endMonth: Int,   _ endDay: Int,   _ endDayOfWeek: Int,   _ endTime: Int
    ) {
      self.javaID = id
      if let tz = Foundation.TimeZone(identifier: id) {
        self.delegate = tz
      } else {
        self.delegate = Foundation.TimeZone(secondsFromGMT: rawOffset / 1000) ?? .current
      }
    }
    
    // MARK: - DST query
    
    /// Returns `true` if the given date falls within daylight saving time for this zone.
    ///
    /// Delegates to `Foundation.TimeZone.isDaylightSavingTime(for:)`.
    public func inDaylightTime(_ date: java.util.Date) -> Bool {
      return delegate.isDaylightSavingTime(for: date.delegate)
    }
    
    // MARK: - TimeZone protocol
    
    /// Returns the timezone ID exactly as it was passed to the constructor,
    /// preserving the Java contract (`getTimeZone("UTC").getID() == "UTC"`).
    public func getID() -> String {
      return javaID
    }
    
    public func getRawOffset() -> Int {
      // Java returns milliseconds
      return delegate.secondsFromGMT() * 1000
    }
  }
}
