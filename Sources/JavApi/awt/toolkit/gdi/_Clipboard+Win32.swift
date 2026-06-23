/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

extension java.awt.toolkit {

  /// Windows clipboard backend using Win32
  /// `OpenClipboard` / `SetClipboardData` / `GetClipboardData`.
  ///
  /// Previously the clipboard logic lived inside `_Win32FocusManager`.
  /// It is now a standalone ``ClipboardProvider`` so that
  /// ``GDIToolkit._makeClipboardProvider()`` can return it and
  /// `java.awt.datatransfer.Clipboard` can use it directly.
  ///
  /// `_Win32FocusManager` delegates its internal copy/paste helpers to a
  /// shared instance of this provider.
  ///
  /// - Since: JavaApi (Java 1.1 datatransfer)
  public final class _Win32ClipboardProvider: ClipboardProvider, @unchecked Sendable {

    /// Shared instance used by `_Win32FocusManager`.
    public static let shared = _Win32ClipboardProvider()

    public init() {}

    // MARK: - ClipboardProvider

    public func _getClipboardText() -> String? {
      guard OpenClipboard(nil) else { return nil }
      defer { CloseClipboard() }
      guard let hMem = GetClipboardData(UINT(CF_UNICODETEXT)) else { return nil }
      guard let ptr  = GlobalLock(hMem) else { return nil }
      defer { GlobalUnlock(hMem) }
      return String(
        decodingCString: ptr.bindMemory(to: WCHAR.self, capacity: 1),
        as: UTF16.self
      )
    }

    public func _setClipboardText(_ text: String) {
      guard OpenClipboard(nil) else { return }
      EmptyClipboard()
      let wide  = Array(text.utf16) + [0]
      let bytes = wide.count * MemoryLayout<WCHAR>.size
      guard let hMem = GlobalAlloc(UINT(GMEM_MOVEABLE), SIZE_T(bytes)) else {
        CloseClipboard()
        return
      }
      guard let ptr = GlobalLock(hMem) else {
        GlobalFree(hMem)
        CloseClipboard()
        return
      }
      ptr.copyMemory(from: wide, byteCount: bytes)
      GlobalUnlock(hMem)
      SetClipboardData(UINT(CF_UNICODETEXT), hMem)
      CloseClipboard()
    }
  }
}
#endif
