/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Java2SwiftFormatter / String.format — Harmony-style edge-case coverage
//
// Apache Harmony's java.util.Formatter test suite (see FormatterTest.java in
// the historical Harmony/Android libcore sources) exercises a large matrix
// of flag/width/precision combinations per conversion rather than one
// assertion per conversion. This file adds a comparable — though smaller —
// combinatorial layer on top of the existing Java2SwiftFormatter tests,
// and doubles as the regression suite for a real bug found while writing
// it: the general conversions ('s'/'S', 'b'/'B', 'h'/'H') silently ignored
// `precision` (truncation) entirely, and 'b'/'B'/'h'/'H' additionally
// ignored `width` (padding) — both are now fixed in Java2SwiftFormatter.swift.

@Suite("Java2SwiftFormatter — general conversion precision/width", .serialized)
struct GeneralConversionPrecisionWidthTests {

  // ── 's'/'S': precision truncates, width pads (in that order) ─────────────

  @Test("%.3s truncates a plain (non-Formattable) string to 3 characters")
  func stringPrecisionTruncates() throws {
    #expect(try String.format("%.3s", "hello") == "hel")
  }

  @Test("%.3s on a string shorter than the precision is left unchanged")
  func stringPrecisionShorterThanString() throws {
    #expect(try String.format("%.3s", "hi") == "hi")
  }

  @Test("%10.3s combines truncation and right-aligned padding")
  func stringPrecisionAndWidthRightAlign() throws {
    #expect(try String.format("%10.3s|", "hello") == "       hel|")
  }

  @Test("%-10.3s combines truncation and left-aligned padding")
  func stringPrecisionAndWidthLeftAlign() throws {
    #expect(try String.format("%-10.3s|", "hello") == "hel       |")
  }

  @Test("%.3S truncates and then uppercases")
  func stringPrecisionUppercase() throws {
    #expect(try String.format("%.3S", "hello") == "HEL")
  }

  // ── 'b'/'B': width and precision, previously ignored entirely ────────────

  @Test("%10b right-pads a boolean's text representation")
  func boolWidth() throws {
    #expect(try String.format("%10b|", true) == "      true|")
  }

  @Test("%-10b left-pads a boolean's text representation")
  func boolWidthLeftAlign() throws {
    #expect(try String.format("%-10b|", false) == "false     |")
  }

  @Test("%.3b truncates a boolean's text representation")
  func boolPrecision() throws {
    #expect(try String.format("%.3b", true) == "tru")
    #expect(try String.format("%.3b", false) == "fal")
  }

  @Test("%.3B truncates and uppercases")
  func boolPrecisionUppercase() throws {
    #expect(try String.format("%.3B", true) == "TRU")
  }

  // ── 'h'/'H': width, precision, and null handling ──────────────────────────

  @Test("%h with a null argument produces 'null', not the hash of 0")
  func hashOfNilIsNullNotZero() throws {
    let arg: String? = nil
    #expect(try String.format("%h", arg as Any?) == "null")
  }

  @Test("%10h pads the hash's hex text to at least the given width")
  func hashWidth() throws {
    let result = try String.format("%10h|", "x")
    // Don't assert the exact hash or its exact hex length (the hash value
    // itself is unspecified) — only that the width was honoured as a
    // *minimum*, which is all `applyWidth` ever guarantees.
    #expect(result.hasSuffix("|"))
    #expect(result.count >= 11)
  }
}

@Suite("Java2SwiftFormatter — %d width/flags combinations", .serialized)
struct IntegerWidthFlagsTests {

  @Test("%05d zero-pads a positive number")
  func zeroPadPositive() throws {
    #expect(try String.format("%05d", 42) == "00042")
  }

  @Test("%05d zero-pads a negative number, keeping the sign in front")
  func zeroPadNegative() throws {
    #expect(try String.format("%05d", -42) == "-0042")
  }

  @Test("%+d shows an explicit '+' for a positive number")
  func explicitPlusPositive() throws {
    #expect(try String.format("%+d", 42) == "+42")
  }

  @Test("%+d still shows '-' for a negative number")
  func explicitPlusNegative() throws {
    #expect(try String.format("%+d", -42) == "-42")
  }

  @Test("'% d' reserves a leading space for a positive number")
  func spaceFlagPositive() throws {
    #expect(try String.format("% d", 42) == " 42")
  }

  @Test("'% d' still shows '-' for a negative number")
  func spaceFlagNegative() throws {
    #expect(try String.format("% d", -42) == "-42")
  }

  @Test("%5d right-pads a negative number with spaces, not zeros")
  func widthNegativeNoZeroFlag() throws {
    #expect(try String.format("%5d", -3) == "   -3")
  }

  @Test("%-5d| left-aligns within the given width")
  func leftAlignInteger() throws {
    #expect(try String.format("%-5d|", 3) == "3    |")
  }
}

@Suite("Java2SwiftFormatter — regression: existing behaviour unaffected by the fixes above", .serialized)
struct FormatterSanityAfterFixesTests {

  @Test("previously-passing plain %s/%S behaviour is unchanged by the precision fix")
  func plainStringBehaviourUnchanged() throws {
    #expect(try String.format("%s", 42) == "42")
    #expect(try String.format("%S", "abc") == "ABC")
    #expect(try String.format("value=%s", nil as String? as Any?) == "value=null")
  }

  @Test("previously-passing plain %b/%B behaviour is unchanged by the width/precision fix")
  func plainBoolBehaviourUnchanged() throws {
    #expect(try String.format("%b", true) == "true")
    #expect(try String.format("%B", false) == "FALSE")
  }
}
