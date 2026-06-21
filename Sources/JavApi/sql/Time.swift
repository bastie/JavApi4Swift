/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.sql {

  /// A thin wrapper around `java.util.Date` that stores only a time-of-day
  /// value (hours, minutes, seconds).
  ///
  /// Mirrors `java.sql.Time` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  open class Time : java.util.Date {

    public init(_ millisecondsSince1970: Int64) {
      super.init()
      let secondsSince1970 = millisecondsSince1970 / 1000
      self.delegate = Foundation.Date(timeIntervalSince1970: Foundation.TimeInterval(secondsSince1970))
    }

    public override init() {
      super.init()
    }

    /// Returns a string in the JDBC time escape format `HH:mm:ss`.
    open override func toString() -> String {
      let cal = Foundation.Calendar(identifier: .gregorian)
      let fields: Set<Foundation.Calendar.Component> = [.hour, .minute, .second]
      let comps = cal.dateComponents(fields, from: self.delegate)
      let h = comps.hour ?? 0
      let m = comps.minute ?? 0
      let s = comps.second ?? 0
      return String(format: "%02d:%02d:%02d", h, m, s)
    }
  }
}
