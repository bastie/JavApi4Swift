/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Float {
  /// A more Swift-like parseFloat function
  public static func parseFloat(_ s: String?) -> Float? {
    guard let s else { return nil }
    return Float(s.trim())
  }
}
