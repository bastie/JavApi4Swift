/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Formats messages with positional placeholders.
  ///
  /// ## Pattern syntax
  ///
  /// ```
  /// MessageFormatPattern := string (FormatElement string)*
  /// FormatElement        := '{' ArgumentIndex [',' FormatType [',' FormatStyle]] '}'
  /// FormatType           := "number" | "date" | "time" | "choice"
  /// FormatStyle (number) := "integer" | "currency" | "percent" | SubformatPattern
  /// FormatStyle (date)   := "short" | "medium" | "long" | "full" | SubformatPattern
  /// FormatStyle (time)   := "short" | "medium" | "long" | "full" | SubformatPattern
  /// ```
  ///
  /// ### Examples
  /// ```swift
  /// let mf = java.text.MessageFormat("At {1,time} on {1,date}, {0} took {2,number} photos.")
  /// let result = try mf.format([name, date, count])
  /// // → "At 12:00 PM on 1 Jan 2026, Alice took 42 photos."
  ///
  /// let quick = java.text.MessageFormat.format("Hello, {0}!", ["World"])
  /// ```
  ///
  /// - Since: Java 1.1
  open class MessageFormat : Format {

    // -------------------------------------------------------------------------
    // MARK: Stored state
    // -------------------------------------------------------------------------

    private var locale: java.util.Locale
    private var pattern: String = ""

    /// The parsed format elements extracted from the pattern.
    private var segments: [Segment] = []

    // -------------------------------------------------------------------------
    // MARK: Internal model
    // -------------------------------------------------------------------------

    private enum Segment {
      case literal(String)
      case argument(index: Int, format: ArgumentFormat)
    }

    private enum ArgumentFormat {
      case none
      case number(NumberStyle)
      case date(DateStyle)
      case time(DateStyle)
      case custom(Format)
    }

    private enum NumberStyle {
      case `default`
      case integer
      case currency
      case percent
      case pattern(String)
    }

    private enum DateStyle {
      case `default`   // medium
      case short
      case medium
      case long
      case full
      case pattern(String)
    }

    /// Override table: argument-index → user-supplied Format (set via setFormat/setFormatByArgumentIndex).
    /// If present, supersedes the pattern-derived format for that argument.
    private var formatOverrides: [Int: Format] = [:]

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates a `MessageFormat` with the given pattern using the default locale.
    public init(_ pattern: String) {
      self.locale = java.util.Locale.getDefault()
      super.init()
      applyPattern(pattern)
    }

    /// Creates a `MessageFormat` with the given pattern and locale.
    public init(_ pattern: String, _ locale: java.util.Locale) {
      self.locale = locale
      super.init()
      applyPattern(pattern)
    }

    // -------------------------------------------------------------------------
    // MARK: Static convenience
    // -------------------------------------------------------------------------

    /// Formats a message pattern with `arguments` using the default locale.
    ///
    /// This is the most common entry point — no instance needed.
    ///
    /// - Parameters:
    ///   - pattern: A `MessageFormat` pattern string.
    ///   - arguments: The objects to substitute.
    /// - Returns: The formatted string.
    public static func format(_ pattern: String, _ arguments: [Any?]) -> String {
      return MessageFormat(pattern).format(arguments)
    }

    // -------------------------------------------------------------------------
    // MARK: Pattern
    // -------------------------------------------------------------------------

    /// Applies a new pattern.
    public func applyPattern(_ pattern: String) {
      self.pattern = pattern
      self.segments = Self.parse(pattern: pattern)
      self.formatOverrides = [:]
    }

    /// Returns the pattern string.
    public func toPattern() -> String { pattern }

    // -------------------------------------------------------------------------
    // MARK: Format accessors (Java 1.2)
    // -------------------------------------------------------------------------

    /// Returns the formats applied to argument positions in pattern order.
    ///
    /// The array has one entry per format element in the pattern (in the order
    /// they appear). Entries for arguments with no explicit format are `nil`.
    ///
    /// - Since: Java 1.2
    public func getFormats() -> [Format?] {
      var result: [Format?] = []
      for segment in segments {
        if case .argument(let idx, _) = segment {
          result.append(formatOverrides[idx])
        }
      }
      return result
    }

    /// Returns the formats indexed by argument index.
    ///
    /// The returned array has `(maxArgumentIndex + 1)` entries; unused indices
    /// are `nil`.
    ///
    /// - Since: Java 1.2
    public func getFormatsByArgumentIndex() -> [Format?] {
      let maxIdx = argumentIndices().max() ?? -1
      guard maxIdx >= 0 else { return [] }
      var result: [Format?] = Array(repeating: nil, count: maxIdx + 1)
      for (idx, fmt) in formatOverrides {
        if idx <= maxIdx { result[idx] = fmt }
      }
      return result
    }

    /// Sets the format for the `formatElementIndex`-th format element
    /// (in pattern order, counting only argument elements, not literals).
    ///
    /// - Since: Java 1.2
    public func setFormat(_ formatElementIndex: Int, _ newFormat: Format?) {
      let argSegments = segments.enumerated().filter {
        if case .argument = $0.element { return true }
        return false
      }
      guard formatElementIndex < argSegments.count else { return }
      if case .argument(let idx, _) = argSegments[formatElementIndex].element {
        if let fmt = newFormat {
          formatOverrides[idx] = fmt
        } else {
          formatOverrides.removeValue(forKey: idx)
        }
      }
    }

    /// Sets the format for the argument at `argumentIndex`.
    ///
    /// - Since: Java 1.2
    public func setFormatByArgumentIndex(_ argumentIndex: Int, _ newFormat: Format?) {
      if let fmt = newFormat {
        formatOverrides[argumentIndex] = fmt
      } else {
        formatOverrides.removeValue(forKey: argumentIndex)
      }
    }

    /// Replaces all format overrides (in pattern order) at once.
    ///
    /// - Since: Java 1.2
    public func setFormats(_ newFormats: [Format?]) {
      formatOverrides = [:]
      let argSegments = segments.filter {
        if case .argument = $0 { return true }
        return false
      }
      for (i, segment) in argSegments.enumerated() {
        if i >= newFormats.count { break }
        if case .argument(let idx, _) = segment, let fmt = newFormats[i] {
          formatOverrides[idx] = fmt
        }
      }
    }

    /// Replaces all format overrides by argument index at once.
    ///
    /// - Since: Java 1.2
    public func setFormatsByArgumentIndex(_ newFormats: [Format?]) {
      formatOverrides = [:]
      for (i, fmt) in newFormats.enumerated() {
        if let fmt = fmt { formatOverrides[i] = fmt }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Locale
    // -------------------------------------------------------------------------

    public func setLocale(_ locale: java.util.Locale) { self.locale = locale }
    public func getLocale() -> java.util.Locale { locale }

    // -------------------------------------------------------------------------
    // MARK: Format
    // -------------------------------------------------------------------------

    /// Formats `arguments` according to the pattern.
    public func format(_ arguments: [Any?]) -> String {
      var result = ""
      for segment in segments {
        switch segment {
        case .literal(let s):
          result += s
        case .argument(let index, let fmt):
          let value: Any? = index < arguments.count ? arguments[index] : nil
          // formatOverrides take priority over pattern-derived format
          if let override = formatOverrides[index], let v = value {
            result += override.format(v)
          } else {
            result += formatValue(value, with: fmt)
          }
        }
      }
      return result
    }

    /// Formats `arguments` (as varargs-style array) and returns the string.
    public func format(_ arguments: Any?...) -> String {
      return format(arguments)
    }

    // -------------------------------------------------------------------------
    // MARK: Format (inherited from Format)
    // -------------------------------------------------------------------------

    open override func format(_ obj: Any, toAppendTo: inout String, pos: FieldPosition) -> String {
      if let array = obj as? [Any?] {
        toAppendTo += format(array)
      } else {
        toAppendTo += "\(obj)"
      }
      return toAppendTo
    }

    open override func parseObject(_ source: String, pos: ParsePosition) -> Any? {
      return try? parse(source)
    }

    // -------------------------------------------------------------------------
    // MARK: Parse
    // -------------------------------------------------------------------------

    /// Parses `source` and returns an array of parsed objects, one per
    /// argument index found in the pattern.
    ///
    /// - Throws: `ParseException` if the string does not match the pattern.
    public func parse(_ source: String) throws -> [Any?] {
      var srcIndex = source.startIndex
      var argResults: [Int: Any?] = [:]
      var maxIndex = -1

      for (segIdx, segment) in segments.enumerated() {
        switch segment {
        case .literal(let lit):
          guard source[srcIndex...].hasPrefix(lit) else {
            let offset = source.distance(from: source.startIndex, to: srcIndex)
            throw ParseException("MessageFormat.parse failed: expected literal \"\(lit)\"", offset)
          }
          srcIndex = source.index(srcIndex, offsetBy: lit.count)

        case .argument(let index, _):
          if index > maxIndex { maxIndex = index }
          // Find the next literal segment to know where this argument ends
          let nextLiteral: String? = nextLiteralAfter(segmentIndex: segIdx)
          let end: String.Index
          if let nl = nextLiteral, let range = source.range(of: nl, range: srcIndex..<source.endIndex) {
            end = range.lowerBound
          } else {
            end = source.endIndex
          }
          argResults[index] = String(source[srcIndex..<end])
          srcIndex = end
        }
      }

      // Build array ordered by argument index
      var result: [Any?] = []
      for i in 0...max(maxIndex, 0) {
        result.append(argResults[i] ?? nil)
      }
      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    private func formatValue(_ value: Any?, with format: ArgumentFormat) -> String {
      guard let value = value else { return "null" }

      switch format {
      case .none:
        return "\(value)"

      case .number(let style):
        let nf = makeNumberFormat(style: style)
        switch value {
        case let d as Double:  return nf.format(d)
        case let f as Float:   return nf.format(Double(f))
        case let i as Int:     return nf.format(Int64(i))
        case let i as Int64:   return nf.format(i)
        case let i as Int32:   return nf.format(Int64(i))
        default: return "\(value)"
        }

      case .date(let style):
        let df = makeDateFormat(style: style, timeOnly: false)
        switch value {
        case let d as java.util.Date: return df.format(d)
        case let d as Foundation.Date: return df.format(java.util.Date(Int64(d.timeIntervalSince1970 * 1000)))
        default: return "\(value)"
        }

      case .time(let style):
        let df = makeDateFormat(style: style, timeOnly: true)
        switch value {
        case let d as java.util.Date: return df.format(d)
        case let d as Foundation.Date: return df.format(java.util.Date(Int64(d.timeIntervalSince1970 * 1000)))
        default: return "\(value)"
        }

      case .custom(let fmt):
        return fmt.format(value)
      }
    }

    private func makeNumberFormat(style: NumberStyle) -> NumberFormat {
      switch style {
      case .default:   return NumberFormat.getInstance(locale)
      case .integer:   return NumberFormat.getIntegerInstance(locale)
      case .currency:  return NumberFormat.getCurrencyInstance(locale)
      case .percent:   return NumberFormat.getPercentInstance(locale)
      case .pattern(let p):
        let nf = NumberFormat.getInstance(locale)
        // DecimalFormat would handle patterns; fall back to plain instance
        _ = p
        return nf
      }
    }

    private func makeDateFormat(style: DateStyle, timeOnly: Bool) -> DateFormat {
      let javaStyle: Int
      switch style {
      case .default, .medium: javaStyle = DateFormat.MEDIUM
      case .short:            javaStyle = DateFormat.SHORT
      case .long:             javaStyle = DateFormat.LONG
      case .full:             javaStyle = DateFormat.FULL
      case .pattern(let p):
        return SimpleDateFormat(p, locale)
      }

      if timeOnly {
        return DateFormat.getTimeInstance(javaStyle, locale: locale)
      } else {
        return DateFormat.getDateInstance(javaStyle, locale: locale)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Pattern parser
    // -------------------------------------------------------------------------

    private static func parse(pattern: String) -> [Segment] {
      var segments: [Segment] = []
      var literal = ""
      var i = pattern.startIndex

      while i < pattern.endIndex {
        let ch = pattern[i]

        switch ch {
        case "'":
          // Quoted literal: '' → single quote; 'text' → text verbatim
          i = pattern.index(after: i)
          if i < pattern.endIndex && pattern[i] == "'" {
            // Escaped single quote
            literal.append("'")
            i = pattern.index(after: i)
          } else {
            // Quoted run — copy until closing quote
            while i < pattern.endIndex {
              let q = pattern[i]
              if q == "'" {
                i = pattern.index(after: i)
                // Peek: '' inside quoted run is an escaped quote
                if i < pattern.endIndex && pattern[i] == "'" {
                  literal.append("'")
                  i = pattern.index(after: i)
                }
                break
              }
              literal.append(q)
              i = pattern.index(after: i)
            }
          }

        case "{":
          if !literal.isEmpty {
            segments.append(.literal(literal))
            literal = ""
          }
          i = pattern.index(after: i)
          // Read until matching closing brace
          var element = ""
          var depth = 1
          while i < pattern.endIndex && depth > 0 {
            let c = pattern[i]
            if c == "{" { depth += 1 }
            else if c == "}" { depth -= 1; if depth == 0 { break } }
            element.append(c)
            i = pattern.index(after: i)
          }
          if i < pattern.endIndex { i = pattern.index(after: i) } // skip closing brace
          segments.append(parseElement(element))

        default:
          literal.append(ch)
          i = pattern.index(after: i)
        }
      }

      if !literal.isEmpty {
        segments.append(.literal(literal))
      }

      return segments
    }

    /// Parses a format element string like `"0"`, `"1,number,currency"`, `"2,date,short"`.
    private static func parseElement(_ element: String) -> Segment {
      let parts = element.split(separator: ",", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)

      guard let index = Int(parts[0].trimmingCharacters(in: .whitespaces)) else {
        return .literal("{\(element)}")
      }

      guard parts.count > 1 else {
        return .argument(index: index, format: .none)
      }

      let typePart = parts[1].trimmingCharacters(in: .whitespaces).lowercased()
      let stylePart = parts.count > 2 ? parts[2].trimmingCharacters(in: .whitespaces) : ""

      switch typePart {
      case "number":
        let style: NumberStyle
        switch stylePart.lowercased() {
        case "":          style = .default
        case "integer":   style = .integer
        case "currency":  style = .currency
        case "percent":   style = .percent
        default:          style = .pattern(stylePart)
        }
        return .argument(index: index, format: .number(style))

      case "date":
        return .argument(index: index, format: .date(parseDateStyle(stylePart)))

      case "time":
        return .argument(index: index, format: .time(parseDateStyle(stylePart)))

      default:
        return .argument(index: index, format: .none)
      }
    }

    private static func parseDateStyle(_ s: String) -> DateStyle {
      switch s.lowercased() {
      case "":       return .default
      case "short":  return .short
      case "medium": return .medium
      case "long":   return .long
      case "full":   return .full
      default:       return .pattern(s)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Parse helpers
    // -------------------------------------------------------------------------

    private func nextLiteralAfter(segmentIndex: Int) -> String? {
      for i in (segmentIndex + 1)..<segments.count {
        if case .literal(let s) = segments[i] { return s }
      }
      return nil
    }

    /// Returns all argument indices that appear in the pattern.
    private func argumentIndices() -> [Int] {
      return segments.compactMap {
        if case .argument(let idx, _) = $0 { return idx }
        return nil
      }
    }

  } // end class MessageFormat

} // end class MessageFormat

