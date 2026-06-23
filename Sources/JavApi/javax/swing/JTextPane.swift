/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A multi-line text component that supports styled (rich) text.
  ///
  /// `JTextPane` extends `JTextComponent` and uses a `StyledDocument`
  /// (by default a `DefaultStyledDocument`) as its model.  It provides
  /// high-level APIs for applying character and paragraph attributes to
  /// selected or specified ranges of text.
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// JComponent
  ///   └── JTextComponent
  ///         └── JTextPane      ← this class
  /// ```
  ///
  /// ## Example
  ///
  /// ```swift
  /// let pane = javax.swing.JTextPane()
  /// pane.setText("Hello, world!")
  ///
  /// // Make "Hello" bold and red
  /// let attrs = javax.swing.text.SimpleAttributeSet()
  /// javax.swing.text.StyleConstants.setBold(attrs, true)
  /// javax.swing.text.StyleConstants.setForeground(attrs, java.awt.Color.red)
  /// pane.setCharacterAttributes(attrs, replace: false)
  /// // (select range 0..<5 first via setSelectionStart/setSelectionEnd)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JTextPane: javax.swing.JEditorPane {

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates an empty `JTextPane` backed by a `DefaultStyledDocument`.
    public override init() {
      super.init()
      // Replace the EditorKit's plain document with a DefaultStyledDocument
      setDocument(javax.swing.text.DefaultStyledDocument())
      updateUI()
    }

    /// Creates a `JTextPane` backed by the supplied `StyledDocument`.
    public init(doc: javax.swing.text.StyledDocument) {
      super.init()
      setDocument(doc)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "TextPaneUI" }

    // -------------------------------------------------------------------------
    // MARK: Character attributes
    // -------------------------------------------------------------------------

    /// Applies `attrs` to the current selection (or insertion point if no
    /// selection).
    ///
    /// - Parameters:
    ///   - attrs:   Attributes to apply.
    ///   - replace: If `true`, existing attributes in the range are replaced.
    ///              If `false`, `attrs` is merged on top.
    public func setCharacterAttributes(
      _ attrs: javax.swing.text.AttributeSet,
      replace: Bool
    ) {
      guard let sd = getStyledDocument() else { return }
      let start  = getSelectionStart()
      let end    = getSelectionEnd()
      let length = end - start
      if length > 0 {
        sd.setCharacterAttributes(start, length, attrs, replace)
      }
      // Store as input attributes for future typing (simplified)
      _inputAttributes.addAttributes(attrs)
    }

    /// Applies `attrs` to an explicit character range.
    ///
    /// - Parameters:
    ///   - offset:  Start of the range.
    ///   - length:  Length of the range.
    ///   - attrs:   Attributes to apply.
    ///   - replace: Replace vs. merge.
    public func setCharacterAttributes(
      _ offset: Int,
      _ length: Int,
      _ attrs: javax.swing.text.AttributeSet,
      replace: Bool
    ) {
      getStyledDocument()?.setCharacterAttributes(offset, length, attrs, replace)
    }

    /// Returns the character attributes at `position`.
    public func getCharacterAttributes(at position: Int) -> javax.swing.text.AttributeSet? {
      return getStyledDocument()?.getCharacterElement(position)
    }

    // -------------------------------------------------------------------------
    // MARK: Paragraph attributes
    // -------------------------------------------------------------------------

    /// Applies `attrs` to the paragraph(s) overlapping the current selection.
    public func setParagraphAttributes(
      _ attrs: javax.swing.text.AttributeSet,
      replace: Bool
    ) {
      guard let sd = getStyledDocument() else { return }
      let start  = getSelectionStart()
      let length = max(1, getSelectionEnd() - start)
      sd.setParagraphAttributes(start, length, attrs, replace)
    }

    /// Returns the paragraph attributes at `position`.
    public func getParagraphAttributes(at position: Int) -> javax.swing.text.AttributeSet? {
      return getStyledDocument()?.getParagraphElement(position)
    }

    // -------------------------------------------------------------------------
    // MARK: Caret movement — update input attributes
    // -------------------------------------------------------------------------

    /// Overrides caret placement so that `_inputAttributes` always reflects
    /// the character style at the new caret position.
    ///
    /// This mirrors Java Swing behaviour: when the caret moves into a run of
    /// large blue text, the next character typed inherits that style.
    override public func setCaretPosition(_ pos: Int) {
      super.setCaretPosition(pos)
      _syncInputAttributes(at: pos)
    }

    /// Same as `setCaretPosition` but extends the selection anchor.
    override public func moveCaretPosition(_ pos: Int) {
      super.moveCaretPosition(pos)
      // Do NOT update input attrs on drag/extend — only the insert point matters.
    }

    // -------------------------------------------------------------------------
    // MARK: Input attributes
    // -------------------------------------------------------------------------

    /// The attributes that will be applied to newly typed characters.
    private var _inputAttributes = javax.swing.text.SimpleAttributeSet()

    /// Returns the current input attributes (the style for the next typed char).
    public func getInputAttributes() -> javax.swing.text.SimpleAttributeSet {
      return _inputAttributes
    }

    /// Copies the character attributes at `pos` into `_inputAttributes`.
    private func _syncInputAttributes(at pos: Int) {
      guard let sd = getStyledDocument() else { return }
      // When the caret is between two runs, use the attributes of the character
      // *before* the caret (Java Swing convention).  At position 0 use pos 0.
      let lookupPos = max(0, min(pos > 0 ? pos - 1 : 0, sd.getLength() - 1))
      guard lookupPos >= 0, let attrs = sd.getCharacterElement(lookupPos) else { return }
      _inputAttributes = javax.swing.text.SimpleAttributeSet(copying: attrs)
    }

    // -------------------------------------------------------------------------
    // MARK: Content type (simplified)
    // -------------------------------------------------------------------------

    private var _contentType: String = "text/plain"

    /// The MIME content type of this pane (e.g. `"text/plain"`, `"text/html"`).
    /// Setting this does not change rendering in the current SwiftUI backend.
    public override func getContentType() -> String { _contentType }
    public override func setContentType(_ type: String) { _contentType = type }
  }
}
