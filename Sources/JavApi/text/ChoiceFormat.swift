/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// A `NumberFormat` subclass that selects a string based on numeric ranges.
  ///
  /// Mirrors `java.text.ChoiceFormat`.
  ///
  /// `ChoiceFormat` maps a number to a string by finding the range it falls into.
  /// It is typically used with `MessageFormat` for pluralisation:
  /// ```swift
  /// let cf = java.text.ChoiceFormat("0#no files|1#one file|2<many files")
  /// cf.format(0.0)   // "no files"
  /// cf.format(1.0)   // "one file"
  /// cf.format(5.0)   // "many files"
  /// ```
  ///
  /// ## Pattern syntax
  ///
  /// The pattern is a `|`-delimited list of choices, each of the form:
  /// ```
  /// limit#text     — matches: value == limit
  /// limit<text     — matches: value > limit
  /// ```
  ///
  /// Choices **must** be in ascending `limit` order. The highest matching
  /// choice is selected (i.e. `ChoiceFormat` uses a ≥ comparison internally).
  ///
  /// - Since: Java 1.1
  open class ChoiceFormat : NumberFormat {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    /// The lower bounds of each choice.
    private var limits: [Double] = []

    /// The text for each choice.
    private var formats: [String] = []

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates a `ChoiceFormat` from a pattern string.
    ///
    /// - Parameter newPattern: A pattern like `"0#none|1#one|2<many"`.
    public init(_ newPattern: String) {
      super.init(Foundation.NumberFormatter())
      applyPattern(newPattern)
    }

    /// Creates a `ChoiceFormat` with explicit limits and formats arrays.
    ///
    /// - Parameters:
    ///   - limits:  Ascending lower bounds.
    ///   - formats: Text for each bound; must have the same count as `limits`.
    public init(limits: [Double], formats: [String]) {
      super.init(Foundation.NumberFormatter())
      self.limits  = limits
      self.formats = formats
    }

    // -------------------------------------------------------------------------
    // MARK: Pattern
    // -------------------------------------------------------------------------

    /// Applies a new pattern string, replacing the current limits and formats.
    ///
    /// - Parameter newPattern: A pattern like `"0#none|1#one|2<many"`.
    public func applyPattern(_ newPattern: String) {
      var newLimits:  [Double] = []
      var newFormats: [String] = []

      let choices = newPattern.split(separator: "|", omittingEmptySubsequences: false)
      for choice in choices {
        let s = String(choice)
        // Find the first '#' or '<' separator
        if let hashRange = s.range(of: "#") {
          let limitStr = String(s[s.startIndex..<hashRange.lowerBound])
          let text     = String(s[hashRange.upperBound...])
          if let limit = Double(limitStr) {
            newLimits.append(limit)
            newFormats.append(text)
          }
        } else if let ltRange = s.range(of: "<") {
          let limitStr = String(s[s.startIndex..<ltRange.lowerBound])
          let text     = String(s[ltRange.upperBound...])
          if let limit = Double(limitStr) {
            // `<` means strictly greater than; encode as limit + smallest epsilon
            newLimits.append(nextDouble(limit))
            newFormats.append(text)
          }
        }
      }

      limits  = newLimits
      formats = newFormats
    }

    /// Returns the pattern string reconstructed from the current limits and formats.
    public func toPattern() -> String {
      var parts: [String] = []
      for (i, limit) in limits.enumerated() {
        let text = i < formats.count ? formats[i] : ""
        // Format the limit: use integer representation if it is a whole number
        let limitStr: String
        if limit == limit.rounded() && !limit.isInfinite {
          limitStr = "\(Int(limit))"
        } else {
          limitStr = "\(limit)"
        }
        parts.append("\(limitStr)#\(text)")
      }
      return parts.joined(separator: "|")
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    /// Returns the array of lower limits.
    public func getLimits() -> [Double] { limits }

    /// Returns the array of format strings.
    public func getFormats() -> [String] { formats }

    // -------------------------------------------------------------------------
    // MARK: Format
    // -------------------------------------------------------------------------

    /// Returns the string that corresponds to `number`.
    public override func format(_ number: Double) -> String {
      guard !limits.isEmpty else { return "\(number)" }
      // Find the last limit that is ≤ number
      var chosen = 0
      for (i, limit) in limits.enumerated() {
        if number >= limit { chosen = i } else { break }
      }
      return chosen < formats.count ? formats[chosen] : "\(number)"
    }

    /// Formats an object.  Accepts `Double`, `Float`, `Int`, `Int64`, `Int32`.
    open override func format(_ obj: Any, toAppendTo: inout String, pos: FieldPosition) -> String {
      let d: Double
      switch obj {
      case let v as Double:  d = v
      case let v as Float:   d = Double(v)
      case let v as Int:     d = Double(v)
      case let v as Int64:   d = Double(v)
      case let v as Int32:   d = Double(v)
      default:
        toAppendTo += "\(obj)"
        return toAppendTo
      }
      toAppendTo += format(d)
      return toAppendTo
    }

    // -------------------------------------------------------------------------
    // MARK: Parse
    // -------------------------------------------------------------------------

    /// Parses `text` and returns the lower limit of the matching choice, or
    /// the index of the matching format as a `Double` if no limit matches.
    ///
    /// Named `parseChoice` to avoid ambiguity with ``NumberFormat/parse(_:)``
    /// which returns `NSNumber`.
    ///
    /// - Throws: `ParseException` if no format matches.
    public func parseChoice(_ text: String) throws -> Double {
      for (i, fmt) in formats.enumerated() {
        if text.hasPrefix(fmt) {
          return i < limits.count ? limits[i] : Double(i)
        }
      }
      throw ParseException("ChoiceFormat.parse: no match for \"\(text)\"", 0)
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    /// Returns the smallest `Double` value strictly greater than `d`.
    private func nextDouble(_ d: Double) -> Double {
      return d.nextUp
    }
  }
}
