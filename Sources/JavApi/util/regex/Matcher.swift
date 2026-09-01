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

    /// Which match operation was last performed — used by `requireEnd()` to
    /// pick the correct empirical re-check (see there).
    private enum _Operation { case matches, find, lookingAt }
    private var _lastOperation: _Operation = .find

    /// Backing storage for `hasAnchoringBounds()`/`useAnchoringBounds(_:)`.
    /// Defaults to `true`, matching the JDK.
    private var _anchoringBounds: Bool = true

    /// Backing storage for `hasTransparentBounds()`/`useTransparentBounds(_:)`.
    /// Defaults to `false`, matching the JDK.
    private var _transparentBounds: Bool = false

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
      /// The raw Swift regex output, kept around only so named capture
      /// groups can be looked up by name (`AnyRegexOutput` supports
      /// `subscript(_ name: String)`, which the pre-flattened
      /// `groupRanges` array above has no way to represent).
      var output: AnyRegexOutput

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
      _lastOperation = .matches
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
      _lastOperation = .find
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
      _lastOperation = .lookingAt
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

    /// Returns the named capturing group, or `nil` if the group exists in
    /// the pattern but did not participate in this match.
    ///
    /// - Throws: `IllegalArgumentException` if the pattern has no capturing
    ///   group with the given `name` — matches
    ///   `java.util.regex.Matcher.group(String)`'s documented behaviour
    ///   (an unchecked `IllegalArgumentException` in Java; modelled as
    ///   `throws` here rather than silently returning `nil`, per this
    ///   project's throws-not-silent-wrong-result convention).
    /// - Since: Java 7
    public func group(_ name: String) throws -> String? {
      guard let s = _state else {
        preconditionFailure("Matcher: no match has been attempted")
      }
      guard let element = s.output[name] else {
        throw IllegalArgumentException("No group with name <\(name)>")
      }
      guard let range = element.range else { return nil }
      return String(_input[range])
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
    /// - Throws: `IllegalArgumentException` if `replacement` references a
    ///   `${name}` group that doesn't exist in this matcher's pattern.
    /// - Since: Java 1.4
    public func replaceAll(_ replacement: String) throws -> String {
      reset()
      var result = ""
      var lastEnd = _regionStart

      while find() {
        guard let s = _state else { break }
        result += _input[lastEnd..<s.wholeRange.lowerBound]
        result += try _expandReplacement(replacement, state: s)
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
    /// - Throws: `IllegalArgumentException` if `replacement` references a
    ///   `${name}` group that doesn't exist in this matcher's pattern.
    /// - Since: Java 1.4
    public func replaceFirst(_ replacement: String) throws -> String {
      reset()
      guard find(), let s = _state else { return _input }
      var result = ""
      result += _input[_regionStart..<s.wholeRange.lowerBound]
      result += try _expandReplacement(replacement, state: s)
      result += _input[s.wholeRange.upperBound..<_regionEnd]
      return result
    }

    // MARK: - appendReplacement / appendTail

    /// Implements a terminal append-and-replace step.
    ///
    /// Each call appends the subsequence of the input since the end of the
    /// last match, with the matched portion replaced by `replacement`.
    ///
    /// - Throws: `IllegalArgumentException` if `replacement` references a
    ///   `${name}` group that doesn't exist in this matcher's pattern.
    /// - Since: Java 1.4
    @discardableResult
    public func appendReplacement(_ sb: StringBuffer, _ replacement: String) throws -> Matcher {
      guard let s = _state else { return self }
      _ = sb.append(String(_input[_appendPos..<s.wholeRange.lowerBound]))
      _ = sb.append(try _expandReplacement(replacement, state: s))
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

    // MARK: - Region boundary behaviour

    /// Returns `true` if this matcher's region boundaries are treated as
    /// anchors (`^`/`$` match there), matching the JDK default.
    ///
    /// **Implementation note:** matching in this port already runs against
    /// `_input[_regionStart..<_regionEnd]` as an independent Swift
    /// `Substring`, whose start/end Swift's `Regex` engine treats as the
    /// effective string boundaries for `^`/`$` — i.e. the current
    /// implementation's behaviour already *is* `useAnchoringBounds(true)`,
    /// the JDK default. `useAnchoringBounds(false)` is accepted and
    /// remembered (so `hasAnchoringBounds()` reports it correctly), but
    /// Swift's `Regex` engine exposes no way to make `^`/`$` ignore a
    /// sub-range's boundaries and refer only to the true start/end of the
    /// whole input, so toggling it to `false` has no further effect on
    /// match behaviour — a known limitation versus the reference JDK,
    /// consistent with the one already documented for ``hitEnd()``/
    /// ``requireEnd()``.
    ///
    /// - Since: Java 1.5
    public func hasAnchoringBounds() -> Bool { _anchoringBounds }

    /// Sets whether this matcher's region boundaries are transparent to
    /// `^`/`$` anchors. See ``hasAnchoringBounds()`` for the implementation
    /// limitation.
    ///
    /// - Since: Java 1.5
    @discardableResult
    public func useAnchoringBounds(_ b: Bool) -> Matcher {
      _anchoringBounds = b
      return self
    }

    /// Returns `true` if this matcher's region boundaries are transparent to
    /// lookahead, lookbehind, and boundary matchers — i.e. whether they may
    /// "see" beyond the region into the rest of the input. The JDK default
    /// is `false` (opaque bounds).
    ///
    /// **Implementation note:** matching in this port runs against
    /// `_input[_regionStart..<_regionEnd]` as an independent `Substring`,
    /// which Swift's `Regex` engine cannot see past — i.e. the current
    /// implementation's behaviour already *is* `useTransparentBounds(false)`,
    /// the JDK default. `useTransparentBounds(true)` is accepted and
    /// remembered (so `hasTransparentBounds()` reports it correctly), but
    /// making lookaround see past the region boundary would require
    /// matching against the full input while still constraining where the
    /// overall match may start/end — not expressible with Swift's `Regex`
    /// API — so toggling it to `true` has no further effect on match
    /// behaviour, a known limitation versus the reference JDK.
    ///
    /// - Since: Java 1.5
    public func hasTransparentBounds() -> Bool { _transparentBounds }

    /// Sets whether this matcher's region boundaries are transparent. See
    /// ``hasTransparentBounds()`` for the implementation limitation.
    ///
    /// - Since: Java 1.5
    @discardableResult
    public func useTransparentBounds(_ b: Bool) -> Matcher {
      _transparentBounds = b
      return self
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
        input: _input,
        output: match.output
      )
    }

    /// Expands `$n`, `${name}`, `\$`, and `\\` references in `template`.
    ///
    /// - Throws: `IllegalArgumentException` if `template` contains a
    ///   `${name}` reference to a group that doesn't exist in this
    ///   matcher's pattern — matches Java's documented behaviour for
    ///   `appendReplacement`/`replaceAll`/`replaceFirst`.
    private func _expandReplacement(_ template: String, state: MatchState) throws -> String {
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
            // ${name} — named group.
            if let closeBrace = template[next...].firstIndex(of: "}") {
              let nameStart = template.index(after: next)
              let name = String(template[nameStart..<closeBrace])
              guard let element = state.output[name] else {
                throw IllegalArgumentException("No group with name <\(name)>")
              }
              if let range = element.range {
                result += state.input[range]
              }
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

    // MARK: - pattern / hitEnd / requireEnd

    /// Returns the `Pattern` this matcher is using.
    ///
    /// Mirrors `java.util.regex.Matcher.pattern()` (Java 1.5).
    ///
    /// - Since: Java 1.5
    public func pattern() -> Pattern { _pattern }

    /// Returns `true` if the end of input was hit by the search engine in
    /// the last match operation performed by this matcher.
    ///
    /// Intended for text processors that perform incremental matching: a
    /// `true` result means more input could still change the outcome of the
    /// last `find()`/`matches()`/`lookingAt()` call.
    ///
    /// **Implementation note:** unlike the reference JDK, Swift's `Regex`
    /// engine does not expose whether its backtracking search touched the
    /// end of the input. This is therefore computed heuristically: `true`
    /// if the last match attempt found no match at all (the engine
    /// necessarily scanned the whole region without success), or if a match
    /// was found whose end coincides with the end of the search region.
    /// Returns `false` if no match has been attempted yet, matching the
    /// JDK's initial state.
    ///
    /// - Since: Java 1.5
    public func hitEnd() -> Bool {
      guard _matchAttempted else { return false }
      guard let s = _state else { return true }
      return s.wholeRange.upperBound == _regionEnd
    }

    /// Returns `true` if more input could change a positive match into a
    /// negative one — i.e. cause the current match to be *lost*, as opposed
    /// to merely extended.
    ///
    /// Only meaningful immediately after a successful match that also hit
    /// the end of input (see ``hitEnd()``); returns `false` otherwise,
    /// matching the JDK's "has no meaning" case without throwing.
    ///
    /// **Implementation note:** Swift's `Regex` engine does not expose
    /// backtracking state either, so this is determined empirically: one
    /// representative probe character — an ordinary lowercase letter (`"a"`),
    /// chosen because it is `\w`-forming and thus the character most likely
    /// to reveal a dependency on a following word boundary (`\b`), line
    /// anchor (`$`), or same-class quantifier (`a+` and similar) — is
    /// appended immediately after the search region, and the same match
    /// operation is re-run. If the original match is lost — it no longer
    /// matches at all (`matches()`/`lookingAt()`), or `find()` no longer
    /// finds a match at the exact same start position — this returns
    /// `true`. A match that merely grows longer with the probe present is
    /// not considered lost, matching Java's documented distinction between
    /// "changed" and "lost". Because only a single representative character
    /// is probed rather than every possible next character, this can miss
    /// cases that depend on a *specific* following character (e.g. a
    /// lookahead for a particular digit or symbol) — a known limitation
    /// versus the reference JDK's exhaustive backtracking-based answer.
    ///
    /// - Since: Java 1.5
    public func requireEnd() -> Bool {
      guard _matchAttempted, let s = _state, hitEnd() else { return false }

      let probe: Character = "a"
      var extended = _input
      extended.insert(probe, at: _regionEnd)

      let startOffset = _input.distance(from: _input.startIndex, to: _regionStart)
      let regionEndOffset = _input.distance(from: _input.startIndex, to: _regionEnd)
      let matchStartOffset = s.startOffset(0)

      let probeMatcher = Matcher(pattern: _pattern, input: extended)
      probeMatcher.region(startOffset, regionEndOffset + 1)

      switch _lastOperation {
      case .matches:
        return !probeMatcher.matches()
      case .lookingAt:
        return !probeMatcher.lookingAt()
      case .find:
        guard probeMatcher.find(matchStartOffset) else { return true }
        return probeMatcher.start() != matchStartOffset
      }
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

    // MARK: - quoteReplacement

    /// Returns a literal replacement `String` for the specified `String`.
    ///
    /// This method produces a `String` that will work as a literal
    /// replacement `replacement` in the `appendReplacement(_:_:)` method of
    /// this class (and therefore also `replaceAll(_:)`/`replaceFirst(_:)`):
    /// the `\` and `$` characters will have no special meaning in the
    /// returned string.
    ///
    /// Mirrors `java.util.regex.Matcher.quoteReplacement(String)` (Java 1.5).
    ///
    /// - Since: Java 1.5
    public static func quoteReplacement(_ s: String) -> String {
      guard s.contains("\\") || s.contains("$") else { return s }
      var result = ""
      result.reserveCapacity(s.count)
      for c in s {
        if c == "\\" || c == "$" { result.append("\\") }
        result.append(c)
      }
      return result
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
