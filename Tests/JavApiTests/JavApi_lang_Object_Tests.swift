/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

/// Note: implements base tests
final class JavApi_lang_Object_Tests: XCTestCase {

  public func testEqualable () {
    
    let not1_1 = NoObjectType(1)
    let not1_2 = NoObjectType(1)
    let not2_1 = NoObjectType(2)
    
    XCTAssertEqual(not1_1, not1_2)
    XCTAssertNotEqual(not1_1, not2_1)

    // Test other hashCode with same value
    XCTAssertEqual(not1_1.value, not1_2.value)
    XCTAssertNotEqual(not1_1.hashValue, not1_2.hashValue)

  }
  
}

public class NoObjectType : Equatable, Hashable {
  
  internal var value: Int
  
  public init (_ newValue: Int) {
    value = newValue
  }
  
  // the Java method
  public func hashCode () -> Int {
    return hashValue // delegate work to Swift function
  }
  
  // a property for hash value but without calculate this
  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher) // delegate the calculate into the hash function
    return hasher.finalize()
  }
  
  // calculate the hash
  public func hash(into hasher: inout Hasher) {
    hasher.combine(System.identityHashCode(self)) // put a system identical hash code part for this object
                                                  // add more specific hash information over add some lines with
                                                  // hasher.combine(...)
    hasher.combine(value)
  }
  
  public static func == (lhs: NoObjectType, rhs: NoObjectType) -> Bool {
    return lhs.value == rhs.value
  }
}
