/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CryptoKit)
import CryptoKit

// Swiftify
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Insecure {
  public typealias CRC32C = java.util.zip.CRC32C
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Insecure.CRC32C {
  /// Hash name
  public var description: String { "CRC-32C" }
}
#endif
