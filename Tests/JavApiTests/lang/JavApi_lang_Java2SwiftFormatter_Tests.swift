/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// ---------------------------------------------------------------------------
// Tests for Java2SwiftFormatter (via String.format public API)
// ---------------------------------------------------------------------------
// NOTE: Tests that depend on locale-specific output (currency symbols,
// decimal/grouping separators) use the system's current locale. Those tests
// are marked with a comment so they can be skipped on CI if needed.
// ---------------------------------------------------------------------------

struct JavApi_lang_Java2SwiftFormatter_Tests {

  // ── %s / %S ────────────────────────────────────────────────────────────────

  @Test("%s inserts string argument")
  func testStringSpecifier() {
    #expect(String.format("Hello, %s!", "World") == "Hello, World!")
  }

  @Test("%s with nil produces 'null'")
  func testStringNil() {
    let arg: String? = nil
    #expect(String.format("value=%s", arg as Any?) == "value=null")
  }

  @Test("%S uppercases the argument")
  func testStringUpperSpecifier() {
    #expect(String.format("%S", "hello") == "HELLO")
  }

  @Test("%s with width right-pads when left-aligned")
  func testStringWidth() {
    #expect(String.format("%-10s|", "hi") == "hi        |")
  }

  @Test("%s with width left-pads when right-aligned (default)")
  func testStringWidthRightAlign() {
    #expect(String.format("%10s|", "hi") == "        hi|")
  }

  // ── %% ─────────────────────────────────────────────────────────────────────

  @Test("%% produces a literal percent sign")
  func testLiteralPercent() {
    #expect(String.format("100%%") == "100%")
  }

  // ── %n ─────────────────────────────────────────────────────────────────────

  @Test("%n produces the platform line separator")
  func testLineSeparator() {
    let sep = java.lang.System.getProperty("line.separator", "\n")
    #expect(String.format("line1%nline2") == "line1\(sep)line2")
  }

  // ── %b / %B ────────────────────────────────────────────────────────────────

  @Test("%b with Bool true produces 'true'")
  func testBoolTrue() {
    #expect(String.format("%b", true) == "true")
  }

  @Test("%b with Bool false produces 'false'")
  func testBoolFalse() {
    #expect(String.format("%b", false) == "false")
  }

  @Test("%b with nil produces 'false'")
  func testBoolNil() {
    let v: Bool? = nil
    #expect(String.format("%b", v as Any?) == "false")
  }

  @Test("%b with non-nil non-Bool produces 'true'")
  func testBoolNonNil() {
    #expect(String.format("%b", 42) == "true")
  }

  @Test("%B uppercases boolean output")
  func testBoolUppercase() {
    #expect(String.format("%B", true)  == "TRUE")
    #expect(String.format("%B", false) == "FALSE")
  }

  // ── %d ─────────────────────────────────────────────────────────────────────

  @Test("%d formats integer")
  func testInteger() {
    #expect(String.format("%d", 42) == "42")
  }

  @Test("%d with width pads with spaces")
  func testIntegerWidth() {
    #expect(String.format("%5d", 42) == "   42")
  }

  @Test("%d with zero-flag pads with zeros")
  func testIntegerZeroPad() {
    #expect(String.format("%05d", 42) == "00042")
  }

  @Test("%d negative value")
  func testIntegerNegative() {
    #expect(String.format("%d", -7) == "-7")
  }

  // ── %,d grouping ───────────────────────────────────────────────────────────
  // Grouping separator is locale-dependent; we just verify the digit groups
  // are present and the value is correct when we strip separators.

  @Test("%,d inserts grouping separators")
  func testGroupingInteger() {
    let result = String.format("%,d", 1_000_000)
    let digits = result.filter { $0.isNumber || $0 == "-" }
    #expect(digits == "1000000")
    // Must be longer than plain digits (separator(s) inserted)
    #expect(result.count > 7)
  }

  @Test("%,d negative with grouping")
  func testGroupingNegative() {
    let result = String.format("%,d", -1_234)
    #expect(result.contains("-"))
    let digits = result.filter { $0.isNumber }
    #expect(digits == "1234")
  }

  // ── %f ─────────────────────────────────────────────────────────────────────

  @Test("%f formats double with default 6 decimal places")
  func testFloat() {
    let saved = java.util.Locale.getDefault()
    java.util.Locale.setDefault(java.util.Locale.US)
    defer { java.util.Locale.setDefault(saved) }
    #expect(String.format("%f", 3.14159) == "3.141590")
  }

  @Test("%.2f rounds to 2 decimal places")
  func testFloatPrecision() {
    let saved = java.util.Locale.getDefault()
    java.util.Locale.setDefault(java.util.Locale.US)
    defer { java.util.Locale.setDefault(saved) }
    #expect(String.format("%.2f", 3.14159) == "3.14")
  }

  // ── %e ─────────────────────────────────────────────────────────────────────

  @Test("%e scientific notation")
  func testScientific() {
    #expect(String.format("%e", 123456.789) == String(format: "%e", 123456.789))
  }

  // ── %o / %x / %X ───────────────────────────────────────────────────────────

  @Test("%o octal")
  func testOctal() {
    #expect(String.format("%o", 8) == "10")
  }

  @Test("%x lowercase hex")
  func testHexLower() {
    #expect(String.format("%x", 255) == "ff")
  }

  @Test("%X uppercase hex")
  func testHexUpper() {
    #expect(String.format("%X", 255) == "FF")
  }

  // ── %c ─────────────────────────────────────────────────────────────────────

  @Test("%c formats a Character")
  func testCharacter() {
    #expect(String.format("%c", Character("A")) == "A")
  }

  // ── argument index (%1$s) ──────────────────────────────────────────────────

  @Test("%1$s selects first argument")
  func testArgIndex1() {
    #expect(String.format("%1$s %2$s", "Hello", "World") == "Hello World")
  }

  @Test("%2$s selects second argument")
  func testArgIndex2() {
    #expect(String.format("%2$s %1$s", "World", "Hello") == "Hello World")
  }

  @Test("argument index can repeat an argument")
  func testArgIndexRepeat() {
    #expect(String.format("%1$s/%1$s", "ping") == "ping/ping")
  }

  // ── mixed specifiers ────────────────────────────────────────────────────────

  @Test("mixed specifiers in one format string")
  func testMixed() {
    let saved = java.util.Locale.getDefault()
    java.util.Locale.setDefault(java.util.Locale.US)
    defer { java.util.Locale.setDefault(saved) }
    let result = String.format("%s has %d items (%.1f%%)", "Cart", 3, 100.0)
    #expect(result == "Cart has 3 items (100.0%)")
  }

  // ── Locale-sensitive grouping / decimal separator ──────────────────────────
  //
  // We set Locale.setDefault() before the assertion and restore the original
  // afterwards so tests remain independent of the machine's system locale.

  @Test("%,d with de_DE locale uses '.' as grouping separator")
  func testGroupingDE() {
    let saved = java.util.Locale.getDefault()
    java.util.Locale.setDefault(java.util.Locale.GERMANY)
    defer { java.util.Locale.setDefault(saved) }

    let result = String.format("%,d", 1_234_567)
    // de_DE: 1.234.567
    #expect(result == "1.234.567")
  }

  @Test("%,d with en_US locale uses ',' as grouping separator")
  func testGroupingUS() {
    let saved = java.util.Locale.getDefault()
    java.util.Locale.setDefault(java.util.Locale.US)
    defer { java.util.Locale.setDefault(saved) }

    let result = String.format("%,d", 1_234_567)
    // en_US: 1,234,567
    #expect(result == "1,234,567")
  }

  @Test("%,f with de_DE locale uses ',' as decimal separator")
  func testDecimalDE() {
    let saved = java.util.Locale.getDefault()
    java.util.Locale.setDefault(java.util.Locale.GERMANY)
    defer { java.util.Locale.setDefault(saved) }

    let result = String.format("%.2f", 1234.5)
    // de_DE: 1234,50  (no grouping in plain %f, but decimal sep is ',')
    #expect(result.contains(","))
    #expect(!result.contains("."))
  }

  @Test("%,f with en_US locale uses '.' as decimal separator")
  func testDecimalUS() {
    let saved = java.util.Locale.getDefault()
    java.util.Locale.setDefault(java.util.Locale.US)
    defer { java.util.Locale.setDefault(saved) }

    let result = String.format("%.2f", 1234.5)
    // en_US: 1234.50
    #expect(result.contains("."))
    #expect(!result.contains(","))
  }

  @Test("%,d with exotic locale (ar_EG) produces digit groups")
  func testGroupingExotic() {
    let saved = java.util.Locale.getDefault()
    // Arabic Egypt — grouping separator is U+066C (Arabic Thousands Separator)
    // or a regular comma depending on the platform; we just check that
    // the digit content is correct and that separators were inserted.
    java.util.Locale.setDefault(java.util.Locale("ar", "EG"))
    defer { java.util.Locale.setDefault(saved) }

    let result = String.format("%,d", 1_000_000)
    // Strip anything that isn't an ASCII/Arabic-Indic digit
    let asciiDigits = result.unicodeScalars
      .filter { ($0.value >= 48 && $0.value <= 57) ||   // ASCII 0-9
                ($0.value >= 0x0660 && $0.value <= 0x0669) } // Arabic-Indic
      .map { String($0) }
      .joined()
    // Must contain exactly "1000000" worth of digits
    #expect(asciiDigits == "1000000" || asciiDigits == "١٠٠٠٠٠٠")
    // Must be longer than 7 chars (separators present)
    #expect(result.count > 7)
  }

  // ── java.util.Formatter ────────────────────────────────────────────────────

  @Test("java.util.Formatter accumulates output")
  func testFormatter() {
    let f = java.util.Formatter()
    f.format("Hello, %s!", "Java")
    f.format(" Count: %d.", 7)
    #expect(f.toString() == "Hello, Java! Count: 7.")
  }

  @Test("java.util.Formatter.format returns self (chaining)")
  func testFormatterChaining() {
    let f = java.util.Formatter()
    let returned = f.format("a").format("b")
    #expect(f === returned)
    #expect(f.toString() == "ab")
  }
}
