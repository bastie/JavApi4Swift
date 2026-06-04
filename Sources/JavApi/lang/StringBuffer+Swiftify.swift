/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension StringBuffer {

  /// The number of characters in the buffer. Swift-idiomatic alias for ``length()``.
  public var count: Int {
    return self.length()
  }
}

extension StringBuffer: Equatable {
  public static func == (lhs: StringBuffer, rhs: StringBuffer) -> Bool {
    return lhs === rhs
  }
}

extension StringBuffer: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
    hasher.combine(self.toString())
  }
}

extension StringBuffer: CustomStringConvertible {
  public var description: String { toString() }
}
