/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

///
/// Extension for FileDialog on GDI (Windows) platforms. **Must implement `_setToolkitVisible`!**
///

#if os(Windows)
import WinSDK
import Foundation

extension java.awt.FileDialog {
  /// Runs GetOpenFileNameW or GetSaveFileNameW synchronously and stores the result.
  public func _setToolkitVisible() {
    
    // Build filter string: pairs of "Description\0*.ext\0" terminated by "\0\0"
    let exts = parseExtensions(filenameFilter)
    var filterBuf: [WCHAR] = []
    if !exts.isEmpty {
      let desc = exts.map { "*.\($0)" }.joined(separator: ";")
      for c in (desc + "\0" + desc + "\0").utf16 { filterBuf.append(WCHAR(c)) }
    }
    // All files fallback
    for c in ("All Files (*.*)\0*.*\0\0").utf16 { filterBuf.append(WCHAR(c)) }
    
    // Result buffer — MAX_PATH = 260
    var fileNameBuf = [WCHAR](repeating: 0, count: 32768)
    
    // Pre-fill with existing file name if set
    if let f = file {
      let wide = Array(f.utf16)
      for (i, c) in wide.prefix(32767).enumerated() { fileNameBuf[i] = c }
    }
    
    // Initial directory
    var initDirBuf: [WCHAR] = []
    if let dir = directory {
      initDirBuf = Array(dir.utf16) + [0]
    }
    
    let result: Bool = fileNameBuf.withUnsafeMutableBufferPointer { fileBuf in
      filterBuf.withUnsafeMutableBufferPointer { fltBuf in
        initDirBuf.isEmpty
        ? _openDialogCore(fileBuf: fileBuf, fltBuf: fltBuf, initDir: nil)
        : initDirBuf.withUnsafeMutableBufferPointer { dirBuf in
          _openDialogCore(fileBuf: fileBuf, fltBuf: fltBuf, initDir: dirBuf.baseAddress)
        }
      }
    }
    
    if result {
      let nullIdx = fileNameBuf.firstIndex(of: 0) ?? fileNameBuf.endIndex
      let fullPath = String(decoding: fileNameBuf[..<nullIdx], as: UTF16.self)
      let url = URL(fileURLWithPath: fullPath)
      file      = url.lastPathComponent
      directory = url.deletingLastPathComponent().path + "/"
    } else {
      file      = nil
      directory = nil
    }
  }
  
  private func _openDialogCore(
    fileBuf: UnsafeMutableBufferPointer<WCHAR>,
    fltBuf:  UnsafeMutableBufferPointer<WCHAR>,
    initDir: UnsafeMutablePointer<WCHAR>?
  ) -> Bool {
    var ofn = OPENFILENAMEW()
    ofn.lStructSize     = DWORD(MemoryLayout<OPENFILENAMEW>.size)
    ofn.lpstrFilter     = UnsafePointer(fltBuf.baseAddress)
    ofn.lpstrFile       = fileBuf.baseAddress
    ofn.nMaxFile        = DWORD(fileBuf.count)
    ofn.lpstrInitialDir = UnsafePointer(initDir)
    // OFN_HIDEREADONLY=4, OFN_PATHMUSTEXIST=0x800, OFN_FILEMUSTEXIST=0x1000, OFN_OVERWRITEPROMPT=2
    ofn.Flags = DWORD(0x0004 | 0x0800 | 0x1000) // HIDEREADONLY | PATHMUSTEXIST | FILEMUSTEXIST
    
    // Title as wide string (pinned for duration of call)
    let titleWide = Array(getTitle().utf16) + [WCHAR(0)]
    return titleWide.withUnsafeBufferPointer { titleBuf in
      ofn.lpstrTitle = titleBuf.baseAddress
      switch mode {
      case .LOAD :
        return GetOpenFileNameW(&ofn)
      case .SAVE :
        ofn.Flags = DWORD(0x0002 | 0x0004 | 0x0800) // OVERWRITEPROMPT | HIDEREADONLY | PATHMUSTEXIST
        return GetSaveFileNameW(&ofn)
      }
    }
  }
}
#endif
