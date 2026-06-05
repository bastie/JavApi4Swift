/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CryptoKit)
import CryptoKit

// Swiftify
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Insecure {
  public typealias Adler32 = java.util.zip.Adler32
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Insecure.Adler32 {
  /// Hash name
  public var description: String { "Adler-32" }
}
#endif
