/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(tvOS) || os(watchOS)
import Foundation

extension java.awt.toolkit {

  /// In-app clipboard backend for tvOS and watchOS.
  ///
  /// Both platforms provide no accessible system clipboard API, so this
  /// implementation keeps the clipboard content in process memory.
  /// Copy/paste works fully within the same app instance; content is
  /// not shared with other apps or persisted across launches.
  ///
  /// Thread-safety is achieved via a dedicated `actor` so the
  /// implementation is compatible with Swift 6.3 strict concurrency.
  ///
  /// - Since: JavaApi (Java 1.1 datatransfer)
  public final class _UIKitClipboardProvider: ClipboardProvider, @unchecked Sendable {

    private let lock = NSLock()
    private var _text: String? = nil

    public init() {}

    public func _getClipboardText() -> String? {
      lock.withLock { _text }
    }

    public func _setClipboardText(_ text: String) {
      lock.withLock { _text = text }
    }
  }
}
#endif
