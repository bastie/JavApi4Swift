/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Tracks which component currently has keyboard focus and routes
/// keyboard / clipboard operations to the active text-input component.
///
/// Both AWT (`java.awt.TextComponent`) and Swing (`javax.swing.text.JTextComponent`)
/// are handled uniformly via the `_AnyTextInput` bridge protocol.
@MainActor
public final class _SwiftUIFocusManager {

  public static let shared = _SwiftUIFocusManager()
  private init() {}

  private(set) weak var focusOwner: java.awt.Component?

  // ---------------------------------------------------------------------------
  // MARK: Focus transfer
  // ---------------------------------------------------------------------------

  func requestFocus(_ component: java.awt.Component?) {
    guard focusOwner !== component else { return }
    if let old = focusOwner {
      let e = java.awt.event.FocusEvent(old, java.awt.event.FocusEvent.FOCUS_LOST)
      old.processFocusEvent(e)
    }
    focusOwner = component
    if let new = component {
      let e = java.awt.event.FocusEvent(new, java.awt.event.FocusEvent.FOCUS_GAINED)
      new.processFocusEvent(e)
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Text input
  // ---------------------------------------------------------------------------

  /// Insert `ch` at the caret, replacing any selection.
  func typeCharacter(_ ch: Character) {
    guard let tc = focusOwner as? _AnyTextInput, tc.isEditable() else { return }
    var chars = Array(tc.getText())
    if tc._ti_hasSelection {
      let lo = tc._ti_selectionStart, hi = tc._ti_selectionEnd
      chars.removeSubrange(lo..<hi)
      chars.insert(ch, at: lo)
      tc.setText(String(chars))
      tc.setCaretPosition(lo + 1)
    } else {
      let pos = min(tc._ti_caretPosition, chars.count)
      chars.insert(ch, at: pos)
      tc.setText(String(chars))
      tc.setCaretPosition(pos + 1)
    }
    tc._ti_ensureCaretVisible()
  }

  /// Delete the selection or the character before the caret (Backspace).
  func handleBackspace() {
    guard let tc = focusOwner as? _AnyTextInput, tc.isEditable() else { return }
    var chars = Array(tc.getText())
    if tc._ti_hasSelection {
      let lo = tc._ti_selectionStart, hi = tc._ti_selectionEnd
      chars.removeSubrange(lo..<hi)
      tc.setText(String(chars))
      tc.setCaretPosition(lo)
    } else {
      let pos = tc._ti_caretPosition
      guard pos > 0 else { return }
      chars.remove(at: pos - 1)
      tc.setText(String(chars))
      tc.setCaretPosition(pos - 1)
    }
    tc._ti_ensureCaretVisible()
  }

  /// Delete the selection or the character after the caret (Forward Delete).
  func handleDelete() {
    guard let tc = focusOwner as? _AnyTextInput, tc.isEditable() else { return }
    var chars = Array(tc.getText())
    if tc._ti_hasSelection {
      let lo = tc._ti_selectionStart, hi = tc._ti_selectionEnd
      chars.removeSubrange(lo..<hi)
      tc.setText(String(chars))
      tc.setCaretPosition(lo)
    } else {
      let pos = tc._ti_caretPosition
      guard pos < chars.count else { return }
      chars.remove(at: pos)
      tc.setText(String(chars))
      tc.setCaretPosition(pos)
    }
    tc._ti_ensureCaretVisible()
  }

  /// Return / Enter: fire ActionEvent in TextField / JTextField,
  /// insert newline in TextArea / JTextArea.
  func handleEnter() {
    (focusOwner as? _AnyTextInput)?._ti_handleEnter()
  }

  // ---------------------------------------------------------------------------
  // MARK: Selection
  // ---------------------------------------------------------------------------

  func selectAll() {
    (focusOwner as? _AnyTextInput)?.selectAll()
  }

  /// Move the caret by `delta` characters, optionally extending the selection.
  func moveCaret(by delta: Int, extending: Bool) {
    guard let tc = focusOwner as? _AnyTextInput else { return }
    if !extending && tc._ti_hasSelection {
      let edge = delta < 0 ? tc._ti_selectionStart : tc._ti_selectionEnd
      tc.setCaretPosition(edge)
      return
    }
    let newPos = max(0, min(tc._ti_caretPosition + delta, tc.getText().count))
    if extending {
      tc.extendSelection(to: newPos)
    } else {
      tc.setCaretPosition(newPos)
    }
    tc._ti_ensureCaretVisible()
  }

  /// Move caret up one line, or to start of text for single-line inputs.
  func moveCaretUp(extending: Bool) {
    (focusOwner as? _AnyTextInput)?._ti_moveCaretToAdjacentLine(up: true, extending: extending)
  }

  /// Move caret down one line, or to end of text for single-line inputs.
  func moveCaretDown(extending: Bool) {
    (focusOwner as? _AnyTextInput)?._ti_moveCaretToAdjacentLine(up: false, extending: extending)
  }

  /// Jump to start or end of current line (multiline) or whole text (single-line).
  func moveCaretToEnd(end: Bool, extending: Bool) {
    (focusOwner as? _AnyTextInput)?._ti_moveCaretToLineEdge(end: end, extending: extending)
  }

  // ---------------------------------------------------------------------------
  // MARK: Clipboard
  // ---------------------------------------------------------------------------

  #if canImport(AppKit)

  func copySelection() {
    guard let tc = focusOwner as? _AnyTextInput, tc._ti_hasSelection else { return }
    let chars    = Array(tc.getText())
    let selected = String(chars[tc._ti_selectionStart..<tc._ti_selectionEnd])
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(selected, forType: .string)
  }

  func cutSelection() {
    guard let tc = focusOwner as? _AnyTextInput,
          tc.isEditable(), tc._ti_hasSelection else { return }
    copySelection()
    handleBackspace()
  }

  func pasteText() {
    guard let tc = focusOwner as? _AnyTextInput, tc.isEditable() else { return }
    guard let text = NSPasteboard.general.string(forType: .string) else { return }
    for ch in text { typeCharacter(ch) }
  }

  #elseif canImport(UIKit) && os(watchOS)
  func copySelection()  {}
  func cutSelection()   {}
  func pasteText()      {}

  #elseif canImport(UIKit) && !os(tvOS)

  func copySelection() {
    guard let tc = focusOwner as? _AnyTextInput, tc._ti_hasSelection else { return }
    let chars    = Array(tc.getText())
    let selected = String(chars[tc._ti_selectionStart..<tc._ti_selectionEnd])
    UIPasteboard.general.string = selected
  }

  func cutSelection() {
    guard let tc = focusOwner as? _AnyTextInput,
          tc.isEditable(), tc._ti_hasSelection else { return }
    copySelection()
    handleBackspace()
  }

  func pasteText() {
    guard let tc = focusOwner as? _AnyTextInput, tc.isEditable() else { return }
    guard let text = UIPasteboard.general.string else { return }
    for ch in text { typeCharacter(ch) }
  }

  #else
  func copySelection()  {}
  func cutSelection()   {}
  func pasteText()      {}
  #endif

  // ---------------------------------------------------------------------------
  // MARK: Legacy / convenience
  // ---------------------------------------------------------------------------

  func handleSpecialKey(_ key: Int) {
    switch key {
    case java.awt.event.KeyEvent.VK_BACK_SPACE:
      handleBackspace()
    case java.awt.event.KeyEvent.VK_ENTER:
      handleEnter()
    default:
      break
    }
  }
}

#endif
