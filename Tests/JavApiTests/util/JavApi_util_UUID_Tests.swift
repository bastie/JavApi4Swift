/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_UUID_Tests {

  @Test("two random UUIDs are not equal")
  func testCreateRandom() {
    let uuid1 = java.util.UUID.randomUUID()
    let uuid2 = java.util.UUID.randomUUID()
    #expect(uuid1 != uuid2)
  }

  @Test("UUID from string parses correctly and compares by value")
  func testCreateFromString() throws {
    let uuid1 = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    let uuid2 = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    let uuid3 = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d2")
    #expect(uuid1 == uuid2)
    #expect(uuid1 != uuid3)
  }

  @Test("nameUUIDFromBytes is deterministic and differs for different inputs")
  func testCreateFromName() throws {
    let uuid1 = try java.util.UUID.nameUUIDFromBytes("www.ritter.biz".getBytes("UTF-8"))
    let uuid2 = try java.util.UUID.nameUUIDFromBytes("www.ritter.biz".getBytes("UTF-8"))
    let uuid3 = try java.util.UUID.nameUUIDFromBytes("www.example.com".getBytes("UTF-8"))
    #expect(uuid1 == uuid2)
    #expect(uuid1 != uuid3)
  }
}
