/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension System {
  
  /// Implements a different getProperty NullPattern like implementation without nil-able or throwable results
  public static func getProperty (_ key : String = "", _ resultIfMissing : String) -> String {
    guard !key.isEmpty() else {
      return resultIfMissing
    }

    if SYSTEM_PROPERTIES.keys.contains(key) {
      return SYSTEM_PROPERTIES[key]!
    }
    return resultIfMissing
  }
  
  /// Return the current time in nanoseconds
  ///
  /// - Returns: milliseconds as UInt64
  public static func currentTimeNanos () -> UInt64 {
    return UInt64(Date().timeIntervalSince1970.advanced(by: 0)*1_000_000)
  }
}
