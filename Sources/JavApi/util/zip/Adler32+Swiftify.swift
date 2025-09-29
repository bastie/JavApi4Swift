/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(macOS)
import CryptoKit
#endif

// Swiftify
@available(macOS 10.15, *)
extension Insecure {
  public typealias Adler32 = java.util.zip.Adler32
}

@available(macOS 10.15, *)
extension Insecure.Adler32 {
  
  /// Hash name
  public var description : String {
    get {"Adler-32"}
  }
}
