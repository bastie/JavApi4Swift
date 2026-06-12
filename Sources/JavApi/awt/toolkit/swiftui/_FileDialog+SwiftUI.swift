/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

///
/// Extension for FileDialog on SwiftUI platforms. **Must implement `_setToolkitVisible`!**
///


#if canImport(AppKit)
import AppKit
import UniformTypeIdentifiers
import Foundation

extension java.awt.FileDialog {
  
  public func _setToolkitVisible() {
    let extensions = parseExtensions(filenameFilter)
    
    switch mode {
    case .LOAD :
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
      
    case .SAVE :
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
  }

  private func applyExtensions(_ exts: [String], to panel: NSSavePanel) {
    guard !exts.isEmpty else { return }
    if #available(macOS 11.0, *) {
      panel.allowedContentTypes = exts.compactMap {
        UTType(filenameExtension: $0)
      }
    }
    else {
      panel.allowedFileTypes = exts
    }
  }
  
  private func applyDirectory(to panel: NSSavePanel) {
    if let dir = directory {
      panel.directoryURL = URL(fileURLWithPath: dir, isDirectory: true)
    }
  }
}
#endif
