/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

#if canImport(AppKit)
import AppKit
import UniformTypeIdentifiers
#elseif os(Windows)
import WinSDK
#endif

extension java.awt {

  /// Nativer Dateiauswahl-Dialog — mirrors `java.awt.FileDialog`.
  ///
  /// Hierarchie: Component → Container → Window → Dialog → **FileDialog**
  ///
  /// Auf macOS mappt `LOAD` auf `NSOpenPanel` und `SAVE` auf `NSSavePanel`.
  /// Der Dialog ist immer modal (Java-Spezifikation).
  ///
  /// ### Verwendung
  /// ```swift
  /// let fd = java.awt.FileDialog(parentFrame, "Öffnen", java.awt.FileDialog.LOAD)
  /// fd.setVisible(true)          // blockiert bis der User auswählt oder abbricht
  /// if let file = fd.getFile() {
  ///   print(fd.getDirectory()! + file)
  /// }
  /// ```
  @MainActor
  open class FileDialog: Dialog {

    // -------------------------------------------------------------------------
    // MARK: Modus-Konstanten
    // -------------------------------------------------------------------------

    /// Öffnen-Modus — mappt auf NSOpenPanel.
    public static let LOAD = 0
    /// Speichern-Modus — mappt auf NSSavePanel.
    public static let SAVE = 1

    // -------------------------------------------------------------------------
    // MARK: Eigenschaften
    // -------------------------------------------------------------------------

    /// Aktueller Modus: `LOAD` oder `SAVE`.
    public private(set) var mode: Int

    /// Verzeichnis, das beim Öffnen angezeigt wird.
    /// Nach `setVisible(true)` enthält es das Verzeichnis der gewählten Datei.
    public var directory: String?

    /// Dateiname ohne Verzeichnispfad.
    /// Nach `setVisible(true)` enthält es den gewählten Namen, oder `nil`
    /// wenn der Nutzer abgebrochen hat.
    public var file: String?

    /// Optionaler Dateifilter, z.B. `"*.swift;*.txt"` oder `"swift;txt"`.
    public var filenameFilter: String?

    // -------------------------------------------------------------------------
    // MARK: Konstruktoren
    // -------------------------------------------------------------------------

    public init(_ parent: Frame?, _ title: String = "", _ mode: Int = FileDialog.LOAD) {
      self.mode = mode
      super.init(parent, title, true)   // FileDialog ist laut Java-Spec immer modal
    }

    // -------------------------------------------------------------------------
    // MARK: Java API
    // -------------------------------------------------------------------------

    public func getMode()      -> Int     { mode }
    public func getDirectory() -> String? { directory }
    public func getFile()      -> String? { file }

    public func setDirectory(_ dir: String?) { directory = dir }
    public func setFile(_ f: String?)        { file = f }
    public func setMode(_ m: Int)            { mode = m }

    // -------------------------------------------------------------------------
    // MARK: setVisible — öffnet den nativen Panel synchron (runModal)
    // -------------------------------------------------------------------------

    open override func setVisible(_ visible: Bool) {
      guard visible else { return }

#if canImport(AppKit)
      let extensions = parseExtensions(filenameFilter)

      if mode == java.awt.FileDialog.LOAD {
        // ── NSOpenPanel ──────────────────────────────────────────────────────
        let panel = NSOpenPanel()
        panel.title                  = getTitle()
        panel.canChooseFiles          = true
        panel.canChooseDirectories    = false
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles        = false

        applyExtensions(extensions, to: panel)
        applyDirectory(to: panel)
        if let f = file { panel.nameFieldStringValue = f }

        if panel.runModal() == .OK, let url = panel.url {
          file      = url.lastPathComponent
          directory = url.deletingLastPathComponent().path + "/"
        } else {
          file      = nil
          directory = nil
        }

      } else {
        // ── NSSavePanel ──────────────────────────────────────────────────────
        let panel = NSSavePanel()
        panel.title = getTitle()

        applyExtensions(extensions, to: panel)
        applyDirectory(to: panel)
        if let f = file { panel.nameFieldStringValue = f }

        if panel.runModal() == .OK, let url = panel.url {
          file      = url.lastPathComponent
          directory = url.deletingLastPathComponent().path + "/"
        } else {
          file      = nil
          directory = nil
        }
      }
#elseif os(Windows)
      _runWin32FileDialog()
#elseif os(Linux) || os(FreeBSD)
      _runLinuxFileDialog()
#else
      // Headless — keine native Implementierung
      file      = nil
      directory = nil
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Hilfsmethoden (plattformunabhängig)
    // -------------------------------------------------------------------------

    /// Parst `"*.swift;*.txt"` oder `"swift;txt"` in `["swift", "txt"]`.
    private func parseExtensions(_ filter: String?) -> [String] {
      guard let f = filter, !f.isEmpty else { return [] }
      return f
        .components(separatedBy: CharacterSet(charactersIn: ";,| "))
        .map { $0.trimmingCharacters(in: .whitespaces)
                  .replacingOccurrences(of: "*.", with: "")
                  .replacingOccurrences(of: ".",  with: "") }
        .filter { !$0.isEmpty }
    }

#if os(Windows)
    /// Runs GetOpenFileNameW or GetSaveFileNameW synchronously and stores the result.
    private func _runWin32FileDialog() {
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
        if mode == java.awt.FileDialog.LOAD {
          return GetOpenFileNameW(&ofn)
        } else {
          ofn.Flags = DWORD(0x0002 | 0x0004 | 0x0800) // OVERWRITEPROMPT | HIDEREADONLY | PATHMUSTEXIST
          return GetSaveFileNameW(&ofn)
        }
      }
    }
#endif

#if os(Linux) || os(FreeBSD)
    /// Tries `zenity` (GNOME), then `kdialog` (KDE) to show a native file dialog.
    /// Both tools block until the user confirms or cancels, so this method is
    /// naturally synchronous — matching the macOS `runModal()` / Windows `GetOpenFileNameW` pattern.
    private func _runLinuxFileDialog() {
      let isSave = (mode == java.awt.FileDialog.SAVE)
      let title  = getTitle().isEmpty ? (isSave ? "Save" : "Open") : getTitle()

      // ── Try zenity (GTK / GNOME) ─────────────────────────────────────────────
      if let path = _runZenity(title: title, isSave: isSave) {
        _setResult(path: path); return
      }
      // ── Try kdialog (KDE / Qt) ────────────────────────────────────────────────
      if let path = _runKdialog(title: title, isSave: isSave) {
        _setResult(path: path); return
      }
      // ── Nothing available — leave file/directory nil ──────────────────────────
      file      = nil
      directory = nil
    }

    private func _setResult(path: String) {
      let url   = URL(fileURLWithPath: path)
      file      = url.lastPathComponent
      directory = url.deletingLastPathComponent().path + "/"
    }

    /// Runs `zenity --file-selection …` and returns the chosen path, or nil.
    private func _runZenity(title: String, isSave: Bool) -> String? {
      var args = ["zenity", "--file-selection", "--title=\(title)"]
      if isSave { args.append("--save") }
      if let dir = directory { args.append("--filename=\(dir)") }
      if let f   = file, !f.isEmpty, let dir = directory {
        args[args.count - 1] = "--filename=\(dir)\(f)"
      }
      let exts = parseExtensions(filenameFilter)
      if !exts.isEmpty {
        let pattern = exts.map { "*.\($0)" }.joined(separator: " ")
        args += ["--file-filter=\(pattern)"]
      }
      return _runTool(args)
    }

    /// Runs `kdialog --getopenfilename` / `--getsavefilename` and returns the path, or nil.
    private func _runKdialog(title: String, isSave: Bool) -> String? {
      let startDir = directory ?? FileManager.default.currentDirectoryPath
      let verb     = isSave ? "--getsavefilename" : "--getopenfilename"
      var args     = ["kdialog", verb, startDir, "--title", title]
      let exts     = parseExtensions(filenameFilter)
      if !exts.isEmpty {
        let pattern = exts.map { "*.\($0)" }.joined(separator: " ")
        args.append(pattern)
      }
      return _runTool(args)
    }

    /// Forks the given command, waits for it, and returns trimmed stdout, or nil on error / cancel.
    private func _runTool(_ args: [String]) -> String? {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
      process.arguments     = args
      let pipe = Pipe()
      process.standardOutput = pipe
      process.standardError  = Pipe()   // swallow errors silently
      do {
        try process.run()
        process.waitUntilExit()
      } catch {
        return nil
      }
      guard process.terminationStatus == 0 else { return nil }
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let out  = String(data: data, encoding: .utf8)?
                   .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      return out.isEmpty ? nil : out
    }
#endif

#if canImport(AppKit)
    private func applyExtensions(_ exts: [String], to panel: NSSavePanel) {
      guard !exts.isEmpty else { return }
      if #available(macOS 11.0, *) {
        panel.allowedContentTypes = exts.compactMap { UTType(filenameExtension: $0) }
      } else {
        panel.allowedFileTypes = exts
      }
    }

    private func applyDirectory(to panel: NSSavePanel) {
      if let dir = directory {
        panel.directoryURL = URL(fileURLWithPath: dir, isDirectory: true)
      }
    }
#endif
  }
}
