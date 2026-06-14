/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Abstract base class for `Document` implementations.
  ///
  /// `AbstractDocument` provides listener management, property storage,
  /// and the `fireInsertUpdate` / `fireRemoveUpdate` / `fireChangedUpdate`
  /// fire helpers that concrete subclasses call after mutating their content.
  ///
  /// Subclasses must implement:
  /// - `getLength() -> Int`
  /// - `getText(offset:length:) throws -> String`
  /// - `insertString(_:offset:) throws`
  /// - `remove(offset:length:) throws`
  ///
  /// - Since: Java 1.2
  @MainActor
  open class AbstractDocument: javax.swing.text.Document {

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var documentListeners: [javax.swing.event.DocumentListener] = []

    // -------------------------------------------------------------------------
    // MARK: Properties map
    // -------------------------------------------------------------------------

    private var properties: [String: Any] = [:]

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Document — to be overridden
    // -------------------------------------------------------------------------

    open func getLength() -> Int {
      fatalError("\(type(of: self)).getLength() must be overridden")
    }

    open func getText(offset: Int, length: Int) throws -> String {
      fatalError("\(type(of: self)).getText(offset:length:) must be overridden")
    }

    open func insertString(_ string: String, offset: Int) throws {
      fatalError("\(type(of: self)).insertString(_:offset:) must be overridden")
    }

    open func remove(offset: Int, length: Int) throws {
      fatalError("\(type(of: self)).remove(offset:length:) must be overridden")
    }

    // -------------------------------------------------------------------------
    // MARK: Document — property map
    // -------------------------------------------------------------------------

    open func getProperty(_ key: String) -> Any? { properties[key] }

    open func putProperty(_ key: String, _ value: Any?) {
      properties[key] = value
    }

    // -------------------------------------------------------------------------
    // MARK: Document — listener management
    // -------------------------------------------------------------------------

    open func addDocumentListener(_ l: javax.swing.event.DocumentListener) {
      documentListeners.append(l)
    }

    open func removeDocumentListener(_ l: javax.swing.event.DocumentListener) {
      documentListeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Fire helpers (called by subclasses)
    // -------------------------------------------------------------------------

    /// Notifies listeners that text was inserted.
    open func fireInsertUpdate(offset: Int, length: Int) {
      guard !documentListeners.isEmpty else { return }
      let e = _DocumentEventImpl(document: self,
                                 type: .INSERT,
                                 offset: offset,
                                 length: length)
      for l in documentListeners { l.insertUpdate(e) }
    }

    /// Notifies listeners that text was removed.
    open func fireRemoveUpdate(offset: Int, length: Int) {
      guard !documentListeners.isEmpty else { return }
      let e = _DocumentEventImpl(document: self,
                                 type: .REMOVE,
                                 offset: offset,
                                 length: length)
      for l in documentListeners { l.removeUpdate(e) }
    }

    /// Notifies listeners that attributes changed.
    open func fireChangedUpdate(offset: Int, length: Int) {
      guard !documentListeners.isEmpty else { return }
      let e = _DocumentEventImpl(document: self,
                                 type: .CHANGE,
                                 offset: offset,
                                 length: length)
      for l in documentListeners { l.changedUpdate(e) }
    }
  }
}

// -----------------------------------------------------------------------------
// MARK: Internal DocumentEvent implementation
// -----------------------------------------------------------------------------

/// Private concrete `DocumentEvent` used by `AbstractDocument`'s fire helpers.
@MainActor
private final class _DocumentEventImpl: javax.swing.event.DocumentEvent {

  let type:     javax.swing.event.DocumentEvent.EventType
  let offset:   Int
  let length:   Int
  let document: javax.swing.text.Document

  init(document: javax.swing.text.Document,
       type:     javax.swing.event.DocumentEvent.EventType,
       offset:   Int,
       length:   Int) {
    self.document = document
    self.type     = type
    self.offset   = offset
    self.length   = length
  }
}
