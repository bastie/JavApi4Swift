/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


///
/// Extension for FileDialog on X11 platforms. **Must implement `_setToolkitVisible`!**
///

#if os(Linux) || os(FreeBSD)
import Foundation

extension java.awt.FileDialog {

  /// Tries `zenity` (GNOME), then `kdialog` (KDE) to show a native file dialog.
  /// Both tools block until the user confirms or cancels, so this method is
  /// naturally synchronous — matching the macOS `runModal()` / Windows `GetOpenFileNameW` pattern.
  public func _setToolkitVisible() {
    
    let isSave = mode == .SAVE
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
}
#endif
