/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Java2SwiftFormatter / String.format — IllegalFormatException wiring
//
// See Text-Implementierung.md, Java-1.5 section: `Java2SwiftFormatter.format`
// (and therefore `String.format`/`Formatter.format`/`PrintStream.printf`) is
// now `throws` and raises the matching `java.util.IllegalFormatException`
// subclass instead of silently passing malformed specifiers through or
// producing a nonsensical fallback value.

struct JavApi_lang_Java2SwiftFormatter_ExceptionTests {

  // ── java.util.UnknownFormatConversionException ──────────────────────────────────────

  @Test("An unknown conversion character throws java.util.UnknownFormatConversionException")
  func unknownConversionThrows() {
    #expect(throws: java.util.UnknownFormatConversionException.self) {
      _ = try String.format("%q", "x")
    }
  }

  // ── java.util.MissingFormatArgumentException ────────────────────────────────────────

  @Test("A specifier with no corresponding argument throws java.util.MissingFormatArgumentException")
  func missingArgumentThrows() {
    #expect(throws: java.util.MissingFormatArgumentException.self) {
      _ = try String.format("%s")
    }
  }

  @Test("An out-of-range %n$ argument index throws java.util.MissingFormatArgumentException")
  func missingIndexedArgumentThrows() {
    #expect(throws: java.util.MissingFormatArgumentException.self) {
      _ = try String.format("%2$s", "only one")
    }
  }

  // ── java.util.IllegalFormatConversionException ──────────────────────────────────────

  @Test("%d with a non-integer argument throws java.util.IllegalFormatConversionException")
  func integerConversionMismatchThrows() {
    #expect(throws: java.util.IllegalFormatConversionException.self) {
      _ = try String.format("%d", "not a number")
    }
  }

  @Test("%f with an Int argument throws java.util.IllegalFormatConversionException (Java requires Float/Double)")
  func floatConversionMismatchThrows() {
    #expect(throws: java.util.IllegalFormatConversionException.self) {
      _ = try String.format("%f", 42)
    }
  }

  @Test("%c with a non-Character/Int argument throws java.util.IllegalFormatConversionException")
  func charConversionMismatchThrows() {
    #expect(throws: java.util.IllegalFormatConversionException.self) {
      _ = try String.format("%c", "AB")
    }
  }

  @Test("The exception reports the offending conversion and the Swift argument type")
  func conversionExceptionCarriesDetails() {
    do {
      _ = try String.format("%d", "oops")
      Issue.record("expected java.util.IllegalFormatConversionException to be thrown")
    } catch let e as java.util.IllegalFormatConversionException {
      #expect(e.getConversion() == "d")
      #expect(e.getArgumentClass() == "String")
    } catch {
      Issue.record("expected java.util.IllegalFormatConversionException, got \(error)")
    }
  }

  // ── java.util.IllegalFormatCodePointException ───────────────────────────────────────

  @Test("%c with an out-of-range code point throws java.util.IllegalFormatCodePointException")
  func invalidCodePointThrows() {
    #expect(throws: java.util.IllegalFormatCodePointException.self) {
      _ = try String.format("%c", 0x110000)
    }
  }

  @Test("%c with a negative code point throws java.util.IllegalFormatCodePointException")
  func negativeCodePointThrows() {
    #expect(throws: java.util.IllegalFormatCodePointException.self) {
      _ = try String.format("%c", -1)
    }
  }

  // ── java.util.DuplicateFormatFlagsException ─────────────────────────────────────────

  @Test("A flag repeated in one specifier throws java.util.DuplicateFormatFlagsException")
  func duplicateFlagThrows() {
    #expect(throws: java.util.DuplicateFormatFlagsException.self) {
      _ = try String.format("%--5d", 1)
    }
  }

  // ── java.util.MissingFormatWidthException ───────────────────────────────────────────

  @Test("'-' flag without a width throws java.util.MissingFormatWidthException")
  func missingWidthThrows() {
    #expect(throws: java.util.MissingFormatWidthException.self) {
      _ = try String.format("%-d", 1)
    }
  }

  // ── java.util.IllegalFormatPrecisionException ───────────────────────────────────────

  @Test("Precision on a conversion that doesn't support it throws java.util.IllegalFormatPrecisionException")
  func illegalPrecisionThrows() {
    #expect(throws: java.util.IllegalFormatPrecisionException.self) {
      _ = try String.format("%.2d", 1)
    }
  }

  // ── java.util.FormatFlagsConversionMismatchException ────────────────────────────────

  @Test("',' grouping flag on a conversion that doesn't support it throws java.util.FormatFlagsConversionMismatchException")
  func groupingOnUnsupportedConversionThrows() {
    #expect(throws: java.util.FormatFlagsConversionMismatchException.self) {
      _ = try String.format("%,s", "x")
    }
  }

  @Test("'#' flag on 's' with a non-Formattable argument throws java.util.FormatFlagsConversionMismatchException")
  func alternateFlagOnPlainStringThrows() {
    #expect(throws: java.util.FormatFlagsConversionMismatchException.self) {
      _ = try String.format("%#s", "plain string")
    }
  }

  // ── Sanity: valid format strings still succeed after all the above ───────

  @Test("Well-formed specifiers still succeed and don't throw")
  func wellFormedSpecifiersStillWork() throws {
    #expect(try String.format("%s is %d years old", "Alice", 30) == "Alice is 30 years old")
    // Pinned to Locale.US: `String.format` with no explicit Locale follows
    // `java.util.Locale.getDefault()` (matching real Java), so a hardcoded
    // "." decimal-point expectation is only correct on an English-locale
    // machine. This test is about specifiers not throwing, not about
    // locale — pin the locale explicitly so it doesn't depend on the
    // machine it runs on. (Found via a German-locale CI/dev machine, where
    // the unpinned version produced "3,14" — itself correct Java-locale
    // behavior, just not what this test intends to check.)
    #expect(try String.format(java.util.Locale.US, "%.2f", 3.14159) == "3.14")
    #expect(try String.format("%c", Character("A")) == "A")
    #expect(try String.format("%c", 65) == "A")
  }
}
