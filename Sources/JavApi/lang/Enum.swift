/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java compiler generates some functions
/// - Since: Java 5
public protocol Enum<E> : CaseIterable {
  associatedtype E
  
  /// Subtypes should be implement, by default throws `IllegalArgumentException`.
  /// - Throws: `IllegalArgumentException` if no implementation for given `name`
  /// - Parameter name: name of enum
  /// - Returns: enum value
  func valueOf(_ name : String) throws (IllegalArgumentException) -> E
  /// Values of the enum.
  /// - Note: Swift has `allCases` properties
  /// - Returns: all cases of enumeration
  func values() -> [E]
}

extension java.lang.Enum {

  // use Swift enum property `allCases` to provide Java function values
  public func values() -> [E] {
    let all = Self.allCases
    var values : [E] = []
    for case let e as E in all {
      values.append(e)
    }
    return values
  }
  
  public func valueOf(_ name : String) throws (IllegalArgumentException) -> E {
    for value in values() {
      if "\(value)" == name {
        return value
      }
    }
    throw IllegalArgumentException("No enum constant with name '\(name)'")
  }
}
