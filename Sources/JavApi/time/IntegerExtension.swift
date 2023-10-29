/*
 * SPDX-License-Identifier: MIT
 */
import Foundation

public extension BinaryInteger {

    /// Obtains the Period instance for the year.
  var year: java.time.Period {
    return java.time.Period(year: Int(self), month: 0, day: 0, hour: 0, minute: 0, second: 0, nano: 0)
    }
    
    /// Obtains the Period instance for the month.
  var month: java.time.Period {
    return java.time.Period(year: 0, month: Int(self), day: 0, hour: 0, minute: 0, second: 0, nano: 0)
    }

    /// Obtains the Period instance for the week.
  var week: java.time.Period {
    return java.time.Period(year: 0, month: 0, day: Int(self) * 7, hour: 0, minute: 0, second: 0, nano: 0)
    }

    /// Obtains the Period instance for the day.
  var day: java.time.Period {
    return java.time.Period(year: 0, month: 0, day: Int(self), hour: 0, minute: 0, second: 0, nano: 0)
    }

    /// Obtains the Period instance for the hour.
  var hour: java.time.Period {
    return java.time.Period(year: 0, month: 0, day: 0, hour: Int(self), minute: 0, second: 0, nano: 0)
    }

    /// Obtains the Period instance for the minute.
  var minute: java.time.Period {
    return java.time.Period(year: 0, month: 0, day: 0, hour: 0, minute: Int(self), second: 0, nano: 0)
    }

    /// Obtains the Period instance for the second.
  var second: java.time.Period {
    return java.time.Period(year: 0, month: 0, day: 0, hour: 0, minute: 0, second: Int(self), nano: 0)
    }

    /// Obtains the Period instance for the nano-of-second.
  var nanosecond: java.time.Period {
    return java.time.Period(year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, nano: Int(self))
    }

}
