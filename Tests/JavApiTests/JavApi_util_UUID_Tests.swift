/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_util_UUID_Tests : XCTestCase {
  
  func testCreateRandom () {
    let uuid_1 = java.util.UUID.randomUUID()
    let uuid_2 = java.util.UUID.randomUUID()
    
    XCTAssertNotEqual(uuid_1, uuid_2)
  }
  
  func testCreateFormString () throws {
    let uuid1 = try UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1") // created with Java
    let uuid2 = try UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    let uuid3 = try UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d2")
    
    XCTAssertEqual(uuid1, uuid2)
    XCTAssertNotEqual(uuid1, uuid3)
  }
  
  func testCreateFromName () throws {
    let uuid1 = try UUID.nameUUIDFromBytes("www.ritter.biz".getBytes("UTF-8"))
    let uuid2 = try UUID.nameUUIDFromBytes("www.ritter.biz".getBytes("UTF-8"))
    let uuid3 = try UUID.nameUUIDFromBytes("www.example.com".getBytes("UTF-8"))
    XCTAssertEqual(uuid1, uuid2)
    XCTAssertNotEqual(uuid1, uuid3)
  }
  
  
}
