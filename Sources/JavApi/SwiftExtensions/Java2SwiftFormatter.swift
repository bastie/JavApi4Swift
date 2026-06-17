/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

/// Bridges Java-style `printf`/`String.format` format strings to Swift's
/// `String(format:)` (which uses C/Objective-C printf conventions).
///
/// ## What this handles
///
/// | Java specifier      | Action |
/// |---------------------|--------|
/// | `%s`, `%S`          | → `%@` (Swift string placeholder) |
/// | `%n`                | → `\n` |
/// | `%b`, `%B`          | Rendered directly as `"true"`/`"false"` before Swift sees it |
/// | `%,d` / `%,f` etc.  | Grouping flag `,` stripped; grouping applied after formatting |
/// | `%tY`, `%tm`, …     | Date/time specifiers expanded before Swift sees them |
/// | `%1$s`, `%2$d`, …   | Argument-index notation resolved; args reordered for Swift |
/// | Everything else     | Passed through unchanged to `String(format:)` |
///
/// ## Usage
///
/// ```swift
/// let result = Java2SwiftFormatter.format("%,d items cost %.2f€", args: [1_000, 3.99])
/// // → "1.000 items cost 3,99€"  (locale-dependent)
/// ```
///
/// This type is **internal** — callers are `String.format(...)`, `Formatter`,
/// and `PrintStream.printf(...)`.
struct Java2SwiftFormatter {

  // ---------------------------------------------------------------------------
  // MARK: Public entry point
  // ---------------------------------------------------------------------------

  /// Formats `args` according to the Java format string `fmt`.
  ///
  /// - Parameters:
  ///   - fmt:  A Java-style format string.
  ///   - args: The arguments referenced by the format string.
  /// - Returns: The formatted string.
  static func format(_ fmt: String, args: [Any?]) -> String {
    // Phase 1: resolve argument-index notation (%1$s → positional)
    let (resolvedFmt, resolvedArgs) = resolveArgumentIndices(fmt, args: args)

    // Phase 2: walk specifiers and build Swift format + transformed args
    var swiftFmt   = ""
    var swiftArgs  : [CVarArg] = []
    var argIdx     = 0
    var i          = resolvedFmt.startIndex
    var hasGrouping = false

    while i < resolvedFmt.endIndex {
      let ch = resolvedFmt[i]

      guard ch == "%" else {
        swiftFmt.append(ch)
        i = resolvedFmt.index(after: i)
        continue
      }

      // We are at '%' — scan the full specifier
      let specStart = i
      i = resolvedFmt.index(after: i)   // skip '%'
      guard i < resolvedFmt.endIndex else { swiftFmt.append("%"); break }

      // %% escape
      if resolvedFmt[i] == "%" {
        swiftFmt.append("%%")
        i = resolvedFmt.index(after: i)
        continue
      }

      // %n — platform line separator (like Java's System.lineSeparator())
      if resolvedFmt[i] == "n" {
        swiftFmt.append(java.lang.System.getProperty("line.separator", "\n"))
        i = resolvedFmt.index(after: i)
        continue
      }

      // Collect flags, width, precision, conversion
      var flags     = ""
      var width     = ""
      var precision = ""

      // Flags: -, +, 0, ' ', #, ,
      while i < resolvedFmt.endIndex && "-+ #0,(".contains(resolvedFmt[i]) {
        let f = resolvedFmt[i]
        if f == "," { hasGrouping = true }
        else { flags.append(f) }
        i = resolvedFmt.index(after: i)
      }
      // Width
      while i < resolvedFmt.endIndex && resolvedFmt[i].isNumber {
        width.append(resolvedFmt[i])
        i = resolvedFmt.index(after: i)
      }
      // Precision
      if i < resolvedFmt.endIndex && resolvedFmt[i] == "." {
        i = resolvedFmt.index(after: i)
        while i < resolvedFmt.endIndex && resolvedFmt[i].isNumber {
          precision.append(resolvedFmt[i])
          i = resolvedFmt.index(after: i)
        }
      }

      guard i < resolvedFmt.endIndex else { break }
      let conv = resolvedFmt[i]
      i = resolvedFmt.index(after: i)

      let arg = argIdx < resolvedArgs.count ? resolvedArgs[argIdx] : nil
      argIdx += 1

      switch conv {

      // ── String ──────────────────────────────────────────────────────────────
      case "s":
        let s = arg.map { "\($0)" } ?? "null"
        let padded = applyWidth(s, width: Int(width) ?? 0,
                                leftAlign: flags.contains("-"),
                                upper: false)
        swiftFmt  += "%@"
        swiftArgs.append(padded as CVarArg)

      case "S":
        let s = (arg.map { "\($0)" } ?? "null").uppercased()
        let padded = applyWidth(s, width: Int(width) ?? 0,
                                leftAlign: flags.contains("-"),
                                upper: false)
        swiftFmt  += "%@"
        swiftArgs.append(padded as CVarArg)

      // ── Boolean ─────────────────────────────────────────────────────────────
      case "b":
        let b: Bool
        switch arg {
        case let v as Bool:   b = v
        case .none:           b = false
        default:              b = true
        }
        swiftFmt  += "%@"
        swiftArgs.append((b ? "true" : "false") as CVarArg)

      case "B":
        let b: Bool
        switch arg {
        case let v as Bool:   b = v
        case .none:           b = false
        default:              b = true
        }
        swiftFmt  += "%@"
        swiftArgs.append((b ? "TRUE" : "FALSE") as CVarArg)

      // ── Character ───────────────────────────────────────────────────────────
      case "c", "C":
        let s: String
        switch arg {
        case let c as Character: s = String(c)
        case let n as Int:       s = String(UnicodeScalar(n) ?? UnicodeScalar(0))
        default:                 s = arg.map { "\($0)" } ?? "?"
        }
        swiftFmt  += "%@"
        swiftArgs.append(s as CVarArg)

      // ── Integer ─────────────────────────────────────────────────────────────
      case "d":
        let spec = buildCSpec(flags: flags, width: width, precision: precision, conv: "d")
        if hasGrouping {
          // Format first, then insert grouping separators
          let n = toInt64(arg)
          let raw = String(format: spec, n)
          swiftFmt  += "%@"
          swiftArgs.append(insertGrouping(raw) as CVarArg)
        } else {
          swiftFmt  += spec
          swiftArgs.append(toInt64(arg))
        }

      case "o":
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "o")
        swiftArgs.append(toInt64(arg))

      case "x":
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "x")
        swiftArgs.append(toInt64(arg))

      case "X":
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "X")
        swiftArgs.append(toInt64(arg))

      // ── Floating point ───────────────────────────────────────────────────────
      case "f":
        let prec = Int(precision) ?? 6
        let formatted = formatDouble(toDouble(arg), precision: prec,
                                     grouping: hasGrouping,
                                     width: Int(width) ?? 0,
                                     leftAlign: flags.contains("-"))
        swiftFmt  += "%@"
        swiftArgs.append(formatted as CVarArg)

      case "e":
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "e")
        swiftArgs.append(toDouble(arg))

      case "E":
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "E")
        swiftArgs.append(toDouble(arg))

      case "g", "G":
        let c2: Character = conv == "g" ? "g" : "G"
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: c2)
        swiftArgs.append(toDouble(arg))

      case "a", "A":
        // Hex float — Swift supports %a
        let c2: Character = conv == "a" ? "a" : "A"
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: c2)
        swiftArgs.append(toDouble(arg))

      // ── Date/time (%t prefix already consumed as 't', next char is sub-spec)
      case "t", "T":
        guard i < resolvedFmt.endIndex else { break }
        let sub = resolvedFmt[i]
        i = resolvedFmt.index(after: i)
        let dateStr = formatDateArg(arg, subSpec: sub)
        let upper   = conv == "T"
        swiftFmt  += "%@"
        swiftArgs.append((upper ? dateStr.uppercased() : dateStr) as CVarArg)
        argIdx -= 1   // %t consumes no extra arg beyond arg already fetched

      // ── Hash code / identity ────────────────────────────────────────────────
      case "h", "H":
        let hash = arg.map { ObjectIdentifier($0 as AnyObject).hashValue } ?? 0
        let hex  = String(format: "%x", hash)
        swiftFmt  += "%@"
        swiftArgs.append((conv == "H" ? hex.uppercased() : hex) as CVarArg)

      default:
        // Unknown — pass through verbatim
        let raw = String(resolvedFmt[specStart..<i])
        swiftFmt  += raw
        argIdx -= 1   // didn't consume an arg
      }
    }
    if hasGrouping {
      return String(
        format: swiftFmt,
        locale: java.util.Locale.getDefault().delegate,
        arguments: swiftArgs
      )
    }
    else {
      return String(
        format: swiftFmt,
        arguments: swiftArgs
      )
    }
    //return String(format: swiftFmt, locale: java.util.Locale.getDefault().delegate,  arguments: swiftArgs)
  }

  // ---------------------------------------------------------------------------
  // MARK: Argument-index resolution  (%1$s, %2$d, …)
  // ---------------------------------------------------------------------------

  /// Resolves Java argument-index notation (`%1$s`) into positional order.
  ///
  /// Returns a new format string (with indices stripped) and a reordered
  /// argument array matching the positional order of specifiers in the string.
  private static func resolveArgumentIndices(_ fmt: String, args: [Any?]) -> (String, [Any?]) {
    // Quick check — if no '$' present, nothing to do
    guard fmt.contains("$") else { return (fmt, args) }

    var result    = ""
    var outArgs   : [Any?] = []
    var i         = fmt.startIndex

    while i < fmt.endIndex {
      guard fmt[i] == "%" else {
        result.append(fmt[i])
        i = fmt.index(after: i)
        continue
      }
      result.append("%")
      i = fmt.index(after: i)
      guard i < fmt.endIndex else { break }

      // Try to read  <digits>$
      var digits = ""
      var j = i
      while j < fmt.endIndex && fmt[j].isNumber { digits.append(fmt[j]); j = fmt.index(after: j) }
      if !digits.isEmpty && j < fmt.endIndex && fmt[j] == "$" {
        // Found argument index
        let idx = (Int(digits) ?? 1) - 1   // Java is 1-based
        outArgs.append(idx < args.count ? args[idx] : nil)
        i = fmt.index(after: j)   // skip past '$'
        // Do NOT append the index or '$' to result
      } else {
        // No index — sequential
        outArgs.append(outArgs.count < args.count ? args[outArgs.count] : nil)
        // i stays at current position
      }
    }
    return (result, outArgs)
  }

  // ---------------------------------------------------------------------------
  // MARK: Date/time sub-specifiers
  // ---------------------------------------------------------------------------

  private static func formatDateArg(_ arg: Any?, subSpec: Character) -> String {
    let date: Foundation.Date
    switch arg {
    case let d as java.util.Date:      date = d.delegate
    case let d as Foundation.Date:     date = d
    case let ms as Int64:              date = Foundation.Date(timeIntervalSince1970: Double(ms) / 1000)
    case let ms as Int:                date = Foundation.Date(timeIntervalSince1970: Double(ms) / 1000)
    default:                           date = Foundation.Date()
    }

    let cal  = Foundation.Calendar.current
    let comp = cal.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday], from: date)
    let fmt  = Foundation.DateFormatter()
    fmt.locale = java.util.Locale.getDefault().delegate ?? Foundation.Locale.current

    switch subSpec {
    case "H": fmt.dateFormat = "HH"
    case "I": fmt.dateFormat = "hh"
    case "k": return "\(comp.hour ?? 0)"
    case "l": return "\(((comp.hour ?? 0) % 12) == 0 ? 12 : (comp.hour ?? 0) % 12)"
    case "M": fmt.dateFormat = "mm"
    case "S": fmt.dateFormat = "ss"
    case "L": return String(format: "%03d", (comp.nanosecond ?? 0) / 1_000_000)
    case "N": return String(format: "%09d", comp.nanosecond ?? 0)
    case "p": fmt.dateFormat = "a"; return fmt.string(from: date).lowercased()
    case "z": fmt.dateFormat = "Z"
    case "Z": fmt.dateFormat = "zzz"
    case "s": return "\(Int64(date.timeIntervalSince1970))"
    case "Q": return "\(Int64(date.timeIntervalSince1970 * 1000))"
    case "B": fmt.dateFormat = "MMMM"
    case "b", "h": fmt.dateFormat = "MMM"
    case "A": fmt.dateFormat = "EEEE"
    case "a": fmt.dateFormat = "EEE"
    case "C": return String(format: "%02d", (comp.year ?? 0) / 100)
    case "Y": fmt.dateFormat = "yyyy"
    case "y": fmt.dateFormat = "yy"
    case "j": fmt.dateFormat = "DDD"
    case "m": fmt.dateFormat = "MM"
    case "d": fmt.dateFormat = "dd"
    case "e": return "\(comp.day ?? 0)"
    case "R": fmt.dateFormat = "HH:mm"
    case "T": fmt.dateFormat = "HH:mm:ss"
    case "r": fmt.dateFormat = "hh:mm:ss a"
    case "D": fmt.dateFormat = "MM/dd/yy"
    case "F": fmt.dateFormat = "yyyy-MM-dd"
    case "c": fmt.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
    default:  return "?"
    }
    return fmt.string(from: date)
  }

  // ---------------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------------

  /// Formats a `Double` locale-sensitively for `%f`.
  ///
  /// `String(format: "%f", ...)` always uses the C locale (`.` as decimal
  /// separator). We use `Foundation.NumberFormatter` instead so that the
  /// locale set via `java.util.Locale.setDefault()` is respected.
  private static func formatDouble(_ value: Double, precision: Int,
                                   grouping: Bool, width: Int,
                                   leftAlign: Bool) -> String {
    let nf = Foundation.NumberFormatter()
    nf.locale          = java.util.Locale.getDefault().delegate ?? Foundation.Locale.current
    nf.numberStyle     = .decimal
    nf.minimumFractionDigits = precision
    nf.maximumFractionDigits = precision
    nf.usesGroupingSeparator = grouping
    let raw = nf.string(from: NSNumber(value: value)) ?? String(format: "%.\(precision)f", value)
    return applyWidth(raw, width: width, leftAlign: leftAlign, upper: false)
  }

  /// Builds a C printf specifier from parsed components.
  private static func buildCSpec(flags: String, width: String, precision: String, conv: Character) -> String {
    var s = "%"
    s += flags
    s += width
    if !precision.isEmpty { s += ".\(precision)" }
    s.append(conv)
    return s
  }

  /// Inserts locale-aware grouping separators into a formatted integer string.
  private static func insertGrouping(_ raw: String) -> String {
    // Split on decimal point if present
    let sep = String(java.util.Locale.getDefault().delegate.decimalSeparator ?? ".")
    let parts = raw.components(separatedBy: sep)
    var intPart = parts[0]
    let fracPart = parts.count > 1 ? sep + parts[1] : ""

    // Strip leading minus for processing
    let negative = intPart.hasPrefix("-")
    if negative { intPart = String(intPart.dropFirst()) }

    let groupSep = String(java.util.Locale.getDefault().delegate.groupingSeparator ?? ",")
    var result = ""
    for (offset, ch) in intPart.reversed().enumerated() {
      if offset > 0 && offset % 3 == 0 { result.insert(contentsOf: groupSep.reversed(), at: result.startIndex) }
      result.insert(ch, at: result.startIndex)
    }
    return (negative ? "-" : "") + result + fracPart
  }

  private static func applyWidth(_ s: String, width: Int, leftAlign: Bool, upper: Bool) -> String {
    let t = upper ? s.uppercased() : s
    guard width > t.count else { return t }
    let pad = String(repeating: " ", count: width - t.count)
    return leftAlign ? t + pad : pad + t
  }

  private static func toInt64(_ arg: Any?) -> Int64 {
    switch arg {
    case let v as Int64:  return v
    case let v as Int:    return Int64(v)
    case let v as Int32:  return Int64(v)
    case let v as Int16:  return Int64(v)
    case let v as Int8:   return Int64(v)
    case let v as UInt64: return Int64(bitPattern: v)
    case let v as Double: return Int64(v)
    case let v as Float:  return Int64(v)
    case let v as NSNumber: return v.int64Value
    default: return 0
    }
  }

  private static func toDouble(_ arg: Any?) -> Double {
    switch arg {
    case let v as Double:   return v
    case let v as Float:    return Double(v)
    case let v as Int:      return Double(v)
    case let v as Int64:    return Double(v)
    case let v as NSNumber: return v.doubleValue
    default: return 0.0
    }
  }
}
