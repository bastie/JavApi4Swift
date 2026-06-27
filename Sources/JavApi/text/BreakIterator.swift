/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Locates boundaries in text (characters, words, sentences, lines).
  ///
  /// Use the factory methods to obtain an instance:
  /// - ``getCharacterInstance()`` / ``getCharacterInstance(_:)``
  /// - ``getWordInstance()`` / ``getWordInstance(_:)``
  /// - ``getSentenceInstance()`` / ``getSentenceInstance(_:)``
  /// - ``getLineInstance()`` / ``getLineInstance(_:)``
  ///
  /// Iterate by calling ``next()`` or ``previous()`` until the result equals
  /// ``BreakIterator/DONE``.
  ///
  /// ## Implementation note
  ///
  /// This implementation is pure Swift — it uses `String` and
  /// `Character.UnicodeScalarView` directly, with no NS/CF types.
  ///
  /// - Since: Java 1.1
  open class BreakIterator {

    // -------------------------------------------------------------------------
    // MARK: Sentinel
    // -------------------------------------------------------------------------

    /// Returned by ``next()`` and ``previous()`` when no more boundaries exist.
    public static let DONE: Int = -1

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    /// The text being analysed, stored as an array of Swift `Character`
    /// (Unicode grapheme clusters) so that index arithmetic is O(1).
    var chars: [Character] = []

    /// Current position (boundary index, 0…chars.count).
    var position: Int = 0

    // -------------------------------------------------------------------------
    // MARK: Initialisers (protected — use factory methods)
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Text access
    // -------------------------------------------------------------------------

    /// Sets the text to analyse and resets the iterator to the start.
    open func setText(_ text: String) {
      chars    = Array(text)
      position = 0
    }

    /// Returns the text being analysed.
    open func getText() -> String { String(chars) }

    // -------------------------------------------------------------------------
    // MARK: Navigation
    // -------------------------------------------------------------------------

    /// Returns the index of the first boundary (always 0 for non-empty text).
    open func first() -> Int {
      position = 0
      return position
    }

    /// Returns the index past the last character (== `chars.count`).
    open func last() -> Int {
      position = chars.count
      return position
    }

    /// Returns the current position.
    open func current() -> Int { position }

    /// Advances to the next boundary and returns it, or ``DONE``.
    open func next() -> Int {
      guard position < chars.count else { return Self.DONE }
      position = nextBoundary(after: position)
      return position < chars.count || position == chars.count ? position : Self.DONE
    }

    /// Moves to the previous boundary and returns it, or ``DONE``.
    open func previous() -> Int {
      guard position > 0 else { return Self.DONE }
      position = previousBoundary(before: position)
      return position
    }

    /// Moves to `offset` and returns the first boundary at or after it.
    open func following(_ offset: Int) -> Int {
      position = max(0, min(offset, chars.count))
      return next()
    }

    /// Returns the first boundary strictly before `offset`.
    open func preceding(_ offset: Int) -> Int {
      position = max(0, min(offset, chars.count))
      return previous()
    }

    /// Returns `true` if `offset` is a boundary in the current text.
    open func isBoundary(_ offset: Int) -> Bool {
      guard offset >= 0 && offset <= chars.count else { return false }
      if offset == 0 || offset == chars.count { return true }
      let saved = position
      position = 0
      var b = next()
      while b != Self.DONE && b < offset { b = next() }
      position = saved
      return b == offset
    }

    // -------------------------------------------------------------------------
    // MARK: Subclass hooks
    // -------------------------------------------------------------------------

    /// Returns the next boundary position after `pos`. Subclasses override this.
    open func nextBoundary(after pos: Int) -> Int {
      return pos + 1
    }

    /// Returns the previous boundary position before `pos`. Subclasses override this.
    open func previousBoundary(before pos: Int) -> Int {
      return pos - 1
    }

    // -------------------------------------------------------------------------
    // MARK: Factory methods
    // -------------------------------------------------------------------------

    /// Returns the set of locales for which `BreakIterator` instances are available.
    ///
    /// - Since: Java 1.2
    public static func getAvailableLocales() -> [java.util.Locale] {
      return Foundation.Locale.availableIdentifiers.map { java.util.Locale($0) }
    }

    /// Returns a `BreakIterator` for Unicode grapheme-cluster (character) boundaries.
    public static func getCharacterInstance() -> BreakIterator {
      return getCharacterInstance(java.util.Locale.getDefault())
    }

    /// Returns a grapheme-cluster iterator for `locale`.
    public static func getCharacterInstance(_ locale: java.util.Locale) -> BreakIterator {
      return CharacterBreakIterator()
    }

    /// Returns a `BreakIterator` for word boundaries.
    public static func getWordInstance() -> BreakIterator {
      return getWordInstance(java.util.Locale.getDefault())
    }

    /// Returns a word-boundary iterator for `locale`.
    public static func getWordInstance(_ locale: java.util.Locale) -> BreakIterator {
      return WordBreakIterator()
    }

    /// Returns a `BreakIterator` for sentence boundaries.
    public static func getSentenceInstance() -> BreakIterator {
      return getSentenceInstance(java.util.Locale.getDefault())
    }

    /// Returns a sentence-boundary iterator for `locale`.
    public static func getSentenceInstance(_ locale: java.util.Locale) -> BreakIterator {
      return SentenceBreakIterator()
    }

    /// Returns a `BreakIterator` for line-wrap boundaries.
    public static func getLineInstance() -> BreakIterator {
      return getLineInstance(java.util.Locale.getDefault())
    }

    /// Returns a line-break iterator for `locale`.
    public static func getLineInstance(_ locale: java.util.Locale) -> BreakIterator {
      return LineBreakIterator()
    }
  }

  // ===========================================================================
  // MARK: - CharacterBreakIterator
  // ===========================================================================

  /// Breaks text at every Unicode grapheme cluster boundary.
  ///
  /// Every `Character` in Swift already represents a grapheme cluster, so
  /// boundaries are simply at every index 0…chars.count.
  final class CharacterBreakIterator: BreakIterator {

    override func nextBoundary(after pos: Int) -> Int {
      return min(pos + 1, chars.count)
    }

    override func previousBoundary(before pos: Int) -> Int {
      return max(pos - 1, 0)
    }
  }

  // ===========================================================================
  // MARK: - WordBreakIterator
  // ===========================================================================

  /// Breaks text at word boundaries.
  ///
  /// A boundary exists between a word character (letter or digit) and a
  /// non-word character, matching Java's basic word-break behaviour.
  final class WordBreakIterator: BreakIterator {

    override func nextBoundary(after pos: Int) -> Int {
      guard pos < chars.count else { return chars.count }
      let wasWord = isWordChar(chars[pos])
      var i = pos + 1
      while i < chars.count {
        if isWordChar(chars[i]) != wasWord { return i }
        i += 1
      }
      return chars.count
    }

    override func previousBoundary(before pos: Int) -> Int {
      guard pos > 0 else { return 0 }
      let idx = pos - 1
      let wasWord = isWordChar(chars[idx])
      var i = idx - 1
      while i >= 0 {
        if isWordChar(chars[i]) != wasWord { return i + 1 }
        i -= 1
      }
      return 0
    }

    private func isWordChar(_ c: Character) -> Bool {
      return c.isLetter || c.isNumber
    }
  }

  // ===========================================================================
  // MARK: - SentenceBreakIterator
  // ===========================================================================

  /// Breaks text at sentence boundaries.
  ///
  /// A boundary is placed after a sentence-terminating character (`.`, `!`, `?`,
  /// `…`) that is followed by whitespace or end-of-text.
  final class SentenceBreakIterator: BreakIterator {

    private static let terminators: Set<Character> = [".", "!", "?", "\u{2026}"]

    override func nextBoundary(after pos: Int) -> Int {
      var i = pos
      while i < chars.count {
        if Self.terminators.contains(chars[i]) {
          let boundary = i + 1
          // Skip trailing whitespace after the terminator
          if boundary >= chars.count { return boundary }
          if chars[boundary].isWhitespace { return boundary }
        }
        i += 1
      }
      return chars.count
    }

    override func previousBoundary(before pos: Int) -> Int {
      guard pos > 0 else { return 0 }
      var i = pos - 1
      while i > 0 {
        let prev = i - 1
        if Self.terminators.contains(chars[prev]) {
          if i >= chars.count || chars[i].isWhitespace { return i }
        }
        i -= 1
      }
      return 0
    }
  }

  // ===========================================================================
  // MARK: - LineBreakIterator
  // ===========================================================================

  /// Breaks text at line-wrap opportunities.
  ///
  /// Boundaries occur after whitespace characters (spaces, tabs) and after
  /// hyphens, matching the most common line-wrap rules.
  final class LineBreakIterator: BreakIterator {

    override func nextBoundary(after pos: Int) -> Int {
      var i = pos
      while i < chars.count {
        let ch = chars[i]
        // After whitespace
        if ch.isWhitespace {
          // Include the whitespace in the run, then break after it
          var j = i + 1
          while j < chars.count && chars[j].isWhitespace { j += 1 }
          return j
        }
        // After hyphen (opportunity to wrap after the hyphen)
        if ch == "-" || ch == "\u{2010}" { return i + 1 }
        i += 1
      }
      return chars.count
    }

    override func previousBoundary(before pos: Int) -> Int {
      guard pos > 0 else { return 0 }
      var i = pos - 1
      while i > 0 {
        let ch = chars[i - 1]
        if ch.isWhitespace || ch == "-" || ch == "\u{2010}" { return i }
        i -= 1
      }
      return 0
    }
  }
}
