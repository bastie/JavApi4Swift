/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux)
enum Insecure{}
#else
import CryptoKit
#endif

// Swiftify
@available(macOS 10.15, *)
extension Insecure {
  public typealias CRC32C = java.util.zip.CRC32C
}

@available(macOS 10.15, *)
extension Insecure.CRC32C {
  
  /// Hash name
  public var description : String {
    get {"CRC-32C"}
  }
}
