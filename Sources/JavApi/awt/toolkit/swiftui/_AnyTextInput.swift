/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)

/// Internal bridge protocol used by `_SwiftUIFocusManager` and
/// `_SwiftUINativeCanvas` to handle both AWT (`java.awt.TextComponent`)
/// and Swing (`javax.swing.text.JTextComponent`) text-input components
/// through a single code path.
///
/// Conformances are added via `extension` on each concrete hierarchy —
/// no changes to the original class files are needed.
@MainActor
protocol _AnyTextInput: AnyObject {

  // -------------------------------------------------------------------------
  // MARK: Text content
  // -------------------------------------------------------------------------

  func getText() -> String
  func setText(_ t: String)

  // -------------------------------------------------------------------------
  // MARK: Editable flag
  // -------------------------------------------------------------------------

  func isEditable() -> Bool

  // -------------------------------------------------------------------------
  // MARK: Caret & selection
  // -------------------------------------------------------------------------

  var _ti_caretPosition: Int { get }
  func setCaretPosition(_ pos: Int)
  func extendSelection(to pos: Int)
  func selectAll()

  var _ti_selectionStart: Int { get }
  var _ti_selectionEnd:   Int { get }
  var _ti_hasSelection:   Bool { get }

  // -------------------------------------------------------------------------
  // MARK: Optional multiline support
  // -------------------------------------------------------------------------

  /// Scroll so that the caret line is visible.  No-op for single-line inputs.
  func _ti_ensureCaretVisible()

  /// Move caret up or down one line.  No-op for single-line inputs.
  func _ti_moveCaretToAdjacentLine(up: Bool, extending: Bool)

  /// Move caret to start or end of current line.
  func _ti_moveCaretToLineEdge(end: Bool, extending: Bool)

  // -------------------------------------------------------------------------
  // MARK: Action (Return key)
  // -------------------------------------------------------------------------

  /// Fire the "action" for this component:
  /// - TextField / JTextField: fire ActionEvent to ActionListeners
  /// - TextArea / JTextArea: insert newline
  func _ti_handleEnter()
}

// =============================================================================
// MARK: - AWT conformances
// =============================================================================

extension java.awt.TextComponent: _AnyTextInput {
  var _ti_caretPosition: Int  { caretPosition }
  var _ti_selectionStart: Int { selectionStart }
  var _ti_selectionEnd:   Int { selectionEnd   }
  var _ti_hasSelection:   Bool { hasSelection  }

  func _ti_ensureCaretVisible() {
    (self as? java.awt.TextArea)?.ensureCaretVisible()
  }

  func _ti_moveCaretToAdjacentLine(up: Bool, extending: Bool) {
    (self as? java.awt.TextArea)?._moveCaretToAdjacentLine(up: up, extending: extending)
  }

  func _ti_moveCaretToLineEdge(end: Bool, extending: Bool) {
    (self as? java.awt.TextArea)?._moveCaretToLineEdge(end: end, extending: extending)
      ?? _ti_fallbackLineEdge(end: end, extending: extending)
  }

  func _ti_handleEnter() {
    if let tf = self as? java.awt.TextField {
      tf.doAction()
    } else if let ta = self as? java.awt.TextArea, ta.isEditable() {
      var chars = Array(getText())
      let pos   = min(caretPosition, chars.count)
      chars.insert("\n", at: pos)
      setText(String(chars))
      setCaretPosition(pos + 1)
    }
  }
}

// =============================================================================
// MARK: - Swing conformances
// =============================================================================

extension javax.swing.text.JTextComponent: _AnyTextInput {
  var _ti_caretPosition: Int  { getCaretPosition()   }
  var _ti_selectionStart: Int { getSelectionStart()  }
  var _ti_selectionEnd:   Int { getSelectionEnd()    }
  var _ti_hasSelection:   Bool { getSelectionStart() != getSelectionEnd() }

  func extendSelection(to pos: Int) {
    moveCaretPosition(pos)
  }

  func _ti_ensureCaretVisible() {
    // JScrollPane scrolling not yet implemented — no-op for now
  }

  func _ti_moveCaretToAdjacentLine(up: Bool, extending: Bool) {
    // JTextArea line navigation
    guard let area = self as? javax.swing.JTextArea else {
      // Single-line: up → start, down → end
      let target = up ? 0 : getText().count
      if extending { moveCaretPosition(target) } else { setCaretPosition(target) }
      return
    }
    let content = area.getText()
    let lines   = content.components(separatedBy: "\n")
    let pos     = getCaretPosition()
    // Find current line + column
    var charCount = 0
    var currentLine = 0
    var currentCol  = 0
    for (i, line) in lines.enumerated() {
      let lineEnd = charCount + line.count
      if pos <= lineEnd {
        currentLine = i
        currentCol  = pos - charCount
        break
      }
      charCount += line.count + 1
    }
    let targetLine = up ? max(0, currentLine - 1) : min(lines.count - 1, currentLine + 1)
    guard targetLine != currentLine else { return }
    // Rebuild offset for target line
    var targetOffset = 0
    for i in 0..<targetLine { targetOffset += lines[i].count + 1 }
    let col = min(currentCol, lines[targetLine].count)
    let newPos = targetOffset + col
    if extending { moveCaretPosition(newPos) } else { setCaretPosition(newPos) }
  }

  func _ti_moveCaretToLineEdge(end: Bool, extending: Bool) {
    _ti_fallbackLineEdge(end: end, extending: extending)
  }

  func _ti_handleEnter() {
    if let tf = self as? javax.swing.JTextField {
      tf.fireActionPerformed()
    } else if isEditable() {
      // JTextArea: insert newline at caret
      let pos = getCaretPosition()
      try? getDocument().insertString(pos, "\n")
      setCaretPosition(pos + 1)
    }
  }
}

// =============================================================================
// MARK: - Shared helper
// =============================================================================

extension _AnyTextInput {
  /// Fallback line-edge navigation for single-line inputs (or when no
  /// multiline implementation is available): jump to start or end of text.
  func _ti_fallbackLineEdge(end: Bool, extending: Bool) {
    let target = end ? getText().count : 0
    if extending { extendSelection(to: target) } else { setCaretPosition(target) }
  }
}

// Helper so java.awt.TextArea optional call compiles cleanly
private extension Optional where Wrapped == Void {
  static func ?? (lhs: Void?, rhs: @autoclosure () -> Void) {
    if lhs == nil { rhs() }
  }
}

#endif
