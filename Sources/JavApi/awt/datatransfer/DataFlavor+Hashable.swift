/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.datatransfer.DataFlavor: Hashable {

  /// Hashes on the same normalised MIME type used by `==`
  /// (case-insensitive, full string including parameters — matching
  /// `DataFlavor`'s existing `Equatable` conformance), so `DataFlavor` can
  /// be used as a `Dictionary` key (needed by ``SystemFlavorMap``).
  public func hash(into hasher: inout Hasher) {
    hasher.combine(getMimeType().lowercased())
  }
}
