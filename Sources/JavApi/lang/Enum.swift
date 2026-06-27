/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java compiler generates some functions
public protocol Enum<E> : CaseIterable {
  associatedtype E
  func valueOf(_ name : String) throws (IllegalArgumentException) -> E
  func values() -> [E]
}

extension java.lang.Enum {

  public func values() -> [E] {
    let all = Self.allCases
    var values : [E] = []
    for case let e as E in all {
      values.append(e)
    }
    return values
  }
  
  public func valueOf(_ name : String) throws (IllegalArgumentException) -> E {
    throw IllegalArgumentException("Not implemented")
  }
}
