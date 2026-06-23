/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// The central interface for text-component models — mirrors
  /// `javax.swing.text.Document` from Java 1.2 / JFC 1.0.
  ///
  /// A `Document` stores the text content and fires `DocumentEvent`s to
  /// registered `DocumentListener`s whenever the content changes.
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// Document                   ← this protocol
  ///   └── StyledDocument       ← adds character/paragraph attributes
  ///         └── AbstractDocument (open class, partial impl)
  ///               ├── PlainDocument
  ///               └── DefaultStyledDocument
  /// ```
  ///
  /// ## Key properties
  ///
  /// | Key constant | Type | Meaning |
  /// |---|---|---|
  /// | `StreamDescriptionProperty` | `String` | Description of the stream used to init this doc |
  /// | `TitleProperty` | `String` | Title of the document |
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  public protocol Document: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Content access
    // -------------------------------------------------------------------------

    /// Returns the number of characters in this document.
    func getLength() -> Int

    /// Returns the text stored in `[offset, offset+length)`.
    ///
    /// - Throws: `BadLocationException` if the range is out of bounds.
    func getText(_ offset: Int, _ length: Int) throws -> String

    // -------------------------------------------------------------------------
    // MARK: Mutation
    // -------------------------------------------------------------------------

    /// Inserts `string` into the document at `offset`.
    ///
    /// - Throws: `BadLocationException` if `offset` is out of bounds.
    func insertString(_ offset: Int, _ string: String) throws

    /// Removes `length` characters starting at `offset`.
    ///
    /// - Throws: `BadLocationException` if the range is out of bounds.
    func remove(_ offset: Int, _ length: Int) throws

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// Returns the value stored under `key` in this document's property map,
    /// or `nil` if no value is associated with `key`.
    func getProperty(_ key: String) -> Any?

    /// Stores `value` under `key` in this document's property map.
    /// Pass `nil` to remove the entry.
    func putProperty(_ key: String, _ value: Any?)

    // -------------------------------------------------------------------------
    // MARK: Listener management
    // -------------------------------------------------------------------------

    /// Registers `l` to receive change notifications from this document.
    func addDocumentListener(_ l: javax.swing.event.DocumentListener)

    /// Removes a previously registered listener.
    func removeDocumentListener(_ l: javax.swing.event.DocumentListener)
  }
}

// -----------------------------------------------------------------------------
// MARK: Standard property key constants
// -----------------------------------------------------------------------------

extension javax.swing.text.Document {

  /// Property key for a description of the stream used to initialise this
  /// document (analogous to Java's `Document.StreamDescriptionProperty`).
  public static var StreamDescriptionProperty: String { "stream" }

  /// Property key for the document title
  /// (analogous to Java's `Document.TitleProperty`).
  public static var TitleProperty: String { "title" }
}
