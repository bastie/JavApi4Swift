/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A gap-buffer implementation of `AbstractDocument.Content` — mirrors
  /// `javax.swing.text.GapContent` from Java 1.2 / JFC 1.0.
  ///
  /// `GapContent` is the default `Content` implementation used by
  /// `DefaultStyledDocument`.  It stores characters in a contiguous array
  /// with a moveable gap so that insertions near the caret are O(1).
  ///
  /// In JavApi⁴Swift this is a simplified implementation backed by a Swift
  /// `String` (no actual gap buffer array).  The public API is fully
  /// source-compatible with Java; only the internal performance model differs.
  ///
  /// ## Usage (Java-compatible)
  ///
  /// ```swift
  /// let content = javax.swing.text.GapContent()
  /// try content.insertString(0, "Hello")
  /// let text = try content.getString(0, content.length())
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class GapContent: javax.swing.text.AbstractDocumentContent {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    /// Internal character buffer.  Swing documents always end with '\n',
    /// which we maintain implicitly via the trailing sentinel.
    private var _buf: [Character]

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a `GapContent` with an initial buffer capacity.
    /// (In Java the capacity parameter hints the gap size; here it is ignored.)
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
          "GapContent.getString: where=\(where_) len=\(len) length=\(_buf.count)", where_)
      }
      return String(_buf[where_ ..< where_ + len])
    }

    open func insertString(_ where_: Int, _ str: String) throws {
      // Allow insert at any position except past the trailing '\n'
      guard where_ >= 0, where_ < _buf.count else {
        throw javax.swing.text.BadLocationException(
          "GapContent.insertString: where=\(where_) length=\(_buf.count)", where_)
      }
      _buf.insert(contentsOf: str, at: _buf.index(_buf.startIndex, offsetBy: where_))
    }

    open func remove(_ where_: Int, _ nitems: Int) throws {
      guard where_ >= 0, nitems >= 0, where_ + nitems < _buf.count else {
        // Must keep the trailing '\n'
        throw javax.swing.text.BadLocationException(
          "GapContent.remove: where=\(where_) nitems=\(nitems) length=\(_buf.count)", where_)
      }
      let start = _buf.index(_buf.startIndex, offsetBy: where_)
      let end   = _buf.index(start, offsetBy: nitems)
      _buf.removeSubrange(start ..< end)
    }

    open func createPosition(_ offset: Int) throws -> javax.swing.text.Position {
      guard offset >= 0, offset <= _buf.count else {
        throw javax.swing.text.BadLocationException(
          "GapContent.createPosition: offset=\(offset) length=\(_buf.count)", offset)
      }
      return _SimplePosition(offset: offset)
    }
  }
}

// -----------------------------------------------------------------------------
// MARK: Internal position helper (shared with StringContent)
// -----------------------------------------------------------------------------

/// Minimal fixed-offset `Position` — does not track mutations.
/// Sufficient for source-level API compatibility.
@MainActor
internal final class _SimplePosition: javax.swing.text.Position {
  private let _offset: Int
  init(offset: Int) { _offset = offset }
  func getOffset() -> Int { _offset }
}
