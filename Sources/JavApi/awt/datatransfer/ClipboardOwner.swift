/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.datatransfer {

  /// Implemented by objects that wish to be notified when they are no longer
  /// the owner of the system clipboard contents.
  ///
  /// Mirrors `java.awt.datatransfer.ClipboardOwner` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol ClipboardOwner: AnyObject {

    /// Called when this object is no longer the owner of the contents of the
    /// clipboard.
    ///
    /// - Parameters:
    ///   - clipboard: The clipboard that is no longer owned.
    ///   - contents: The contents that were previously on the clipboard.
    func lostOwnership(_ clipboard: Clipboard, _ contents: any Transferable)
  }
}
