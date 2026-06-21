/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.datatransfer {

  /// A clipboard object that transfers data using cut/copy/paste operations.
  ///
  /// Mirrors `java.awt.datatransfer.Clipboard` (Java 1.1).
  ///
  /// Obtain the system clipboard via `Toolkit`:
  /// ```swift
  /// let clipboard = java.awt.Toolkit.getDefaultToolkit().getSystemClipboard()
  /// ```
  ///
  /// The implementation delegates the actual read/write to a
  /// ``java.awt.toolkit.ClipboardProvider`` that is supplied by the active
  /// platform toolkit (SwiftUI/AppKit, Win32, X11, or the headless in-memory
  /// fallback used on WASI and server builds).
  ///
  /// - Since: JavaApi (Java 1.1)
  public final class Clipboard: @unchecked Sendable {

    private let name: String
    private let provider: any java.awt.toolkit.ClipboardProvider
    private var owner: (any ClipboardOwner)?
    private var contents: (any Transferable)?

    /// Creates a clipboard with the given name backed by `provider`.
    ///
    /// - Parameters:
    ///   - name:     A human-readable name (e.g. `"System"` or `"AWT clipboard"`).
    ///   - provider: The platform backend that performs the real clipboard I/O.
    public init(name: String, provider: any java.awt.toolkit.ClipboardProvider) {
      self.name = name
      self.provider = provider
    }

    // MARK: - Public API

    /// Returns the name of this clipboard.
    public func getName() -> String { name }

    /// Sets the current contents of the clipboard to the specified
    /// `Transferable` object and registers the specified clipboard owner as
    /// the owner of the new contents.
    ///
    /// If the clipboard currently has an owner that is different from the
    /// argument, the old owner's ``ClipboardOwner/lostOwnership(_:_:)`` method
    /// is called.
    public func setContents(_ contents: any Transferable, _ owner: (any ClipboardOwner)?) {
      // Notify previous owner
      if let previousOwner = self.owner,
         let previousContents = self.contents,
         previousOwner !== owner as AnyObject? {
        previousOwner.lostOwnership(self, previousContents)
      }
      self.contents = contents
      self.owner = owner

      // Push text to the platform clipboard if the content supports stringFlavor
      if let text = try? contents.getTransferData(DataFlavor.stringFlavor) as? String {
        provider._setClipboardText(text)
      }
    }

    /// Returns a `Transferable` object representing the current contents of
    /// the clipboard.
    ///
    /// If the clipboard has no contents, or the contents have been replaced by
    /// native operations since the last call to ``setContents(_:_:)``, this
    /// method reads the platform clipboard and wraps the result in a
    /// ``StringSelection``.
    ///
    /// - Parameter requestor: The object requesting the clipboard data
    ///   (unused in this implementation, kept for API compatibility).
    /// - Returns: The current clipboard contents, or `nil` if empty.
    public func getContents(_ requestor: AnyObject?) -> (any Transferable)? {
      // If we have in-process contents, prefer those — they may carry richer flavors.
      if let c = contents { return c }
      // Fall back to reading the platform clipboard as plain text.
      guard let text = provider._getClipboardText() else { return nil }
      return StringSelection(text)
    }

    /// Returns `true` if the clipboard currently has contents available in the
    /// given flavor.
    public func isDataFlavorAvailable(_ flavor: DataFlavor) -> Bool {
      guard let c = getContents(nil) else { return false }
      return c.isDataFlavorSupported(flavor)
    }

    /// Retrieves the data in the specified flavor directly.
    ///
    /// - Throws: ``UnsupportedFlavorException`` if not supported.
    public func getData(_ flavor: DataFlavor) throws -> Any {
      guard let c = getContents(nil) else {
        throw UnsupportedFlavorException(flavor)
      }
      return try c.getTransferData(flavor)
    }
  }
}
