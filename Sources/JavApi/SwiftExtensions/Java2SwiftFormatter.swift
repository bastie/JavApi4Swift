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

  /// Formats `args` according to the Java format string `fmt`, using the
  /// global `java.util.Locale.getDefault()` — mirrors
  /// `java.util.Formatter.format(String, Object...)` /
  /// `String.format(String, Object...)`.
  ///
  /// - Parameters:
  ///   - fmt:  A Java-style format string.
  ///   - args: The arguments referenced by the format string.
  /// - Returns: The formatted string.
  ///
  /// - Throws: An appropriate `java.util.IllegalFormatException` subclass
  ///   (`java.util.UnknownFormatConversionException`, `java.util.MissingFormatArgumentException`,
  ///   `java.util.IllegalFormatConversionException`, `java.util.DuplicateFormatFlagsException`,
  ///   `java.util.MissingFormatWidthException`, `java.util.IllegalFormatPrecisionException`,
  ///   `java.util.FormatFlagsConversionMismatchException`,
  ///   `java.util.IllegalFormatCodePointException`) if `fmt` is malformed or `args`
  ///   does not match it — see the per-case notes below for exactly which
  ///   checks are implemented.
  static func format(_ fmt: String, args: [Any?]) throws -> String {
    return try format(fmt, args: args, locale: java.util.Locale.getDefault())
  }

  /// Formats `args` according to the Java format string `fmt`, using an
  /// explicit `Locale` instead of the global `java.util.Locale.getDefault()`.
  ///
  /// Mirrors `java.util.Formatter.format(Locale, String, Object...)` /
  /// `String.format(Locale, String, Object...)`. Per the Java API contract
  /// for those overloads, passing `nil` means *"no localization is
  /// applied"* — number formatting falls back to a fixed,
  /// locale-independent convention ('.' decimal separator, ',' grouping
  /// separator, i.e. `Locale.ROOT`-like behaviour) instead of consulting
  /// the global default.
  ///
  /// - Parameters:
  ///   - fmt:    A Java-style format string.
  ///   - args:   The arguments referenced by the format string.
  ///   - locale: The `Locale` to format with, or `nil` for no localization
  ///             (matches Java's documented `null`-`Locale` behaviour).
  /// - Returns: The formatted string.
  static func format(_ fmt: String, args: [Any?], locale: java.util.Locale?) throws -> String {
    let resolvedLocale: Foundation.Locale = locale?.delegate ?? Foundation.Locale(identifier: "en_US_POSIX")
    // Phase 1: resolve argument-index notation (%1$s → positional).
    // `missingArgPositions` marks positions in `resolvedArgs` that don't
    // correspond to a real caller-supplied argument (out-of-range %n$
    // index, or simply ran out of positional args) — distinct from a
    // caller-supplied Java `null`, which is a legitimate `nil` at a
    // *present* position.
    let (resolvedFmt, resolvedArgs, missingArgPositions) = resolveArgumentIndices(fmt, args: args)

    // Phase 2: walk specifiers and build Swift format + transformed args
    var swiftFmt   = ""
    var swiftArgs  : [CVarArg] = []
    var argIdx     = 0
    var i          = resolvedFmt.startIndex
    var hasGrouping = false

    // Conversions that accept a precision at all, per java.util.Formatter's
    // documented grammar — everything else throws java.util.IllegalFormatPrecisionException.
    let precisionCapableConversions: Set<Character> = ["s", "S", "b", "B", "h", "H", "e", "E", "f", "g", "G"]
    // Conversions the ',' grouping flag is legal on. Per java.util.Formatter's
    // own per-conversion documentation, 'e'/'E' explicitly throw
    // FormatFlagsConversionMismatchException when ',' is given ("If the ','
    // flag is given, then a FormatFlagsConversionMismatchException will be
    // thrown.") — despite the class-level flags *summary table* listing
    // 'e'/'E' alongside 'f'/'g'/'G' as accepting the flag, the authoritative
    // per-conversion text for 'e' contradicts that and is what real JDKs
    // implement; 'g'/'G' have no such sentence in their own description and
    // do apply grouping (in their decimal-format branch), same as 'f'.
    let groupingCapableConversions: Set<Character> = ["d", "f", "g", "G"]

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
      var flags        = ""
      var width        = ""
      var precision    = ""
      var seenFlagChars: Set<Character> = []

      // Flags: -, +, 0, ' ', #, ,
      while i < resolvedFmt.endIndex && "-+ #0,(".contains(resolvedFmt[i]) {
        let f = resolvedFmt[i]
        if seenFlagChars.contains(f) {
          throw java.util.DuplicateFormatFlagsException("\(f)\(f)")
        }
        seenFlagChars.insert(f)
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

      // '-' (left-justify) requires an explicit width.
      if flags.contains("-") && width.isEmpty {
        throw java.util.MissingFormatWidthException(String(resolvedFmt[specStart..<i]))
      }
      // Precision is only legal on the conversions that document it.
      if !precision.isEmpty && !precisionCapableConversions.contains(conv) {
        throw java.util.IllegalFormatPrecisionException(Int(precision) ?? -1)
      }
      // ',' (grouping) is only legal on the numeric conversions that support it.
      if seenFlagChars.contains(",") && !groupingCapableConversions.contains(conv) {
        throw java.util.FormatFlagsConversionMismatchException(",", conv)
      }

      let hasArg = argIdx < resolvedArgs.count && !missingArgPositions.contains(argIdx)
      let arg    = hasArg ? resolvedArgs[argIdx] : nil
      argIdx += 1
      // Every conversion besides '%' and 'n' (both already handled above,
      // before reaching this point) consumes an argument.
      if !hasArg {
        throw java.util.MissingFormatArgumentException("%" + String(conv))
      }

      switch conv {

      // ── String ──────────────────────────────────────────────────────────────
      // Per Java's `Formatter` javadoc, 's'/'S' first check whether the
      // argument implements `Formattable` and, if so, delegate rendering to
      // it entirely (it is then responsible for honouring width/precision/
      // flags itself); otherwise fall back to plain `toString()`-style
      // rendering with this formatter's own width handling.
      case "s", "S":
        let upper = conv == "S"
        // '#' ("alternate") is only meaningful for 's'/'S' when the
        // argument implements Formattable, which is then responsible for
        // honouring it itself — matches Java's documented behaviour.
        if flags.contains("#"), let value = arg, !(value is java.util.Formattable) {
          throw java.util.FormatFlagsConversionMismatchException("#", conv)
        }
        if let formattable = arg as? java.util.Formattable {
          swiftFmt += "%@"
          swiftArgs.append(
            try formatUsingFormattable(
              formattable, flags: flags, upper: upper,
              width: Int(width) ?? -1, precision: Int(precision) ?? -1,
              locale: locale, fallback: arg
            ) as CVarArg
          )
        } else {
          let s = arg.map { "\($0)" } ?? "null"
          let padded = applyGeneralFormatting(s, width: width, precision: precision,
                                              leftAlign: flags.contains("-"), upper: upper)
          swiftFmt  += "%@"
          swiftArgs.append(padded as CVarArg)
        }

      // ── Boolean ─────────────────────────────────────────────────────────────
      // 'b'/'B' are general conversions too, so — like 's'/'S' — they honour
      // width (padding) and precision (truncation), which the previous
      // implementation silently ignored for both.
      case "b", "B":
        let b: Bool
        switch arg {
        case let v as Bool:   b = v
        case .none:           b = false
        default:              b = true
        }
        let word = applyGeneralFormatting(b ? "true" : "false", width: width, precision: precision,
                                          leftAlign: flags.contains("-"), upper: conv == "B")
        swiftFmt  += "%@"
        swiftArgs.append(word as CVarArg)

      // ── Character ───────────────────────────────────────────────────────────
      case "c", "C":
        let s: String
        switch arg {
        case let c as Character:
          s = String(c)
        case let n as Int:
          guard (0...0x10FFFF).contains(n) else {
            throw java.util.IllegalFormatCodePointException(n)
          }
          s = String(UnicodeScalar(n) ?? UnicodeScalar(0))
        case .none:
          s = "null"
        default:
          throw java.util.IllegalFormatConversionException(conv, type(of: arg!))
        }
        swiftFmt  += "%@"
        swiftArgs.append(s as CVarArg)

      // ── Integer ─────────────────────────────────────────────────────────────
      case "d":
        if let value = arg, !isIntegerArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        let spec = buildCSpec(flags: flags, width: width, precision: precision, conv: "d")
        if hasGrouping {
          // Format first, then insert grouping separators
          let n = toInt64(arg)
          let raw = String(format: spec, n)
          swiftFmt  += "%@"
          swiftArgs.append(insertGrouping(raw, locale: resolvedLocale) as CVarArg)
        } else {
          swiftFmt  += spec
          swiftArgs.append(toInt64(arg))
        }

      case "o":
        if let value = arg, !isIntegerArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "o")
        swiftArgs.append(toInt64(arg))

      case "x":
        if let value = arg, !isIntegerArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "x")
        swiftArgs.append(toInt64(arg))

      case "X":
        if let value = arg, !isIntegerArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "X")
        swiftArgs.append(toInt64(arg))

      // ── Floating point ───────────────────────────────────────────────────────
      // Matches Java: %f/%e/%E/%g/%G/%a/%A require a Float or Double
      // argument (Java also accepts BigDecimal, which this port does not
      // yet model) — anything else is an java.util.IllegalFormatConversionException.
      case "f":
        if let value = arg, !isFloatArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        let prec = Int(precision) ?? 6
        let formatted = formatDouble(toDouble(arg), precision: prec,
                                     grouping: hasGrouping,
                                     width: Int(width) ?? 0,
                                     leftAlign: flags.contains("-"),
                                     locale: resolvedLocale)
        swiftFmt  += "%@"
        swiftArgs.append(formatted as CVarArg)

      case "e":
        if let value = arg, !isFloatArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "e")
        swiftArgs.append(toDouble(arg))

      case "E":
        if let value = arg, !isFloatArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: "E")
        swiftArgs.append(toDouble(arg))

      case "g", "G":
        if let value = arg, !isFloatArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        let formatted = formatGeneral(
          toDouble(arg), precision: Int(precision) ?? 6,
          grouping: hasGrouping, width: Int(width) ?? 0,
          leftAlign: flags.contains("-"), upper: conv == "G",
          flags: flags, locale: resolvedLocale
        )
        swiftFmt  += "%@"
        swiftArgs.append(formatted as CVarArg)

      case "a", "A":
        if let value = arg, !isFloatArgument(value) {
          throw java.util.IllegalFormatConversionException(conv, type(of: value))
        }
        // Hex float — Swift supports %a
        let c2: Character = conv == "a" ? "a" : "A"
        swiftFmt  += buildCSpec(flags: flags, width: width, precision: precision, conv: c2)
        swiftArgs.append(toDouble(arg))

      // ── Date/time (%t prefix already consumed as 't', next char is sub-spec)
      case "t", "T":
        guard i < resolvedFmt.endIndex else { break }
        let sub = resolvedFmt[i]
        i = resolvedFmt.index(after: i)
        let dateStr = formatDateArg(arg, subSpec: sub, locale: resolvedLocale)
        let upper   = conv == "T"
        swiftFmt  += "%@"
        swiftArgs.append((upper ? dateStr.uppercased() : dateStr) as CVarArg)
        argIdx -= 1   // %t consumes no extra arg beyond arg already fetched

      // ── Hash code / identity ────────────────────────────────────────────────
      // Also a general conversion — honours width/precision like 's'/'S'/'b'/'B'.
      case "h", "H":
        let hash = arg.map { ObjectIdentifier($0 as AnyObject).hashValue } ?? 0
        let hex  = arg == nil ? "null" : String(format: "%x", hash)
        let word = applyGeneralFormatting(hex, width: width, precision: precision,
                                          leftAlign: flags.contains("-"), upper: conv == "H")
        swiftFmt  += "%@"
        swiftArgs.append(word as CVarArg)

      default:
        throw java.util.UnknownFormatConversionException(String(resolvedFmt[specStart..<i]))
      }
    }
    if hasGrouping {
      return String(
        format: swiftFmt,
        locale: resolvedLocale,
        arguments: swiftArgs
      )
    }
    else {
      return String(
        format: swiftFmt,
        arguments: swiftArgs
      )
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Argument-index resolution  (%1$s, %2$d, …)
  // ---------------------------------------------------------------------------

  /// Resolves Java argument-index notation (`%1$s`) and the `<` relative
  /// index flag ("reuse the previous specifier's argument", e.g.
  /// `String.format("%d %<x", 255)`) into positional order.
  ///
  /// Returns a new format string (with indices and any `<` flag stripped),
  /// a reordered argument array matching the positional order of specifiers
  /// in the string, and the set of positions in that array which don't
  /// correspond to a real caller-supplied argument (an out-of-range `%n$`
  /// index, `%<` used on the very first specifier, or simply running out of
  /// positional arguments) — needed so the caller can tell "missing
  /// argument" apart from a legitimate Java `null` argument, both of which
  /// would otherwise show up as `nil` in the array.
  ///
  /// Per Java's Formatter grammar, `<` is one of the *flag* characters
  /// (`[-#+ 0,(<]`) rather than part of `argument_index` itself, and so can
  /// in principle appear anywhere among a specifier's other flags, not only
  /// immediately after `%`; this scans the whole flags run (order-
  /// independent) to find it, exactly as it scans for a leading `<digits>$`
  /// argument index.
  private static func resolveArgumentIndices(_ fmt: String, args: [Any?]) -> (String, [Any?], Set<Int>) {
    // Quick check — if neither notation appears anywhere, nothing to do.
    guard fmt.contains("$") || fmt.contains("<") else {
      // No argument-index notation anywhere — purely sequential, and
      // `resolvedArgs.count` (== `args.count`) already lets the caller
      // detect a short argument list without needing a missing-set.
      return (fmt, args, [])
    }

    let flagChars: Set<Character> = ["-", "+", " ", "#", "0", ",", "(", "<"]

    var result    = ""
    var outArgs   : [Any?] = []
    var missing   : Set<Int> = []
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
        if idx < args.count {
          outArgs.append(args[idx])
        } else {
          missing.insert(outArgs.count)
          outArgs.append(nil)
        }
        i = fmt.index(after: j)   // skip past '$'
        // Do NOT append the index or '$' to result
        continue
      }

      // Peek through the flags run (order-independent, like Java's own
      // `[-#+ 0,(<]*`) to see whether '<' — "reuse the previous
      // specifier's argument" — appears among them.
      var k = i
      var hasRelativeIndex = false
      while k < fmt.endIndex && flagChars.contains(fmt[k]) {
        if fmt[k] == "<" { hasRelativeIndex = true }
        k = fmt.index(after: k)
      }
      if hasRelativeIndex {
        let lastIdx = outArgs.count - 1
        if lastIdx >= 0 {
          outArgs.append(outArgs[lastIdx])
          if missing.contains(lastIdx) { missing.insert(outArgs.count - 1) }
        } else {
          // '%<' on the very first specifier: Java throws
          // MissingFormatArgumentException since there is no previous
          // argument to reuse.
          missing.insert(outArgs.count)
          outArgs.append(nil)
        }
        // Copy the flags run into `result`, omitting '<' itself — Swift's
        // printf-style flags don't recognise it, and Phase 2's own flag
        // scan doesn't expect it either.
        var p = i
        while p < k {
          if fmt[p] != "<" { result.append(fmt[p]) }
          p = fmt.index(after: p)
        }
        i = k
        continue
      }

      // No index notation on this specifier — sequential.
      if outArgs.count < args.count {
        outArgs.append(args[outArgs.count])
      } else {
        missing.insert(outArgs.count)
        outArgs.append(nil)
      }
      // i stays at current position — the flags/width/conversion that
      // follow are copied through verbatim by the loop's plain-character
      // branch above on subsequent iterations.
    }
    return (result, outArgs, missing)
  }

  // ---------------------------------------------------------------------------
  // MARK: Date/time sub-specifiers
  // ---------------------------------------------------------------------------

  private static func formatDateArg(_ arg: Any?, subSpec: Character, locale: Foundation.Locale) -> String {
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
    fmt.locale = locale

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
  // MARK: Formattable
  // ---------------------------------------------------------------------------

  /// Renders a `%s`/`%S` argument that implements `java.util.Formattable` by
  /// delegating to its `formatTo(_:_:_:_:)`, matching Java's documented
  /// precedence (`Formattable` wins over plain `toString()` for those two
  /// conversions).
  ///
  /// - Throws: Whatever `formattable.formatTo(...)` throws — matches Java,
  ///   where a `Formattable` is expected to throw `IllegalFormatException`
  ///   for a malformed flags/width/precision combination it was handed, and
  ///   that exception propagates straight out of the enclosing `format(...)`
  ///   call rather than being swallowed.
  private static func formatUsingFormattable(
    _ formattable: java.util.Formattable, flags: String, upper: Bool,
    width: Int, precision: Int, locale: java.util.Locale?, fallback: Any?
  ) throws -> String {
    var flagsInt = 0
    if flags.contains("-") { flagsInt |= java.util.FormattableFlags.LEFT_JUSTIFY }
    if upper                { flagsInt |= java.util.FormattableFlags.UPPERCASE }
    if flags.contains("#") { flagsInt |= java.util.FormattableFlags.ALTERNATE }

    let temp = java.util.Formatter(locale)
    try formattable.formatTo(temp, flagsInt, width, precision)
    return try temp.toString()
  }

  // ---------------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------------

  /// Formats a `Double` for `%f`.
  ///
  /// Rounding always follows C-printf semantics (%.2f of 3.14159 → "3.14"),
  /// which matches Java's behaviour and is consistent across platforms.
  /// The decimal separator and grouping separator are then applied from the
  /// current locale so that e.g. de_DE produces "1.234,50".
  private static func formatDouble(_ value: Double, precision: Int,
                                   grouping: Bool, width: Int,
                                   leftAlign: Bool, locale: Foundation.Locale) -> String {
    // Step 1: round with C-locale printf — cross-platform, matches Java.
    let cFormatted = String(format: "%.\(precision)f", value)

    // Step 2: replace '.' with the locale decimal separator, and optionally
    //         insert grouping separators into the integer part.
    let decSep = String(locale.decimalSeparator ?? ".")

    let raw: String
    if grouping {
      let grpSep = String(locale.groupingSeparator ?? ",")
      // Split C-formatted string at '.'
      let parts = cFormatted.components(separatedBy: ".")
      var intPart = parts[0]
      let fracPart = parts.count > 1 ? decSep + parts[1] : ""

      let negative = intPart.hasPrefix("-")
      if negative { intPart = String(intPart.dropFirst()) }

      // Insert grouping separators every 3 digits from the right
      var grouped = ""
      for (offset, ch) in intPart.reversed().enumerated() {
        if offset > 0 && offset % 3 == 0 { grouped.insert(contentsOf: grpSep.reversed(), at: grouped.startIndex) }
        grouped.insert(ch, at: grouped.startIndex)
      }
      raw = (negative ? "-" : "") + grouped + fracPart
    } else {
      // Just swap the decimal separator
      raw = decSep == "." ? cFormatted : cFormatted.replacingOccurrences(of: ".", with: decSep)
    }

    return applyWidth(raw, width: width, leftAlign: leftAlign, upper: false)
  }

  /// Formats a `Double` for `%g`/`%G` per Java's own "general scientific
  /// notation" algorithm (`java.util.Formatter`, conversions 'g'/'G'):
  ///
  /// > After rounding for the precision, the formatting of the resulting
  /// > magnitude *m* depends on its value. If *m* is greater than or equal
  /// > to 10⁻⁴ but less than 10^precision then it is represented in decimal
  /// > format. If *m* is less than 10⁻⁴ or greater than or equal to
  /// > 10^precision, then it is represented in scientific notation. The
  /// > total number of significant digits in *m* is equal to the precision.
  ///
  /// This is deliberately **not** implemented by delegating to C's/Swift's
  /// native `%g` (as this function's previous implementation did): the
  /// decimal/scientific switching *threshold* happens to be the same
  /// exponent rule as C's, but C's `%g` strips trailing zeros by default
  /// while Java's always shows exactly `precision` significant digits —
  /// e.g. `String.format("%g", 100.0)` is `"100.000"` in Java (6 significant
  /// digits) but C's/Swift's `%g` of the same value strips to `"100"`. This
  /// reimplements the decimal-vs-scientific decision and digit count from
  /// scratch and reuses the already-correct `formatDouble`/`buildCSpec`
  /// helpers (used by `%f`/`%e`) purely for the actual digit rendering,
  /// sign, grouping, and width/locale handling.
  ///
  /// The exponent of the rounded magnitude is obtained by asking C's own
  /// well-tested `%e` rounding for the answer (parsing the exponent out of
  /// `String(format: "%.\(precision-1)e", m)`) rather than computing
  /// `floor(log10(m))` by hand, which is prone to floating-point boundary
  /// errors exactly at powers of ten (e.g. `log10(1000)` can evaluate to
  /// `2.9999999999999996`).
  private static func formatGeneral(_ value: Double, precision: Int,
                                    grouping: Bool, width: Int,
                                    leftAlign: Bool, upper: Bool,
                                    flags: String, locale: Foundation.Locale) -> String {
    let prec = precision == 0 ? 1 : precision

    guard value.isFinite, value != 0 else {
      // NaN / ±Infinity and an exact zero: route through the same
      // formatDouble helper %f itself uses (this does not change — and is
      // not intended to fix — whatever %f's own current NaN/Infinity
      // rendering already is), and treat an exact zero as a
      // one-significant-digit decimal value the way the real JDK does
      // (applying the literal 10⁻⁴/10^precision boundary rule to a raw
      // zero would otherwise route it into the scientific branch, which
      // the JDK does not do).
      let fracDigits = value == 0 ? max(prec - 1, 0) : prec
      return formatDouble(value, precision: fracDigits, grouping: grouping,
                          width: width, leftAlign: leftAlign, locale: locale)
    }

    let m = abs(value)
    let roundedSci = String(format: "%.\(max(prec - 1, 0))e", m)
    guard let eIdx = roundedSci.firstIndex(where: { $0 == "e" || $0 == "E" }),
          let exponent = Int(roundedSci[roundedSci.index(after: eIdx)...]) else {
      // Unreachable in practice — String(format: "%e", ...) always
      // includes an exponent — but fail safe into decimal formatting
      // rather than crash if a platform's libc ever varies this.
      return formatDouble(value, precision: prec, grouping: grouping,
                          width: width, leftAlign: leftAlign, locale: locale)
    }

    let useScientific = exponent < -4 || exponent >= prec
    if useScientific {
      let sciPrec = max(prec - 1, 0)
      let spec = buildCSpec(flags: flags, width: "", precision: "\(sciPrec)", conv: upper ? "E" : "e")
      let s = String(format: spec, value)
      return applyWidth(s, width: width, leftAlign: leftAlign, upper: false)
    } else {
      let fracDigits = max(prec - exponent - 1, 0)
      return formatDouble(value, precision: fracDigits, grouping: grouping,
                          width: width, leftAlign: leftAlign, locale: locale)
    }
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
  private static func insertGrouping(_ raw: String, locale: Foundation.Locale) -> String {
    // Split on decimal point if present
    let sep = String(locale.decimalSeparator ?? ".")
    let parts = raw.components(separatedBy: sep)
    var intPart = parts[0]
    let fracPart = parts.count > 1 ? sep + parts[1] : ""

    // Strip leading minus for processing
    let negative = intPart.hasPrefix("-")
    if negative { intPart = String(intPart.dropFirst()) }

    let groupSep = String(locale.groupingSeparator ?? ",")
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

  /// Applies precision (truncation) and then width (padding) to `raw`,
  /// matching Java's documented behaviour for the *general* conversions
  /// that support both: `s`/`S`, `b`/`B`, `h`/`H` (`c`/`C` and `n`/`%` do
  /// not support precision — enforced separately, before this is reached).
  /// Precision truncates to at most `precision` characters; width then
  /// pads the (possibly truncated) result up to `width` characters.
  private static func applyGeneralFormatting(_ raw: String, width: String, precision: String,
                                             leftAlign: Bool, upper: Bool) -> String {
    var s = raw
    if let p = Int(precision), p >= 0, s.count > p {
      s = String(s.prefix(p))
    }
    return applyWidth(s, width: Int(width) ?? 0, leftAlign: leftAlign, upper: upper)
  }

  /// Whether `arg` is one of the Swift integer types accepted by Java's
  /// `%d`/`%o`/`%x`/`%X` conversions (Java itself also accepts
  /// `BigInteger`, which this port does not yet model).
  private static func isIntegerArgument(_ arg: Any) -> Bool {
    switch arg {
    case is Int, is Int64, is Int32, is Int16, is Int8,
         is UInt, is UInt64, is UInt32, is UInt16, is UInt8:
      return true
    default:
      return false
    }
  }

  /// Whether `arg` is one of the Swift floating-point types accepted by
  /// Java's `%f`/`%e`/`%E`/`%g`/`%G`/`%a`/`%A` conversions (Java itself
  /// also accepts `BigDecimal`, which this port does not yet model).
  private static func isFloatArgument(_ arg: Any) -> Bool {
    switch arg {
    case is Double, is Float:
      return true
    default:
      return false
    }
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
