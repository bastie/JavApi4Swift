/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.sql {

  /// A thin wrapper around `java.util.Date` that stores only a date value
  /// (year, month, day) without a time-of-day component.
  ///
  /// Mirrors `java.sql.Date` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  open class Date : java.util.Date {

    /// Creates a `java.sql.Date` from milliseconds since the epoch.
    public init(_ millisecondsSince1970: Int64) {
      super.init()
      let secondsSince1970 = millisecondsSince1970 / 1000
      self.delegate = Foundation.Date(timeIntervalSince1970: Foundation.TimeInterval(secondsSince1970))
    }

    /// Creates a `java.sql.Date` for the current date.
    public override init() {
      super.init()
    }

    /// Returns a string representation in the JDBC date escape format `yyyy-MM-dd`.
    open override func toString() -> String {
      let cal = Foundation.Calendar(identifier: .gregorian)
      let fields: Set<Foundation.Calendar.Component> = [.year, .month, .day]
      let comps = cal.dateComponents(fields, from: self.delegate)
      let y = comps.year ?? 1970
      let m = comps.month ?? 1
      let d = comps.day ?? 1
      return String(format: "%04d-%02d-%02d", y, m, d)
    }
  }
}
