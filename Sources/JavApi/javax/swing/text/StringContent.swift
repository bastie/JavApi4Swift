/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A simple `String`-backed implementation of `AbstractDocument.Content` —
  /// mirrors `javax.swing.text.StringContent` from Java 1.2 / JFC 1.0.
  ///
  /// `StringContent` is the default `Content` implementation used by
  /// `PlainDocument`.  It is simpler (and slower for large documents) than
  /// `GapContent` because every insertion copies the entire string.
  ///
  /// In JavApi⁴Swift both `StringContent` and `GapContent` are backed by a
  /// `[Character]` array — the performance difference is academic at this
  /// implementation level.  The public API is fully source-compatible with Java.
  ///
  /// ## Usage (Java-compatible)
  ///
  /// ```swift
  /// let content = javax.swing.text.StringContent()
  /// try content.insertString(0, "Hello")
  /// let text = try content.getString(0, content.length())
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class StringContent: javax.swing.text.AbstractDocumentContent {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var _buf: [Character]

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a `StringContent` with an optional initial capacity hint
    /// (ignored in this implementation).
    public init(_ initialLength: Int = 10) {
      // Swing documents always contain at least the mandatory trailing '\n'
      _buf = ["\n"]
    }

    // -------------------------------------------------------------------------
    // MARK: AbstractDocumentContent
    // -------------------------------------------------------------------------

    /// Returns the number of characters, *including* the mandatory trailing '\n'.
    open func length() -> Int { _buf.count }

    open func getString(_ where_: Int, _ len: Int) throws -> String {
      guard where_ >= 0, len >= 0, where_ + len <= _buf.count else {
        throw javax.swing.text.BadLocationException(
          "StringContent.getString: where=\(where_) len=\(len) length=\(_buf.count)", where_)
      }
      return String(_buf[where_ ..< where_ + len])
    }

    open func insertString(_ where_: Int, _ str: String) throws {
      guard where_ >= 0, where_ < _buf.count else {
        throw javax.swing.text.BadLocationException(
          "StringContent.insertString: where=\(where_) length=\(_buf.count)", where_)
      }
      _buf.insert(contentsOf: str, at: _buf.index(_buf.startIndex, offsetBy: where_))
    }

    open func remove(_ where_: Int, _ nitems: Int) throws {
      guard where_ >= 0, nitems >= 0, where_ + nitems < _buf.count else {
        throw javax.swing.text.BadLocationException(
          "StringContent.remove: where=\(where_) nitems=\(nitems) length=\(_buf.count)", where_)
      }
      let start = _buf.index(_buf.startIndex, offsetBy: where_)
      let end   = _buf.index(start, offsetBy: nitems)
      _buf.removeSubrange(start ..< end)
    }

    open func createPosition(_ offset: Int) throws -> javax.swing.text.Position {
      guard offset >= 0, offset <= _buf.count else {
        throw javax.swing.text.BadLocationException(
          "StringContent.createPosition: offset=\(offset) length=\(_buf.count)", offset)
      }
      return _SimplePosition(offset: offset)
    }
  }
}
