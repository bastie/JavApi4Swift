/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Cloneable {
  // Swift called the function copy instead clone
  func copy() -> Cloneable { // TODO: check the result type
    return try! self.clone()
  }
}
