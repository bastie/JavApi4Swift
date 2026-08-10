/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.regex {

  /// A compiled representation of a regular expression.
  ///
  /// ### Backend
  ///
  /// The backend is Swift 6 `Regex<AnyRegexOutput>`, which is part of the
  /// Swift standard library and available on all target platforms (Apple,
  /// Linux, Windows, FreeBSD, Android, WASM).
  ///
  /// ### Java → Swift syntax translation
  ///
  /// The pattern string undergoes the following transformations before being
  /// passed to the Swift regex engine:
  ///
  /// 1. `\Q...\E` literal-quoting sections are expanded and the contents
  ///    are escaped so that metacharacters are treated literally.
  /// 2. When `LITERAL` is set the entire pattern is escaped.
  /// 3. Integer flags are translated to inline flag groups
  ///    (e.g. `CASE_INSENSITIVE` → `(?i)` prepended to the pattern).
  ///
  /// Most Java / ICU regex syntax (`\d`, `\w`, `(?:...)`, `(?=...)`,
  /// `(?<name>...)`, backreferences, POSIX classes `\p{Alpha}` etc.) is
  /// identical in Swift Regex.
  ///
  /// **Known differences / limitations:**
  /// - Java possessive quantifiers (`a++`, `a*+`) are not supported.
  ///   Use atomic groups `(?>a+)` instead.
  /// - `COMMENTS` mode (`(?x)` / flag 4) may not be supported on all Swift
  ///   versions; test before relying on it.
  ///
  /// Mirrors `java.util.regex.Pattern` (Java 1.4).
  ///
  /// - Since: Java 1.4
  public final class Pattern: @unchecked Sendable {

    // MARK: - Flag constants (Java API)

    /// Enables Unix lines mode.  Only `\n` is recognised as a line terminator.
    public static let UNIX_LINES: Int = 1

    /// Enables case-insensitive matching (ASCII only unless `UNICODE_CASE` is
    /// also set).  Equivalent to inline flag `(?i)`.
    public static let CASE_INSENSITIVE: Int = 2

    /// Permits whitespace and comments in the pattern.
    /// Equivalent to inline flag `(?x)`.
    public static let COMMENTS: Int = 4

    /// Enables multiline mode: `^` and `$` match at line boundaries.
    /// Equivalent to inline flag `(?m)`.
    public static let MULTILINE: Int = 8

    /// Treats the entire pattern string as a literal sequence of characters.
    public static let LITERAL: Int = 16

    /// Enables DOTALL mode: `.` matches any character, including line
    /// terminators.  Equivalent to inline flag `(?s)`.
    public static let DOTALL: Int = 32

    /// Enables Unicode-aware case folding when combined with
    /// `CASE_INSENSITIVE`.
    public static let UNICODE_CASE: Int = 64

    /// Enables canonical equivalence.  (Not supported — accepted but ignored.)
    public static let CANON_EQ: Int = 128

    /// Enables the Unicode character class definitions.
    /// (Accepted; Swift Regex uses Unicode by default.)
    public static let UNICODE_CHARACTER_CLASS: Int = 256

    // MARK: - State

    /// The original Java pattern string as supplied by the caller.
    private let _patternString: String

    /// The integer flags originally supplied to `compile`.
    private let _flags: Int

    /// The compiled Swift regex (translated from the Java pattern).
    internal let _regex: Regex<AnyRegexOutput>

    /// Number of capturing groups, derived from the original pattern string at
    /// compile time (Swift's `Regex<AnyRegexOutput>` does not expose this value
    /// directly).
    private let _groupCount: Int

    // MARK: - Private initialiser

    private init(_ pattern: String, _ flags: Int, _ regex: Regex<AnyRegexOutput>) {
      _patternString = pattern
      _flags = flags
      _regex = regex
      _groupCount = Self._countCaptures(in: pattern)
    }

    // MARK: - Factory methods

    /// Compiles the given regular expression.
    ///
    /// - Parameter regex: A Java-syntax regular expression.
    /// - Throws: `PatternSyntaxException` if the pattern is syntactically invalid.
    /// - Since: Java 1.4
    public static func compile(_ regex: String) throws(java.util.regex.PatternSyntaxException) -> Pattern {
      try compile(regex, 0)
    }

    /// Compiles the given regular expression with the specified flags.
    ///
    /// - Parameters:
    ///   - regex: A Java-syntax regular expression.
    ///   - flags: A bitmask of `Pattern` flag constants.
    /// - Throws: `PatternSyntaxException` if the pattern is syntactically invalid.
    /// - Since: Java 1.4
    public static func compile(
      _ regex: String,
      _ flags: Int
    ) throws(java.util.regex.PatternSyntaxException) -> Pattern {
      let translated = _translatePattern(regex, flags: flags)
      do {
        let r = try Regex<AnyRegexOutput>(translated)
        return Pattern(regex, flags, r)
      } catch {
        throw PatternSyntaxException(error.localizedDescription, regex, -1)
      }
    }

    // MARK: - Instance methods

    /// Creates a `Matcher` that matches `input` against this pattern.
    ///
    /// - Since: Java 1.4
    public func matcher(_ input: String) -> Matcher {
      Matcher(pattern: self, input: input)
    }

    /// Returns the original pattern string.
    ///
    /// - Since: Java 1.4
    public func pattern() -> String { _patternString }

    /// Returns the flags used to compile this pattern.
    ///
    /// - Since: Java 1.4
    public func flags() -> Int { _flags }

    /// Returns the number of capturing groups in this pattern.
    ///
    /// - Since: Java 1.4
    public func groupCount() -> Int { _groupCount }

    // MARK: - Static convenience methods

    /// Returns `true` if `input` matches the given pattern in its entirety.
    ///
    /// This is a convenience wrapper around `Pattern.compile` + `Matcher.matches()`.
    ///
    /// - Throws: `PatternSyntaxException` if the pattern is invalid.
    /// - Since: Java 1.4
    public static func matches(_ regex: String, _ input: String) throws(java.util.regex.PatternSyntaxException) -> Bool {
      try compile(regex).matcher(input).matches()
    }

    /// Returns a predicate that tests whether a string matches this pattern.
    ///
    /// - Since: Java 8
    public func asPredicate() -> (String) -> Bool {
      { [self] input in self.matcher(input).find() }
    }

    /// Returns a predicate that tests whether the entire string matches this pattern.
    ///
    /// - Since: Java 11
    public func asMatchPredicate() -> (String) -> Bool {
      { [self] input in self.matcher(input).matches() }
    }

    // MARK: - split

    /// Splits `input` around matches of this pattern.
    ///
    /// Trailing empty strings are discarded (Java default behaviour when
    /// `limit == 0`).
    ///
    /// - Since: Java 1.4
    public func split(_ input: String) -> [String] {
      split(input, 0)
    }

    /// Splits `input` around matches of this pattern.
    ///
    /// - Parameter limit: Controls the number of times the pattern is applied.
    ///   - `> 0`: at most `limit - 1` splits; the last element is the remainder.
    ///   - `== 0`: trailing empty strings are discarded.
    ///   - `< 0`: apply the pattern as many times as possible, keeping all parts.
    /// - Since: Java 1.4
    public func split(_ input: String, _ limit: Int) -> [String] {
      var results: [String] = []
      var remaining = Substring(input)
      let maxSplits = limit > 0 ? limit - 1 : Int.max

      while results.count < maxSplits {
        guard let match = remaining.firstMatch(of: _regex) else { break }
        results.append(String(remaining[..<match.range.lowerBound]))
        if match.range.isEmpty {
          // Zero-length match: advance one character to avoid infinite loop.
          guard !remaining.isEmpty,
                match.range.upperBound < remaining.endIndex else { break }
          remaining = remaining[remaining.index(after: match.range.upperBound)...]
        } else {
          remaining = remaining[match.range.upperBound...]
        }
      }
      results.append(String(remaining))

      // Remove trailing empty strings unless limit != 0.
      if limit == 0 {
        while results.last == "" {
          results.removeLast()
        }
      }
      return results
    }

    // MARK: - Java → Swift pattern translation

    /// Translates a Java regex pattern string and flag bitmask into a Swift
    /// `Regex`-compatible pattern string.
    private static func _translatePattern(_ pattern: String, flags: Int) -> String {
      var translated = pattern

      // 1. LITERAL: escape every metacharacter.
      if flags & LITERAL != 0 {
        translated = _escapeLiteral(translated)
      } else {
        // 2. Expand \Q...\E literal quoting.
        translated = _expandLiteralQuoting(translated)
      }

      // 3. Prepend inline flag group for integer flags.
      var inline = ""
      if flags & CASE_INSENSITIVE != 0 { inline += "i" }
      if flags & DOTALL != 0          { inline += "s" }
      if flags & MULTILINE != 0       { inline += "m" }
      if flags & COMMENTS != 0        { inline += "x" }

      if !inline.isEmpty {
        translated = "(?\(inline))" + translated
      }

      return translated
    }

    /// Escapes all regex metacharacters in `s` so that it matches literally.
    static func _escapeLiteral(_ s: String) -> String {
      let metacharacters: Set<Character> = [
        "\\", "^", "$", ".", "|", "?", "*", "+",
        "(", ")", "[", "]", "{", "}"
      ]
      return s.reduce(into: "") { result, c in
        if metacharacters.contains(c) { result += "\\" }
        result.append(c)
      }
    }

    /// Replaces `\Q...\E` sections with their escaped equivalents.
    private static func _expandLiteralQuoting(_ pattern: String) -> String {
      guard pattern.contains("\\Q") else { return pattern }

      var result = ""
      var i = pattern.startIndex

      while i < pattern.endIndex {
        // Look for \Q
        if pattern[i] == "\\" {
          let next = pattern.index(after: i)
          if next < pattern.endIndex && pattern[next] == "Q" {
            // Found \Q — find matching \E
            let contentStart = pattern.index(after: next)
            if let eRange = pattern.range(of: "\\E", range: contentStart..<pattern.endIndex) {
              // Escape the literal content and skip \Q...\E
              result += _escapeLiteral(String(pattern[contentStart..<eRange.lowerBound]))
              i = eRange.upperBound
            } else {
              // No closing \E — escape everything to end of pattern
              result += _escapeLiteral(String(pattern[contentStart...]))
              return result
            }
            continue
          }
        }
        result.append(pattern[i])
        i = pattern.index(after: i)
      }
      return result
    }

    /// Counts the number of capturing groups in `pattern` by walking the
    /// pattern string.  This is needed because `Regex<AnyRegexOutput>` does
    /// not expose a `numberOfCaptures` property.
    ///
    /// Rules:
    /// - `\x` (escaped char) — skip two characters
    /// - `[...]` (character class) — skip until unescaped `]`
    /// - `(?:`, `(?=`, `(?!`, `(?>`, `(?#` — non-capturing, don't count
    /// - `(?<=`, `(?<!` — lookbehind, don't count
    /// - `(?<name>`, `(?'name'` — named capture, **count**
    /// - `(?i)`, `(?m)` etc. (letters/hyphens after `?`) — inline flags, don't count
    /// - `(` otherwise — capturing, count
    private static func _countCaptures(in pattern: String) -> Int {
      var count = 0
      var i = pattern.startIndex

      while i < pattern.endIndex {
        let c = pattern[i]

        // Skip escaped character.
        if c == "\\" {
          let next = pattern.index(after: i)
          i = next < pattern.endIndex ? pattern.index(after: next) : next
          continue
        }

        // Skip character class [...]
        if c == "[" {
          i = pattern.index(after: i)
          while i < pattern.endIndex {
            if pattern[i] == "\\" {
              let next = pattern.index(after: i)
              i = next < pattern.endIndex ? pattern.index(after: next) : next
            } else if pattern[i] == "]" {
              i = pattern.index(after: i)
              break
            } else {
              i = pattern.index(after: i)
            }
          }
          continue
        }

        if c == "(" {
          let next = pattern.index(after: i)
          if next < pattern.endIndex && pattern[next] == "?" {
            let afterQ = pattern.index(after: next)
            if afterQ < pattern.endIndex {
              let nc = pattern[afterQ]
              switch nc {
              case ":", "=", "!", ">", "#":
                // Non-capturing: (?:…), (?=…), (?!…), (?>…), (?#…)
                i = pattern.index(after: i)
                continue
              case "<":
                // (?<=…) / (?<!…) are lookbehinds (non-capturing).
                // (?<name>…) is a named capture (count it).
                let afterLT = pattern.index(after: afterQ)
                if afterLT < pattern.endIndex {
                  let peek = pattern[afterLT]
                  if peek == "=" || peek == "!" {
                    i = pattern.index(after: i)
                    continue
                  }
                  // Otherwise: named capture group — fall through to count.
                }
              default:
                // Letters/hyphens following `?` are inline flags — non-capturing.
                if nc.isLetter || nc == "-" {
                  i = pattern.index(after: i)
                  continue
                }
              }
            }
          }
          // Capturing group.
          count += 1
        }

        i = pattern.index(after: i)
      }
      return count
    }
  }
}
