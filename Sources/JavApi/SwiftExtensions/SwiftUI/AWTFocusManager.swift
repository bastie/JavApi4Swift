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

/// Tracks which AWT component currently has keyboard focus and routes
/// keyboard / clipboard operations to the active TextComponent.
@MainActor
public final class AWTFocusManager {

  public static let shared = AWTFocusManager()
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
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    var chars = Array(tc.getText())
    if tc.hasSelection {
      let lo = tc.selectionStart, hi = tc.selectionEnd
      chars.removeSubrange(lo..<hi)
      chars.insert(ch, at: lo)
      tc.setText(String(chars))
      tc.setCaretPosition(lo + 1)
    } else {
      let pos = min(tc.caretPosition, chars.count)
      chars.insert(ch, at: pos)
      tc.setText(String(chars))
      tc.setCaretPosition(pos + 1)
    }
    (tc as? java.awt.TextArea)?.ensureCaretVisible()
  }

  /// Delete the selection or the character before the caret (Backspace).
  func handleBackspace() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    var chars = Array(tc.getText())
    if tc.hasSelection {
      let lo = tc.selectionStart, hi = tc.selectionEnd
      chars.removeSubrange(lo..<hi)
      tc.setText(String(chars))
      tc.setCaretPosition(lo)
    } else {
      let pos = tc.caretPosition
      guard pos > 0 else { return }
      chars.remove(at: pos - 1)
      tc.setText(String(chars))
      tc.setCaretPosition(pos - 1)
    }
    (tc as? java.awt.TextArea)?.ensureCaretVisible()
  }

  /// Delete the selection or the character after the caret (Forward Delete).
  func handleDelete() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    var chars = Array(tc.getText())
    if tc.hasSelection {
      let lo = tc.selectionStart, hi = tc.selectionEnd
      chars.removeSubrange(lo..<hi)
      tc.setText(String(chars))
      tc.setCaretPosition(lo)
    } else {
      let pos = tc.caretPosition
      guard pos < chars.count else { return }
      chars.remove(at: pos)
      tc.setText(String(chars))
      tc.setCaretPosition(pos)
    }
    (tc as? java.awt.TextArea)?.ensureCaretVisible()
  }

  /// Return / Enter: fire ActionEvent in TextField, insert newline in TextArea.
  func handleEnter() {
    if let tf = focusOwner as? java.awt.TextField {
      tf.doAction()
    } else if let ta = focusOwner as? java.awt.TextArea, ta.editable {
      typeCharacter("\n")
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Selection
  // ---------------------------------------------------------------------------

  func selectAll() {
    (focusOwner as? java.awt.TextComponent)?.selectAll()
  }

  /// Move the caret by `delta` characters, optionally extending the selection.
  func moveCaret(by delta: Int, extending: Bool) {
    guard let tc = focusOwner as? java.awt.TextComponent else { return }
    if !extending && tc.hasSelection {
      let edge = delta < 0 ? tc.selectionStart : tc.selectionEnd
      tc.setCaretPosition(edge)
      return
    }
    let newPos = max(0, min(tc.caretPosition + delta, tc.getText().count))
    if extending {
      tc.extendSelection(to: newPos)
    } else {
      tc.setCaretPosition(newPos)
    }
    (tc as? java.awt.TextArea)?.ensureCaretVisible()
  }

  /// Move caret up one line (TextArea) or to start of text (TextField).
  func moveCaretUp(extending: Bool) {
    if let ta = focusOwner as? java.awt.TextArea {
      ta.moveCaretToAdjacentLine(up: true, extending: extending)
    } else if let tc = focusOwner as? java.awt.TextComponent {
      // TextField: Up → go to beginning
      if extending { tc.extendSelection(to: 0) } else { tc.setCaretPosition(0) }
    }
  }

  /// Move caret down one line (TextArea) or to end of text (TextField).
  func moveCaretDown(extending: Bool) {
    if let ta = focusOwner as? java.awt.TextArea {
      ta.moveCaretToAdjacentLine(up: false, extending: extending)
    } else if let tc = focusOwner as? java.awt.TextComponent {
      // TextField: Down → go to end
      let end = tc.getText().count
      if extending { tc.extendSelection(to: end) } else { tc.setCaretPosition(end) }
    }
  }

  /// Jump to beginning (`end = false`) or end (`end = true`) of the current
  /// line (TextArea) or whole text (TextField).
  func moveCaretToEnd(end: Bool, extending: Bool) {
    if let ta = focusOwner as? java.awt.TextArea {
      ta.moveCaretToLineEdge(end: end, extending: extending)
    } else if let tc = focusOwner as? java.awt.TextComponent {
      let newPos = end ? tc.getText().count : 0
      if extending { tc.extendSelection(to: newPos) } else { tc.setCaretPosition(newPos) }
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Clipboard
  // ---------------------------------------------------------------------------

  #if canImport(AppKit)

  func copySelection() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.hasSelection else { return }
    let chars    = Array(tc.getText())
    let selected = String(chars[tc.selectionStart..<tc.selectionEnd])
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(selected, forType: .string)
  }

  func cutSelection() {
    guard let tc = focusOwner as? java.awt.TextComponent,
          tc.editable, tc.hasSelection else { return }
    copySelection()
    handleBackspace()
  }

  func pasteText() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    guard let text = NSPasteboard.general.string(forType: .string) else { return }
    for ch in text { typeCharacter(ch) }
  }

  #elseif canImport(UIKit)

  func copySelection() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.hasSelection else { return }
    let chars    = Array(tc.getText())
    let selected = String(chars[tc.selectionStart..<tc.selectionEnd])
    UIPasteboard.general.string = selected
  }

  func cutSelection() {
    guard let tc = focusOwner as? java.awt.TextComponent,
          tc.editable, tc.hasSelection else { return }
    copySelection()
    handleBackspace()
  }

  func pasteText() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
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
