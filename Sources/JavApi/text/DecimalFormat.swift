/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Formats and parses decimal numbers using a pattern string.
  ///
  /// Mirrors `java.text.DecimalFormat`.
  ///
  /// ## Pattern syntax
  ///
  /// A pattern has the form `positiveSubpattern[;negativeSubpattern]`.
  /// Each sub-pattern is built from:
  ///
  /// | Symbol | Meaning |
  /// |--------|---------|
  /// | `0`    | Digit — always shown (leading/trailing zero) |
  /// | `#`    | Digit — suppressed if zero (optional digit) |
  /// | `.`    | Decimal separator |
  /// | `,`    | Grouping separator |
  /// | `E`    | Scientific notation separator |
  /// | `%`    | Multiply by 100 and show as percentage |
  /// | `‰`    | Multiply by 1000 and show as per-mille |
  /// | `¤`    | Currency symbol |
  /// | `'`    | Quote — wraps literal text |
  /// | `;`    | Separates positive and negative sub-patterns |
  ///
  /// ### Examples
  /// ```swift
  /// let df = java.text.DecimalFormat("#,##0.00")
  /// df.format(1234567.89)   // "1,234,567.89"
  ///
  /// let pct = java.text.DecimalFormat("0.##%")
  /// pct.format(0.1234)      // "12.34%"
  ///
  /// let sci = java.text.DecimalFormat("0.###E0")
  /// sci.format(123456.789)  // "1.235E5"
  /// ```
  ///
  /// - Since: Java 1.1
  open class DecimalFormat : NumberFormat {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _pattern: String
    private var _symbols: DecimalFormatSymbols

    // Parsed pattern components
    private var minIntegerDigits:  Int = 1
    private var maxIntegerDigits:  Int = Int.max
    private var minFractionDigits: Int = 0
    private var maxFractionDigits: Int = 3
    private var useGrouping:       Bool = false
    private var groupingSize:      Int = 3
    private var isPercent:         Bool = false
    private var isPerMill:         Bool = false
    private var isScientific:      Bool = false
    private var minExponentDigits: Int = 1
    private var positivePrefix:    String = ""
    private var positiveSuffix:    String = ""
    private var negativePrefix:    String = ""
    private var negativeSuffix:    String = ""

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates a `DecimalFormat` with the given pattern and default-locale symbols.
    public init(_ pattern: String) {
      _pattern = pattern
      _symbols = DecimalFormatSymbols(java.util.Locale.getDefault())
      let nf = Foundation.NumberFormatter()
      nf.locale = java.util.Locale.getDefault().delegate
      super.init(nf)
      applyPattern(pattern)
    }

    /// Creates a `DecimalFormat` with an explicit symbols object.
    public init(_ pattern: String, _ symbols: DecimalFormatSymbols) {
      _pattern = pattern
      _symbols = symbols
      let nf = Foundation.NumberFormatter()
      nf.locale = java.util.Locale.getDefault().delegate
      super.init(nf)
      applyPattern(pattern)
    }

    // -------------------------------------------------------------------------
    // MARK: Pattern
    // -------------------------------------------------------------------------

    /// Returns the positive sub-pattern string.
    public func toPattern() -> String { _pattern }

    /// Applies a new pattern.
    public func applyPattern(_ pattern: String) {
      _pattern = pattern
      parsePattern(pattern)
      configureFormatter()
    }

    // -------------------------------------------------------------------------
    // MARK: Symbols
    // -------------------------------------------------------------------------

    public func getDecimalFormatSymbols() -> DecimalFormatSymbols { _symbols }
    public func setDecimalFormatSymbols(_ symbols: DecimalFormatSymbols) {
      _symbols = symbols
      configureFormatter()
    }

    // -------------------------------------------------------------------------
    // MARK: Format overrides
    // -------------------------------------------------------------------------

    open override func format(_ obj: Any, toAppendTo: inout String, pos: FieldPosition) -> String {
      switch obj {
      case let v as Double:  toAppendTo += format(v);         return toAppendTo
      case let v as Float:   toAppendTo += format(Double(v)); return toAppendTo
      case let v as Int:     toAppendTo += format(Int64(v));  return toAppendTo
      case let v as Int64:   toAppendTo += format(v);         return toAppendTo
      case let v as Int32:   toAppendTo += format(Int64(v));  return toAppendTo
      case let v as NSNumber: toAppendTo += format(v.doubleValue); return toAppendTo
      default:
        toAppendTo += "\(obj)"
        return toAppendTo
      }
    }

    /// Formats a `Double`.
    public override func format(_ number: Double) -> String {
      var value = number
      if isPercent  { value *= 100.0  }
      if isPerMill  { value *= 1000.0 }

      if isScientific {
        return formatScientific(value)
      }

      let result = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
      return applyPrefixSuffix(result, negative: number < 0)
    }

    /// Formats an `Int64`.
    public override func format(_ number: Int64) -> String {
      return format(Double(number))
    }

    // -------------------------------------------------------------------------
    // MARK: Parse overrides
    // -------------------------------------------------------------------------

    open override func parseObject(_ source: String, pos: ParsePosition) -> Any? {
      return parse(source, pos: pos)
    }

    public override func parse(_ source: String, pos: ParsePosition) -> NSNumber? {
      // Strip prefix/suffix, then delegate to formatter
      var s = source
      let start = pos.getIndex()
      if start > 0 {
        s = String(s[s.index(s.startIndex, offsetBy: start)...])
      }

      // Remove known prefix/suffix from positive pattern
      if !positivePrefix.isEmpty && s.hasPrefix(positivePrefix) {
        s = String(s.dropFirst(positivePrefix.count))
      }
      if !positiveSuffix.isEmpty && s.hasSuffix(positiveSuffix) {
        s = String(s.dropLast(positiveSuffix.count))
      }

      if let number = formatter.number(from: s) {
        pos.setIndex(source.count)
        var value = number.doubleValue
        if isPercent  { value /= 100.0  }
        if isPerMill  { value /= 1000.0 }
        return NSNumber(value: value)
      }
      pos.setErrorIndex(start)
      return nil
    }

    public override func parse(_ source: String) throws -> NSNumber {
      let pos = ParsePosition(0)
      guard let result = parse(source, pos: pos) else {
        throw ParseException("DecimalFormat.parse(\"\(source)\") failed", pos.getErrorIndex())
      }
      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Pattern parser
    // -------------------------------------------------------------------------

    private func parsePattern(_ pattern: String) {
      // Split on ';' for positive/negative sub-patterns
      let parts = pattern.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
        .map(String.init)
      let posPart = parts[0]
      let negPart = parts.count > 1 ? parts[1] : nil

      parsePosSubPattern(posPat: posPart)

      if let neg = negPart {
        negativePrefix = extractPrefix(neg)
        negativeSuffix = extractSuffix(neg)
      } else {
        negativePrefix = String(_symbols.getMinusSign()) + positivePrefix
        negativeSuffix = positiveSuffix
      }
    }

    private func parsePosSubPattern(posPat: String) {
      // Reset
      isPercent   = false
      isPerMill   = false
      isScientific = false
      useGrouping  = false
      minIntegerDigits  = 1
      maxIntegerDigits  = Int.max
      minFractionDigits = 0
      maxFractionDigits = 3
      groupingSize      = 3

      positivePrefix = extractPrefix(posPat)
      positiveSuffix = extractSuffix(posPat)

      // Detect multiplier symbols in prefix/suffix
      let full = positivePrefix + posPat + positiveSuffix
      if full.contains("%")         { isPercent  = true }
      if full.contains("\u{2030}")  { isPerMill  = true }

      // Extract the numeric part (strip prefix/suffix)
      var numeric = posPat
      if !positivePrefix.isEmpty { numeric = String(numeric.dropFirst(positivePrefix.count)) }
      if !positiveSuffix.isEmpty { numeric = String(numeric.dropLast(positiveSuffix.count)) }

      // Scientific notation?
      if let eRange = numeric.range(of: "E") {
        isScientific = true
        let expPart  = String(numeric[numeric.index(after: eRange.lowerBound)...])
        minExponentDigits = expPart.filter { $0 == "0" }.count
        numeric = String(numeric[..<eRange.lowerBound])
      }

      // Grouping separator?
      if numeric.contains(",") {
        useGrouping = true
        // Grouping size = number of digits between last comma and decimal point (or end)
        let lastComma = numeric.lastIndex(of: ",")!
        let afterComma = String(numeric[numeric.index(after: lastComma)...])
        let beforeDot  = afterComma.split(separator: ".").first.map(String.init) ?? afterComma
        groupingSize = beforeDot.filter { $0 == "0" || $0 == "#" }.count
        if groupingSize == 0 { groupingSize = 3 }
      }

      // Integer / fraction digit counts
      let dotIdx = numeric.firstIndex(of: ".")
      let intPart  = dotIdx.map { String(numeric[..<$0]) } ?? numeric
      let fracPart = dotIdx.map { String(numeric[numeric.index(after: $0)...]) } ?? ""

      let cleanInt = intPart.replacingOccurrences(of: ",", with: "")
      minIntegerDigits = cleanInt.filter { $0 == "0" }.count
      if minIntegerDigits == 0 { minIntegerDigits = 1 }

      minFractionDigits = fracPart.filter { $0 == "0" }.count
      maxFractionDigits = fracPart.filter { $0 == "0" || $0 == "#" }.count
    }

    /// Extracts the literal prefix (characters before the first `#`, `0`, or `,`).
    private func extractPrefix(_ s: String) -> String {
      var prefix = ""
      var inQuote = false
      for ch in s {
        if ch == "'" { inQuote = !inQuote; continue }
        if inQuote   { prefix.append(ch); continue }
        if ch == "#" || ch == "0" || ch == "," || ch == "." { break }
        if ch == ";" { break }
        prefix.append(ch)
      }
      return prefix
    }

    /// Extracts the literal suffix (characters after the last `#`, `0`, or `.`).
    private func extractSuffix(_ s: String) -> String {
      var suffix = ""
      var inQuote = false
      for ch in s.reversed() {
        if ch == "'" { inQuote = !inQuote; continue }
        if inQuote   { suffix.insert(ch, at: suffix.startIndex); continue }
        if ch == "#" || ch == "0" || ch == "," || ch == "." || ch == "E" { break }
        if ch == ";" { break }
        suffix.insert(ch, at: suffix.startIndex)
      }
      return suffix
    }

    // -------------------------------------------------------------------------
    // MARK: Formatter configuration
    // -------------------------------------------------------------------------

    private func configureFormatter() {
      formatter.locale = java.util.Locale.getDefault().delegate
      formatter.minimumIntegerDigits   = minIntegerDigits
      formatter.minimumFractionDigits  = minFractionDigits
      formatter.maximumFractionDigits  = maxFractionDigits
      formatter.usesGroupingSeparator  = useGrouping
      if useGrouping { formatter.groupingSize = groupingSize }
      formatter.numberStyle = .decimal
      // Decimal/grouping separator from symbols
      formatter.decimalSeparator  = String(_symbols.getDecimalSeparator())
      formatter.groupingSeparator = String(_symbols.getGroupingSeparator())
    }

    // -------------------------------------------------------------------------
    // MARK: Scientific formatting
    // -------------------------------------------------------------------------

    private func formatScientific(_ value: Double) -> String {
      guard value != 0 else {
        let zeros = String(repeating: "0", count: minFractionDigits)
        return "0" + (zeros.isEmpty ? "" : String(_symbols.getDecimalSeparator()) + zeros)
             + _symbols.getExponentSeparator()
             + String(repeating: "0", count: max(minExponentDigits, 1))
      }

      let exp = Int(floor(log10(abs(value))))
      let mantissa = value / pow(10.0, Double(exp))

      let mantissaStr: String
      if maxFractionDigits > 0 {
        let nf = Foundation.NumberFormatter()
        nf.locale = java.util.Locale.getDefault().delegate
        nf.minimumFractionDigits = minFractionDigits
        nf.maximumFractionDigits = maxFractionDigits
        nf.decimalSeparator = String(_symbols.getDecimalSeparator())
        mantissaStr = nf.string(from: NSNumber(value: mantissa)) ?? "\(mantissa)"
      } else {
        mantissaStr = "\(Int(mantissa))"
      }

      let expStr = String(format: "%0\(max(minExponentDigits,1))d", abs(exp))
      let sign   = exp < 0 ? "-" : ""
      return "\(mantissaStr)\(_symbols.getExponentSeparator())\(sign)\(expStr)"
    }

    // -------------------------------------------------------------------------
    // MARK: Prefix / suffix helper
    // -------------------------------------------------------------------------

    private func applyPrefixSuffix(_ formatted: String, negative: Bool) -> String {
      // The formatter already handles the minus sign; we only prepend/append
      // custom prefix/suffix that aren't the minus sign itself.
      let prefix = negative ? negativePrefix : positivePrefix
      let suffix = negative ? negativeSuffix : positiveSuffix

      // Avoid double-prefixing the minus
      if negative && prefix == String(_symbols.getMinusSign()) {
        return prefix + formatted.replacingOccurrences(
          of: String(_symbols.getMinusSign()), with: "") + suffix
      }
      return prefix + formatted + suffix
    }
  }
}
