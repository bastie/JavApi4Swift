/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// - NOTE: file is named "TextDocument" instead of "Document" because Swift compiler did not accept same filenames (directory is not important here). So filename is changed but type name is correct.

extension javax.swing.text {

  /// The model for Swing text components (`JTextField`, `JTextArea`, etc.).
  ///
  /// A `Document` stores text as a character sequence with an optional set
  /// of attributes per run.  The content is accessed via `getText(offset:length:)`
  /// and modified with `insertString(_:offset:)` and `remove(offset:length:)`.
  ///
  /// Every mutation fires a `DocumentEvent` to registered `DocumentListener`s.
  ///
  /// ## Key property
  ///
  /// The `"content"` key stored in the document's property map is often used
  /// to hold the raw string; use `getProperty(_:)` / `putProperty(_:_:)`.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol Document: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Length
    // -------------------------------------------------------------------------

    /// The number of characters currently in the document.
    func getLength() -> Int

    // -------------------------------------------------------------------------
    // MARK: Text access
    // -------------------------------------------------------------------------

    /// Returns the text in the range `[offset, offset+length)`.
    ///
    /// - Throws: If `offset` or `length` is out of range.
    func getText(offset: Int, length: Int) throws -> String

    // -------------------------------------------------------------------------
    // MARK: Mutation
    // -------------------------------------------------------------------------

    /// Inserts `string` at `offset`.
    ///
    /// - Throws: If `offset` is out of range.
    func insertString(_ string: String, offset: Int) throws

    /// Removes `length` characters starting at `offset`.
    ///
    /// - Throws: If the range is out of range.
    func remove(offset: Int, length: Int) throws

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// Returns the value associated with `key` in the document's property map.
    func getProperty(_ key: String) -> Any?

    /// Stores `value` under `key` in the document's property map.
    func putProperty(_ key: String, _ value: Any?)

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    func addDocumentListener(_ l: javax.swing.event.DocumentListener)
    func removeDocumentListener(_ l: javax.swing.event.DocumentListener)
  }
}
