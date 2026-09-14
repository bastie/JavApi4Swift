/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Coverage for `StringBuffer.capacity()`/`ensureCapacity(_:)`/`trimToSize()`
/// (Java 1.0). See `JavApi_lang_StringBuffer_Sendable_Tests.swift` for the
/// concurrency-focused coverage of this class.
struct JavApi_lang_StringBuffer_Tests {

  @Test("capacity()/ensureCapacity()/trimToSize() do not affect content")
  func testCapacityIsAdvisoryOnly() {
    let sb = StringBuffer("abc")
    #expect(sb.capacity() >= sb.length())
    sb.ensureCapacity(100)
    #expect(sb.toString() == "abc")
    sb.trimToSize()
    #expect(sb.toString() == "abc")
  }

  @Test("setLength still truncates and pads correctly (StringBuffer was already correct; guards against regressing while porting the StringBuilder fix)")
  func testSetLengthStillWorks() throws {
    let sb = StringBuffer("abcdef")
    try sb.setLength(3)
    #expect(sb.toString() == "abc")
    try sb.setLength(5)
    #expect(sb.toString() == "abc\u{0000}\u{0000}")
  }

  @Test("setLength to the current length is a no-op")
  func testSetLengthUnchanged() throws {
    let sb = StringBuffer("abc")
    try sb.setLength(3)
    #expect(sb.toString() == "abc")
  }

  @Test("ensureCapacity with a non-positive value does not affect content or crash")
  func testEnsureCapacityNonPositiveIsNoOp() {
    let sb = StringBuffer("abc")
    sb.ensureCapacity(0)
    sb.ensureCapacity(-5)
    #expect(sb.toString() == "abc")
  }
}
