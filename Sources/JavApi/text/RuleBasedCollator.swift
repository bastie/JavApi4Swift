/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// A concrete ``Collator`` that uses a rule string to define sort order.
  ///
  /// Mirrors `java.text.RuleBasedCollator`.
  ///
  /// ## Rule syntax (simplified Java subset)
  ///
  /// Rules are separated by `<` (less than) or `=` (equal weight):
  /// ```
  /// "< a < b < c < d"          // a sorts before b, etc.
  /// "< a,A < b,B"              // case variants at same secondary level
  /// "< a < b = B < c"          // B has same primary weight as b
  /// ```
  ///
  /// For rules that cannot be parsed, the collator falls back to the
  /// standard locale-based ordering (same as ``Collator/getInstance()``).
  ///
  /// ## Usage
  /// ```swift
  /// let rules = "< a < e < i < o < u < b < c"
  /// let col   = try java.text.RuleBasedCollator(rules)
  /// col.compare("a", "b")  // -1
  /// col.compare("u", "b")  // -1 (vowels sort before consonants)
  /// ```
  ///
  /// - Since: Java 1.1
  open class RuleBasedCollator : Collator {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private let rules: String

    /// Maps each character (or string) to its primary sort index.
    /// Characters not in the table fall back to their Unicode code point.
    /// Internal so ``CollationElementIterator`` can read it.
    var orderTable: [String: Int] = [:]

    /// `true` when the rule string was successfully parsed into `orderTable`.
    private var hasCustomOrder: Bool = false

    // -------------------------------------------------------------------------
    // MARK: Initialiser
    // -------------------------------------------------------------------------

    /// Creates a `RuleBasedCollator` from a rule string.
    ///
    /// - Parameter rules: A Java-style collation rule string.
    /// - Throws: `ParseException` if the rule string is syntactically invalid.
    public init(_ rules: String) throws {
      self.rules = rules
      super.init(locale: Foundation.Locale.current)
      try parseRules(rules)
    }

    // -------------------------------------------------------------------------
    // MARK: Public API
    // -------------------------------------------------------------------------

    /// Returns the rule string used to create this collator.
    public func getRules() -> String { rules }

    // -------------------------------------------------------------------------
    // MARK: CollationElementIterator factory
    // -------------------------------------------------------------------------

    /// Returns a ``CollationElementIterator`` for the given string.
    ///
    /// - Parameter source: The string to iterate over.
    /// - Returns: A `CollationElementIterator` positioned at the start of `source`.
    public func getCollationElementIterator(_ source: String) -> CollationElementIterator {
      return CollationElementIterator(text: source, collator: self)
    }

    /// Returns a ``CollationElementIterator`` for the text provided by
    /// the given ``StringCharacterIterator``.
    ///
    /// - Parameter source: An iterator whose text will be iterated.
    /// - Returns: A `CollationElementIterator` positioned at the start of the text.
    public func getCollationElementIterator(_ source: StringCharacterIterator) -> CollationElementIterator {
      return CollationElementIterator(text: source.getText(), collator: self)
    }

    // -------------------------------------------------------------------------
    // MARK: Comparison override
    // -------------------------------------------------------------------------

    open override func compare(_ source: String, _ target: String) -> Int {
      if hasCustomOrder {
        let si = primaryIndex(of: source)
        let ti = primaryIndex(of: target)
        if si != ti { return si < ti ? -1 : 1 }
        // Same primary weight — tokens are explicitly equal-weight in the rule table.
        // At PRIMARY and when both tokens appear in the orderTable, treat as equal.
        let sourceInTable = orderTable[source] != nil
        let targetInTable = orderTable[target] != nil
        if getStrength() == Self.PRIMARY { return 0 }
        if sourceInTable && targetInTable { return 0 }
        // SECONDARY: compare without case sensitivity
        if getStrength() == Self.SECONDARY {
          let sl = source.lowercased()
          let tl = target.lowercased()
          if sl < tl { return -1 }
          if sl > tl { return  1 }
          return 0
        }
        // TERTIARY / IDENTICAL: exact Unicode comparison
        if source < target { return -1 }
        if source > target { return  1 }
        return 0
      }
      // Fallback: locale-based comparison
      return super.compare(source, target)
    }

    open override func getCollationKey(_ source: String) -> CollationKey {
      if hasCustomOrder {
        // Build a sort key from the primary indices of each character
        let key = source.unicodeScalars.map { scalar -> String in
          let ch = String(scalar)
          let idx = orderTable[ch] ?? (Int(scalar.value) + 100_000)
          // Zero-pad to 8 digits so lexicographic order matches numeric order
          return String(format: "%08d", idx)
        }.joined()
        return CollationKey(source: source, sortKey: key)
      }
      return super.getCollationKey(source)
    }

    // -------------------------------------------------------------------------
    // MARK: Rule parser
    // -------------------------------------------------------------------------

    /// Parses the rule string into `orderTable`.
    ///
    /// Supports:
    /// - `< token` — next primary weight
    /// - `= token` / `, token` — same primary weight as previous
    /// - `& token` — reset anchor (ignored; treated as weight anchor)
    /// - Whitespace around operators is ignored
    /// - Multi-character tokens are stored as strings
    private func parseRules(_ rules: String) throws {
      var order = 0
      var lastOrder = 0
      var i = rules.startIndex

      func skipWhitespace() {
        while i < rules.endIndex && rules[i].isWhitespace { i = rules.index(after: i) }
      }

      func readToken() -> String {
        skipWhitespace()
        var token = ""
        // Quoted token: 'text'
        if i < rules.endIndex && rules[i] == "'" {
          i = rules.index(after: i)
          while i < rules.endIndex && rules[i] != "'" {
            token.append(rules[i]); i = rules.index(after: i)
          }
          if i < rules.endIndex { i = rules.index(after: i) } // closing quote
          return token
        }
        // Unquoted: read until operator or whitespace
        while i < rules.endIndex {
          let ch = rules[i]
          if ch == "<" || ch == "=" || ch == "," || ch == "&" || ch == ";" { break }
          if ch.isWhitespace { break }
          token.append(ch); i = rules.index(after: i)
        }
        return token
      }

      skipWhitespace()

      // Handle optional leading token before any operator (anchor)
      if i < rules.endIndex && rules[i] != "<" && rules[i] != "=" && rules[i] != "&" {
        let anchor = readToken()
        if !anchor.isEmpty {
          orderTable[anchor] = order
          lastOrder = order
          order += 1
        }
      }

      while i < rules.endIndex {
        skipWhitespace()
        guard i < rules.endIndex else { break }
        let op = rules[i]
        i = rules.index(after: i)

        switch op {
        case "<":
          // New primary weight
          let token = readToken()
          guard !token.isEmpty else {
            throw ParseException("RuleBasedCollator: empty token after '<'", rules.distance(from: rules.startIndex, to: i))
          }
          lastOrder = order
          orderTable[token] = order
          order += 1

        case "=", ",":
          // Same primary weight as previous
          let token = readToken()
          if !token.isEmpty {
            orderTable[token] = lastOrder
          }

        case "&":
          // Reset/anchor — skip the anchor token, continue parsing
          _ = readToken()

        case ";":
          // Rule separator — ignore
          break

        default:
          // Unknown operator — skip
          break
        }
      }

      hasCustomOrder = !orderTable.isEmpty
    }

    // -------------------------------------------------------------------------
    // MARK: Helper
    // -------------------------------------------------------------------------

    /// Returns the primary sort index for the first character (or string) in `s`.
    private func primaryIndex(of s: String) -> Int {
      // Try full string match first (for multi-character tokens)
      if let idx = orderTable[s] { return idx }
      // Fall back to first character
      if let first = s.unicodeScalars.first {
        let ch = String(first)
        if let idx = orderTable[ch] { return idx }
        // Unknown character: use code point + large offset so custom chars sort first
        return Int(first.value) + 100_000
      }
      return Int.max
    }
  }
}
