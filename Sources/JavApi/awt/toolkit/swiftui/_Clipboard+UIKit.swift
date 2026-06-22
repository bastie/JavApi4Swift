/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
import UIKit

extension java.awt.toolkit {

  /// iOS clipboard backend backed by `UIPasteboard.general`.
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

#if os(tvOS)

extension java.awt.toolkit {

  /// tvOS clipboard backend — no-op (`UIPasteboard` is unavailable on tvOS).
  ///
  /// - Since: JavaApi (Java 1.1 datatransfer)
  public final class _UIKitClipboardProvider: ClipboardProvider, @unchecked Sendable {

    public init() {}

    public func _getClipboardText() -> String? {
      nil
    }

    public func _setClipboardText(_ text: String) {
      // UIPasteboard is unavailable on tvOS — no-op
    }
  }
}
#endif
