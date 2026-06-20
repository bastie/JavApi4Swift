/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// The storage interface for an `AbstractDocument` — mirrors
  /// `AbstractDocument.Content` from Java 1.2 / JFC 1.0.
  ///
  /// In Java this is a nested interface inside `AbstractDocument`.
  /// Swift does not allow nested protocols, so it lives here as a top-level
  /// type in `javax.swing.text`.  A `typealias` in `AbstractDocument` restores
  /// the Java-style dot notation: `AbstractDocument.Content`.
  ///
  /// Implementors: `GapContent` (gap-buffer, default for `DefaultStyledDocument`)
  /// and `StringContent` (simple `String`, default for `PlainDocument`).
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  public protocol AbstractDocumentContent: AnyObject {

    /// Returns the length of the content in characters (excluding the
    /// mandatory trailing newline that Swing documents always maintain).
    func length() -> Int

    /// Returns the text in `[where, where+len)`.
    ///
    /// - Throws: `BadLocationException` if the range is out of bounds.
    func getString(_ where_: Int, _ len: Int) throws -> String

    /// Inserts `str` at `where`.
    ///
    /// - Throws: `BadLocationException` if `where` is out of bounds.
    func insertString(_ where_: Int, _ str: String) throws

    /// Removes `nitems` characters starting at `where`.
    ///
    /// - Throws: `BadLocationException` if the range is out of bounds.
    func remove(_ where_: Int, _ nitems: Int) throws

    /// Creates a `Position` that tracks the character at `offset`.
    ///
    /// - Throws: `BadLocationException` if `offset` is out of bounds.
    func createPosition(_ offset: Int) throws -> javax.swing.text.Position
  }
}

// -----------------------------------------------------------------------------
// MARK: AbstractDocument typealias — restores Java dot-notation
// -----------------------------------------------------------------------------

extension javax.swing.text.AbstractDocument {
  /// Java-compatible alias: `AbstractDocument.Content` maps to the top-level
  /// `javax.swing.text.AbstractDocumentContent` protocol.
  public typealias Content = javax.swing.text.AbstractDocumentContent
}
