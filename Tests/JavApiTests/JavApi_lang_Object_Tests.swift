/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Note: implements base tests
struct JavApi_lang_Object_Tests {

  @Test("equality is value-based, hashValue is identity-based")
  func testEqualable() {
    let not1_1 = NoObjectType(1)
    let not1_2 = NoObjectType(1)
    let not2_1 = NoObjectType(2)

    // == is value-based: same value → equal
    #expect(not1_1 == not1_2)
    #expect(not1_1 != not2_1)

    // hashValue is identity-based: same value, different instances → different hash
    #expect(not1_1.value     == not1_2.value)
    #expect(not1_1.hashValue != not1_2.hashValue)
  }
}

// MARK: - Helper type (kept public for potential reuse across tests)

public class NoObjectType: Equatable, Hashable {

  internal var value: Int

  public init(_ newValue: Int) {
    value = newValue
  }

  /// Java-style hashCode delegates to Swift hashValue
  public func hashCode() -> Int { hashValue }

  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher)
    return hasher.finalize()
  }

  public func hash(into hasher: inout Hasher) {
    // Identity-based component ensures distinct objects never share a hash,
    // even when their value fields are equal.
    hasher.combine(System.identityHashCode(self))
    hasher.combine(value)
  }

  public static func == (lhs: NoObjectType, rhs: NoObjectType) -> Bool {
    lhs.value == rhs.value
  }
}
