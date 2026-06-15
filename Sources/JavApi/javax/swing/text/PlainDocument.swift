/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A plain-text implementation of `Document`.
  ///
  /// `PlainDocument` stores its content as a single Swift `String` and is
  /// the default model used by `JTextField` and `JTextArea`.
  ///
  /// All mutations fire the appropriate `DocumentEvent` to registered listeners:
  /// - `insertString(_:_:)` → `fireInsertUpdate`
  /// - `remove(offset:length:)` → `fireRemoveUpdate`
  ///
  /// ## Example
  ///
  /// ```swift
  /// let doc = javax.swing.text.PlainDocument()
  /// try doc.insertString(0, "Hello")
  /// try doc.insertString(5, ", world!")
  /// try doc.getText(offset: 0, length: doc.getLength()) // "Hello, world!"
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class PlainDocument: javax.swing.text.AbstractDocument {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var content: String = ""

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates an empty `PlainDocument`.
    public override init() {
      super.init()
    }

    /// Creates a `PlainDocument` pre-populated with `text`.
    public init(text: String) {
      super.init()
      content = text
    }

    // -------------------------------------------------------------------------
    // MARK: Document — length & text access
    // -------------------------------------------------------------------------

    override open func getLength() -> Int { content.count }

    override open func getText(_ offset: Int, _ length: Int) throws -> String {
      guard offset >= 0, length >= 0, offset + length <= content.count else {
        throw javax.swing.text.BadLocationException(
          "getText: offset=\(offset) length=\(length) docLength=\(content.count)",
          offset)
      }
      let start = content.index(content.startIndex, offsetBy: offset)
      let end   = content.index(start, offsetBy: length)
      return String(content[start..<end])
    }

    // -------------------------------------------------------------------------
    // MARK: Document — mutation
    // -------------------------------------------------------------------------

    override open func insertString(_ offset: Int, _ string: String) throws {
      guard offset >= 0, offset <= content.count else {
        throw javax.swing.text.BadLocationException(
          "insertString: offset=\(offset) docLength=\(content.count)", offset)
      }
      let idx = content.index(content.startIndex, offsetBy: offset)
      content.insert(contentsOf: string, at: idx)
      fireInsertUpdate(offset: offset, length: string.count)  // internal helper — labels OK
    }

    override open func remove(_ offset: Int, _ length: Int) throws {
      guard offset >= 0, length >= 0, offset + length <= content.count else {
        throw javax.swing.text.BadLocationException(
          "remove: offset=\(offset) length=\(length) docLength=\(content.count)",
          offset)
      }
      guard length > 0 else { return }
      let start = content.index(content.startIndex, offsetBy: offset)
      let end   = content.index(start, offsetBy: length)
      content.removeSubrange(start..<end)
      fireRemoveUpdate(offset: offset, length: length)
    }

    // -------------------------------------------------------------------------
    // MARK: Convenience
    // -------------------------------------------------------------------------

    /// Returns the entire document content as a `String`.
    open func getText() -> String { content }
  }
}
