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
    #expect(SwiftMessageDigestProvidedAlgorithm.provides(algorithm: "SHA-1"))
    #expect(SwiftMessageDigestProvidedAlgorithm.provides(algorithm: "SHA-256"))
    #expect(SwiftMessageDigestProvidedAlgorithm.provides(algorithm: "SHA-384"))
    #expect(!SwiftMessageDigestProvidedAlgorithm.provides(algorithm: "UNKNOWN"))
  }

  // MARK: - SHA-1

  @Test("SHA-1 algorithm is available")
  func testSHA1Available() throws {
    #expect(throws: Never.self) {
      try java.security.MessageDigest.getInstance("SHA-1")
    }
  }

  @Test("SHA-1 of 'hello' matches known hash")
  func testSHA1KnownHash() throws {
    let md = try java.security.MessageDigest.getInstance("SHA-1")
    let hash = md.digest(Array("hello".utf8))
    // SHA-1("hello") = aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
    let expected: [UInt8] = [0xaa, 0xf4, 0xc6, 0x1d, 0xdc, 0xc5, 0xe8, 0xa2,
                              0xda, 0xbe, 0xde, 0x0f, 0x3b, 0x48, 0x2c, 0xd9,
                              0xae, 0xa9, 0x43, 0x4d]
    #expect(hash == expected)
  }

  @Test("SHA-1 of empty input matches known hash")
  func testSHA1EmptyInput() throws {
    let md = try java.security.MessageDigest.getInstance("SHA-1")
    let hash = md.digest([])
    // SHA-1("") = da39a3ee5e6b4b0d3255bfef95601890afd80709
    let expected: [UInt8] = [0xda, 0x39, 0xa3, 0xee, 0x5e, 0x6b, 0x4b, 0x0d,
                              0x32, 0x55, 0xbf, 0xef, 0x95, 0x60, 0x18, 0x90,
                              0xaf, 0xd8, 0x07, 0x09]
    #expect(hash == expected)
  }

  // MARK: - SHA-256

  @Test("SHA-256 algorithm is available")
  func testSHA256Available() throws {
    #expect(throws: Never.self) {
      try java.security.MessageDigest.getInstance("SHA-256")
    }
  }

  @Test("SHA-256 of 'hello' matches known hash")
  func testSHA256KnownHash() throws {
    let md = try java.security.MessageDigest.getInstance("SHA-256")
    let hash = md.digest(Array("hello".utf8))
    // SHA-256("hello") = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
    let expected: [UInt8] = [0x2c, 0xf2, 0x4d, 0xba, 0x5f, 0xb0, 0xa3, 0x0e,
                              0x26, 0xe8, 0x3b, 0x2a, 0xc5, 0xb9, 0xe2, 0x9e,
                              0x1b, 0x16, 0x1e, 0x5c, 0x1f, 0xa7, 0x42, 0x5e,
                              0x73, 0x04, 0x33, 0x62, 0x93, 0x8b, 0x98, 0x24]
    #expect(hash == expected)
  }

  @Test("SHA-256 of empty input matches known hash")
  func testSHA256EmptyInput() throws {
    let md = try java.security.MessageDigest.getInstance("SHA-256")
    let hash = md.digest([])
    // SHA-256("") = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
    let expected: [UInt8] = [0xe3, 0xb0, 0xc4, 0x42, 0x98, 0xfc, 0x1c, 0x14,
                              0x9a, 0xfb, 0xf4, 0xc8, 0x99, 0x6f, 0xb9, 0x24,
                              0x27, 0xae, 0x41, 0xe4, 0x64, 0x9b, 0x93, 0x4c,
                              0xa4, 0x95, 0x99, 0x1b, 0x78, 0x52, 0xb8, 0x55]
    #expect(hash == expected)
  }

  // MARK: - SHA-384

  @Test("SHA-384 algorithm is available")
  func testSHA384Available() throws {
    #expect(throws: Never.self) {
      try java.security.MessageDigest.getInstance("SHA-384")
    }
  }

  @Test("SHA-384 of 'hello' matches known hash")
  func testSHA384KnownHash() throws {
    let md = try java.security.MessageDigest.getInstance("SHA-384")
    let hash = md.digest(Array("hello".utf8))
    // SHA-384("hello") = 59e1748777448c69de6b800d7a33bbfb9ff1b463e44354c3553bcdb9c666fa90125a3c79f90397bdf5f6a13de828684f
    let expected: [UInt8] = [0x59, 0xe1, 0x74, 0x87, 0x77, 0x44, 0x8c, 0x69,
                              0xde, 0x6b, 0x80, 0x0d, 0x7a, 0x33, 0xbb, 0xfb,
                              0x9f, 0xf1, 0xb4, 0x63, 0xe4, 0x43, 0x54, 0xc3,
                              0x55, 0x3b, 0xcd, 0xb9, 0xc6, 0x66, 0xfa, 0x90,
                              0x12, 0x5a, 0x3c, 0x79, 0xf9, 0x03, 0x97, 0xbd,
                              0xf5, 0xf6, 0xa1, 0x3d, 0xe8, 0x28, 0x68, 0x4f]
    #expect(hash == expected)
  }

  @Test("SHA-384 of empty input matches known hash")
  func testSHA384EmptyInput() throws {
    let md = try java.security.MessageDigest.getInstance("SHA-384")
    let hash = md.digest([])
    // SHA-384("") = 38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b
    let expected: [UInt8] = [0x38, 0xb0, 0x60, 0xa7, 0x51, 0xac, 0x96, 0x38,
                              0x4c, 0xd9, 0x32, 0x7e, 0xb1, 0xb1, 0xe3, 0x6a,
                              0x21, 0xfd, 0xb7, 0x11, 0x14, 0xbe, 0x07, 0x43,
                              0x4c, 0x0c, 0xc7, 0xbf, 0x63, 0xf6, 0xe1, 0xda,
                              0x27, 0x4e, 0xde, 0xbf, 0xe7, 0x6f, 0x65, 0xfb,
                              0xd5, 0x1a, 0xd2, 0xf1, 0x48, 0x98, 0xb9, 0x5b]
    #expect(hash == expected)
  }
}
