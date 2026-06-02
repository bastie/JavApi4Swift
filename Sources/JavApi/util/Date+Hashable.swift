/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.Date : Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(delegate)
  }

  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher)
    return hasher.finalize()
  }

  public func hashCode() -> Int {
    return hashValue
  }
}
