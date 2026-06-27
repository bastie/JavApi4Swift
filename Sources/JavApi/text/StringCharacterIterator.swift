/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  /// Implements ``CharacterIterator`` for a `String`.
  ///
  /// - Since: Java 1.1
  open class StringCharacterIterator : CharacterIterator {

    private var text: [Character]
    private let begin: Int
    private let end: Int
    private var pos: Int

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates an iterator over the entire string.
    public init(_ text: String) {
      self.text  = Array(text)
      self.begin = 0
      self.end   = self.text.count
      self.pos   = 0
    }

    /// Creates an iterator over the entire string, positioned at `pos`.
    public init(_ text: String, _ pos: Int) {
      self.text  = Array(text)
      self.begin = 0
      self.end   = self.text.count
      self.pos   = pos
    }

    /// Creates an iterator over the sub-range `[begin, end)`, positioned at `pos`.
    public init(_ text: String, _ begin: Int, _ end: Int, _ pos: Int) {
      self.text  = Array(text)
      self.begin = begin
      self.end   = end
      self.pos   = pos
    }

    // -------------------------------------------------------------------------
    // MARK: CharacterIterator
    // -------------------------------------------------------------------------

    public func first() -> Character {
      pos = begin
      return current()
    }

    public func last() -> Character {
      if end == begin {
        pos = end
        return Self.DONE
      }
      pos = end - 1
      return current()
    }

    public func current() -> Character {
      guard pos >= begin && pos < end else { return Self.DONE }
      return text[pos]
    }

    public func next() -> Character {
      pos += 1
      if pos >= end {
        pos = end
        return Self.DONE
      }
      return text[pos]
    }

    public func previous() -> Character {
      if pos <= begin { return Self.DONE }
      pos -= 1
      return text[pos]
    }

    public func setIndex(_ position: Int) -> Character {
      guard position >= begin && position <= end else {
        fatalError("StringCharacterIterator.setIndex: \(position) out of range [\(begin), \(end)]")
      }
      pos = position
      return current()
    }

    public func getBeginIndex() -> Int { begin }
    public func getEndIndex()   -> Int { end   }
    public func getIndex()      -> Int { pos   }

    public func clone() -> any CharacterIterator {
      return StringCharacterIterator(String(text), begin, end, pos)
    }

    // -------------------------------------------------------------------------
    // MARK: Text replacement
    // -------------------------------------------------------------------------

    /// Replaces the text and resets the iterator to the beginning.
    public func setText(_ text: String) {
      self.text = Array(text)
      pos = begin
    }

    /// Returns the underlying string.
    public func getText() -> String { String(text) }
  }
}
