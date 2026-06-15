/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_net_URLEncoder_Tests {

  // MARK: - Spaces

  @available(*, deprecated)
  @Test("Space is encoded as '+'")
  func testSpaceBecomesPlus() {
    #expect(java.net.URLEncoder.encode("hello world") == "hello+world")
  }

  @available(*, deprecated)
  @Test("Multiple spaces are each encoded as '+'")
  func testMultipleSpaces() {
    #expect(java.net.URLEncoder.encode("a b c") == "a+b+c")
  }

  // MARK: - Unreserved characters (must not be encoded)

  @available(*, deprecated)
  @Test("Letters and digits are not encoded")
  func testUnreservedAlphanumeric() {
    let input = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    #expect(java.net.URLEncoder.encode(input) == input)
  }

  @available(*, deprecated)
  @Test("Unreserved special characters _ - . * are not encoded")
  func testUnreservedSpecial() {
    #expect(java.net.URLEncoder.encode("_-.*") == "_-.*")
  }

  // MARK: - Reserved / special characters

  @available(*, deprecated)
  @Test("Ampersand is percent-encoded")
  func testAmpersand() {
    #expect(java.net.URLEncoder.encode("a&b") == "a%26b")
  }

  @available(*, deprecated)
  @Test("Equals sign is percent-encoded")
  func testEquals() {
    #expect(java.net.URLEncoder.encode("a=b") == "a%3Db")
  }

  @available(*, deprecated)
  @Test("Plus sign is percent-encoded")
  func testPlus() {
    #expect(java.net.URLEncoder.encode("a+b") == "a%2Bb")
  }

  @available(*, deprecated)
  @Test("Slash is percent-encoded")
  func testSlash() {
    #expect(java.net.URLEncoder.encode("a/b") == "a%2Fb")
  }

  @available(*, deprecated)
  @Test("At-sign is percent-encoded")
  func testAtSign() {
    #expect(java.net.URLEncoder.encode("user@example.com") == "user%40example.com")
  }

  // MARK: - Query string use case

  @available(*, deprecated)
  @Test("Typical query string key=value pair is encoded correctly")
  func testQueryPair() {
    let key = java.net.URLEncoder.encode("first name")
    let value = java.net.URLEncoder.encode("John & Jane")
    #expect(key == "first+name")
    #expect(value == "John+%26+Jane")
  }

  // MARK: - Unicode

  @available(*, deprecated)
  @Test("Non-ASCII characters are UTF-8 percent-encoded")
  func testUnicode() {
    // "ä" is U+00E4, UTF-8: 0xC3 0xA4
    #expect(java.net.URLEncoder.encode("ä") == "%C3%A4")
    // "€" is U+20AC, UTF-8: 0xE2 0x82 0xAC
    #expect(java.net.URLEncoder.encode("€") == "%E2%82%AC")
  }

  // MARK: - Charset parameter

  @available(*, deprecated)
  @Test("encode(_:_:) with UTF-8 matches encode(_:)")
  func testExplicitUTF8() {
    let s = "hello wörld"
    #expect(try! java.net.URLEncoder.encode(s, "UTF-8") == java.net.URLEncoder.encode(s))
  }

  // MARK: - Edge cases

  @available(*, deprecated)
  @Test("Empty string encodes to empty string")
  func testEmpty() {
    #expect(java.net.URLEncoder.encode("") == "")
  }

  @available(*, deprecated)
  @Test("Already safe string is returned unchanged")
  func testAlreadySafe() {
    #expect(java.net.URLEncoder.encode("hello123") == "hello123")
  }
}
