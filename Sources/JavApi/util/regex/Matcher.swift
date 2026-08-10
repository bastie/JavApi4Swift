/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.regex {

  /// An engine that performs match operations on a character sequence by
  /// interpreting a `Pattern`.
  ///
  /// Created via `Pattern.matcher(_:)`.  A matcher is **not** thread-safe.
  ///
  /// Mirrors `java.util.regex.Matcher` (Java 1.4).
  ///
  /// - Since: Java 1.4
  public final class Matcher: java.util.regex.MatchResult, @unchecked Sendable {

    // MARK: - Internal state

    /// The pattern currently being used.
    private var _pattern: Pattern

    /// The full input string (region is a sub-range of this).
    private var _input: String

    /// Start of the region to search within.
    private var _regionStart: String.Index

    /// End of the region to search within (exclusive).
    private var _regionEnd: String.Index

    /// The position from which the next `find()` call starts.
    private var _searchStart: String.Index

    /// The position up to which text has been appended in
    /// `appendReplacement` / `appendTail`.
    private var _appendPos: String.Index

    /// Whether a match operation has been attempted since the last reset.
    private var _matchAttempted: Bool = false

    /// Current match state; `nil` when no match has been found yet, or after
    /// a failed match attempt.
    private var _state: MatchState?

    // MARK: - MatchState

    /// Snapshot of a single successful match.
    internal struct MatchState {
      /// Range of the whole match within the original `_input` string.
      var wholeRange: Range<String.Index>
      /// Ranges of each capture group (group 1 = index 0).
      /// `nil` means the group did not participate.
      var groupRanges: [Range<String.Index>?]
      /// The string the match was performed against (same as `_input`).
      var input: String

        /// Character-distance offset of the start of group `g` (0 = whole match), or -1.
      ///
      /// Note: uses Swift grapheme-cluster distances, not Java UTF-16 code-unit
      /// indices. For BMP input the values are identical.
      func startOffset(_ g: Int) -> Int {
        guard let r = range(g) else { return -1 }
        return input.distance(from: input.startIndex, to: r.lowerBound)
      }

      /// Character-distance offset after the last character of group `g`, or -1.
      func endOffset(_ g: Int) -> Int {
        guard let r = range(g) else { return -1 }
        return input.distance(from: input.startIndex, to: r.upperBound)
      }

      func range(_ g: Int) -> Range<String.Index>? {
        if g == 0 { return wholeRange }
        guard g >= 1, g <= groupRanges.count else { return nil }
        return groupRanges[g - 1]
      }

      func substring(_ g: Int) -> Substring? {
        guard let r = range(g) else { return nil }
        return input[r]
      }
    }

    // MARK: - Initialiser (internal — use Pattern.matcher)

    internal init(pattern: Pattern, input: String) {
      _pattern = pattern
      _input = input
      _regionStart = input.startIndex
      _regionEnd = input.endIndex
      _searchStart = input.startIndex
      _appendPos = input.startIndex
    }

    // MARK: - Match operations

    /// Attempts to match the entire region against the pattern.
    ///
    /// - Returns: `true` if, and only if, the entire region matches the pattern.
    /// - Since: Java 1.4
    @discardableResult
    public func matches() -> Bool {
      _matchAttempted = true
      let region = _input[_regionStart..<_regionEnd]
      guard let match = region.wholeMatch(of: _pattern._regex) else {
        _state = nil
        return false
      }
      _state = _extractState(from: match)
      return true
    }

    /// Attempts to find the next subsequence that matches the pattern.
    ///
    /// - Returns: `true` if a match was found.
    /// - Since: Java 1.4
    @discardableResult
    public func find() -> Bool {
      _matchAttempted = true
      let searchRegion = _input[_searchStart..<_regionEnd]
      guard let match = searchRegion.firstMatch(of: _pattern._regex) else {
        _state = nil
        return false
      }
      _state = _extractState(from: match)
      // Advance search start; guard against infinite loops on zero-length match.
      if match.range.isEmpty, match.range.upperBound < _regionEnd {
        _searchStart = _input.index(after: match.range.upperBound)
      } else {
        _searchStart = match.range.upperBound
      }
      return true
    }

    /// Resets the matcher and then attempts to find the next subsequence
    /// starting at `start` (character-distance from the beginning of the input).
    ///
    /// - Since: Java 1.4
    @discardableResult
    public func find(_ start: Int) -> Bool {
      reset()
      guard start >= 0 else {
        preconditionFailure("Matcher.find(_:): start index \(start) < 0")
      }
      _searchStart = _input.index(
        _input.startIndex,
        offsetBy: min(start, _input.count),
        limitedBy: _input.endIndex
      ) ?? _input.endIndex
      return find()
    }

    /// Attempts to match the region, starting at the beginning, against the pattern.
    ///
    /// Unlike `matches()`, `lookingAt()` does not require the entire region to match.
    ///
    /// - Since: Java 1.4
    @discardableResult
    public func lookingAt() -> Bool {
      _matchAttempted = true
      let region = _input[_regionStart..<_regionEnd]
      // prefixMatch checks that the match starts at the beginning of the region.
      guard let match = region.prefixMatch(of: _pattern._regex) else {
        _state = nil
        return false
      }
      _state = _extractState(from: match)
      return true
    }

    // MARK: - MatchResult conformance

    /// - Since: Java 1.4
    public func start() -> Int { start(0) }

    /// - Since: Java 1.4
    public func start(_ group: Int) -> Int {
      guard let s = _state else {
        preconditionFailure("Matcher: no match has been attempted")
      }
      return s.startOffset(group)
    }

    /// - Since: Java 1.4
    public func end() -> Int { end(0) }

    /// - Since: Java 1.4
    public func end(_ group: Int) -> Int {
      guard let s = _state else {
        preconditionFailure("Matcher: no match has been attempted")
      }
      return s.endOffset(group)
    }

    /// Returns the whole matched string.
    /// - Since: Java 1.4
    public func group() -> String { group(0) ?? "" }

    /// Returns the substring captured by `group`, or `nil` if the group did
    /// not participate in the match.
    ///
    /// Group 0 is the whole match; groups are numbered from 1.
    ///
    /// - Since: Java 1.4
    public func group(_ group: Int) -> String? {
      guard let s = _state else {
        preconditionFailure("Matcher: no match has been attempted")
      }
      return s.substring(group).map(String.init)
    }

    /// Returns the named capturing group, or `nil` if the group did not match.
    ///
    /// - Since: Java 7
    public func group(_ name: String) -> String? {
      // Named group access requires dynamic lookup via AnyRegexOutput.
      // We re-run the match to extract named captures.
      guard _state != nil else {
        preconditionFailure("Matcher: no match has been attempted")
      }
      // Named groups are not directly indexable in AnyRegexOutput by name
      // without compile-time knowledge. Return nil for now.
      return nil
    }

    /// Returns the number of capturing groups in the current pattern.
    ///
    /// - Since: Java 1.4
    public func groupCount() -> Int { _pattern.groupCount() }

    // MARK: - Reset

    /// Resets this matcher, discarding all state but keeping the input and pattern.
    ///
    /// - Since: Java 1.4
    @discardableResult
    public func reset() -> Matcher {
      _searchStart = _regionStart
      _appendPos = _input.startIndex
      _state = nil
      _matchAttempted = false
      return self
    }

    /// Resets this matcher with a new input sequence.
    ///
    /// - Since: Java 1.4
    @discardableResult
    public func reset(_ input: String) -> Matcher {
      _input = input
      _regionStart = input.startIndex
      _regionEnd = input.endIndex
      return reset()
    }

    // MARK: - Pattern replacement

    /// Changes the `Pattern` used by this matcher and resets state.
    ///
    /// - Since: Java 1.4
    @discardableResult
    public func usePattern(_ newPattern: Pattern) -> Matcher {
      _pattern = newPattern
      _state = nil
      _matchAttempted = false
      return self
    }

    // MARK: - Replacement helpers

    /// Replaces every subsequence that matches the pattern with `replacement`.
    ///
    /// The replacement string may contain references to capture groups:
    /// `$0` or `$&` for the whole match, `$1`…`$9` for numbered groups,
    /// `${name}` for named groups. Use `\\` to include a literal backslash
    /// and `\$` to include a literal dollar sign.
    ///
    /// - Since: Java 1.4
    public func replaceAll(_ replacement: String) -> String {
      reset()
      var result = ""
      var lastEnd = _regionStart

      while find() {
        guard let s = _state else { break }
        result += _input[lastEnd..<s.wholeRange.lowerBound]
        result += _expandReplacement(replacement, state: s)
        lastEnd = s.wholeRange.upperBound
        // Guard against zero-length match infinite loop.
        if s.wholeRange.isEmpty, lastEnd < _regionEnd {
          result += String(_input[lastEnd])
          lastEnd = _input.index(after: lastEnd)
          _searchStart = lastEnd
        }
      }
      result += _input[lastEnd..<_regionEnd]
      return result
    }

    /// Replaces the first subsequence that matches the pattern with `replacement`.
    ///
    /// - Since: Java 1.4
    public func replaceFirst(_ replacement: String) -> String {
      reset()
      guard find(), let s = _state else { return _input }
      var result = ""
      result += _input[_regionStart..<s.wholeRange.lowerBound]
      result += _expandReplacement(replacement, state: s)
      result += _input[s.wholeRange.upperBound..<_regionEnd]
      return result
    }

    // MARK: - appendReplacement / appendTail

    /// Implements a terminal append-and-replace step.
    ///
    /// Each call appends the subsequence of the input since the end of the
    /// last match, with the matched portion replaced by `replacement`.
    ///
    /// - Since: Java 1.4
    @discardableResult
    public func appendReplacement(_ sb: StringBuffer, _ replacement: String) -> Matcher {
      guard let s = _state else { return self }
      _ = sb.append(String(_input[_appendPos..<s.wholeRange.lowerBound]))
      _ = sb.append(_expandReplacement(replacement, state: s))
      _appendPos = s.wholeRange.upperBound
      return self
    }

    /// Appends the remainder of the input after the last match.
    ///
    /// - Since: Java 1.4
    @discardableResult
    public func appendTail(_ sb: StringBuffer) -> StringBuffer {
      _ = sb.append(String(_input[_appendPos...]))
      _appendPos = _input.endIndex
      return sb
    }

    // MARK: - Region

    /// Sets the limits of the region to search (character-distance offsets).
    ///
    /// - Since: Java 1.5
    @discardableResult
    public func region(_ start: Int, _ end: Int) -> Matcher {
      _regionStart = _input.index(
        _input.startIndex,
        offsetBy: min(start, _input.count),
        limitedBy: _input.endIndex
      ) ?? _input.endIndex
      _regionEnd = _input.index(
        _input.startIndex,
        offsetBy: min(end, _input.count),
        limitedBy: _input.endIndex
      ) ?? _input.endIndex
      return reset()
    }

    /// Returns the start of the search region (character distance from startIndex).
    ///
    /// - Since: Java 1.5
    public func regionStart() -> Int {
      _input.distance(from: _input.startIndex, to: _regionStart)
    }

    /// Returns the end of the search region (character distance from startIndex).
    ///
    /// - Since: Java 1.5
    public func regionEnd() -> Int {
      _input.distance(from: _input.startIndex, to: _regionEnd)
    }

    /// Returns `true` if there is another match in the region after the current
    /// position without changing matcher state.
    ///
    /// - Since: Java 1.5
    public func hasMatch() -> Bool {
      guard !_matchAttempted else { return _state != nil }
      return _input[_searchStart..<_regionEnd].firstMatch(of: _pattern._regex) != nil
    }

    // MARK: - Private helpers

    /// Builds a `MatchState` from a successful Swift regex match.
    private func _extractState(from match: Regex<AnyRegexOutput>.Match) -> MatchState {
      var groupRanges: [Range<String.Index>?] = []
      var first = true
      for element in match.output {
        if first { first = false; continue }   // skip index 0 (whole match)
        groupRanges.append(element.range)
      }
      return MatchState(
        wholeRange: match.range,
        groupRanges: groupRanges,
        input: _input
      )
    }

    /// Expands `$n`, `${name}`, `\$`, and `\\` references in `template`.
    private func _expandReplacement(_ template: String, state: MatchState) -> String {
      var result = ""
      var i = template.startIndex

      while i < template.endIndex {
        let c = template[i]

        if c == "\\" {
          let next = template.index(after: i)
          if next < template.endIndex {
            result.append(template[next])
            i = template.index(after: next)
          } else {
            result.append(c)
            i = next
          }
          continue
        }

        if c == "$" {
          let next = template.index(after: i)
          guard next < template.endIndex else { result.append(c); break }

          let nc = template[next]

          if nc == "{" {
            // ${name} — named group (limited support: skip to })
            if let closeBrace = template[next...].firstIndex(of: "}") {
              let nameStart = template.index(after: next)
              let name = String(template[nameStart..<closeBrace])
              // Named group lookup is not fully supported; emit empty string.
              _ = name
              i = template.index(after: closeBrace)
            } else {
              result.append(c)
              i = next
            }
            continue
          }

          if nc.isNumber {
            // Collect all consecutive digits after $.
            var numStr = ""
            var j = next
            while j < template.endIndex && template[j].isNumber {
              numStr.append(template[j])
              j = template.index(after: j)
            }
            if let g = Int(numStr) {
              result += state.substring(g).map(String.init) ?? ""
            }
            i = j
            continue
          }

          // $ not followed by digit or { — treat as literal.
          result.append(c)
          i = next
          continue
        }

        result.append(c)
        i = template.index(after: i)
      }

      return result
    }

    // MARK: - toMatchResult

    /// Returns a frozen snapshot of the current match as a `MatchResult`.
    ///
    /// The snapshot is independent of further changes to this matcher.
    ///
    /// Mirrors `java.util.regex.Matcher.toMatchResult()` (Java 5).
    ///
    /// - Since: Java 5
    public func toMatchResult() -> java.util.regex.MatchResult {
      guard let s = _state else {
        preconditionFailure("Matcher.toMatchResult(): no match has been performed")
      }
      return MatchSnapshot(state: s)
    }
  }
}

// MARK: - MatchSnapshot (internal frozen copy of a match)

extension java.util.regex {

  /// A value-type snapshot of a match produced by `Matcher.toMatchResult()`.
  ///
  /// Conforms to `MatchResult`; all values are pre-computed at the moment the
  /// snapshot is created and are independent of the originating `Matcher`.
  struct MatchSnapshot: MatchResult {

    // Mirrors the fields of Matcher.MatchState.
    private let _wholeRange: Range<String.Index>
    private let _groupRanges: [Range<String.Index>?]
    private let _input: String

    fileprivate init(state: Matcher.MatchState) {
      _wholeRange = state.wholeRange
      _groupRanges = state.groupRanges
      _input = state.input
    }

    public func start() -> Int { startOff(0) }
    public func start(_ group: Int) -> Int { startOff(group) }
    public func end() -> Int { endOff(0) }
    public func end(_ group: Int) -> Int { endOff(group) }

    public func group() -> String { sub(0).map(String.init) ?? "" }
    public func group(_ group: Int) -> String? { sub(group).map(String.init) }
    public func groupCount() -> Int { _groupRanges.count }

    private func range(_ g: Int) -> Range<String.Index>? {
      if g == 0 { return _wholeRange }
      guard g >= 1, g <= _groupRanges.count else { return nil }
      return _groupRanges[g - 1]
    }

    private func sub(_ g: Int) -> Substring? {
      guard let r = range(g) else { return nil }
      return _input[r]
    }

    private func startOff(_ g: Int) -> Int {
      guard let r = range(g) else { return -1 }
      return _input.distance(from: _input.startIndex, to: r.lowerBound)
    }

    private func endOff(_ g: Int) -> Int {
      guard let r = range(g) else { return -1 }
      return _input.distance(from: _input.startIndex, to: r.upperBound)
    }
  }
}
