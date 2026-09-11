/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Coverage for the `java.util.stream`-bridging String/CharSequence methods
/// added once `IntStream`/`Stream` became available: `chars()`, `codePoints()`,
/// and `lines()`.
@Suite("java.lang.String / CharSequence — stream bridges (Java 8/11)")
struct JavApi_lang_String_Java8Stream_Tests {

  // MARK: - chars()

  @Test("chars() returns UTF-16 code units, including a surrogate pair for a non-BMP character")
  func charsReturnsUtf16CodeUnits() {
    // "AB" -> two BMP code units. U+1F600 (😀) -> a single code point but
    // TWO UTF-16 code units (a surrogate pair) -- exactly matching real
    // Java's String.chars(), unlike this port's usual char[]->[Character]
    // (grapheme cluster) simplification.
    let s = "AB\u{1F600}"
    let values = s.chars().toArray()
    #expect(values.count == 4)
    #expect(values[0] == 65)  // 'A'
    #expect(values[1] == 66)  // 'B'
    // U+1F600 as a UTF-16 surrogate pair: high surrogate 0xD83D, low surrogate 0xDE00.
    #expect(values[2] == 0xD83D)
    #expect(values[3] == 0xDE00)
  }

  @Test("chars() on an empty string returns an empty IntStream")
  func charsOnEmptyString() {
    #expect("".chars().toArray().isEmpty)
  }

  // MARK: - codePoints()

  @Test("codePoints() returns one Int per Unicode code point, unlike chars()")
  func codePointsReturnsCodePoints() {
    let s = "AB\u{1F600}"
    let values = s.codePoints().toArray()
    #expect(values.count == 3)
    #expect(values[0] == 65)
    #expect(values[1] == 66)
    #expect(values[2] == 0x1F600)
  }

  // MARK: - CharSequence.chars() / codePoints() defaults

  @Test("CharSequence.chars()/codePoints() default methods delegate to toString()")
  func charSequenceDefaultsDelegateToString() {
    let sb = StringBuilder("Hi!")
    #expect(sb.chars().toArray() == "Hi!".chars().toArray())
    #expect(sb.codePoints().toArray() == "Hi!".codePoints().toArray())
  }

  // MARK: - lines()

  @Test("lines() splits on \\n, \\r, and \\r\\n without including the terminator")
  func linesSplitsOnAllTerminators() {
    #expect("a\nb\rc\r\nd".lines().toArray() == ["a", "b", "c", "d"])
  }

  @Test("lines() on an empty string yields zero lines")
  func linesOnEmptyString() {
    #expect("".lines().toArray().isEmpty)
  }

  @Test("lines() does not produce an extra trailing empty line for a final terminator")
  func linesTrailingTerminatorProducesNoExtraLine() {
    #expect("a\n".lines().toArray() == ["a"])
  }

  @Test("lines() keeps interior empty lines from consecutive terminators")
  func linesKeepsInteriorEmptyLines() {
    #expect("a\n\nb".lines().toArray() == ["a", "", "b"])
  }

  @Test("lines() on a single terminator yields one empty line")
  func linesOnSingleTerminator() {
    #expect("\n".lines().toArray() == [""])
  }

  @Test("lines() on text without any terminator yields that text as the only line")
  func linesWithoutTerminator() {
    #expect("no newline here".lines().toArray() == ["no newline here"])
  }
}
