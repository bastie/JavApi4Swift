/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Abstract base class for all Swing text components.
  ///
  /// `JTextComponent` sits between `JComponent` and the concrete text
  /// components (`JTextField`, `JPasswordField`, `JTextArea`, `JEditorPane`).
  /// It provides the shared infrastructure that every text widget needs:
  ///
  /// - A **document model** (`Document`) that stores the text content.
  /// - **`getText()` / `setText()`** convenience accessors.
  /// - **Caret position** and **selection** (selectionStart / selectionEnd).
  /// - **Editable** flag.
  /// - **`CaretListener`** and **`DocumentListener`** management
  ///   (listeners forwarded from the document model).
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// JComponent
  ///   └── JTextComponent          ← this class
  ///         ├── JTextField
  ///         │     └── JPasswordField
  ///         ├── JTextArea
  ///         └── JEditorPane
  ///               └── JTextPane
  /// ```
  ///
  /// ## Example
  ///
  /// ```swift
  /// // Subclasses are usually instantiated, not JTextComponent directly.
  /// let field = javax.swing.JTextField("Hello")
  /// field.setEditable(false)
  /// let text = field.getText()   // "Hello"
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JTextComponent: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Document model
    // -------------------------------------------------------------------------

    private var _document: javax.swing.text.Document

    /// Creates a `JTextComponent` backed by a `PlainDocument`.
    public override init() {
      self._document = javax.swing.text.PlainDocument()
      super.init()
    }

    /// Creates a `JTextComponent` backed by the given document.
    public init(document: javax.swing.text.Document) {
      self._document = document
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Document access
    // -------------------------------------------------------------------------

    /// Returns the text model used by this component.
    public func getDocument() -> javax.swing.text.Document { _document }

    /// Replaces the text model.
    ///
    /// Replaces the text model. Document listeners registered with the previous
    /// document are **not** automatically transferred.
    public func setDocument(_ doc: javax.swing.text.Document) {
      _document = doc
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Text access
    // -------------------------------------------------------------------------

    /// Returns the entire text content of the document.
    public func getText() -> String {
      let len = _document.getLength()
      guard len > 0 else { return "" }
      return (try? _document.getText(0, len)) ?? ""
    }

    /// Returns a substring of the document.
    ///
    /// - Parameters:
    ///   - offset: Zero-based start position.
    ///   - length: Number of characters to return.
    /// - Throws: `BadLocationException` if the range is invalid.
    public func getText(_ offset: Int, _ length: Int) throws -> String {
      return try _document.getText(offset, length)
    }

    /// Replaces the entire document content with `text`.
    ///
    /// Removes all existing content and inserts the new text at offset 0.
    public func setText(_ text: String) {
      let len = _document.getLength()
      do {
        if len > 0 {
          try _document.remove(0, len)
        }
        if !text.isEmpty {
          try _document.insertString(0, text)
        }
        setCaretPosition(0)
      } catch {
        // BadLocationException should not occur here — lengths are correct.
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Editable
    // -------------------------------------------------------------------------

    private var _editable: Bool = true

    /// Whether the user can edit the component's text.
    public func isEditable() -> Bool { _editable }

    /// Sets whether the user can edit the text.
    public func setEditable(_ editable: Bool) { _editable = editable }

    // -------------------------------------------------------------------------
    // MARK: Caret position
    // -------------------------------------------------------------------------

    private var _caretPosition: Int = 0

    /// The current caret position (insertion point).
    public func getCaretPosition() -> Int { _caretPosition }

    /// Moves the caret to `position`.
    ///
    /// Clamps the value to `[0, document.length]` and clears any selection.
    public func setCaretPosition(_ position: Int) {
      let clamped = max(0, min(position, _document.getLength()))
      _caretPosition = clamped
      _selectionStart = clamped
      _selectionEnd   = clamped
      fireCaretUpdate()
    }

    /// Moves the caret to `position` while extending the current selection.
    public func moveCaretPosition(_ position: Int) {
      let clamped = max(0, min(position, _document.getLength()))
      let anchor  = _selectionStart == _caretPosition ? _selectionEnd : _selectionStart
      _caretPosition  = clamped
      _selectionStart = min(anchor, clamped)
      _selectionEnd   = max(anchor, clamped)
      fireCaretUpdate()
    }

    // -------------------------------------------------------------------------
    // MARK: Selection
    // -------------------------------------------------------------------------

    private var _selectionStart: Int = 0
    private var _selectionEnd:   Int = 0

    /// Start of the selected region (inclusive), or caret position if no selection.
    public func getSelectionStart() -> Int { _selectionStart }

    /// End of the selected region (exclusive), or caret position if no selection.
    public func getSelectionEnd() -> Int { _selectionEnd }

    /// Selects the text between `selectionStart` and `selectionEnd`.
    public func select(_ selectionStart: Int, _ selectionEnd: Int) {
      let len   = _document.getLength()
      let start = max(0, min(selectionStart, len))
      let end   = max(start, min(selectionEnd, len))
      _selectionStart = start
      _selectionEnd   = end
      _caretPosition  = end
      fireCaretUpdate()
    }

    /// Selects all text in the component.
    public func selectAll() {
      select(0, _document.getLength())
    }

    /// Returns the currently selected text, or an empty string if nothing is selected.
    public func getSelectedText() -> String {
      let len = _selectionEnd - _selectionStart
      guard len > 0 else { return "" }
      return (try? _document.getText(_selectionStart, len)) ?? ""
    }

    // -------------------------------------------------------------------------
    // MARK: Clipboard operations (stubs)
    // -------------------------------------------------------------------------

    /// Copies the selected text to the system clipboard.
    open func copy() { /* platform-specific — override in subclass or UI delegate */ }

    /// Cuts the selected text and places it on the system clipboard.
    open func cut()  { /* platform-specific — override in subclass or UI delegate */ }

    /// Pastes text from the system clipboard at the caret position.
    open func paste() { /* platform-specific — override in subclass or UI delegate */ }

    // -------------------------------------------------------------------------
    // MARK: Caret listeners
    // -------------------------------------------------------------------------

    private var caretListeners: [javax.swing.event.CaretListener] = []

    /// Adds a listener that is notified when the caret position changes.
    public func addCaretListener(_ l: javax.swing.event.CaretListener) {
      caretListeners.append(l)
    }

    /// Removes a previously registered caret listener.
    public func removeCaretListener(_ l: javax.swing.event.CaretListener) {
      caretListeners.removeAll { $0 === (l as AnyObject) }
    }

    /// Returns all currently registered caret listeners.
    public func getCaretListeners() -> [javax.swing.event.CaretListener] {
      caretListeners
    }

    private func fireCaretUpdate() {
      repaint()   // caret / selection rendering must be refreshed
      guard !caretListeners.isEmpty else { return }
      let e = _CaretEventImpl(dot: _caretPosition, mark: _selectionStart, source: self)
      for l in caretListeners { l.caretUpdate(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Document listeners (convenience forwarding)
    // -------------------------------------------------------------------------

    /// Adds a `DocumentListener` to the underlying document model.
    public func addDocumentListener(_ l: javax.swing.event.DocumentListener) {
      _document.addDocumentListener(l)
    }

    /// Removes a `DocumentListener` from the underlying document model.
    public func removeDocumentListener(_ l: javax.swing.event.DocumentListener) {
      _document.removeDocumentListener(l)
    }

    // -------------------------------------------------------------------------
    // MARK: Focus — repaint so caret / focus ring appears / disappears
    // -------------------------------------------------------------------------

    override open func processFocusEvent(_ e: java.awt.event.FocusEvent) {
      super.processFocusEvent(e)
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate ID (overridden by subclasses)
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "TextComponentUI" }
  }
}

// -----------------------------------------------------------------------------
// MARK: Internal CaretEvent implementation
// -----------------------------------------------------------------------------

/// Private concrete `CaretEvent` fired by `JTextComponent`.
@MainActor
private final class _CaretEventImpl: javax.swing.event.CaretEvent {

  let dot:    Int
  let mark:   Int
  let source: AnyObject

  init(dot: Int, mark: Int, source: AnyObject) {
    self.dot    = dot
    self.mark   = mark
    self.source = source
  }
}
