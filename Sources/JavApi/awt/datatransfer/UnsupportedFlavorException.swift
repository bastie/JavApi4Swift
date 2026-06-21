/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.datatransfer {

  /// Thrown by ``Transferable/getTransferData(_:)`` when the requested
  /// ``DataFlavor`` is not supported.
  ///
  /// Mirrors `java.awt.datatransfer.UnsupportedFlavorException` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  public final class UnsupportedFlavorException: java.lang.Exception, @unchecked Sendable {

    /// The flavor that was not supported, if available.
    public private(set) var flavor: DataFlavor?

    /// Creates an exception for the given unsupported flavor.
    public init(_ flavor: DataFlavor) {
      self.flavor = flavor
      super.init("Unsupported DataFlavor: \(flavor.getMimeType())")
    }

    /// Creates an exception with a plain message (for compatibility).
    public override init(_ message: String) {
      self.flavor = nil
      super.init(message)
    }
  }
}
