/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - Sequence / IteratorProtocol

/// Makes ``java.util.StringTokenizer`` usable in Swift `for`-`in` loops.
///
/// ```swift
/// let st = java.util.StringTokenizer("one,two,three", ",")
/// for token in st {
///     print(token)   // one, two, three
/// }
/// ```
extension java.util.StringTokenizer : Sequence, IteratorProtocol {

  public func next() -> String? {
    guard hasMoreTokens() else { return nil }
    return try? nextToken()
  }

  public func makeIterator() -> java.util.StringTokenizer {
    return self
  }
}
