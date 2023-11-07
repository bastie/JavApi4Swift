/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Double {
  /// A more Swift like parseDouble function
  public static func parseDouble (_ s : String?) -> Double? {
    if let s {
      return Double(s)
    }
    return nil
  }
}
