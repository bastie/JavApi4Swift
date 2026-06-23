/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
#if canImport(Glibc)
import Glibc
#endif

// =============================================================================
// MARK: _X11FocusManager
// =============================================================================

/// Tracks which AWT component currently holds keyboard focus and routes
/// keyboard / clipboard operations to the active `TextComponent`.
///
/// Mirrors `_Win32FocusManager` for Linux / FreeBSD.
/// All text-input logic is identical; the clipboard section is currently a
/// no-op — replace with `XSetSelectionOwner` (X11 primary/clipboard selection)
/// or `xclip`/`wl-clipboard` for a full implementation.
@MainActor
public final class _X11FocusManager {

  public static let shared = _X11FocusManager()
  private init() {}

  private(set) weak var focusOwner: java.awt.Component?

  /// The root component of the current window — set by the window host so
  /// that Tab-order traversal can walk the full component tree.
  weak var rootComponent: java.awt.Component?

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
  // MARK: Text input  (identical to _Win32FocusManager / _SwiftUIFocusManager)
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
  // MARK: Clipboard — X11 / Wayland (delegated to _X11ClipboardProvider)
  // ---------------------------------------------------------------------------

  private let clipboardProvider = java.awt.toolkit._X11ClipboardProvider()

  func copySelection() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.hasSelection else { return }
    let selected = String(Array(tc.getText())[tc.selectionStart..<tc.selectionEnd])
    clipboardProvider._setClipboardText(selected)
  }

  func cutSelection() {
    guard let tc = focusOwner as? java.awt.TextComponent,
          tc.editable, tc.hasSelection else { return }
    copySelection()
    handleBackspace()
  }

  func pasteText() {
    guard let tc = focusOwner as? java.awt.TextComponent, tc.editable else { return }
    guard let text = clipboardProvider._getClipboardText() else { return }
    for ch in text { typeCharacter(ch) }
  }

  // ---------------------------------------------------------------------------
  // MARK: Tab / focus traversal
  // ---------------------------------------------------------------------------

  func transferFocus(forward: Bool) {
    guard let root = rootComponent else { return }
    let all = focusableComponents(in: root)
    guard !all.isEmpty else { return }
    if let current = focusOwner, let idx = all.firstIndex(where: { $0 === current }) {
      let next = forward
        ? all[(idx + 1) % all.count]
        : all[(idx - 1 + all.count) % all.count]
      requestFocus(next)
    } else {
      requestFocus(forward ? all.first : all.last)
    }
  }

  private func focusableComponents(in component: java.awt.Component) -> [java.awt.Component] {
    guard component.isVisible() && component.isEnabled() else { return [] }
    if !(component is java.awt.Container) {
      return isFocusable(component) ? [component] : []
    }
    var result: [java.awt.Component] = []
    if isFocusable(component) {
      result.append(component)
    } else if let container = component as? java.awt.Container {
      for child in container.getComponents() {
        result += focusableComponents(in: child)
      }
    }
    return result
  }

  private func isFocusable(_ c: java.awt.Component) -> Bool {
    guard c.isVisible() && c.isEnabled() else { return false }
    if c is _AnyTextInput              { return true }
    if c is javax.swing.JButton        { return true }
    if c is javax.swing.JToggleButton  { return true }
    if c is javax.swing.JCheckBox      { return true }
    if c is javax.swing.JRadioButton   { return true }
    if c is javax.swing.JSpinner       { return true }
    if let jc = c as? javax.swing.JComponent {
      let id = jc.getUIClassID()
      if id == "ComboBoxUI" || id == "ListUI" { return true }
    }
    return false
  }
}
#endif
