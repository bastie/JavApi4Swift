/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension Substring : CharSequence {
  public func toString() -> String {
      let result = String(self)
      return result
  }
}
