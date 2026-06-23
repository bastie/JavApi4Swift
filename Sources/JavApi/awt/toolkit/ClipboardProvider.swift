/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.toolkit {

  /// Platform-specific clipboard backend.
  ///
  /// Analogous to ``RobotProvider`` and ``FileDialogProvider``, each platform
  /// extension provides exactly one conforming type guarded by
  /// `#if canImport(…)` / `#if os(…)`.
  ///
  /// The two methods deal only with plain text because that is the scope of
  /// the Java 1.1 `StringSelection` API. Richer types (images, files, …) can
  /// be added in a future iteration.
  ///
  /// - Since: JavaApi (Java 1.1 datatransfer)
  public protocol ClipboardProvider: Sendable {

    /// Reads the current plain-text contents of the system clipboard.
    ///
    /// Returns `nil` if the clipboard is empty or does not contain text.
    func _getClipboardText() -> String?

    /// Writes plain text to the system clipboard, replacing any previous
    /// contents.
    func _setClipboardText(_ text: String)
  }
}
