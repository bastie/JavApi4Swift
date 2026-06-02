/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - Equatable

extension java.util.BitSet : Equatable {
  public static func == (lhs: java.util.BitSet, rhs: java.util.BitSet) -> Bool {
    return lhs.equals(rhs)
  }
}

// MARK: - Hashable

extension java.util.BitSet : Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(words)
  }
}

// MARK: - CustomStringConvertible

extension java.util.BitSet : CustomStringConvertible {
  public var description: String {
    return toString()
  }
}
