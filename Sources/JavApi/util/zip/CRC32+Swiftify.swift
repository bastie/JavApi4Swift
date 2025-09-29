/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(macOS)
import CryptoKit
#else
enum Insecure{}
#endif

// Swiftify
@available(macOS 10.15, *)
extension Insecure {
  public typealias CRC32 = java.util.zip.CRC32
}

@available(macOS 10.15, *)
extension Insecure.CRC32 {
  
  /// Hash name
  public var description : String {
    get {"CRC-32"}
  }
}
