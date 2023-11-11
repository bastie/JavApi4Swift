/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension System {
  
  /// Implements a different getProperty NullPattern like implementation without nil-able or throwable results
  public static func getProperty (_ key : String = "", _ resultIfMissing : String) -> String {
    let internalKey = key.isEmpty() ? "salt\(java.security.SecureRandom().nextInt())pepper" : key
    if SYSTEM_PROPERTIES.keys.contains(internalKey) {
      return SYSTEM_PROPERTIES[internalKey]!
    }
    return resultIfMissing
  }
  
}
