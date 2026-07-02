/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(AppKit) && os(macOS)
import AppKit

extension java.awt.dnd {

  /// Bridges between `java.awt.datatransfer` types and AppKit's `NSPasteboard` API.
  ///
  /// Used internally by the macOS DnD backend to convert drag payloads.
  enum _AppKitPasteboardBridge {

    // ── DataFlavor → NSPasteboard.PasteboardType ─────────────────────────────

    /// Maps a `DataFlavor` to the closest `NSPasteboard.PasteboardType`.
    ///
    /// Returns `nil` for flavors that have no known AppKit equivalent.
    static func pasteboardType(
      for flavor: java.awt.datatransfer.DataFlavor
    ) -> NSPasteboard.PasteboardType? {
      let mime = flavor.getMimeType()
      if mime.hasPrefix("application/x-java-serialized-object") &&
         mime.contains("class=java.lang.String") {
        return .string
      }
      if mime.hasPrefix("text/plain") { return .string }
      if mime.hasPrefix("text/html")  { return .html   }
      if mime.hasPrefix("text/uri-list") || mime.hasPrefix("application/x-java-file-list") {
        return .fileURL
      }
      if mime.hasPrefix("image/") { return .tiff }
      // Fallback: use the MIME type as a custom UTI
      return NSPasteboard.PasteboardType(rawValue: mime)
    }

    // ── NSPasteboard.PasteboardType → DataFlavor ─────────────────────────────

    /// Maps an `NSPasteboard.PasteboardType` to a `DataFlavor`.
    static func dataFlavor(
      for type: NSPasteboard.PasteboardType
    ) -> java.awt.datatransfer.DataFlavor? {
      switch type {
      case .string:  return java.awt.datatransfer.DataFlavor.stringFlavor
      case .fileURL: return java.awt.datatransfer.DataFlavor.javaFileListFlavor
      default:       return nil
      }
    }

    // ── NSDragOperation ↔ DnDConstants ───────────────────────────────────────

    /// Converts a `DnDConstants` action mask to `NSDragOperation`.
    static func dragOperation(from dndActions: Int) -> NSDragOperation {
      var ops: NSDragOperation = []
      if dndActions & DnDConstants.ACTION_COPY != 0 { ops.insert(.copy) }
      if dndActions & DnDConstants.ACTION_MOVE != 0 { ops.insert(.move) }
      if dndActions & DnDConstants.ACTION_LINK != 0 { ops.insert(.link) }
      return ops
    }

    /// Converts an `NSDragOperation` to a `DnDConstants` action mask.
    static func dndAction(from nsOp: NSDragOperation) -> Int {
      var action = DnDConstants.ACTION_NONE
      if nsOp.contains(.copy) { action |= DnDConstants.ACTION_COPY }
      if nsOp.contains(.move) { action |= DnDConstants.ACTION_MOVE }
      if nsOp.contains(.link) { action |= DnDConstants.ACTION_LINK }
      return action
    }

    // ── Transferable → NSPasteboardItem ──────────────────────────────────────

    /// Wraps a `Transferable` into an array of `NSPasteboardItem` for
    /// use in `beginDraggingSession(with:event:source:)`.
    static func pasteboardItems(
      for transferable: any java.awt.datatransfer.Transferable
    ) -> [NSPasteboardItem] {
      let item = NSPasteboardItem()
      for flavor in transferable.getTransferDataFlavors() {
        guard let pbType = pasteboardType(for: flavor) else { continue }
        guard let data = try? transferable.getTransferData(flavor) else { continue }
        if let str = data as? String {
          item.setString(str, forType: pbType)
        } else if let nsData = data as? Data {
          item.setData(nsData, forType: pbType)
        }
      }
      return [item]
    }

    // ── NSPasteboard → Transferable wrapper ──────────────────────────────────

    /// Wraps an `NSDraggingInfo` pasteboard into a `Transferable` that
    /// the Java DnD API can read from the drop handler.
    @MainActor
    static func transferable(
      from info: NSDraggingInfo
    ) -> any java.awt.datatransfer.Transferable {
      _NSPasteboardTransferable(pasteboard: info.draggingPasteboard)
    }
  }
}

// MARK: - NSPasteboard-backed Transferable

/// Read-only `Transferable` backed by an `NSPasteboard` (used on the drop side).
private final class _NSPasteboardTransferable: java.awt.datatransfer.Transferable {

  private let pasteboard: NSPasteboard

  init(pasteboard: NSPasteboard) {
    self.pasteboard = pasteboard
  }

  func getTransferDataFlavors() -> [java.awt.datatransfer.DataFlavor] {
    guard let types = pasteboard.types else { return [] }
    return types.compactMap { java.awt.dnd._AppKitPasteboardBridge.dataFlavor(for: $0) }
  }

  func isDataFlavorSupported(_ flavor: java.awt.datatransfer.DataFlavor) -> Bool {
    guard let pbType = java.awt.dnd._AppKitPasteboardBridge.pasteboardType(for: flavor) else {
      return false
    }
    return pasteboard.types?.contains(pbType) ?? false
  }

  func getTransferData(_ flavor: java.awt.datatransfer.DataFlavor) throws -> Any {
    guard let pbType = java.awt.dnd._AppKitPasteboardBridge.pasteboardType(for: flavor) else {
      throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
    }
    if pbType == .string, let str = pasteboard.string(forType: .string) {
      return str
    }
    if pbType == .fileURL,
       let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
      return urls
    }
    throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
  }
}

#endif
