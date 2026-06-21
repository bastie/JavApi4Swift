/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension java.awt.toolkit {

  /// iOS / tvOS clipboard backend backed by `UIPasteboard.general`.
  ///
  /// - Since: JavaApi (Java 1.1 datatransfer)
  public final class _UIKitClipboardProvider: ClipboardProvider, @unchecked Sendable {

    public init() {}

    public func _getClipboardText() -> String? {
      UIPasteboard.general.string
    }

    public func _setClipboardText(_ text: String) {
      UIPasteboard.general.string = text
    }
  }
}
#endif
