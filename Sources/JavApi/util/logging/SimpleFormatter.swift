/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.logging {

  /// A `Formatter` that produces human-readable, single-line log output.
  ///
  /// The output format is:
  /// ```
  /// <date> <level>: [<class>.<method>] <message>\n
  /// ```
  /// where `<date>` uses ISO-8601 local time (falling back to epoch millis
  /// when `Foundation.DateFormatter` is unavailable).
  ///
  /// This implementation mirrors the spirit of `java.util.logging.SimpleFormatter`
  /// (Java 1.4).  The exact format string (`java.util.logging.SimpleFormatter.format`)
  /// is not honoured because that requires `printf`-style formatting which is
  /// outside the scope of this port.
  ///
  /// - Since: Java 1.4
  open class SimpleFormatter: Formatter {

    public override init() { super.init() }

    open override func format(_ record: LogRecord) -> String {
      // Build a readable timestamp from epoch millis.
      let millis = record.getMillis()
      let date = Date(timeIntervalSince1970: Double(millis) / 1_000.0)
      let dateStr: String
      let fmt = DateFormatter()
      fmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
      dateStr = fmt.string(from: date)

      let levelStr = record.getLevel().getName()

      var source = ""
      if let cls = record.getSourceClassName(), !cls.isEmpty {
        source = cls
        if let mth = record.getSourceMethodName(), !mth.isEmpty {
          source += ".\(mth)"
        }
        source = " [\(source)]"
      }

      let msg = record.getMessage() ?? ""

      var result = "\(dateStr) \(levelStr):\(source) \(msg)\n"

      if let thrown = record.getThrown() {
        result += "Thrown: \(thrown)\n"
      }

      return result
    }
  }
}
