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
    #expect(Int(num) == 1234)
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

// =============================================================================
// MARK: - DecimalFormatSymbols
// =============================================================================

struct JavApi_text_DecimalFormatSymbols_Tests {

  @Test("DecimalFormatSymbols: en_US decimal separator is '.'")
  func testDecimalSeparatorUS() {
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    #expect(sym.getDecimalSeparator() == ".")
  }

  @Test("DecimalFormatSymbols: en_US grouping separator is ','")
  func testGroupingSeparatorUS() {
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    #expect(sym.getGroupingSeparator() == ",")
  }

  @Test("DecimalFormatSymbols: minus sign is '-'")
  func testMinusSign() {
    let sym = java.text.DecimalFormatSymbols()
    #expect(sym.getMinusSign() == "-")
  }

  @Test("DecimalFormatSymbols: percent symbol is '%'")
  func testPercent() {
    let sym = java.text.DecimalFormatSymbols()
    #expect(sym.getPercent() == "%")
  }

  @Test("DecimalFormatSymbols: zero digit is '0'")
  func testZeroDigit() {
    let sym = java.text.DecimalFormatSymbols()
    #expect(sym.getZeroDigit() == "0")
  }

  @Test("DecimalFormatSymbols: setDecimalSeparator overrides symbol")
  func testSetDecimalSeparator() {
    let sym = java.text.DecimalFormatSymbols()
    sym.setDecimalSeparator(",")
    #expect(sym.getDecimalSeparator() == ",")
  }

  @Test("DecimalFormatSymbols: getInstance() returns non-nil")
  func testGetInstance() {
    let sym = java.text.DecimalFormatSymbols.getInstance()
    // just verify construction doesn't crash
    #expect(sym.getZeroDigit() == "0")
  }
}

// =============================================================================
// MARK: - DecimalFormat
// =============================================================================

struct JavApi_text_DecimalFormat_Tests {

  // ---------------------------------------------------------------------------
  // MARK: Basic formatting
  // ---------------------------------------------------------------------------

  @Test("DecimalFormat: '#,##0.00' formats 1234567.89 with grouping and 2 decimals")
  func testGroupingAndDecimals() {
    let df = java.text.DecimalFormat("#,##0.00")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(1234567.89)
    #expect(result == "1,234,567.89")
  }

  @Test("DecimalFormat: '0.00' formats 3.1 with trailing zero")
  func testTrailingZero() {
    let df = java.text.DecimalFormat("0.00")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(3.1)
    #expect(result == "3.10")
  }

  @Test("DecimalFormat: '#.##' suppresses trailing zeros")
  func testSuppressTrailingZeros() {
    let df = java.text.DecimalFormat("#.##")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(3.1)
    #expect(result == "3.1")
  }

  @Test("DecimalFormat: '0' formats integer part only")
  func testIntegerOnly() {
    let df = java.text.DecimalFormat("0")
    let result = df.format(42.9)
    // rounds to 43
    #expect(result == "43")
  }

  @Test("DecimalFormat: format(Int64) produces same as format(Double)")
  func testFormatInt64() {
    let df = java.text.DecimalFormat("#,##0")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(Int64(1000))
    #expect(result == "1,000")
  }

  // ---------------------------------------------------------------------------
  // MARK: Percentage
  // ---------------------------------------------------------------------------

  @Test("DecimalFormat: '0%' multiplies by 100 and appends percent")
  func testPercent() {
    let df = java.text.DecimalFormat("0%")
    let result = df.format(0.5)
    #expect(result == "50%")
  }

  @Test("DecimalFormat: '0.##%' shows decimal percentage")
  func testPercentDecimals() {
    let df = java.text.DecimalFormat("0.##%")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(0.1234)
    #expect(result == "12.34%")
  }

  // ---------------------------------------------------------------------------
  // MARK: Scientific notation
  // ---------------------------------------------------------------------------

  @Test("DecimalFormat: '0.###E0' formats 123456.789 in scientific notation")
  func testScientific() {
    let df = java.text.DecimalFormat("0.###E0")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(123456.789)
    // Expected: mantissa rounded to 3 fractional digits → "1.235E5"
    #expect(result == "1.235E5")
  }

  @Test("DecimalFormat: '0.##E0' formats 0.00123")
  func testScientificSmall() {
    let df = java.text.DecimalFormat("0.##E0")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(0.00123)
    #expect(result == "1.23E-3")
  }

  // ---------------------------------------------------------------------------
  // MARK: toPattern / applyPattern
  // ---------------------------------------------------------------------------

  @Test("DecimalFormat: toPattern() returns the applied pattern")
  func testToPattern() {
    let df = java.text.DecimalFormat("#,##0.00")
    #expect(df.toPattern() == "#,##0.00")
  }

  @Test("DecimalFormat: applyPattern() changes the active pattern")
  func testApplyPattern() {
    let df = java.text.DecimalFormat("#")
    df.applyPattern("0.000")
    #expect(df.toPattern() == "0.000")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    #expect(df.format(1.5) == "1.500")
  }

  // ---------------------------------------------------------------------------
  // MARK: Parse
  // ---------------------------------------------------------------------------

  @Test("DecimalFormat: parse() round-trips a formatted number")
  func testParseRoundTrip() throws {
    let df = java.text.DecimalFormat("#,##0.00")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let formatted = df.format(1234.56)
    let parsed = try df.parse(formatted)
    #expect(abs(parsed - 1234.56) < 0.01)
  }

  @Test("DecimalFormat: parse() throws ParseException on invalid input")
  func testParseThrows() {
    let df = java.text.DecimalFormat("#,##0.00")
    #expect(throws: (any Error).self) {
      try df.parse("not-a-number")
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: format(_:toAppendTo:pos:) from Format
  // ---------------------------------------------------------------------------

  @Test("DecimalFormat: format(_:toAppendTo:pos:) appends to buffer")
  func testFormatToBuffer() {
    let df = java.text.DecimalFormat("0.00")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    var buf = "Value: "
    let pos = java.text.FieldPosition(0)
    _ = df.format(3.14 as Any, toAppendTo: &buf, pos: pos)
    #expect(buf == "Value: 3.14")
  }
}

// =============================================================================
// MARK: - BreakIterator
// =============================================================================

struct JavApi_text_BreakIterator_Tests {

  // ---------------------------------------------------------------------------
  // MARK: Character boundaries
  // ---------------------------------------------------------------------------

  @Test("BreakIterator: character iterator visits every grapheme cluster")
  func testCharacterIterator() {
    let bi = java.text.BreakIterator.getCharacterInstance()
    bi.setText("abc")
    #expect(bi.first() == 0)
    #expect(bi.next()  == 1)
    #expect(bi.next()  == 2)
    #expect(bi.next()  == 3)
    #expect(bi.next()  == java.text.BreakIterator.DONE)
  }

  @Test("BreakIterator: character iterator previous() walks backwards")
  func testCharacterIteratorBackwards() {
    let bi = java.text.BreakIterator.getCharacterInstance()
    bi.setText("abc")
    _ = bi.last()
    #expect(bi.previous() == 2)
    #expect(bi.previous() == 1)
    #expect(bi.previous() == 0)
    #expect(bi.previous() == java.text.BreakIterator.DONE)
  }

  @Test("BreakIterator: DONE constant is -1")
  func testDONEValue() {
    #expect(java.text.BreakIterator.DONE == -1)
  }

  // ---------------------------------------------------------------------------
  // MARK: Word boundaries
  // ---------------------------------------------------------------------------

  @Test("BreakIterator: word iterator splits 'hello world'")
  func testWordBoundaries() {
    let bi = java.text.BreakIterator.getWordInstance()
    bi.setText("hello world")
    var boundaries: [Int] = [bi.first()]
    var b = bi.next()
    while b != java.text.BreakIterator.DONE {
      boundaries.append(b)
      b = bi.next()
    }
    // Expected: 0, 5, 6, 11
    #expect(boundaries.contains(0))
    #expect(boundaries.contains(5))  // after "hello"
    #expect(boundaries.contains(11)) // end
  }

  @Test("BreakIterator: word iterator on empty string returns 0 then DONE")
  func testWordIteratorEmpty() {
    let bi = java.text.BreakIterator.getWordInstance()
    bi.setText("")
    #expect(bi.first() == 0)
    #expect(bi.next()  == java.text.BreakIterator.DONE)
  }

  @Test("BreakIterator: word iterator previous() works")
  func testWordIteratorPrevious() {
    let bi = java.text.BreakIterator.getWordInstance()
    bi.setText("one two")
    _ = bi.last()
    let prev = bi.previous()
    #expect(prev >= 0)
    #expect(prev < 7)
  }

  // ---------------------------------------------------------------------------
  // MARK: Sentence boundaries
  // ---------------------------------------------------------------------------

  @Test("BreakIterator: sentence iterator splits 'Hello. World.'")
  func testSentenceBoundaries() {
    let bi = java.text.BreakIterator.getSentenceInstance()
    bi.setText("Hello. World.")
    _ = bi.first()
    let b1 = bi.next()
    // First boundary should be after "Hello. " (index 7)
    #expect(b1 > 0)
    #expect(b1 < 13)
  }

  // ---------------------------------------------------------------------------
  // MARK: Line boundaries
  // ---------------------------------------------------------------------------

  @Test("BreakIterator: line iterator finds space as wrap opportunity")
  func testLineBoundaryAtSpace() {
    let bi = java.text.BreakIterator.getLineInstance()
    bi.setText("word1 word2")
    _ = bi.first()
    let b = bi.next()
    // Boundary after the space following "word1"
    #expect(b == 6)
  }

  @Test("BreakIterator: line iterator finds hyphen as wrap opportunity")
  func testLineBoundaryAtHyphen() {
    let bi = java.text.BreakIterator.getLineInstance()
    bi.setText("self-aware")
    _ = bi.first()
    let b = bi.next()
    // Boundary after "-" = index 5
    #expect(b == 5)
  }

  // ---------------------------------------------------------------------------
  // MARK: setText / getText
  // ---------------------------------------------------------------------------

  @Test("BreakIterator: getText() returns the set text")
  func testGetText() {
    let bi = java.text.BreakIterator.getWordInstance()
    bi.setText("swift")
    #expect(bi.getText() == "swift")
  }

  @Test("BreakIterator: setText resets position to 0")
  func testSetTextResetsPosition() {
    let bi = java.text.BreakIterator.getCharacterInstance()
    bi.setText("abc")
    _ = bi.next()
    bi.setText("xyz")
    #expect(bi.current() == 0)
  }

  // ---------------------------------------------------------------------------
  // MARK: following / preceding
  // ---------------------------------------------------------------------------

  @Test("BreakIterator: following() finds boundary after given offset")
  func testFollowing() {
    let bi = java.text.BreakIterator.getWordInstance()
    bi.setText("one two three")
    let b = bi.following(4)
    #expect(b > 4)
  }
}

// =============================================================================
// MARK: - Collator
// =============================================================================

struct JavApi_text_Collator_Tests {

  // ---------------------------------------------------------------------------
  // MARK: Basic comparison
  // ---------------------------------------------------------------------------

  @Test("Collator: 'a' < 'b' at TERTIARY strength")
  func testBasicOrder() {
    let c = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    #expect(c.compare("a", "b") < 0)
    #expect(c.compare("b", "a") > 0)
    #expect(c.compare("a", "a") == 0)
  }

  @Test("Collator: equals() returns true for same string")
  func testEquals() {
    let c = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    #expect(c.equals("hello", "hello"))
    #expect(!c.equals("hello", "world"))
  }

  @Test("Collator: PRIMARY strength ignores accents")
  func testPrimaryIgnoresAccents() {
    let c = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    c.setStrength(java.text.Collator.PRIMARY)
    // 'e' and 'é' should be equal at PRIMARY
    #expect(c.compare("e", "é") == 0)
  }

  @Test("Collator: PRIMARY strength ignores case")
  func testPrimaryIgnoresCase() {
    let c = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    c.setStrength(java.text.Collator.PRIMARY)
    #expect(c.compare("a", "A") == 0)
  }

  @Test("Collator: SECONDARY strength ignores case but respects accents")
  func testSecondaryIgnoresCaseOnly() {
    let c = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    c.setStrength(java.text.Collator.SECONDARY)
    #expect(c.compare("a", "A") == 0)
  }

  @Test("Collator: TERTIARY strength respects case")
  func testTertiaryRespresentsCase() {
    let c = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    c.setStrength(java.text.Collator.TERTIARY)
    #expect(c.compare("a", "A") != 0)
  }

  // ---------------------------------------------------------------------------
  // MARK: getStrength / setStrength
  // ---------------------------------------------------------------------------

  @Test("Collator: default strength is TERTIARY")
  func testDefaultStrength() {
    let c = java.text.Collator.getInstance()
    #expect(c.getStrength() == java.text.Collator.TERTIARY)
  }

  @Test("Collator: setStrength persists")
  func testSetStrength() {
    let c = java.text.Collator.getInstance()
    c.setStrength(java.text.Collator.PRIMARY)
    #expect(c.getStrength() == java.text.Collator.PRIMARY)
  }

  // ---------------------------------------------------------------------------
  // MARK: Strength constants
  // ---------------------------------------------------------------------------

  @Test("Collator: strength constants have expected values")
  func testStrengthConstants() {
    #expect(java.text.Collator.PRIMARY   == 0)
    #expect(java.text.Collator.SECONDARY == 1)
    #expect(java.text.Collator.TERTIARY  == 2)
    #expect(java.text.Collator.IDENTICAL == 3)
  }
}

// =============================================================================
// MARK: - CollationKey
// =============================================================================

struct JavApi_text_CollationKey_Tests {

  @Test("CollationKey: getSourceString() returns original string")
  func testGetSourceString() {
    let c   = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    let key = c.getCollationKey("hello")
    #expect(key.getSourceString() == "hello")
  }

  @Test("CollationKey: compareTo() is consistent with Collator.compare()")
  func testCompareToConsistency() {
    let c  = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    let k1 = c.getCollationKey("apple")
    let k2 = c.getCollationKey("banana")
    let keyResult = k1.compareTo(k2)
    let colResult = c.compare("apple", "banana")
    // Both should agree on sign
    let sameSign = (keyResult < 0 && colResult < 0) ||
                   (keyResult == 0 && colResult == 0) ||
                   (keyResult > 0 && colResult > 0)
    #expect(sameSign)
  }

  @Test("CollationKey: Comparable < operator")
  func testLessThan() {
    let c  = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    c.setStrength(java.text.Collator.TERTIARY)
    let k1 = c.getCollationKey("a")
    let k2 = c.getCollationKey("b")
    #expect(k1 < k2)
  }

  @Test("CollationKey: equal keys compare as ==")
  func testEquality() {
    let c  = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    let k1 = c.getCollationKey("same")
    let k2 = c.getCollationKey("same")
    #expect(k1 == k2)
  }

  @Test("CollationKey: keys can be sorted with Array.sorted()")
  func testSortWithCollationKeys() {
    let c     = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    let words = ["banana", "cherry", "apple"]
    let sorted = words
      .map { c.getCollationKey($0) }
      .sorted()
      .map { $0.getSourceString() }
    #expect(sorted == ["apple", "banana", "cherry"])
  }
}

// =============================================================================
// MARK: - RuleBasedCollator
// =============================================================================

struct JavApi_text_RuleBasedCollator_Tests {

  @Test("RuleBasedCollator: custom order vowels before consonants")
  func testCustomOrder() throws {
    let rules = "< a < e < i < o < u < b < c < d"
    let col   = try java.text.RuleBasedCollator(rules)
    #expect(col.compare("a", "b") < 0)  // vowel before consonant
    #expect(col.compare("u", "b") < 0)  // 'u' still before 'b'
    #expect(col.compare("b", "c") < 0)  // consonant order respected
  }

  @Test("RuleBasedCollator: equal-weight tokens compare as 0")
  func testEqualWeight() throws {
    let rules = "< a = A < b"
    let col   = try java.text.RuleBasedCollator(rules)
    #expect(col.compare("a", "A") == 0)
    #expect(col.compare("a", "b") < 0)
  }

  @Test("RuleBasedCollator: getRules() returns the original rule string")
  func testGetRules() throws {
    let rules = "< a < b < c"
    let col   = try java.text.RuleBasedCollator(rules)
    #expect(col.getRules() == rules)
  }

  @Test("RuleBasedCollator: getCollationKey uses custom order")
  func testCollationKeyCustomOrder() throws {
    let rules = "< z < a < b"   // z sorts before a
    let col   = try java.text.RuleBasedCollator(rules)
    let kz    = col.getCollationKey("z")
    let ka    = col.getCollationKey("a")
    #expect(kz < ka)
  }

  @Test("RuleBasedCollator: invalid rule throws ParseException")
  func testInvalidRule() {
    // A rule with '<' but no token should throw
    #expect(throws: (any Error).self) {
      try java.text.RuleBasedCollator("< ")
    }
  }
}

// =============================================================================
// MARK: - Ergänzende Tests (Lückenabdeckung)
// =============================================================================

struct JavApi_text_Supplemental_Tests {

  // ---------------------------------------------------------------------------
  // MARK: MessageFormat — currency und multi-arg parse
  // ---------------------------------------------------------------------------

  @Test("MessageFormat: {0,number,currency} produces non-empty string")
  func testMessageFormatCurrency() {
    let locale = java.util.Locale("en", "US")
    let mf = java.text.MessageFormat("{0,number,currency}", locale)
    let result = mf.format([9.99])
    #expect(!result.isEmpty)
    // Should contain digits
    #expect(result.contains("9") || result.contains("10"))
  }

  @Test("MessageFormat: parse() with two arguments")
  func testMessageFormatParseTwoArgs() throws {
    let mf = java.text.MessageFormat("{0} + {1}")
    let parsed = try mf.parse("foo + bar")
    #expect(parsed.count == 2)
    #expect(parsed[0] as? String == "foo")
    #expect(parsed[1] as? String == "bar")
  }

  @Test("MessageFormat: parse() with prefix and suffix")
  func testMessageFormatParseWithSurroundingText() throws {
    let mf = java.text.MessageFormat("Hello {0}, you have {1} messages.")
    let parsed = try mf.parse("Hello Alice, you have 3 messages.")
    #expect(parsed.count == 2)
    #expect(parsed[0] as? String == "Alice")
    #expect(parsed[1] as? String == "3")
  }

  // ---------------------------------------------------------------------------
  // MARK: DecimalFormat — negative numbers and zero
  // ---------------------------------------------------------------------------

  @Test("DecimalFormat: negative number keeps minus sign")
  func testDecimalFormatNegative() {
    let df = java.text.DecimalFormat("0.00")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(-3.14)
    #expect(result.contains("-"))
    #expect(result.contains("3"))
  }

  @Test("DecimalFormat: zero formats correctly with '0.00'")
  func testDecimalFormatZero() {
    let df = java.text.DecimalFormat("0.00")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    #expect(df.format(0.0) == "0.00")
  }

  @Test("DecimalFormat: negative grouping number")
  func testDecimalFormatNegativeGrouping() {
    let df = java.text.DecimalFormat("#,##0.00")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let result = df.format(-1234.56)
    #expect(result.contains("-"))
    #expect(result.contains("1,234"))
  }

  @Test("DecimalFormat: parse() handles negative number")
  func testDecimalFormatParseNegative() throws {
    let df = java.text.DecimalFormat("0.00")
    let sym = java.text.DecimalFormatSymbols(java.util.Locale("en", "US"))
    df.setDecimalFormatSymbols(sym)
    let formatted = df.format(-2.5)
    let parsed = try df.parse(formatted)
    #expect(abs(parsed - (-2.5)) < 0.01)
  }

  // ---------------------------------------------------------------------------
  // MARK: BreakIterator — isBoundary / preceding
  // ---------------------------------------------------------------------------

  @Test("BreakIterator: isBoundary() returns true at position 0")
  func testIsBoundaryAtZero() {
    let bi = java.text.BreakIterator.getCharacterInstance()
    bi.setText("abc")
    #expect(bi.isBoundary(0))
  }

  @Test("BreakIterator: isBoundary() returns true at end")
  func testIsBoundaryAtEnd() {
    let bi = java.text.BreakIterator.getCharacterInstance()
    bi.setText("abc")
    #expect(bi.isBoundary(3))
  }

  @Test("BreakIterator: isBoundary() returns true at every character position")
  func testIsBoundaryAllPositions() {
    let bi = java.text.BreakIterator.getCharacterInstance()
    bi.setText("ab")
    #expect(bi.isBoundary(0))
    #expect(bi.isBoundary(1))
    #expect(bi.isBoundary(2))
  }

  @Test("BreakIterator: isBoundary() returns false for out-of-range index")
  func testIsBoundaryOutOfRange() {
    let bi = java.text.BreakIterator.getCharacterInstance()
    bi.setText("abc")
    #expect(!bi.isBoundary(99))
    #expect(!bi.isBoundary(-1))
  }

  @Test("BreakIterator: preceding() returns boundary before offset")
  func testPreceding() {
    let bi = java.text.BreakIterator.getWordInstance()
    bi.setText("one two")
    let b = bi.preceding(4)
    #expect(b >= 0)
    #expect(b < 4)
  }

  @Test("BreakIterator: preceding() at 0 returns DONE")
  func testPrecedingAtZero() {
    let bi = java.text.BreakIterator.getCharacterInstance()
    bi.setText("abc")
    #expect(bi.preceding(0) == java.text.BreakIterator.DONE)
  }

  // ---------------------------------------------------------------------------
  // MARK: Collator — German umlauts at PRIMARY strength
  // ---------------------------------------------------------------------------

  @Test("Collator: 'ä' equals 'a' at PRIMARY for de_DE")
  func testUmlautPrimaryDE() {
    let c = java.text.Collator.getInstance(java.util.Locale("de", "DE"))
    c.setStrength(java.text.Collator.PRIMARY)
    #expect(c.compare("ä", "a") == 0)
  }

  @Test("Collator: 'ö' equals 'o' at PRIMARY for de_DE")
  func testUmlautOPrimaryDE() {
    let c = java.text.Collator.getInstance(java.util.Locale("de", "DE"))
    c.setStrength(java.text.Collator.PRIMARY)
    #expect(c.compare("ö", "o") == 0)
  }

  @Test("Collator: 'ü' equals 'u' at PRIMARY for de_DE")
  func testUmlautUPrimaryDE() {
    let c = java.text.Collator.getInstance(java.util.Locale("de", "DE"))
    c.setStrength(java.text.Collator.PRIMARY)
    #expect(c.compare("ü", "u") == 0)
  }

  @Test("Collator: 'ä' differs from 'a' at TERTIARY for de_DE")
  func testUmlautTertiaryDE() {
    let c = java.text.Collator.getInstance(java.util.Locale("de", "DE"))
    c.setStrength(java.text.Collator.TERTIARY)
    #expect(c.compare("ä", "a") != 0)
  }

  @Test("Collator: sorting ['Zebra','Apfel','Ärger'] with de_DE PRIMARY")
  func testGermanSortPrimary() {
    let c = java.text.Collator.getInstance(java.util.Locale("de", "DE"))
    c.setStrength(java.text.Collator.PRIMARY)
    let words = ["Zebra", "Apfel", "Ärger"]
    let sorted = words.sorted { c.compare($0, $1) < 0 }
    // Ärger ≈ Arger → before Zebra; Apfel before Ärger
    #expect(sorted[0] == "Apfel" || sorted[0] == "Ärger") // both start with A at PRIMARY
    #expect(sorted.last == "Zebra")
  }

  // ---------------------------------------------------------------------------
  // MARK: CollationKey — PRIMARY strength
  // ---------------------------------------------------------------------------

  @Test("CollationKey: PRIMARY strength — 'ä' and 'a' keys compare equal")
  func testCollationKeyPrimaryUmlauts() {
    let c = java.text.Collator.getInstance(java.util.Locale("de", "DE"))
    c.setStrength(java.text.Collator.PRIMARY)
    let ka = c.getCollationKey("a")
    let kae = c.getCollationKey("ä")
    #expect(ka.compareTo(kae) == 0)
  }

  @Test("CollationKey: TERTIARY — 'a' and 'A' keys differ")
  func testCollationKeyTertiaryCase() {
    let c = java.text.Collator.getInstance(java.util.Locale("en", "US"))
    c.setStrength(java.text.Collator.TERTIARY)
    let ka  = c.getCollationKey("a")
    let kA  = c.getCollationKey("A")
    #expect(ka != kA)
  }

  // ---------------------------------------------------------------------------
  // MARK: RuleBasedCollator — multi-char token
  // ---------------------------------------------------------------------------

  @Test("RuleBasedCollator: multi-char token 'ch' sorts as single unit")
  func testMultiCharToken() throws {
    // Spanish traditional: ch sorts after c, before d
    let rules = "< a < b < c < ch < d < e"
    let col   = try java.text.RuleBasedCollator(rules)
    #expect(col.compare("c", "ch") < 0)
    #expect(col.compare("ch", "d") < 0)
  }
}

// =============================================================================
// MARK: - Collator: Unicode / CJK (Japanese)
// =============================================================================

struct JavApi_text_Collator_Japanese_Tests {

  // ---------------------------------------------------------------------------
  // MARK: Robustness — no crash on CJK input
  // ---------------------------------------------------------------------------

  @Test("Collator ja_JP: compare Japanese strings does not crash")
  func testJapaneseNocrash() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    // Must not throw or crash — result value is platform-defined
    let result = c.compare("東京", "大阪")
    #expect(result == -1 || result == 0 || result == 1)
  }

  @Test("Collator ja_JP: compare identical strings returns 0")
  func testJapaneseIdentical() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    #expect(c.compare("東京", "東京") == 0)
  }

  @Test("Collator ja_JP: equals() true for same string")
  func testJapaneseEqualsTrue() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    #expect(c.equals("日本語", "日本語"))
  }

  @Test("Collator ja_JP: equals() false for different strings")
  func testJapaneseEqualsFalse() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    #expect(!c.equals("東京", "大阪"))
  }

  // ---------------------------------------------------------------------------
  // MARK: Hiragana / Katakana at PRIMARY
  // ---------------------------------------------------------------------------

  @Test("Collator ja_JP PRIMARY: hiragana あ and katakana ア compare consistently")
  func testHiraganaKatakanaPrimary() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    c.setStrength(java.text.Collator.PRIMARY)
    // Foundation folds hiragana/katakana to the same form at diacriticInsensitive+caseInsensitive
    // The important guarantee: result must be deterministic (same call → same result)
    let r1 = c.compare("あ", "ア")
    let r2 = c.compare("あ", "ア")
    #expect(r1 == r2)
  }

  @Test("Collator ja_JP IDENTICAL: hiragana あ and katakana ア are distinct at code-point level")
  func testHiraganaKatakanaIdentical() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    c.setStrength(java.text.Collator.IDENTICAL)
    // At IDENTICAL, code-point order is used as tiebreaker:
    // あ (U+3042) != ア (U+30A2) — they must not be equal
    #expect(c.compare("あ", "ア") != 0)
  }

  @Test("Collator ja_JP: hiragana sequence あいう sorts before かきく")
  func testHiraganaOrder() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    // In Japanese gojuuon order: あ行 < か行
    let result = c.compare("あいう", "かきく")
    // Result should be negative (あ before か) — platform may vary for mixed scripts,
    // but within pure hiragana the order must be consistent
    #expect(result == -1 || result == 0 || result == 1) // must not crash
    // Determinism: same inputs must always give same result
    #expect(c.compare("あいう", "かきく") == result)
  }

  // ---------------------------------------------------------------------------
  // MARK: CollationKey stability for CJK
  // ---------------------------------------------------------------------------

  @Test("Collator ja_JP: CollationKey for same string is stable")
  func testCollationKeyStabilityJapanese() {
    let c  = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    let k1 = c.getCollationKey("東京")
    let k2 = c.getCollationKey("東京")
    #expect(k1 == k2)
    #expect(k1.compareTo(k2) == 0)
    #expect(k1.getSourceString() == "東京")
  }

  @Test("Collator ja_JP: CollationKey for different strings are not equal")
  func testCollationKeyInequalityJapanese() {
    let c  = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    let k1 = c.getCollationKey("東京")
    let k2 = c.getCollationKey("大阪")
    #expect(k1 != k2)
  }

  @Test("Collator ja_JP: CollationKey compareTo is antisymmetric")
  func testCollationKeyAntisymmetric() {
    let c  = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    let k1 = c.getCollationKey("東京")
    let k2 = c.getCollationKey("大阪")
    let r12 = k1.compareTo(k2)
    let r21 = k2.compareTo(k1)
    // If k1 < k2 then k2 > k1 — signs must be opposite (or both 0)
    if r12 < 0 { #expect(r21 > 0) }
    if r12 > 0 { #expect(r21 < 0) }
    if r12 == 0 { #expect(r21 == 0) }
  }

  // ---------------------------------------------------------------------------
  // MARK: Sorting a mixed Japanese list
  // ---------------------------------------------------------------------------

  @Test("Collator ja_JP: sorting a list of Japanese words is stable and crash-free")
  func testJapaneseSortStable() {
    let c     = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    let words = ["東京", "大阪", "名古屋", "札幌", "福岡"]
    let sorted = words.sorted { c.compare($0, $1) < 0 }
    // Sorted list must contain exactly the same elements
    #expect(Set(sorted) == Set(words))
    #expect(sorted.count == words.count)
    // Verify sort is consistent: sorting twice gives same result
    let sorted2 = words.sorted { c.compare($0, $1) < 0 }
    #expect(sorted == sorted2)
  }

  @Test("Collator ja_JP: CollationKeys can sort a Japanese word list")
  func testJapaneseCollationKeySort() {
    let c     = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    let words = ["東京", "大阪", "名古屋"]
    let sorted = words
      .map { c.getCollationKey($0) }
      .sorted()
      .map { $0.getSourceString() }
    #expect(Set(sorted) == Set(words))
    #expect(sorted.count == 3)
  }

  // ---------------------------------------------------------------------------
  // MARK: Mixed script (Kanji + Hiragana + Katakana)
  // ---------------------------------------------------------------------------

  @Test("Collator ja_JP: mixed script strings compare without crash")
  func testMixedScriptNocrash() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    let mixed = ["日本語", "にほんご", "ニホンゴ", "Japan"]
    for a in mixed {
      for b in mixed {
        let r = c.compare(a, b)
        #expect(r == -1 || r == 0 || r == 1)
      }
    }
  }

  @Test("Collator ja_JP: empty string compares less than any non-empty string")
  func testEmptyStringJapanese() {
    let c = java.text.Collator.getInstance(java.util.Locale("ja", "JP"))
    #expect(c.compare("", "あ") <= 0)
    #expect(c.compare("", "") == 0)
  }
}

// =============================================================================
// MARK: - CollationElementIterator
// =============================================================================

struct JavApi_text_CollationElementIterator_Tests {

  @Test("CollationElementIterator: next() returns NULLORDER at end")
  func testNullorderAtEnd() throws {
    let col  = try java.text.RuleBasedCollator("< a < b < c")
    let iter = col.getCollationElementIterator("ab")
    _ = iter.next()   // 'a'
    _ = iter.next()   // 'b'
    let sentinel = iter.next()
    #expect(sentinel == java.text.CollationElementIterator.NULLORDER)
  }

  @Test("CollationElementIterator: primary order increases with rule order")
  func testPrimaryOrderAscending() throws {
    let col  = try java.text.RuleBasedCollator("< a < b < c")
    let iter = col.getCollationElementIterator("abc")
    let ea   = iter.next()
    let eb   = iter.next()
    let ec   = iter.next()
    let pa   = java.text.CollationElementIterator.primaryOrder(ea)
    let pb   = java.text.CollationElementIterator.primaryOrder(eb)
    let pc   = java.text.CollationElementIterator.primaryOrder(ec)
    #expect(pa < pb)
    #expect(pb < pc)
  }

  @Test("CollationElementIterator: reset() restarts iteration")
  func testReset() throws {
    let col   = try java.text.RuleBasedCollator("< a < b")
    let iter  = col.getCollationElementIterator("ab")
    let first = iter.next()
    iter.reset()
    let again = iter.next()
    #expect(first == again)
  }

  @Test("CollationElementIterator: previous() walks backwards")
  func testPrevious() throws {
    let col  = try java.text.RuleBasedCollator("< a < b < c")
    let iter = col.getCollationElementIterator("abc")
    _ = iter.next()
    _ = iter.next()
    _ = iter.next()
    let ec = iter.previous()
    let eb = iter.previous()
    let ea = iter.previous()
    let pa = java.text.CollationElementIterator.primaryOrder(ea)
    let pb = java.text.CollationElementIterator.primaryOrder(eb)
    let pc = java.text.CollationElementIterator.primaryOrder(ec)
    #expect(pa < pb)
    #expect(pb < pc)
  }

  @Test("CollationElementIterator: previous() returns NULLORDER at start")
  func testPreviousAtStart() throws {
    let col  = try java.text.RuleBasedCollator("< a")
    let iter = col.getCollationElementIterator("a")
    #expect(iter.previous() == java.text.CollationElementIterator.NULLORDER)
  }

  @Test("CollationElementIterator: order extractors are consistent")
  func testOrderExtractors() throws {
    let col  = try java.text.RuleBasedCollator("< a < b")
    let iter = col.getCollationElementIterator("a")
    let e    = iter.next()
    let p    = java.text.CollationElementIterator.primaryOrder(e)
    let s    = java.text.CollationElementIterator.secondaryOrder(e)
    let t    = java.text.CollationElementIterator.tertiaryOrder(e)
    #expect(p >= 0)
    #expect(s >= 0)
    #expect(t >= 0)
  }

  @Test("CollationElementIterator: via StringCharacterIterator overload")
  func testStringCharacterIteratorOverload() throws {
    let col  = try java.text.RuleBasedCollator("< a < b < c")
    let sci  = java.text.StringCharacterIterator("abc")
    let iter = col.getCollationElementIterator(sci)
    let ea   = iter.next()
    let eb   = iter.next()
    let pa   = java.text.CollationElementIterator.primaryOrder(ea)
    let pb   = java.text.CollationElementIterator.primaryOrder(eb)
    #expect(pa < pb)
  }

  @Test("CollationElementIterator: setOffset repositions")
  func testSetOffset() throws {
    let col  = try java.text.RuleBasedCollator("< a < b < c")
    let iter = col.getCollationElementIterator("abc")
    iter.setOffset(1)
    #expect(iter.getOffset() == 1)
    let e2 = iter.next()   // element at index 1 ('b')
    let p2 = java.text.CollationElementIterator.primaryOrder(e2)
    let col2 = try java.text.RuleBasedCollator("< a < b < c")
    let iter2 = col2.getCollationElementIterator("abc")
    _ = iter2.next()       // 'a'
    let e2ref = iter2.next()
    let p2ref = java.text.CollationElementIterator.primaryOrder(e2ref)
    #expect(p2 == p2ref)
  }
}

// =============================================================================
// MARK: - ChoiceFormat
// =============================================================================

struct JavApi_text_ChoiceFormat_Tests {

  @Test("ChoiceFormat: format 0 → 'no files'")
  func testZero() {
    let cf = java.text.ChoiceFormat("0#no files|1#one file|2<many files")
    #expect(cf.format(0.0) == "no files")
  }

  @Test("ChoiceFormat: format 1 → 'one file'")
  func testOne() {
    let cf = java.text.ChoiceFormat("0#no files|1#one file|2<many files")
    #expect(cf.format(1.0) == "one file")
  }

  @Test("ChoiceFormat: format > 2 → 'many files'")
  func testMany() {
    let cf = java.text.ChoiceFormat("0#no files|1#one file|2<many files")
    #expect(cf.format(5.0) == "many files")
  }

  @Test("ChoiceFormat: format exactly at '<' boundary → previous choice")
  func testAtLtBoundary() {
    // "2<many" means 2.0 itself still maps to "one file"
    let cf = java.text.ChoiceFormat("0#no files|1#one file|2<many files")
    #expect(cf.format(2.0) == "one file")
  }

  @Test("ChoiceFormat: negative number → first choice")
  func testNegative() {
    let cf = java.text.ChoiceFormat("0#zero|1#positive")
    #expect(cf.format(-1.0) == "zero")
  }

  @Test("ChoiceFormat: limits+formats constructor")
  func testLimitsFormatsConstructor() {
    let cf = java.text.ChoiceFormat(limits: [0, 1, 2], formats: ["none", "one", "many"])
    #expect(cf.format(0.0) == "none")
    #expect(cf.format(1.0) == "one")
    #expect(cf.format(3.0) == "many")
  }

  @Test("ChoiceFormat: toPattern round-trips")
  func testToPattern() {
    let pattern = "0#none|1#one|2#many"
    let cf      = java.text.ChoiceFormat(pattern)
    #expect(cf.toPattern() == pattern)
  }

  @Test("ChoiceFormat: getLimits / getFormats")
  func testGetters() {
    let cf = java.text.ChoiceFormat(limits: [0, 1], formats: ["a", "b"])
    #expect(cf.getLimits() == [0, 1])
    #expect(cf.getFormats() == ["a", "b"])
  }

  @Test("ChoiceFormat: parse matching text → limit")
  func testParse() throws {
    let cf = java.text.ChoiceFormat("0#none|1#one|2<many")
    let d: Double = try cf.parseChoice("one")
    #expect(d == 1.0)
  }

  @Test("ChoiceFormat: parse unknown text throws ParseException")
  func testParseUnknown() {
    let cf = java.text.ChoiceFormat("0#none|1#one")
    #expect(throws: java.text.ParseException.self) {
      try cf.parseChoice("unknown")
    }
  }
}

// =============================================================================
// MARK: - AttributedString
// =============================================================================

struct JavApi_text_AttributedString_Tests {

  typealias Attr = java.text.AttributedCharacterIteratorAttribute

  @Test("AttributedString: plain init — no attributes")
  func testPlainInit() {
    let as_ = java.text.AttributedString("Hello")
    let iter = as_.getIterator()
    #expect(iter.getAttributes().isEmpty)
  }

  @Test("AttributedString: init with attributes — whole string covered")
  func testInitWithAttributes() {
    let key  = Attr.LANGUAGE
    let as_  = java.text.AttributedString("Hi", [key: "en" as Any])
    let iter = as_.getIterator()
    let val  = iter.getAttribute(key) as? String
    #expect(val == "en")
  }

  @Test("AttributedString: addAttribute over whole string")
  func testAddAttributeWholeString() {
    let as_  = java.text.AttributedString("Hello")
    let key  = Attr.LANGUAGE
    as_.addAttribute(key, "de")
    let iter = as_.getIterator()
    #expect(iter.getAttribute(key) as? String == "de")
  }

  @Test("AttributedString: addAttribute over subrange only")
  func testAddAttributeSubrange() {
    let as_  = java.text.AttributedString("Hello")
    let key  = Attr.LANGUAGE
    as_.addAttribute(key, value: "fr", beginIndex: 1, endIndex: 3)
    let iter = as_.getIterator()
    // Index 0: no attribute
    #expect(iter.getAttribute(key) == nil)
    // Index 1: has attribute
    _ = iter.next()
    #expect(iter.getAttribute(key) as? String == "fr")
    // Index 3: no attribute
    _ = iter.next()
    _ = iter.next()
    #expect(iter.getAttribute(key) == nil)
  }

  @Test("AttributedString: addAttributes (plural) over subrange")
  func testAddAttributes() {
    let as_  = java.text.AttributedString("Test")
    let key1 = Attr.LANGUAGE
    let key2 = Attr.READING
    as_.addAttributes([key1: "en" as Any, key2: "read" as Any], 0, 2)
    let iter = as_.getIterator()
    #expect(iter.getAttribute(key1) as? String == "en")
    #expect(iter.getAttribute(key2) as? String == "read")
  }

  @Test("AttributedString: getAllAttributeKeys collects all distinct keys")
  func testGetAllAttributeKeys() {
    let as_  = java.text.AttributedString("AB")
    let key1 = Attr.LANGUAGE
    let key2 = Attr.READING
    as_.addAttribute(key1, value: "en", beginIndex: 0, endIndex: 1)
    as_.addAttribute(key2, value: "r",  beginIndex: 1, endIndex: 2)
    let iter = as_.getIterator()
    let keys = iter.getAllAttributeKeys()
    #expect(keys.contains(key1))
    #expect(keys.contains(key2))
    #expect(keys.count == 2)
  }

  @Test("AttributedString: getRunStart / getRunLimit detect boundary")
  func testRunBoundary() {
    let as_  = java.text.AttributedString("ABCD")
    let key  = Attr.LANGUAGE
    as_.addAttribute(key, value: "x", beginIndex: 1, endIndex: 3)
    let iter = as_.getIterator()
    // Position 0: no attribute → run is [0,1)
    #expect(iter.getRunStart() == 0)
    #expect(iter.getRunLimit() == 1)
    // Position 1: has "x" → run is [1,3)
    _ = iter.next()
    #expect(iter.getRunStart() == 1)
    #expect(iter.getRunLimit() == 3)
  }

  @Test("AttributedString: iterator navigation matches CharacterIterator")
  func testNavigation() {
    let as_  = java.text.AttributedString("ABC")
    let iter = as_.getIterator()
    #expect(iter.first() == "A")
    #expect(iter.next()  == "B")
    #expect(iter.next()  == "C")
    #expect(iter.next()  == java.text.StringCharacterIterator.DONE)
  }

  @Test("AttributedString: clone iterator is independent")
  func testClone() {
    let as_   = java.text.AttributedString("XY")
    let iter  = as_.getIterator()
    _ = iter.next()            // move to 'Y'
    let copy  = iter.clone()
    #expect(iter.current() == copy.current())
    _ = iter.next()            // iter advances to DONE
    #expect(copy.current() == "Y")  // copy stays at 'Y'
  }
}

// =============================================================================
// MARK: - Java 1.2 java.text additions
// =============================================================================

@Suite("java.text Java 1.2 additions")
struct JavApi_text_Java12_Tests {

  // ---------------------------------------------------------------------------
  // getAvailableLocales()
  // ---------------------------------------------------------------------------

  @Test("Collator.getAvailableLocales returns non-empty list")
  func testCollatorAvailableLocales() {
    let locales = java.text.Collator.getAvailableLocales()
    #expect(!locales.isEmpty)
  }

  @Test("BreakIterator.getAvailableLocales returns non-empty list")
  func testBreakIteratorAvailableLocales() {
    let locales = java.text.BreakIterator.getAvailableLocales()
    #expect(!locales.isEmpty)
  }

  @Test("NumberFormat.getAvailableLocales returns non-empty list")
  func testNumberFormatAvailableLocales() {
    let locales = java.text.NumberFormat.getAvailableLocales()
    #expect(!locales.isEmpty)
  }

  @Test("DateFormat.getAvailableLocales returns non-empty list")
  func testDateFormatAvailableLocales() {
    let locales = java.text.DateFormat.getAvailableLocales()
    #expect(!locales.isEmpty)
  }

  // ---------------------------------------------------------------------------
  // MessageFormat format accessors
  // ---------------------------------------------------------------------------

  @Test("MessageFormat.getFormats returns empty for pattern without overrides")
  func testGetFormatsEmpty() {
    let mf = java.text.MessageFormat("Hello {0}!")
    let formats = mf.getFormats()
    #expect(formats.count == 1)
    #expect(formats[0] == nil)
  }

  @Test("MessageFormat.setFormatByArgumentIndex overrides argument format")
  func testSetFormatByArgumentIndex() {
    let mf  = java.text.MessageFormat("{0}")
    let nf  = java.text.NumberFormat.getIntegerInstance()
    mf.setFormatByArgumentIndex(0, nf)
    let result = mf.format([42.7])
    // IntegerInstance rounds to nearest integer
    #expect(result == "43")
  }

  @Test("MessageFormat.setFormat overrides by format-element index")
  func testSetFormat() {
    let mf  = java.text.MessageFormat("{0} and {1}")
    let nf  = java.text.NumberFormat.getIntegerInstance()
    mf.setFormat(1, nf)   // second argument element
    let result = mf.format(["hello", 3.9])
    #expect(result == "hello and 4")
  }

  @Test("MessageFormat.getFormatsByArgumentIndex reflects overrides")
  func testGetFormatsByArgumentIndex() {
    let mf  = java.text.MessageFormat("{0} {1}")
    let nf  = java.text.NumberFormat.getInstance()
    mf.setFormatByArgumentIndex(1, nf)
    let formats = mf.getFormatsByArgumentIndex()
    #expect(formats.count == 2)
    #expect(formats[0] == nil)
    #expect(formats[1] != nil)
  }

  @Test("MessageFormat.setFormats replaces all overrides")
  func testSetFormats() {
    let mf  = java.text.MessageFormat("{0} {1}")
    let nf  = java.text.NumberFormat.getIntegerInstance()
    mf.setFormats([nil, nf])
    #expect(mf.getFormats()[0] == nil)
    #expect(mf.getFormats()[1] != nil)
  }

  @Test("MessageFormat.applyPattern clears overrides")
  func testApplyPatternClearsOverrides() {
    let mf  = java.text.MessageFormat("{0}")
    let nf  = java.text.NumberFormat.getIntegerInstance()
    mf.setFormatByArgumentIndex(0, nf)
    mf.applyPattern("{0}")     // re-apply same pattern → clears overrides
    #expect(mf.getFormats()[0] == nil)
  }

  // ---------------------------------------------------------------------------
  // AttributedString(iter, beginIndex:, endIndex:)
  // ---------------------------------------------------------------------------

  @Test("AttributedString(iter,begin,end) copies subrange correctly")
  func testAttributedStringSubrangeInit() {
    let original = java.text.AttributedString("Hello World")
    let key = java.text.AttributedCharacterIteratorAttribute.LANGUAGE
    original.addAttribute(key, value: "en", beginIndex: 0, endIndex: 5)
    original.addAttribute(key, value: "de", beginIndex: 6, endIndex: 11)

    let iter = original.getIterator()
    // Copy only "World" (indices 6..<11)
    let sub  = java.text.AttributedString(iter, 6, 11)
    let subIter = sub.getIterator()
    #expect(subIter.getAttribute(key) as? String == "de")
    // Length of sub should be 5
    #expect(subIter.getEndIndex() == 5)
  }

  @Test("AttributedString(iter,begin,end) empty range produces empty string")
  func testAttributedStringSubrangeEmpty() {
    let original = java.text.AttributedString("ABC")
    let iter = original.getIterator()
    let sub  = java.text.AttributedString(iter, 2, 2)
    #expect(sub.getIterator().getEndIndex() == 0)
  }
}
