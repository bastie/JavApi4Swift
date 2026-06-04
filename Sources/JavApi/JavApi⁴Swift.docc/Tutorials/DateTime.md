# Date and Time

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Working with dates, times, and time zones using the `java.time` API.

## Overview

Time is surprisingly complicated in software. A moment in time depends on where you are in the world, whether daylight saving is in effect, and what calendar system you use. Java 8 introduced the `java.time` package to handle this cleanly. JavApi⁴Swift implements the same API.

The key insight of `java.time` is the separation of concerns:

- **`LocalDate`** — a calendar date with no time of day and no time zone (e.g. "2026-06-04")
- **`LocalTime`** — a time of day with no date and no time zone (e.g. "14:30:00")
- **`LocalDateTime`** — a date combined with a time of day, still without time zone
- **`ZonedDateTime`** — a full point in time, including time zone
- **`Clock`** — represents a time zone offset, used to anchor "local" types to real time
- **`Period`** — an amount of time in years, months, days, hours, minutes, seconds, and nanoseconds

## LocalDate

Use `LocalDate` when you care about the calendar date but not the time of day — birthdays, holidays, deadlines.

```swift
import JavApi

// Today's date in the current time zone
let today = java.time.LocalDate(clock: .current)

// A specific date
let moonLanding = java.time.LocalDate(year: 1969, month: 7, day: 20)

print(moonLanding.year)    // 1969
print(moonLanding.month)   // 7
print(moonLanding.day)     // 20
```

### Arithmetic

```swift
let start = java.time.LocalDate(year: 2026, month: 1, day: 1)

let nextWeek    = start.plus(week: 1)     // 2026-01-08
let nextMonth   = start.plus(month: 1)    // 2026-02-01
let lastYear    = start.minus(year: 1)    // 2025-01-01

// Operators work too
let addDate = java.time.LocalDate(month: 0, day: 10)
let result  = start + addDate             // 2026-01-11
```

### Comparison

```swift
let a = java.time.LocalDate(year: 2020, month: 6, day: 15)
let b = java.time.LocalDate(year: 2021, month: 3, day: 1)

if a < b {
    print("a is earlier")   // prints
}
```

### How Many Days Between Two Dates?

```swift
let from = java.time.LocalDate(year: 2026, month: 1, day: 1)
let to   = java.time.LocalDate(year: 2026, month: 12, day: 31)

let days = from.until(endDate: to, component: .day)
print(days)   // 364
```

### Parsing and Formatting

```swift
import Foundation

// Parse from a standard ISO date string
let parsed = java.time.LocalDate.parse("2026-06-04", clock: .current)!

// Format with a custom pattern
let formatter = DateFormatter()
formatter.dateFormat = "dd.MM.yyyy"
let formatted = parsed.format(formatter)   // "04.06.2026"
```

### Leap Year and Month Length

```swift
let date = java.time.LocalDate(year: 2024, month: 2, day: 1)

print(date.isLeapYear())     // true  (2024 is a leap year)
print(date.lengthOfMonth())  // 29    (February in a leap year)
print(date.lengthOfYear())   // 366
```

## LocalTime

Use `LocalTime` when you care about the time of day but not the date — opening hours, alarm times, scheduling.

```swift
import JavApi

let opening = java.time.LocalTime(hour: 9, minute: 0, second: 0, nanoOfSecond: 0)
let closing = java.time.LocalTime(hour: 17, minute: 30, second: 0, nanoOfSecond: 0)

print(opening.hour)    // 9
print(closing.minute)  // 30

// Convenient factory
let noon = java.time.LocalTime.noon       // 12:00:00
let midnight = java.time.LocalTime.midNight  // 00:00:00
```

### Overflow Is Handled Automatically

```swift
// 14:61 normalizes to 15:01
let time = java.time.LocalTime(hour: 14, minute: 61, second: 0, nanoOfSecond: 0)
print(time.hour)    // 15
print(time.minute)  // 1
```

### How Much Time Between Two Times?

```swift
let start = java.time.LocalTime(hour: 9,  minute: 0,  second: 0, nanoOfSecond: 0)
let end   = java.time.LocalTime(hour: 17, minute: 30, second: 0, nanoOfSecond: 0)

let hours   = start.until(endTime: end, component: .hour)    // 8
let minutes = start.until(endTime: end, component: .minute)  // 510
```

## LocalDateTime

`LocalDateTime` combines date and time without a time zone. Use it for timestamps that should be interpreted relative to the local context — log entries, meeting times.

```swift
import JavApi

let meeting = java.time.LocalDateTime(
    year: 2026, month: 6, day: 15,
    hour: 14, minute: 30, second: 0, nanoOfSecond: 0
)

print(meeting.year)    // 2026
print(meeting.hour)    // 14

// Access the date or time part separately
let dateOnly = meeting.date   // java.time.LocalDate(2026, 6, 15)
let timeOnly = meeting.time   // java.time.LocalTime(14, 30, 0, 0)
```

## Clock and Time Zones

`Clock` represents a time zone offset. The built-in clocks are:

```swift
java.time.Clock.UTC              // UTC+00:00
java.time.Clock.GMT              // same as UTC
java.time.Clock.current          // system time zone
java.time.Clock.autoupdatingCurrent  // updates when system zone changes

// Specific time zone by identifier
let berlin = java.time.Clock(identifier: "Europe/Berlin")!
let tokyo  = java.time.Clock(identifier: "Asia/Tokyo")!

// Offset from UTC in seconds
print(berlin.offsetSecond)   // e.g. 3600 in winter (UTC+1)
```

## ZonedDateTime

`ZonedDateTime` is a `LocalDateTime` pinned to a specific time zone. Use it when you need to compare times across different parts of the world, or convert between time zones.

```swift
import JavApi

let utcTZ = TimeZone(identifier: "UTC")!
let kstTZ = TimeZone(abbreviation: "KST")!   // Korea Standard Time (UTC+9)

// The same calendar time in two different zones
let meetingUTC = java.time.ZonedDateTime(
    year: 2026, month: 6, day: 15,
    hour: 9, minute: 0, second: 0, nanoOfSecond: 0,
    timeZone: utcTZ
)

// How many hours difference to KST?
let meetingKST = meetingUTC.with(zoneSameInstant: kstTZ)
let hourDiff   = meetingUTC.until(endDateTime: meetingKST, component: .hour)
print(hourDiff)   // 9
```

## Period — Amounts of Time

`Period` represents a duration in human calendar units, not a fixed number of seconds.

```swift
import JavApi

let period = java.time.Period(year: 1, month: 6, day: 0,
                              hour: 0, minute: 0, second: 0, nano: 0)

let date   = java.time.LocalDate(year: 2025, month: 1, day: 1)
let future = date + period   // 2026-07-01
```

### Building Periods With Integer Extensions

JavApi⁴Swift adds expressive extensions to `Int` for building periods:

```swift
import JavApi

let oneYearAndTwoWeeks = 1.year + 2.week
let threeMonthsAndADay = 3.month + 1.day

let base   = java.time.LocalDateTime(year: 2026, month: 1, day: 1,
                                     hour: 0, minute: 0, second: 0, nanoOfSecond: 0)
let result = base + oneYearAndTwoWeeks
print(result.year)   // 2027
print(result.day)    // 15  (Jan 1 + 14 days)
```

## Summary

| Type | What it represents | Has time zone? |
|---|---|---|
| `LocalDate` | A calendar date | No |
| `LocalTime` | A time of day | No |
| `LocalDateTime` | Date + time of day | No |
| `ZonedDateTime` | Date + time + zone | Yes |
| `Clock` | A time zone offset | Yes |
| `Period` | An amount of time | No |

The rule of thumb: use `Local*` types whenever you can. Only add a time zone (`ZonedDateTime`) when you actually need to compare moments across zones or display a time to a user in a specific location.

## Questions and Exercises

1. Create a `LocalDate` for your birthday this year. How many days until it? (Hint: use `until(endDate:component:)`.)
2. What does `java.time.LocalTime(hour: 23, minute: 59, second: 61, nanoOfSecond: 0)` produce? What is the resulting hour, minute, and second?
3. A flight departs Tokyo (JST = UTC+9) at 10:00 and arrives in Berlin (CET = UTC+1) at 14:00 local time the same day. Use `ZonedDateTime` and `until` to calculate the actual flight duration in hours.
4. Use `1.year + 6.month` to find the date exactly 18 months from today.

## Next Steps

Continue to <doc:InputOutput> to learn how to read and write data with the `java.io` API.
