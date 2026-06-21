/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.datatransfer {

  /// Defines the interface for classes that can provide data for a transfer
  /// operation.
  ///
  /// Mirrors `java.awt.datatransfer.Transferable` (Java 1.1).
  ///
  /// A `Transferable` exposes one or more ``DataFlavor``s that describe the
  /// available representations of its data. Callers first call
  /// ``getTransferDataFlavors()`` to discover what is on offer, then retrieve
  /// the actual data via ``getTransferData(_:)``.
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol Transferable {

    /// Returns an array of `DataFlavor` objects in which this data can be
    /// provided. The array is ordered from the most descriptive to least
    /// descriptive representation.
    func getTransferDataFlavors() -> [DataFlavor]

    /// Returns whether the specified `DataFlavor` is supported.
    func isDataFlavorSupported(_ flavor: DataFlavor) -> Bool

    /// Returns the data in the requested `DataFlavor`.
    ///
    /// - Throws: ``UnsupportedFlavorException`` if the flavor is not supported.
    func getTransferData(_ flavor: DataFlavor) throws -> Any
  }
}
