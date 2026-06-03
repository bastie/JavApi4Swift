/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_security_MessageDigest_Tests {

  @Test("MD5 algorithm is available")
  func testMD5Available() throws {
    #expect(throws: Never.self) {
      try java.security.MessageDigest.getInstance("MD5")
    }
  }

  @Test("MD5 of 'hello' matches known hash")
  func testMD5KnownHash() throws {
    let md = try java.security.MessageDigest.getInstance("MD5")
    let input: [UInt8] = Array("hello".utf8)
    let hash = md.digest(input)
    // MD5("hello") = 5d41402abc4b2a76b9719d911017c592
    let expected: [UInt8] = [0x5d, 0x41, 0x40, 0x2a, 0xbc, 0x4b, 0x2a, 0x76,
                              0xb9, 0x71, 0x9d, 0x91, 0x10, 0x17, 0xc5, 0x92]
    #expect(hash == expected)
  }

  @Test("MD5 of empty input matches known hash")
  func testMD5EmptyInput() throws {
    let md = try java.security.MessageDigest.getInstance("MD5")
    let hash = md.digest([])
    // MD5("") = d41d8cd98f00b204e9800998ecf8427e
    let expected: [UInt8] = [0xd4, 0x1d, 0x8c, 0xd9, 0x8f, 0x00, 0xb2, 0x04,
                              0xe9, 0x80, 0x09, 0x98, 0xec, 0xf8, 0x42, 0x7e]
    #expect(hash == expected)
  }

  @Test("unknown algorithm throws NoSuchAlgorithmException")
  func testUnknownAlgorithmThrows() {
    #expect(throws: (any Error).self) {
      try java.security.MessageDigest.getInstance("UNKNOWN_ALGO")
    }
  }

  @Test("SwiftMessageDigestProvidedAlgorithm.provides reflects supported algorithms")
  func testProvidedAlgorithms() {
    #expect(SwiftMessageDigestProvidedAlgorithm.provides(algorithm: "MD5"))
    #expect(!SwiftMessageDigestProvidedAlgorithm.provides(algorithm: "UNKNOWN"))
  }
}
