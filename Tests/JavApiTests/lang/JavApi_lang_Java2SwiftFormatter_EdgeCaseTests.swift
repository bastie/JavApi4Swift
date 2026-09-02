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

// MARK: - %< relative argument index
//
// Regression tests for a documented gap found while deepening test
// coverage: `%<` ("reuse the previous specifier's argument") was not
// recognised at all by resolveArgumentIndices, so `String.format("%d %<x", 255)`
// either threw UnknownFormatConversionException or produced a wrong result.

@Suite("Java2SwiftFormatter — %< relative argument index", .serialized)
struct RelativeArgumentIndexTests {

  @Test("%<x reuses the immediately preceding argument")
  func reusesPrecedingArgument() throws {
    #expect(try String.format("%d %<x", 255) == "255 ff")
  }

  @Test("%<s reused across more than one subsequent specifier still refers to the same argument")
  func reusedAcrossMultipleSpecifiers() throws {
    #expect(try String.format("%s %<s %<s", "hi") == "hi hi hi")
  }

  @Test("%<s combined with an explicit %n$ index earlier in the string")
  func combinedWithExplicitIndex() throws {
    // %1$s picks "World" explicitly; %<s then reuses that same argument.
    #expect(try String.format("%2$s %1$s %<s", "World", "Hello") == "Hello World World")
  }

  @Test("'%<' as the very first specifier throws MissingFormatArgumentException, matching Java")
  func relativeIndexOnFirstSpecifierThrows() throws {
    #expect(throws: java.util.MissingFormatArgumentException.self) {
      _ = try String.format("%<s")
    }
  }
}

// MARK: - %g / %G general scientific notation
//
// Regression tests for a documented gap found while deepening test
// coverage: %g/%G previously delegated straight to C's/Swift's native
// `String(format: "%g", ...)`, which strips trailing zeros by default —
// Java's %g always shows exactly `precision` significant digits and
// switches between decimal and scientific notation using a rule that
// (unlike a naive log10 computation) must be applied to the *rounded*
// magnitude. All expected values below were independently verified with a
// small Python re-implementation of the same algorithm before being typed
// in here, to catch a wrong-by-one-digit mistake before it became a wrong
// regression test.

@Suite("Java2SwiftFormatter — %g/%G general scientific notation", .serialized)
struct GeneralScientificNotationTests {

  @Test("%g on a value that renders in decimal form shows exactly `precision` significant digits, unlike C's %g")
  func decimalFormShowsAllSignificantDigits() throws {
    // Default precision 6; C's/Swift's native %g would strip this to "100".
    #expect(try String.format("%g", 100.0) == "100.000")
  }

  @Test("%g just below the 10⁻⁴ decimal/scientific boundary stays in decimal form")
  func justAboveLowerBoundaryStaysDecimal() throws {
    #expect(try String.format("%g", 0.0001234) == "0.000123400")
  }

  @Test("%g just below the 10⁻⁴ boundary switches to scientific notation")
  func justBelowLowerBoundarySwitchesToScientific() throws {
    #expect(try String.format("%g", 0.00001234) == "1.23400e-05")
  }

  @Test("%g at or above 10^precision switches to scientific notation")
  func atUpperBoundarySwitchesToScientific() throws {
    #expect(try String.format("%g", 123456789.0) == "1.23457e+08")
  }

  @Test("%.3g switches to scientific right at the precision boundary (rounded exponent == precision)")
  func explicitPrecisionAtBoundary() throws {
    #expect(try String.format("%.3g", 1234.5678) == "1.23e+03")
  }

  @Test("%.3g stays decimal with a zero fractional-digit count when precision == integer digit count")
  func explicitPrecisionEqualsIntegerDigits() throws {
    #expect(try String.format("%.3g", 123.4) == "123")
  }

  @Test("%G uppercases the scientific exponent marker")
  func uppercaseScientific() throws {
    #expect(try String.format("%G", 123456789.0) == "1.23457E+08")
  }

  @Test("%g on a negative value keeps the sign and rounds correctly")
  func negativeValue() throws {
    #expect(try String.format("%g", -42.5) == "-42.5000")
  }

  @Test("%,g applies grouping separators in its decimal-format branch (previously a silent no-op)")
  func groupingAppliedInDecimalBranch() throws {
    #expect(try String.format("%,.10g", 1234567.0) == "1,234,567.000")
  }

  @Test("%,g with default precision and grouping visible with zero fractional digits")
  func groupingWithZeroFractionalDigits() throws {
    #expect(try String.format("%,g", 123456.0) == "123,456")
  }

  @Test("%,e still throws FormatFlagsConversionMismatchException, matching Java (unlike the previously too-permissive groupingCapableConversions set)")
  func commaFlagOnScientificNotationStillThrows() throws {
    #expect(throws: java.util.FormatFlagsConversionMismatchException.self) {
      _ = try String.format("%,e", 1234.5)
    }
    #expect(throws: java.util.FormatFlagsConversionMismatchException.self) {
      _ = try String.format("%,E", 1234.5)
    }
  }
}
