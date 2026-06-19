/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// =============================================================================
// MARK: - MessageFormat
// =============================================================================

struct JavApi_text_MessageFormat_Tests {

  // ---------------------------------------------------------------------------
  // MARK: Simple positional substitution
  // ---------------------------------------------------------------------------

  @Test("MessageFormat: single placeholder {0}")
  func testSinglePlaceholder() {
    let result = java.text.MessageFormat.format("Hello, {0}!", ["World"])
    #expect(result == "Hello, World!")
  }

  @Test("MessageFormat: multiple placeholders in order")
  func testMultiplePlaceholders() {
    let result = java.text.MessageFormat.format("{0} + {1} = {2}", ["1", "2", "3"])
    #expect(result == "1 + 2 = 3")
  }

  @Test("MessageFormat: placeholder reuse — same index twice")
  func testPlaceholderReuse() {
    let result = java.text.MessageFormat.format("{0} and {0}", ["echo"])
    #expect(result == "echo and echo")
  }

  @Test("MessageFormat: out-of-order placeholders {1} before {0}")
  func testOutOfOrderPlaceholders() {
    let result = java.text.MessageFormat.format("{1} before {0}", ["second", "first"])
    #expect(result == "first before second")
  }

  @Test("MessageFormat: no placeholders — literal passthrough")
  func testNoPlaceholders() {
    let result = java.text.MessageFormat.format("No substitution here.", [])
    #expect(result == "No substitution here.")
  }

  @Test("MessageFormat: empty pattern")
  func testEmptyPattern() {
    let result = java.text.MessageFormat.format("", ["x"])
    #expect(result == "")
  }

  @Test("MessageFormat: nil argument renders as 'null'")
  func testNilArgument() {
    let args: [Any?] = [nil]
    let result = java.text.MessageFormat.format("Value: {0}", args)
    #expect(result == "Value: null")
  }

  // ---------------------------------------------------------------------------
  // MARK: Number formatting
  // ---------------------------------------------------------------------------

  @Test("MessageFormat: {0,number} formats an integer")
  func testNumberDefault() {
    let locale = java.util.Locale("en", "US")
    let mf = java.text.MessageFormat("{0,number}", locale)
    let result = mf.format([42])
    #expect(result == "42")
  }

  @Test("MessageFormat: {0,number,integer} drops fractional part")
  func testNumberInteger() {
    let locale = java.util.Locale("en", "US")
    let mf = java.text.MessageFormat("{0,number,integer}", locale)
    let result = mf.format([3.9])
    #expect(result == "4")
  }

  @Test("MessageFormat: {0,number,percent} formats as percentage")
  func testNumberPercent() {
    let locale = java.util.Locale("en", "US")
    let mf = java.text.MessageFormat("{0,number,percent}", locale)
    let result = mf.format([0.5])
    #expect(result == "50%")
  }

  // ---------------------------------------------------------------------------
  // MARK: Date / time formatting
  // ---------------------------------------------------------------------------

  @Test("MessageFormat: {0,date,short} produces a non-empty string")
  func testDateShortNonEmpty() {
    let locale = java.util.Locale("en", "US")
    let mf = java.text.MessageFormat("{0,date,short}", locale)
    let date = java.util.Date(0) // epoch
    let result = mf.format([date])
    #expect(!result.isEmpty)
  }

  @Test("MessageFormat: {0,time,short} produces a non-empty string")
  func testTimeShortNonEmpty() {
    let locale = java.util.Locale("en", "US")
    let mf = java.text.MessageFormat("{0,time,short}", locale)
    let date = java.util.Date(0)
    let result = mf.format([date])
    #expect(!result.isEmpty)
  }

  // ---------------------------------------------------------------------------
  // MARK: Quoted literals
  // ---------------------------------------------------------------------------

  @Test("MessageFormat: single-quoted text is treated as literal")
  func testQuotedLiteral() {
    // 'at' should appear verbatim, not be consumed as a pattern letter
    let result = java.text.MessageFormat.format("Save 'at' {0}", ["noon"])
    #expect(result == "Save at noon")
  }

  @Test("MessageFormat: '' (two single quotes) produces a literal quote")
  func testEscapedQuote() {
    let result = java.text.MessageFormat.format("It''s {0}!", ["alive"])
    #expect(result == "It's alive!")
  }

  // ---------------------------------------------------------------------------
  // MARK: Instance API
  // ---------------------------------------------------------------------------

  @Test("MessageFormat: applyPattern replaces the pattern")
  func testApplyPattern() {
    let mf = java.text.MessageFormat("{0}")
    mf.applyPattern("Hello {0}")
    #expect(mf.toPattern() == "Hello {0}")
    let result = mf.format(["world"])
    #expect(result == "Hello world")
  }

  @Test("MessageFormat: toPattern returns the current pattern")
  func testToPattern() {
    let pattern = "Dear {0}, you have {1} messages."
    let mf = java.text.MessageFormat(pattern)
    #expect(mf.toPattern() == pattern)
  }

  @Test("MessageFormat: format([Any?]) with mixed types")
  func testFormatArrayMixedTypes() {
    let mf = java.text.MessageFormat("{0} has {1} items")
    let result = mf.format(["Alice", 3])
    #expect(result == "Alice has 3 items")
  }

  // ---------------------------------------------------------------------------
  // MARK: Format (inherited from Format)
  // ---------------------------------------------------------------------------

  @Test("MessageFormat: format(_:) from Format base class")
  func testFormatBaseClass() {
    let mf = java.text.MessageFormat("Hi {0}")
    let result = mf.format(["Bob"] as [Any?])
    #expect(result == "Hi Bob")
  }

  // ---------------------------------------------------------------------------
  // MARK: Parse
  // ---------------------------------------------------------------------------

  @Test("MessageFormat: parse extracts single argument")
  func testParseSingle() throws {
    let mf = java.text.MessageFormat("Hello, {0}!")
    let parsed = try mf.parse("Hello, World!")
    #expect(parsed.count == 1)
    #expect(parsed[0] as? String == "World")
  }

  @Test("MessageFormat: parse throws ParseException on mismatch")
  func testParseThrowsOnMismatch() {
    let mf = java.text.MessageFormat("Hello, {0}!")
    #expect(throws: (any Error).self) {
      try mf.parse("Goodbye, World!")
    }
  }
}

// =============================================================================
// MARK: - StringCharacterIterator
// =============================================================================

struct JavApi_text_StringCharacterIterator_Tests {

  @Test("StringCharacterIterator: first() returns first character")
  func testFirst() {
    let it = java.text.StringCharacterIterator("abc")
    #expect(it.first() == "a")
  }

  @Test("StringCharacterIterator: last() returns last character")
  func testLast() {
    let it = java.text.StringCharacterIterator("abc")
    #expect(it.last() == "c")
  }

  @Test("StringCharacterIterator: next() advances and returns next character")
  func testNext() {
    let it = java.text.StringCharacterIterator("abc")
    _ = it.first()
    #expect(it.next() == "b")
    #expect(it.next() == "c")
  }

  @Test("StringCharacterIterator: next() past end returns DONE")
  func testNextPastEnd() {
    let it = java.text.StringCharacterIterator("a")
    _ = it.first()
    let done = it.next()
    #expect(done == java.text.StringCharacterIterator.DONE)
  }

  @Test("StringCharacterIterator: previous() returns previous character")
  func testPrevious() {
    let it = java.text.StringCharacterIterator("abc")
    _ = it.last()
    #expect(it.previous() == "b")
    #expect(it.previous() == "a")
  }

  @Test("StringCharacterIterator: previous() before begin returns DONE")
  func testPreviousBeforeBegin() {
    let it = java.text.StringCharacterIterator("a")
    _ = it.first()
    #expect(it.previous() == java.text.StringCharacterIterator.DONE)
  }

  @Test("StringCharacterIterator: setIndex positions iterator correctly")
  func testSetIndex() {
    let it = java.text.StringCharacterIterator("abc")
    let ch = it.setIndex(2)
    #expect(ch == "c")
    #expect(it.getIndex() == 2)
  }

  @Test("StringCharacterIterator: getBeginIndex / getEndIndex")
  func testBoundaries() {
    let it = java.text.StringCharacterIterator("abc")
    #expect(it.getBeginIndex() == 0)
    #expect(it.getEndIndex() == 3)
  }

  @Test("StringCharacterIterator: empty string — first() returns DONE")
  func testEmptyString() {
    let it = java.text.StringCharacterIterator("")
    #expect(it.first() == java.text.StringCharacterIterator.DONE)
    #expect(it.last()  == java.text.StringCharacterIterator.DONE)
  }

  @Test("StringCharacterIterator: full forward traversal")
  func testFullForwardTraversal() {
    let it = java.text.StringCharacterIterator("hello")
    var result = ""
    var ch = it.first()
    while ch != java.text.StringCharacterIterator.DONE {
      result.append(ch)
      ch = it.next()
    }
    #expect(result == "hello")
  }

  @Test("StringCharacterIterator: full backward traversal")
  func testFullBackwardTraversal() {
    let it = java.text.StringCharacterIterator("hello")
    var result = ""
    var ch = it.last()
    while ch != java.text.StringCharacterIterator.DONE {
      result.append(ch)
      ch = it.previous()
    }
    #expect(result == "olleh")
  }

  @Test("StringCharacterIterator: DONE value is U+FFFF")
  func testDONEValue() {
    #expect(java.text.StringCharacterIterator.DONE == "\u{FFFF}")
  }

  @Test("StringCharacterIterator: clone() creates independent copy")
  func testClone() {
    let it = java.text.StringCharacterIterator("abc")
    _ = it.first()
    _ = it.next() // now at 'b'
    let clone = it.clone() as! java.text.StringCharacterIterator
    _ = it.next() // advance original to 'c'
    // clone should still be at 'b'
    #expect(clone.current() == "b")
    #expect(it.current() == "c")
  }
}

// =============================================================================
// MARK: - NumberFormat factory methods
// =============================================================================

struct JavApi_text_NumberFormat_Tests {

  @Test("NumberFormat.getInstance() formats integer")
  func testGetInstance() {
    let nf = java.text.NumberFormat.getInstance(java.util.Locale("en", "US"))
    let result = nf.format(Int64(1234))
    #expect(result == "1,234")
  }

  @Test("NumberFormat.getIntegerInstance() drops decimal places")
  func testGetIntegerInstance() {
    let nf = java.text.NumberFormat.getIntegerInstance(java.util.Locale("en", "US"))
    let result = nf.format(3.7)
    #expect(result == "4")
  }

  @Test("NumberFormat.getPercentInstance() formats 0.5 as 50%")
  func testGetPercentInstance() {
    let nf = java.text.NumberFormat.getPercentInstance(java.util.Locale("en", "US"))
    let result = nf.format(0.5)
    #expect(result == "50%")
  }

  @Test("NumberFormat.parse() round-trips a number")
  func testParse() throws {
    let nf = java.text.NumberFormat.getInstance(java.util.Locale("en", "US"))
    let num = try nf.parse("1,234")
    #expect(num.intValue == 1234)
  }

  @Test("NumberFormat.parse() throws ParseException on invalid input")
  func testParseThrows() {
    let nf = java.text.NumberFormat.getInstance(java.util.Locale("en", "US"))
    #expect(throws: (any Error).self) {
      try nf.parse("not a number")
    }
  }
}

// =============================================================================
// MARK: - DateFormat factory methods
// =============================================================================

struct JavApi_text_DateFormat_Tests {

  @Test("DateFormat.getDateInstance() formats epoch to non-empty string")
  func testGetDateInstance() {
    let df = java.text.DateFormat.getDateInstance(
      java.text.DateFormat.SHORT,
      locale: java.util.Locale("en", "US")
    )
    let result = df.format(java.util.Date(0))
    #expect(!result.isEmpty)
  }

  @Test("DateFormat.getTimeInstance() formats epoch to non-empty string")
  func testGetTimeInstance() {
    let df = java.text.DateFormat.getTimeInstance(
      java.text.DateFormat.SHORT,
      locale: java.util.Locale("en", "US")
    )
    let result = df.format(java.util.Date(0))
    #expect(!result.isEmpty)
  }

  @Test("DateFormat style constants have expected values")
  func testStyleConstants() {
    #expect(java.text.DateFormat.FULL   == 0)
    #expect(java.text.DateFormat.LONG   == 1)
    #expect(java.text.DateFormat.MEDIUM == 2)
    #expect(java.text.DateFormat.SHORT  == 3)
    #expect(java.text.DateFormat.DEFAULT == java.text.DateFormat.MEDIUM)
  }
}

// =============================================================================
// MARK: - SimpleDateFormat
// =============================================================================

struct JavApi_text_SimpleDateFormat_Tests {

  @Test("SimpleDateFormat: format with yyyy-MM-dd pattern")
  func testFormatIsoDate() {
    // Use a fixed UTC date: 2000-01-01T00:00:00Z = 946684800000 ms
    let epoch2000 = java.util.Date(946_684_800_000)
    let sdf = java.text.SimpleDateFormat("yyyy-MM-dd")
    // Result is locale/timezone dependent; just verify it matches the pattern shape
    let result = sdf.format(epoch2000)
    #expect(result.count == 10)                   // "yyyy-MM-dd" = 10 chars
    #expect(result.filter { $0 == "-" }.count == 2) // two dashes
  }

  @Test("SimpleDateFormat: toPattern() returns applied pattern")
  func testToPattern() {
    let sdf = java.text.SimpleDateFormat("dd/MM/yyyy")
    #expect(sdf.toPattern() == "dd/MM/yyyy")
  }

  @Test("SimpleDateFormat: applyPattern() changes active pattern")
  func testApplyPattern() {
    let sdf = java.text.SimpleDateFormat("yyyy")
    sdf.applyPattern("MM/dd/yyyy")
    #expect(sdf.toPattern() == "MM/dd/yyyy")
  }

  @Test("SimpleDateFormat: parse() round-trips a date string")
  func testParseRoundTrip() throws {
    let sdf = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale("en", "US"))
    let date = try sdf.parse("2026-06-19")
    let formatted = sdf.format(date)
    #expect(formatted == "2026-06-19")
  }
}
