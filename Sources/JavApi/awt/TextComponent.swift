/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Base class for text-bearing components (`TextField`, `TextArea`).
  /// Mirrors `java.awt.TextComponent`.
  open class TextComponent: Component {

    public internal(set) var text: String = ""
    public var editable: Bool = true

    private var textListeners: [java.awt.event.TextListener] = []

    // -------------------------------------------------------------------------
    // MARK: Caret visibility — simply follows focus, no blinking
    // -------------------------------------------------------------------------

    /// True when this component has keyboard focus (caret is always visible
    /// while focused; never visible when unfocused).
    public var caretVisible: Bool = false

    // -------------------------------------------------------------------------
    // MARK: Selection / caret model  (shared by TextField and TextArea)
    // -------------------------------------------------------------------------

    /// Current insertion-point position (0 … text.count).
    public var caretPosition: Int = 0

    /// Fixed end of the selection range (equals caretPosition when no selection).
    /// Internal — use setCaretPosition / extendSelection / selectAll to modify.
    var selectionAnchor: Int = 0

    /// Normalised start of the selection (always ≤ selectionEnd).
    public var selectionStart: Int { min(selectionAnchor, caretPosition) }
    /// Normalised end of the selection (always ≥ selectionStart).
    public var selectionEnd:   Int { max(selectionAnchor, caretPosition) }
    /// True when a non-empty range is selected.
    public var hasSelection:  Bool { selectionAnchor != caretPosition }

    /// Move the caret and collapse the selection to `pos`.
    public func setCaretPosition(_ pos: Int) {
      let c       = max(0, min(pos, text.count))
      caretPosition   = c
      selectionAnchor = c
    }

    /// Extend the moving end of the selection to `pos` (anchor stays fixed).
    func extendSelection(to pos: Int) {
      caretPosition = max(0, min(pos, text.count))
    }

    /// Select the entire text.
    public func selectAll() {
      selectionAnchor = 0
      caretPosition   = text.count
    }

    // -------------------------------------------------------------------------
    // MARK: Text access
    // -------------------------------------------------------------------------

    public func getText() -> String { text }

    /// Set text and clamp caret/selection indices into the new range.
    public func setText(_ t: String) {
      text = t
      let len         = t.count
      caretPosition   = min(caretPosition,   len)
      selectionAnchor = min(selectionAnchor, len)
      fireTextEvent()
    }

    public func isEditable() -> Bool   { editable }
    public func setEditable(_ e: Bool) { editable = e }

    // -------------------------------------------------------------------------
    // MARK: Text listeners
    // -------------------------------------------------------------------------

    public func addTextListener(_ l: java.awt.event.TextListener) {
      textListeners.append(l)
    }
    public func removeTextListener(_ l: java.awt.event.TextListener) {
      textListeners.removeAll { $0 === l }
    }

    // -------------------------------------------------------------------------
    // MARK: Focus — show/hide caret
    // -------------------------------------------------------------------------

    open override func processFocusEvent(_ e: java.awt.event.FocusEvent) {
      super.processFocusEvent(e)
      caretVisible = (e.getID() == java.awt.event.FocusEvent.FOCUS_GAINED)
    }

    internal func fireTextEvent() {
      let e = java.awt.event.TextEvent(
        self,
        java.awt.event.TextEvent.TEXT_VALUE_CHANGED)
      textListeners.forEach { $0.textValueChanged(e) }
    }
  }
}
