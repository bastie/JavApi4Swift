/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// MARK: - IllegalFormatException hierarchy
//
// These classes were previously entirely missing — see Text-Implementierung.md,
// Java-1.5 section ("FormatterClosedException, IllegalFormatException-Hierarchie").

@Suite("java.util.IllegalFormatException hierarchy")
struct IllegalFormatExceptionHierarchyTests {

  @Test("IllegalFormatException is an IllegalArgumentException")
  func baseClassHierarchy() {
    let ex = java.util.IllegalFormatException("bad format")
    #expect(ex is IllegalArgumentException)
    #expect(ex is RuntimeException)
    #expect(ex.getMessage() == "bad format")
  }

  @Test("DuplicateFormatFlagsException stores the duplicate flags")
  func duplicateFormatFlags() {
    let ex = java.util.DuplicateFormatFlagsException("--")
    #expect(ex.getFlags() == "--")
    #expect(ex is java.util.IllegalFormatException)
    #expect(ex.getMessage()?.contains("--") == true)
  }

  @Test("FormatFlagsConversionMismatchException stores flag and conversion")
  func formatFlagsConversionMismatch() {
    let ex = java.util.FormatFlagsConversionMismatchException(",", "s")
    #expect(ex.getFlags() == ",")
    #expect(ex.getConversion() == "s")
  }

  @Test("IllegalFormatCodePointException stores the code point")
  func illegalFormatCodePoint() {
    let ex = java.util.IllegalFormatCodePointException(0x110000)
    #expect(ex.getCodePoint() == 0x110000)
    #expect(ex.getMessage()?.contains("110000") == true)
  }

  @Test("IllegalFormatConversionException stores conversion and argument type")
  func illegalFormatConversion() {
    let ex = java.util.IllegalFormatConversionException("d", type(of: "not a number"))
    #expect(ex.getConversion() == "d")
    #expect(ex.getArgumentClass().contains("String"))
  }

  @Test("IllegalFormatFlagsException stores the illegal flag combination")
  func illegalFormatFlags() {
    let ex = java.util.IllegalFormatFlagsException("-0")
    #expect(ex.getFlags() == "-0")
  }

  @Test("IllegalFormatPrecisionException stores the illegal precision")
  func illegalFormatPrecision() {
    let ex = java.util.IllegalFormatPrecisionException(-2)
    #expect(ex.getPrecision() == -2)
  }

  @Test("IllegalFormatWidthException stores the illegal width")
  func illegalFormatWidth() {
    let ex = java.util.IllegalFormatWidthException(-2)
    #expect(ex.getWidth() == -2)
  }

  @Test("MissingFormatArgumentException stores the format specifier")
  func missingFormatArgument() {
    let ex = java.util.MissingFormatArgumentException("%s")
    #expect(ex.getFormatSpecifier() == "%s")
  }

  @Test("MissingFormatWidthException stores the format specifier")
  func missingFormatWidth() {
    let ex = java.util.MissingFormatWidthException("%-s")
    #expect(ex.getFormatSpecifier() == "%-s")
  }

  @Test("UnknownFormatConversionException stores the unknown conversion")
  func unknownFormatConversion() {
    let ex = java.util.UnknownFormatConversionException("q")
    #expect(ex.getConversion() == "q")
  }

  @Test("UnknownFormatFlagsException stores the unknown flags")
  func unknownFormatFlags() {
    let ex = java.util.UnknownFormatFlagsException("!")
    #expect(ex.getFlags() == "!")
  }
}

// MARK: - FormatterClosedException / Formatter.close()

@Suite("java.util.Formatter – close() / FormatterClosedException")
struct FormatterCloseTests {

  @Test("FormatterClosedException extends IllegalStateException, not IllegalFormatException")
  func closedExceptionHierarchy() {
    let ex = java.util.FormatterClosedException()
    #expect(ex is IllegalStateException)
    #expect(!(ex is java.util.IllegalFormatException))
  }

  @Test("format() throws FormatterClosedException after close()")
  func formatThrowsAfterClose() {
    let f = java.util.Formatter()
    f.close()
    #expect(throws: java.util.FormatterClosedException.self) {
      try f.format("no longer allowed")
    }
  }

  @Test("format(Locale, ...) throws FormatterClosedException after close()")
  func formatWithLocaleThrowsAfterClose() {
    let f = java.util.Formatter()
    f.close()
    #expect(throws: java.util.FormatterClosedException.self) {
      try f.format(java.util.Locale.US, "no longer allowed")
    }
  }

  @Test("toString() throws FormatterClosedException after close()")
  func toStringThrowsAfterClose() throws {
    let f = java.util.Formatter()
    try f.format("kept")
    f.close()
    #expect(throws: java.util.FormatterClosedException.self) {
      try f.toString()
    }
  }

  @Test("out() throws FormatterClosedException after close()")
  func outThrowsAfterClose() {
    let f = java.util.Formatter()
    f.close()
    #expect(throws: java.util.FormatterClosedException.self) {
      try f.out()
    }
  }

  @Test("flush() throws FormatterClosedException after close()")
  func flushThrowsAfterClose() {
    let f = java.util.Formatter()
    f.close()
    #expect(throws: java.util.FormatterClosedException.self) {
      try f.flush()
    }
  }

  @Test("flush() does not throw before close()")
  func flushDoesNotThrowBeforeClose() throws {
    let f = java.util.Formatter()
    try f.flush()
  }

  @Test("close() is idempotent — calling it twice does not throw")
  func closeIsIdempotent() {
    let f = java.util.Formatter()
    f.close()
    f.close()
    #expect(throws: java.util.FormatterClosedException.self) {
      try f.format("still closed")
    }
  }

  @Test("locale() remains usable after close()")
  func localeStillReadableAfterClose() {
    let f = java.util.Formatter(java.util.Locale.GERMANY)
    f.close()
    #expect(f.locale() == java.util.Locale.GERMANY)
  }

  @Test("ioException() returns nil for the StringBuilder-backed Formatter")
  func ioExceptionAlwaysNil() throws {
    let f = java.util.Formatter()
    try f.format("fine")
    #expect(f.ioException() == nil)
  }
}
