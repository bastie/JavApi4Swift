/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.sql {

  /// A thin wrapper around `java.util.Date` that stores date and time with
  /// nanosecond precision.
  ///
  /// Mirrors `java.sql.Timestamp` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  open class Timestamp : java.util.Date {

    private var nanos: Int = 0

    public init(_ millisecondsSince1970: Int64) {
      self.nanos = Int((millisecondsSince1970 % 1000) * 1_000_000)
      super.init()
      let secondsSince1970 = millisecondsSince1970 / 1000
      self.delegate = Foundation.Date(timeIntervalSince1970: Foundation.TimeInterval(secondsSince1970))
    }

    public override init() {
      super.init()
    }

    open func getNanos() -> Int { return nanos }
    open func setNanos(_ n: Int) { nanos = n }

    /// Returns a string in the JDBC timestamp escape format
    /// `yyyy-MM-dd HH:mm:ss.fffffffff`.
    open override func toString() -> String {
      let cal = Foundation.Calendar(identifier: .gregorian)
      let fields: Set<Foundation.Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
      let comps = cal.dateComponents(fields, from: self.delegate)
      let y = comps.year ?? 1970
      let mo = comps.month ?? 1
      let d = comps.day ?? 1
      let h = comps.hour ?? 0
      let mi = comps.minute ?? 0
      let s = comps.second ?? 0
      return String(format: "%04d-%02d-%02d %02d:%02d:%02d.%09d", y, mo, d, h, mi, s, nanos)
    }
  }
}
