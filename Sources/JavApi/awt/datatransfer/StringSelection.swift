/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.datatransfer {

  /// A `Transferable` that transfers a `String` as plain Unicode text.
  ///
  /// Mirrors `java.awt.datatransfer.StringSelection` (Java 1.1).
  ///
  /// Typical usage — place text on the system clipboard:
  /// ```swift
  /// let sel = java.awt.datatransfer.StringSelection("Hello, World!")
  /// java.awt.Toolkit.getDefaultToolkit()
  ///     .getSystemClipboard()
  ///     .setContents(sel, sel)
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  public final class StringSelection: Transferable, ClipboardOwner, @unchecked Sendable {

    private let data: String

    /// Creates a `StringSelection` holding the given text.
    public init(_ data: String) {
      self.data = data
    }

    // MARK: - Transferable

    public func getTransferDataFlavors() -> [DataFlavor] {
      [DataFlavor.stringFlavor]
    }

    public func isDataFlavorSupported(_ flavor: DataFlavor) -> Bool {
      flavor == DataFlavor.stringFlavor
    }

    /// Returns the `String` if the flavor is ``DataFlavor/stringFlavor``.
    ///
    /// - Throws: ``UnsupportedFlavorException`` for any other flavor.
    public func getTransferData(_ flavor: DataFlavor) throws -> Any {
      guard isDataFlavorSupported(flavor) else {
        throw UnsupportedFlavorException(flavor)
      }
      return data
    }

    // MARK: - ClipboardOwner

    /// Called when this selection is displaced from the clipboard.
    /// Default implementation does nothing — override in a subclass if needed.
    public func lostOwnership(_ clipboard: Clipboard, _ contents: any Transferable) {
      // no-op by design, mirrors Java behaviour
    }
  }
}
