/*
 * SPDX-FileCopyrightText: 2015 - Doug Richardson
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Unlicense
 */
import Testing
@testable import JavApi

struct JavApi_util_Base64_Tests {

  @Test("encoding empty input produces empty string")
  func testEmpty() {
    #expect(java.util.Base64.getEncoder().encodeToString([])    == "")
    #expect(java.util.Base64.getURLEncoder().encodeToString([]) == "")
  }

  @Test("encoding single zero byte produces AA==")
  func testOneByte() {
    #expect(java.util.Base64.getEncoder().encodeToString([0])    == "AA==")
    #expect(java.util.Base64.getURLEncoder().encodeToString([0]) == "AA==")
  }

  @Test("encoding two zero bytes produces AAA=")
  func testTwoBytes() {
    #expect(java.util.Base64.getEncoder().encodeToString([0, 0])    == "AAA=")
    #expect(java.util.Base64.getURLEncoder().encodeToString([0, 0]) == "AAA=")
  }

  @Test("encoding three zero bytes produces AAAA")
  func testThreeBytes() {
    #expect(java.util.Base64.getEncoder().encodeToString([0, 0, 0])    == "AAAA")
    #expect(java.util.Base64.getURLEncoder().encodeToString([0, 0, 0]) == "AAAA")
  }

  @Test("encoding 0xFF differs between standard (+/) and URL-safe (-_)")
  func test255() {
    #expect(java.util.Base64.getEncoder().encodeToString([255])    == "/w==")
    #expect(java.util.Base64.getURLEncoder().encodeToString([255]) == "_w==")
  }

  @Test("encoding 0xFE 0xFF differs between standard and URL-safe")
  func test254Thru255() {
    #expect(java.util.Base64.getEncoder().encodeToString([254, 255])    == "/v8=")
    #expect(java.util.Base64.getURLEncoder().encodeToString([254, 255]) == "_v8=")
  }

  @Test("encoding bytes 0–255 matches known reference output")
  func testZeroThrough255() {
    let expectedStandard = "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="
    let expectedURLSafe  = "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0-P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn-AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq-wsbKztLW2t7i5uru8vb6_wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t_g4eLj5OXm5-jp6uvs7e7v8PHy8_T19vf4-fr7_P3-_w=="
    let bytes = (0...255).map { UInt8($0) }
    #expect(java.util.Base64.getEncoder().encodeToString(bytes)    == expectedStandard)
    #expect(java.util.Base64.getURLEncoder().encodeToString(bytes) == expectedURLSafe)
  }

  @Test("encoding bytes 1–255 matches known reference output")
  func testOneThrough255() {
    let expectedStandard = "AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyAhIiMkJSYnKCkqKywtLi8wMTIzNDU2Nzg5Ojs8PT4/QEFCQ0RFRkdISUpLTE1OT1BRUlNUVVZXWFlaW1xdXl9gYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXp7fH1+f4CBgoOEhYaHiImKi4yNjo+QkZKTlJWWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc7P0NHS09TV1tfY2drb3N3e3+Dh4uPk5ebn6Onq6+zt7u/w8fLz9PX29/j5+vv8/f7/"
    let expectedURLSafe  = "AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyAhIiMkJSYnKCkqKywtLi8wMTIzNDU2Nzg5Ojs8PT4_QEFCQ0RFRkdISUpLTE1OT1BRUlNUVVZXWFlaW1xdXl9gYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXp7fH1-f4CBgoOEhYaHiImKi4yNjo-QkZKTlJWWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr_AwcLDxMXGx8jJysvMzc7P0NHS09TV1tfY2drb3N3e3-Dh4uPk5ebn6Onq6-zt7u_w8fLz9PX29_j5-vv8_f7_"
    let bytes = (1...255).map { UInt8($0) }
    #expect(java.util.Base64.getEncoder().encodeToString(bytes)    == expectedStandard)
    #expect(java.util.Base64.getURLEncoder().encodeToString(bytes) == expectedURLSafe)
  }

  @Test("encoding bytes 2–255 matches known reference output")
  func testTwoThrough255() {
    let expectedStandard = "AgMEBQYHCAkKCwwNDg8QERITFBUWFxgZGhscHR4fICEiIyQlJicoKSorLC0uLzAxMjM0NTY3ODk6Ozw9Pj9AQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVpbXF1eX2BhYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ent8fX5/gIGCg4SFhoeIiYqLjI2Oj5CRkpOUlZaXmJmam5ydnp+goaKjpKWmp6ipqqusra6vsLGys7S1tre4ubq7vL2+v8DBwsPExcbHyMnKy8zNzs/Q0dLT1NXW19jZ2tvc3d7f4OHi4+Tl5ufo6err7O3u7/Dx8vP09fb3+Pn6+/z9/v8="
    let expectedURLSafe  = "AgMEBQYHCAkKCwwNDg8QERITFBUWFxgZGhscHR4fICEiIyQlJicoKSorLC0uLzAxMjM0NTY3ODk6Ozw9Pj9AQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVpbXF1eX2BhYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ent8fX5_gIGCg4SFhoeIiYqLjI2Oj5CRkpOUlZaXmJmam5ydnp-goaKjpKWmp6ipqqusra6vsLGys7S1tre4ubq7vL2-v8DBwsPExcbHyMnKy8zNzs_Q0dLT1NXW19jZ2tvc3d7f4OHi4-Tl5ufo6err7O3u7_Dx8vP09fb3-Pn6-_z9_v8="
    let bytes = (2...255).map { UInt8($0) }
    #expect(java.util.Base64.getEncoder().encodeToString(bytes)    == expectedStandard)
    #expect(java.util.Base64.getURLEncoder().encodeToString(bytes) == expectedURLSafe)
  }

  @Test("encode and decode are inverse operations (large buffer)")
  func testEncodeDecodeRoundtrip() throws {
    let bytes = (0...50_000).map { UInt8($0 % 256) }
    let encoded = java.util.Base64.getEncoder().encode(bytes)
    let decoded = try java.util.Base64.Decoder().decode(encoded)
    #expect(decoded == bytes)
  }

  @Test("decode produces correct bytes for known Base64 string")
  func testDecodeBase64() throws {
    let input    = [UInt8]("Uml0dGVy".data(using: .utf8)!)
    let expected = [UInt8]("Ritter".data(using: .utf8)!)
    let actually = try java.util.Base64.Decoder().decode(input)
    #expect(actually == expected)
  }

  @Test("decode handles two padding characters (==)")
  func testDecodeWith2Padding() throws {
    let input    = [UInt8]("Uml0dGVyLmJpeg==".data(using: .utf8)!)
    let expected = [UInt8]("Ritter.biz".data(using: .utf8)!)
    let actually = try java.util.Base64.Decoder().decode(input)
    #expect(actually == expected)
  }

  @Test("decode handles one padding character (=)")
  func testDecodeWith1Padding() throws {
    let input    = [UInt8]("ZXhhbXBsZS5jb20=".data(using: .utf8)!)
    let expected = [UInt8]("example.com".data(using: .utf8)!)
    let actually = try java.util.Base64.Decoder().decode(input)
    #expect(actually == expected)
  }
}
