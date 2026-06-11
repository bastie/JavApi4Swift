/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

// =============================================================================
// MARK: _Win32FocusManager
// =============================================================================

/// Tracks which AWT component currently holds keyboard focus and routes
/// keyboard / clipboard operations to the active `TextComponent`.
///
/// Mirrors `_SwiftUIFocusManager` for Windows.
/// All text-input logic is identical; only the clipboard implementation
/// uses Win32 APIs (`OpenClipboard` / `SetClipboardData` / `GetClipboardData`)
/// instead of `NSPasteboard`.
@MainActor
public final class _Win32FocusManager {

  public static let shared = _Win32FocusManager()
  private init() {}

  private(set) weak var focusOwner: java.awt.Component?

  // ---------------------------------------------------------------------------
  // MARK: Focus transfer
  // ---------------------------------------------------------------------------

  func requestFocus(_ component: java.awt.Component?) {
    guard focusOwner !== component else { return }
    if let old = focusOwner {
      old.processFocusEvent(
        java.awt.event.FocusEvent(old, java.awt.event.FocusEvent.FOCUS_LOST))
    }
    focusOwner = component
    if let new = component {
      new.processFocusEvent(
        java.awt.event.FocusEvent(new, java.awt.event.FocusEvent.FOCUS_GAINED))
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Text input  (identical to _SwiftUIFocusManager)
  // ---------------------------------------------------------------------------

  func typeCharacter(_ ch: Character) {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    var chars = Array(tc.getText())
    if tc.hasSelection {
      let lo = tc.selectionStart, hi = tc.selectionEnd
      chars.removeSubrange(lo..<hi)
      chars.insert(ch, at: lo)
      tc.setText(String(chars)); tc.setCaretPosition(lo + 1)
    } else {
      let pos = min(tc.caretPosition, chars.count)
      chars.insert(ch, at: pos)
      tc.setText(String(chars)); tc.setCaretPosition(pos + 1)
    }
    (tc as? java.awt.TextArea)?.ensureCaretVisible()
  }

  func handleBackspace() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    var chars = Array(tc.getText())
    if tc.hasSelection {
      let lo = tc.selectionStart, hi = tc.selectionEnd
      chars.removeSubrange(lo..<hi)
      tc.setText(String(chars)); tc.setCaretPosition(lo)
    } else {
      let pos = tc.caretPosition; guard pos > 0 else { return }
      chars.remove(at: pos - 1)
      tc.setText(String(chars)); tc.setCaretPosition(pos - 1)
    }
    (tc as? java.awt.TextArea)?.ensureCaretVisible()
  }

  func handleDelete() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    var chars = Array(tc.getText())
    if tc.hasSelection {
      let lo = tc.selectionStart, hi = tc.selectionEnd
      chars.removeSubrange(lo..<hi)
      tc.setText(String(chars)); tc.setCaretPosition(lo)
    } else {
      let pos = tc.caretPosition; guard pos < chars.count else { return }
      chars.remove(at: pos)
      tc.setText(String(chars)); tc.setCaretPosition(pos)
    }
    (tc as? java.awt.TextArea)?.ensureCaretVisible()
  }

  func handleEnter() {
    if let tf = focusOwner as? java.awt.TextField {
      tf.doAction()
    } else if let ta = focusOwner as? java.awt.TextArea, ta.editable {
      typeCharacter("\n")
    }
  }

  func selectAll() {
    (focusOwner as? java.awt.TextComponent)?.selectAll()
  }

  func moveCaret(by delta: Int, extending: Bool) {
    guard let tc = focusOwner as? java.awt.TextComponent else { return }
    if !extending && tc.hasSelection {
      tc.setCaretPosition(delta < 0 ? tc.selectionStart : tc.selectionEnd)
      return
    }
    let newPos = max(0, min(tc.caretPosition + delta, tc.getText().count))
    extending ? tc.extendSelection(to: newPos) : tc.setCaretPosition(newPos)
    (tc as? java.awt.TextArea)?.ensureCaretVisible()
  }

  func moveCaretUp(extending: Bool) {
    if let ta = focusOwner as? java.awt.TextArea {
      ta._moveCaretToAdjacentLine(up: true, extending: extending)
    } else if let tc = focusOwner as? java.awt.TextComponent {
      extending ? tc.extendSelection(to: 0) : tc.setCaretPosition(0)
    }
  }

  func moveCaretDown(extending: Bool) {
    if let ta = focusOwner as? java.awt.TextArea {
      ta._moveCaretToAdjacentLine(up: false, extending: extending)
    } else if let tc = focusOwner as? java.awt.TextComponent {
      let end = tc.getText().count
      extending ? tc.extendSelection(to: end) : tc.setCaretPosition(end)
    }
  }

  func moveCaretToEnd(end: Bool, extending: Bool) {
    if let ta = focusOwner as? java.awt.TextArea {
      ta._moveCaretToLineEdge(end: end, extending: extending)
    } else if let tc = focusOwner as? java.awt.TextComponent {
      let newPos = end ? tc.getText().count : 0
      extending ? tc.extendSelection(to: newPos) : tc.setCaretPosition(newPos)
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Clipboard — Win32
  // ---------------------------------------------------------------------------

  func copySelection() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.hasSelection else { return }
    let selected = String(Array(tc.getText())[tc.selectionStart..<tc.selectionEnd])
    setWin32Clipboard(selected)
  }

  func cutSelection() {
    guard let tc = focusOwner as? java.awt.TextComponent,
          tc.editable, tc.hasSelection else { return }
    copySelection()
    handleBackspace()
  }

  func pasteText() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    guard let text = getWin32Clipboard() else { return }
    for ch in text { typeCharacter(ch) }
  }

  // ---------------------------------------------------------------------------
  // MARK: Win32 clipboard helpers
  // ---------------------------------------------------------------------------

  private func setWin32Clipboard(_ text: String) {
    guard OpenClipboard(nil) else { return }
    EmptyClipboard()
    let wide    = Array(text.utf16) + [0]
    let bytes   = wide.count * MemoryLayout<WCHAR>.size
    let hMem    = GlobalAlloc(UINT(GMEM_MOVEABLE), SIZE_T(bytes))!
    let ptr     = GlobalLock(hMem)!
    ptr.copyMemory(from: wide, byteCount: bytes)
    GlobalUnlock(hMem)
    SetClipboardData(UINT(CF_UNICODETEXT), hMem)
    CloseClipboard()
  }

  private func getWin32Clipboard() -> String? {
    guard OpenClipboard(nil)                          else { return nil }
    defer { CloseClipboard() }
    guard let hMem = GetClipboardData(UINT(CF_UNICODETEXT)) else { return nil }
    guard let ptr  = GlobalLock(hMem)                       else { return nil }
    defer { GlobalUnlock(hMem) }
    return String(decodingCString: ptr.bindMemory(to: WCHAR.self, capacity: 1),
                  as: UTF16.self)
  }
}

#endif  // os(Windows)
