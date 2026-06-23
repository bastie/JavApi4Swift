/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(AppKit)
import AppKit

extension java.awt.toolkit {

  /// macOS clipboard backend backed by `NSPasteboard.general`.
  ///
  /// - Since: JavaApi (Java 1.1 datatransfer)
  public final class _AppKitClipboardProvider: ClipboardProvider, @unchecked Sendable {

    public init() {}

    public func _getClipboardText() -> String? {
      NSPasteboard.general.string(forType: .string)
    }

    public func _setClipboardText(_ text: String) {
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(text, forType: .string)
    }
  }
}
#endif
