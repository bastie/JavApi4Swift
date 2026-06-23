/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  /// Defines a protocol for bidirectional iteration over text.
  ///
  /// Mirrors `java.text.CharacterIterator`.
  ///
  /// The iterator provides a cursor that moves from `getBeginIndex()` to
  /// `getEndIndex() - 1` (inclusive). When the cursor moves past either end,
  /// `current()` returns ``CharacterIterator/DONE``.
  ///
  /// - Since: Java 1.1
  public protocol CharacterIterator : AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Sentinel
    // -------------------------------------------------------------------------

    /// The sentinel value returned by `current()` and `next()` when the
    /// iterator has reached the end of the text.
    ///
    /// In Java this is `'￿'` (U+FFFF, "not a character").
    // Note: `DONE` is a static constant on the protocol; access via a
    // concrete conforming type (e.g. StringCharacterIterator.DONE).

    // -------------------------------------------------------------------------
    // MARK: Navigation
    // -------------------------------------------------------------------------

    /// Sets the position to `getBeginIndex()` and returns the character at
    /// that position, or ``DONE`` if the text is empty.
    func first() -> Character

    /// Sets the position to `getEndIndex() - 1` and returns the character at
    /// that position, or ``DONE`` if the text is empty.
    func last() -> Character

    /// Returns the character at the current position.
    ///
    /// Returns ``DONE`` if the current position is equal to `getEndIndex()`.
    func current() -> Character

    /// Increments the iterator's index by one and returns the character at
    /// the new position, or ``DONE`` if the new position is `getEndIndex()`.
    func next() -> Character

    /// Decrements the iterator's index by one and returns the character at
    /// the new position, or ``DONE`` if the new position is before
    /// `getBeginIndex()`.
    func previous() -> Character

    /// Sets the position to `position` and returns the character at that
    /// position.
    ///
    /// - Parameter position: Must satisfy `getBeginIndex() <= position <= getEndIndex()`.
    /// - Returns: The character at `position`, or ``DONE`` if
    ///   `position == getEndIndex()`.
    func setIndex(_ position: Int) -> Character

    // -------------------------------------------------------------------------
    // MARK: Boundary / index access
    // -------------------------------------------------------------------------

    /// Returns the start index of the text.
    func getBeginIndex() -> Int

    /// Returns the end index (exclusive) of the text.
    func getEndIndex() -> Int

    /// Returns the current index.
    func getIndex() -> Int

    // -------------------------------------------------------------------------
    // MARK: Cloning
    // -------------------------------------------------------------------------

    /// Creates a copy of this iterator.
    func clone() -> any CharacterIterator
  }
}

extension java.text.CharacterIterator {

  /// The sentinel `Character` returned when iteration goes past the end of text.
  ///
  /// Value: U+FFFF — "not a character" (same as Java `'￿'`).
  public static var DONE: Character { "\u{FFFF}" }
}
