/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

// =============================================================================
// MARK: HRESULT helpers & DnD constants
// =============================================================================

/// Converts an unsigned Win32 error code into a signed `HRESULT`.
@inline(__always) func _hr(_ v: UInt32) -> HRESULT { HRESULT(bitPattern: v) }

// DnD-specific HRESULT values not always exported by the Swift WinSDK overlay.
let _DRAGDROP_S_DROP:              HRESULT = 0x00040100
let _DRAGDROP_S_CANCEL:            HRESULT = 0x00040101
let _DRAGDROP_S_USEDEFAULTCURSORS: HRESULT = 0x00040102
let _DV_E_FORMATETC:               HRESULT = _hr(0x80040064)

// DROPEFFECT flags (DWORD bit mask).
let _DROPEFFECT_NONE: DWORD = 0
let _DROPEFFECT_COPY: DWORD = 1
let _DROPEFFECT_MOVE: DWORD = 2
let _DROPEFFECT_LINK: DWORD = 4

// =============================================================================
// MARK: _Win32OLEDropSource — COM IDropSource implementation
// =============================================================================

// COM requires that a pointer to an `IDropSource` (i.e. the object pointer
// passed to `DoDragDrop`) points to a struct whose first field is a pointer
// to the vtable.  We achieve this by allocating a `_COMDropSource` on the
// heap: its first field is an `IDropSource` value (which itself contains
// `lpVtbl`), so the `UnsafeMutablePointer<IDropSource>` that Win32 sees is
// simply the first-field alias of our wrapper.

private struct _COMDropSource {
  var base: IDropSource                      // ← COM sees `IDropSource*` here
  var obj:  Unmanaged<_Win32OLEDropSource>   // back-pointer to Swift object
}

// -----------------------------------------------------------------------------

/// COM `IDropSource` implementation for Windows OLE drag-and-drop.
///
/// ### COM vtable pattern
/// - A single heap-allocated `IDropSourceVtbl` is shared across all instances
///   (`_vtblPtr`).  It has a stable address for the lifetime of the process.
/// - Each instance owns a heap-allocated `_COMDropSource` that starts with an
///   `IDropSource` value so that Win32 can dereference `lpVtbl` correctly.
/// - The `@convention(c)` callbacks recover the Swift object by casting the
///   `IDropSource*` back to `_COMDropSource*` (valid because `base` is first).
///
/// - Since: Java 1.2 (Windows OLE backend, Step 4b)
@MainActor
final class _Win32OLEDropSource {

  // ── Static heap-allocated vtable (shared, stable address) ─────────────────

  nonisolated(unsafe) private static let _vtblPtr:
      UnsafeMutablePointer<IDropSourceVtbl> = {
    let p = UnsafeMutablePointer<IDropSourceVtbl>.allocate(capacity: 1)
    p.initialize(to: IDropSourceVtbl(
      QueryInterface: { thisPtr, _, ppv in
        guard let ppv else { return _hr(0x80004003) /* E_POINTER */ }
        ppv.pointee = nil
        return _hr(0x80004002) /* E_NOINTERFACE */
      },
      AddRef:  { _ in 1 },
      Release: { _ in 1 },

      QueryContinueDrag: { thisPtr, fEscapePressed, grfKeyState in
        // User pressed Escape → cancel.
        // `fEscapePressed` is `WindowsBool` — use .boolValue, not != 0.
        if fEscapePressed.boolValue { return _DRAGDROP_S_CANCEL }
        // Left button released → commit drop.
        if grfKeyState & DWORD(MK_LBUTTON) == 0 { return _DRAGDROP_S_DROP }
        return S_OK
      },

      GiveFeedback: { _, _ in _DRAGDROP_S_USEDEFAULTCURSORS }
    ))
    return p
  }()

  // ── Per-instance heap allocation ───────────────────────────────────────────

  nonisolated(unsafe) private var _com: UnsafeMutablePointer<_COMDropSource>

  init() {
    // Phase 1 — allocate; stored property `_com` is set.
    let p = UnsafeMutablePointer<_COMDropSource>.allocate(capacity: 1)
    _com = p
    // Phase 2 — `self` is now fully initialised; safe to capture unretained.
    p.initialize(to: _COMDropSource(
      base: IDropSource(lpVtbl: _Win32OLEDropSource._vtblPtr),
      obj:  Unmanaged.passUnretained(self)
    ))
  }

  deinit {
    _com.deinitialize(count: 1)
    _com.deallocate()
  }

  /// Returns the COM pointer passed to `DoDragDrop(_, pbc:, ...)`.
  var asIDropSource: UnsafeMutablePointer<IDropSource> {
    // `_COMDropSource.base` is at offset 0 → reinterpret cast is safe.
    UnsafeMutableRawPointer(_com)
      .bindMemory(to: IDropSource.self, capacity: 1)
  }
}

#endif // os(Windows)
