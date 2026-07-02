/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

// =============================================================================
// MARK: _Win32OLEDropTarget — COM IDropTarget implementation
// =============================================================================

/// COM wrapper struct — must start with `IDropTarget` so Win32 can
/// dereference `lpVtbl` via a plain `IDropTarget*` cast.
private struct _COMDropTarget {
  var base:   IDropTarget                        // ← COM sees `IDropTarget*` here
  var hwnd:   HWND?                              // for ScreenToClient
  var lastPt: POINTL                             // most recent cursor position (screen)
  var obj:    Unmanaged<_Win32OLEDropTarget>     // back-pointer to Swift object
}

// -----------------------------------------------------------------------------

/// COM `IDropTarget` implementation that delegates to `_Win32Canvas`.
///
/// One instance is created per top-level `_Win32Canvas` and registered with
/// `RegisterDragDrop`.  When Win32 calls the COM callbacks, we convert the
/// screen-relative `POINTL` to client coordinates and forward to the canvas
/// methods `_dndDragEntered / _dndDragOver / _dndDragExited / _dndDrop`.
///
/// ### Threading
/// `DoDragDrop` pumps its own message loop on the calling (main) thread, so
/// all COM callbacks arrive on the main thread → `MainActor.assumeIsolated`
/// is safe.
///
/// - Since: Java 1.2 (Windows OLE backend, Step 4b)
@MainActor
final class _Win32OLEDropTarget {

  // ── Static heap-allocated vtable ──────────────────────────────────────────

  nonisolated(unsafe) private static let _vtblPtr:
      UnsafeMutablePointer<IDropTargetVtbl> = {
    let p = UnsafeMutablePointer<IDropTargetVtbl>.allocate(capacity: 1)
    p.initialize(to: IDropTargetVtbl(
      // ── IUnknown ──────────────────────────────────────────────────────────
      QueryInterface: { thisPtr, _, ppv in
        guard let ppv else { return _hr(0x80004003) }
        ppv.pointee = nil
        return _hr(0x80004002) // E_NOINTERFACE
      },
      AddRef:  { _ in 1 },
      Release: { _ in 1 },

      // ── IDropTarget ───────────────────────────────────────────────────────
      //
      // Swift 6 Sendable rules: unsafe C pointers (HWND, UnsafeMutablePointer<…>)
      // are NOT Sendable and must NOT be captured by the MainActor.assumeIsolated
      // closure.  Strategy:
      //   1. Do all pointer reads / Win32 calls (ScreenToClient, pdwEffect.pointee)
      //      BEFORE assumeIsolated — produce only Sendable Int / DWORD values.
      //   2. Compute the outgoing pdwEffect value INSIDE assumeIsolated (returned
      //      as a plain DWORD).
      //   3. Write back to pdwEffect / HRESULT AFTER assumeIsolated.

      DragEnter: { thisPtr, pDataObj, grfKeyState, pt, pdwEffect in
        guard let thisPtr, let pDataObj, let pdwEffect else { return S_OK }
        thisPtr.withMemoryRebound(to: _COMDropTarget.self, capacity: 1) { comPtr in
          comPtr.pointee.lastPt = pt
          // ── pointer work outside MainActor ──────────────────────────────
          let (cx, cy) = _clientCoords(hwnd: comPtr.pointee.hwnd, pt: pt)
          let srcAct   = _dropEffectToAction(pdwEffect.pointee)
          let newEff   = _defaultDropEffect(grfKeyState)
          let self_    = comPtr.pointee.obj.takeUnretainedValue()
          // ── only Sendable values enter assumeIsolated ───────────────────
          MainActor.assumeIsolated {
            self_.canvas?._dndDragEntered(x: cx, y: cy,
                                          sourceActions: srcAct, dropAction: srcAct)
          }
          pdwEffect.pointee = newEff
        }
        return S_OK
      },

      DragOver: { thisPtr, grfKeyState, pt, pdwEffect in
        guard let thisPtr, let pdwEffect else { return S_OK }
        thisPtr.withMemoryRebound(to: _COMDropTarget.self, capacity: 1) { comPtr in
          comPtr.pointee.lastPt = pt
          let (cx, cy) = _clientCoords(hwnd: comPtr.pointee.hwnd, pt: pt)
          let srcAct   = _dropEffectToAction(pdwEffect.pointee)
          let newEff   = _defaultDropEffect(grfKeyState)
          let self_    = comPtr.pointee.obj.takeUnretainedValue()
          MainActor.assumeIsolated {
            self_.canvas?._dndDragOver(x: cx, y: cy,
                                       sourceActions: srcAct, dropAction: srcAct)
          }
          pdwEffect.pointee = newEff
        }
        return S_OK
      },

      DragLeave: { thisPtr in
        guard let thisPtr else { return S_OK }
        thisPtr.withMemoryRebound(to: _COMDropTarget.self, capacity: 1) { comPtr in
          let (cx, cy) = _clientCoords(hwnd: comPtr.pointee.hwnd, pt: comPtr.pointee.lastPt)
          let self_    = comPtr.pointee.obj.takeUnretainedValue()
          MainActor.assumeIsolated {
            self_.canvas?._dndDragExited(x: cx, y: cy)
          }
        }
        return S_OK
      },

      Drop: { thisPtr, pDataObj, grfKeyState, pt, pdwEffect in
        guard let thisPtr, let pDataObj, let pdwEffect else { return S_OK }
        thisPtr.withMemoryRebound(to: _COMDropTarget.self, capacity: 1) { comPtr in
          comPtr.pointee.lastPt = pt
          let (cx, cy)  = _clientCoords(hwnd: comPtr.pointee.hwnd, pt: pt)
          let srcAct    = _dropEffectToAction(pdwEffect.pointee)
          let dropAct   = _dropEffectToAction(_defaultDropEffect(grfKeyState))
          let noneEff   = _DROPEFFECT_NONE
          let dropEff   = _defaultDropEffect(grfKeyState)
          // _Win32OLEInboundTransferable is @unchecked Sendable → safe to capture
          let t         = _Win32OLEInboundTransferable(pDataObj)
          let self_     = comPtr.pointee.obj.takeUnretainedValue()
          let accepted: Bool = MainActor.assumeIsolated {
            self_.canvas?._dndDrop(x: cx, y: cy,
                                   transferable: t,
                                   sourceActions: srcAct,
                                   dropAction: dropAct,
                                   isLocal: false) ?? false
          }
          // Write back outside assumeIsolated — pdwEffect pointer stays non-isolated
          pdwEffect.pointee = accepted ? dropEff : noneEff
        }
        return S_OK
      }
    ))
    return p
  }()

  // ── Per-instance state ─────────────────────────────────────────────────────

  weak var canvas: _Win32Canvas?
  nonisolated(unsafe) private var _com: UnsafeMutablePointer<_COMDropTarget>

  init(canvas: _Win32Canvas, hwnd: HWND) {
    self.canvas = canvas
    let p = UnsafeMutablePointer<_COMDropTarget>.allocate(capacity: 1)
    _com = p
    p.initialize(to: _COMDropTarget(
      base:   IDropTarget(lpVtbl: _Win32OLEDropTarget._vtblPtr),
      hwnd:   hwnd,
      lastPt: POINTL(x: 0, y: 0),
      obj:    Unmanaged.passUnretained(self)
    ))
  }

  deinit {
    _com.deinitialize(count: 1)
    _com.deallocate()
  }

  /// The COM pointer registered with `RegisterDragDrop`.
  var asIDropTarget: UnsafeMutablePointer<IDropTarget> {
    UnsafeMutableRawPointer(_com)
      .bindMemory(to: IDropTarget.self, capacity: 1)
  }
}

// =============================================================================
// MARK: Private COM helpers
// =============================================================================

/// Converts screen coordinates (`POINTL`) to window client coordinates.
private func _clientCoords(hwnd: HWND?, pt: POINTL) -> (Int, Int) {
  var clientPt = POINT(x: LONG(pt.x), y: LONG(pt.y))
  if let hwnd { ScreenToClient(hwnd, &clientPt) }
  return (Int(clientPt.x), Int(clientPt.y))
}

/// Maps a Win32 `DROPEFFECT` bitmask to a Java DnD action constant.
private func _dropEffectToAction(_ effect: DWORD) -> Int {
  if effect & _DROPEFFECT_MOVE != 0 { return java.awt.dnd.DnDConstants.ACTION_MOVE }
  if effect & _DROPEFFECT_COPY != 0 { return java.awt.dnd.DnDConstants.ACTION_COPY }
  if effect & _DROPEFFECT_LINK != 0 { return java.awt.dnd.DnDConstants.ACTION_LINK }
  return java.awt.dnd.DnDConstants.ACTION_NONE
}

/// Chooses the preferred `DROPEFFECT` based on the current modifier keys.
private func _defaultDropEffect(_ grfKeyState: DWORD) -> DWORD {
  // Ctrl = copy, Shift+Ctrl = link, otherwise move (or copy if move not avail).
  if grfKeyState & DWORD(MK_CONTROL) != 0 &&
     grfKeyState & DWORD(MK_SHIFT)   != 0 { return _DROPEFFECT_LINK }
  if grfKeyState & DWORD(MK_CONTROL) != 0  { return _DROPEFFECT_COPY }
  return _DROPEFFECT_MOVE
}

#endif // os(Windows)
