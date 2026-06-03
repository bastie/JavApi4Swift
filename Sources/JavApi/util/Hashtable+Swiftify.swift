/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

// MARK: - Equatable

extension java.util.Hashtable : Equatable where V: Equatable {
  public static func == (lhs: java.util.Hashtable<K, V>, rhs: java.util.Hashtable<K, V>) -> Bool {
    return lhs.storage == rhs.storage
  }
}

// MARK: - CustomStringConvertible

extension java.util.Hashtable : CustomStringConvertible {
  public var description: String {
    return toString()
  }
}

// MARK: - Sequence

/// Enables `for (key, value) in hashtable { }` in Swift.
extension java.util.Hashtable : Sequence {
  public typealias Iterator = Dictionary<K, V>.Iterator

  public func makeIterator() -> Dictionary<K, V>.Iterator {
    return storage.makeIterator()
  }
}
