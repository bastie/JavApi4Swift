/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

// =============================================================================
// MARK: OLE / clipboard constants
// =============================================================================

// Standard clipboard format identifiers.
private let _CF_UNICODETEXT: CLIPFORMAT = 13

// TYMED bit mask for HGLOBAL transfers.
private let _TYMED_HGLOBAL: DWORD = 1

// DVASPECT: content rendering.
private let _DVASPECT_CONTENT: DWORD = 1

// GlobalAlloc flag: moveable memory.
private let _GMEM_MOVEABLE: UINT = 0x0002

// =============================================================================
// MARK: STGMEDIUM helpers
// =============================================================================

/// Writes `hGlobal` into the anonymous union field of `STGMEDIUM`.
///
/// On 64-bit Windows the struct layout is:
/// - offset  0: `tymed` (DWORD, 4 bytes) + 4 bytes alignment padding
/// - offset  8: union (HGLOBAL / HBITMAP / … , 8 bytes)
/// - offset 16: `pUnkForRelease` (pointer, 8 bytes)
///
/// We use raw-byte access because Swift's C-interop representation of
/// anonymous C unions varies across WinSDK overlay versions.
private func _makeHGlobalMedium(_ hGlobal: HGLOBAL?) -> STGMEDIUM {
  var m = STGMEDIUM()
  m.tymed = _TYMED_HGLOBAL
  withUnsafeMutablePointer(to: &m) { ptr in
    UnsafeMutableRawPointer(ptr)
      .advanced(by: 8)                          // offset of union field
      .storeBytes(of: hGlobal, as: HGLOBAL?.self)
  }
  m.pUnkForRelease = nil
  return m
}

/// Reads the HGLOBAL from the anonymous union field of a `STGMEDIUM`.
func _extractHGlobal(from medium: STGMEDIUM) -> HGLOBAL? {
  var copy = medium
  return withUnsafePointer(to: &copy) { ptr in
    UnsafeRawPointer(ptr)
      .advanced(by: 8)
      .load(as: HGLOBAL?.self)
  }
}

// =============================================================================
// MARK: _Win32OLEDataObject — COM IDataObject implementation
// =============================================================================

private struct _COMDataObject {
  var base: IDataObject                       // ← COM sees `IDataObject*` here
  var obj:  Unmanaged<_Win32OLEDataObject>
}

// -----------------------------------------------------------------------------

/// COM `IDataObject` implementation backed by a Java `Transferable`.
///
/// Supports:
/// - `CF_UNICODETEXT` via `DataFlavor.stringFlavor`
///
/// All other methods return `E_NOTIMPL` or `DV_E_FORMATETC`.
///
/// - Note: Not `@MainActor` — COM calls `GetData`/`QueryGetData` synchronously
///   on the thread that called `DoDragDrop` (always the main thread in our case).
///   Properties use `nonisolated(unsafe)` since single-threaded COM access is
///   guaranteed by the Windows OLE contract.
///
/// - Since: Java 1.2 (Windows OLE backend, Step 4b)
final class _Win32OLEDataObject {

  // ── Shared heap-allocated vtable ───────────────────────────────────────────

  nonisolated(unsafe) private static let _vtblPtr:
      UnsafeMutablePointer<IDataObjectVtbl> = {
    let p = UnsafeMutablePointer<IDataObjectVtbl>.allocate(capacity: 1)
    p.initialize(to: IDataObjectVtbl(
      // ── IUnknown ──────────────────────────────────────────────────────────
      QueryInterface: { thisPtr, _, ppv in
        guard let ppv else { return _hr(0x80004003) }
        ppv.pointee = nil
        return _hr(0x80004002)  // E_NOINTERFACE
      },
      AddRef:  { _ in 1 },
      Release: { _ in 1 },

      // ── IDataObject ───────────────────────────────────────────────────────
      //
      // IDataObject callbacks are invoked synchronously on the thread that called
      // DoDragDrop (= main thread). _Win32OLEDataObject is NOT @MainActor, so
      // we call helper methods directly — no MainActor.assumeIsolated needed and
      // no unsafe-pointer Sendable issues.
      GetData: { thisPtr, pFmt, pMedium in
        guard let thisPtr, let pFmt, let pMedium else {
          return _hr(0x80004003) // E_POINTER
        }
        return thisPtr.withMemoryRebound(to: _COMDataObject.self, capacity: 1) { comPtr in
          comPtr.pointee.obj.takeUnretainedValue()
            ._getData(fmt: pFmt.pointee, into: pMedium)
        }
      },

      GetDataHere: { _, _, _ in _hr(0x80004001) /* E_NOTIMPL */ },

      QueryGetData: { thisPtr, pFmt in
        guard let thisPtr, let pFmt else { return _hr(0x80004003) }
        return thisPtr.withMemoryRebound(to: _COMDataObject.self, capacity: 1) { comPtr in
          comPtr.pointee.obj.takeUnretainedValue()
            ._queryGetData(fmt: pFmt.pointee)
        }
      },

      GetCanonicalFormatEtc: { _, _, pFmtOut in
        pFmtOut?.pointee.ptd = nil
        return _hr(0x00040130) // DATA_S_SAMEFORMATETC
      },
      SetData:      { _, _, _, _ in _hr(0x80004001) },
      EnumFormatEtc:{ _, _, ppEnum in
        ppEnum?.pointee = nil
        return _hr(0x80004001)
      },
      DAdvise:      { _, _, _, _, _ in _hr(0x80004001) },
      DUnadvise:    { _, _          in _hr(0x80004001) },
      EnumDAdvise:  { _, _          in _hr(0x80004001) }
    ))
    return p
  }()

  // ── Per-instance state ─────────────────────────────────────────────────────

  nonisolated(unsafe) private let transferable: any java.awt.datatransfer.Transferable
  nonisolated(unsafe) private var _com: UnsafeMutablePointer<_COMDataObject>

  init(transferable: any java.awt.datatransfer.Transferable) {
    self.transferable = transferable
    let p = UnsafeMutablePointer<_COMDataObject>.allocate(capacity: 1)
    _com = p
    p.initialize(to: _COMDataObject(
      base: IDataObject(lpVtbl: _Win32OLEDataObject._vtblPtr),
      obj:  Unmanaged.passUnretained(self)
    ))
  }

  deinit {
    _com.deinitialize(count: 1)
    _com.deallocate()
  }

  var asIDataObject: UnsafeMutablePointer<IDataObject> {
    UnsafeMutableRawPointer(_com)
      .bindMemory(to: IDataObject.self, capacity: 1)
  }

  // ── Private IDataObject helpers ────────────────────────────────────────────

  private func _supportsFormat(_ fmt: FORMATETC) -> Bool {
    fmt.cfFormat == _CF_UNICODETEXT &&
    fmt.dwAspect & _DVASPECT_CONTENT != 0 &&
    fmt.tymed    & _TYMED_HGLOBAL    != 0
  }

  private func _queryGetData(fmt: FORMATETC) -> HRESULT {
    _supportsFormat(fmt) ? S_OK : _DV_E_FORMATETC
  }

  private func _getData(fmt: FORMATETC,
                        into pMedium: UnsafeMutablePointer<STGMEDIUM>) -> HRESULT {
    guard _supportsFormat(fmt) else { return _DV_E_FORMATETC }

    // Retrieve string from Transferable.
    let strFlavor = java.awt.datatransfer.DataFlavor.stringFlavor
    guard let raw = try? transferable.getTransferData(strFlavor),
          let str = raw as? String else {
      return _DV_E_FORMATETC
    }

    // Copy UTF-16 string into an HGLOBAL memory block.
    let utf16 = Array(str.utf16) + [WCHAR(0)]     // NUL-terminated
    let byteCount = utf16.count * MemoryLayout<WCHAR>.size
    guard let hGlobal = GlobalAlloc(_GMEM_MOVEABLE, SIZE_T(byteCount)) else {
      return _hr(0x8007000E) // E_OUTOFMEMORY
    }
    guard let ptr = GlobalLock(hGlobal) else {
      GlobalFree(hGlobal)
      return _hr(0x8007000E)
    }
    utf16.withUnsafeBytes { src in
      ptr.copyMemory(from: src.baseAddress!, byteCount: byteCount)
    }
    GlobalUnlock(hGlobal)

    pMedium.pointee = _makeHGlobalMedium(hGlobal)
    return S_OK
  }
}

// =============================================================================
// MARK: _Win32OLEInboundTransferable — wraps an incoming IDataObject*
// =============================================================================

/// `Transferable` backed by an OLE `IDataObject*` coming from a foreign drag
/// source (e.g. Windows Explorer).
///
/// Data is fetched lazily when `getTransferData(_:)` is called.
///
/// - Note: Not `@MainActor` — the `Transferable` protocol has no actor
///   annotation and Swift 6 rejects conformance-isolation mismatches.
///   All call sites are already on the main actor via `MainActor.assumeIsolated`.
final class _Win32OLEInboundTransferable: java.awt.datatransfer.Transferable, @unchecked Sendable {

  /// Raw pointer to the foreign `IDataObject` — kept alive by OLE for the
  /// duration of the drop callback.
  nonisolated(unsafe) private let _ptr: UnsafeMutableRawPointer

  init(_ dataObj: UnsafeMutablePointer<IDataObject>) {
    _ptr = UnsafeMutableRawPointer(dataObj)
  }

  public func getTransferDataFlavors() -> [java.awt.datatransfer.DataFlavor] {
    [.stringFlavor]
  }

  public func isDataFlavorSupported(
      _ flavor: java.awt.datatransfer.DataFlavor) -> Bool {
    flavor == .stringFlavor   // DataFlavor is Equatable; mimeType is private
  }

  public func getTransferData(
      _ flavor: java.awt.datatransfer.DataFlavor) throws -> Any {
    guard isDataFlavorSupported(flavor) else {
      throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
    }

    let dataObj = _ptr.assumingMemoryBound(to: IDataObject.self)
    var fmt  = FORMATETC()
    fmt.cfFormat = _CF_UNICODETEXT
    fmt.ptd      = nil
    fmt.dwAspect = _DVASPECT_CONTENT
    fmt.lindex   = -1
    fmt.tymed    = _TYMED_HGLOBAL

    var medium = STGMEDIUM()
    let hr = dataObj.pointee.lpVtbl.pointee.GetData(dataObj, &fmt, &medium)
    guard hr == S_OK else {
      throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
    }

    guard let hGlobal = _extractHGlobal(from: medium),
          let raw = GlobalLock(hGlobal) else {
      ReleaseStgMedium(&medium)
      throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
    }
    let wPtr  = raw.assumingMemoryBound(to: WCHAR.self)
    let str   = String(decodingCString: wPtr, as: UTF16.self)
    GlobalUnlock(hGlobal)
    ReleaseStgMedium(&medium)
    return str
  }
}

#endif // os(Windows)
