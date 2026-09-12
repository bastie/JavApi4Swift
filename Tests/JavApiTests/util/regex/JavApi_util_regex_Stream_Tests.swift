/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

/// Coverage for the `java.util.stream`-bridging regex methods:
/// `Pattern.splitAsStream(_:)` and `Matcher.results()`.
@Suite("java.util.regex — stream bridges (Java 8/9)")
struct JavApi_util_regex_Stream_Tests {

  @Test("Pattern.splitAsStream(_:) yields the same elements as split(_:)")
  func splitAsStreamMatchesSplit() throws {
    let p = try java.util.regex.Pattern.compile(",")
    #expect(p.splitAsStream("a,b,c").toArray() == p.split("a,b,c"))
  }

  @Test("Pattern.splitAsStream(_:) discards trailing empty strings, matching split(_:) limit 0 default")
  func splitAsStreamDropsTrailingEmpties() throws {
    let p = try java.util.regex.Pattern.compile(",")
    #expect(p.splitAsStream("a,b,,").toArray() == ["a", "b"])
  }

  @Test("Matcher.results() yields one MatchResult per match, in order")
  func resultsYieldsAllMatches() throws {
    let p = try java.util.regex.Pattern.compile("\\d+")
    let m = p.matcher("ab 11 cd 22 ef 33")
    let results = m.results().toArray()
    #expect(results.count == 3)
    #expect(results.map { $0.group() } == ["11", "22", "33"])
    #expect(results[1].start() == 9)
    #expect(results[1].end() == 11)
  }

  @Test("Matcher.results() on no matches yields an empty stream")
  func resultsOnNoMatches() throws {
    let p = try java.util.regex.Pattern.compile("\\d+")
    let m = p.matcher("no digits here")
    #expect(m.results().toArray().isEmpty)
  }

  @Test("Matcher.results() continues from the matcher's current position rather than resetting")
  func resultsContinuesFromCurrentPosition() throws {
    let p = try java.util.regex.Pattern.compile("\\d+")
    let m = p.matcher("11 22 33")
    #expect(m.find() == true)   // consumes "11"
    #expect(m.group() == "11")
    // results() must pick up from here, not restart at "11".
    let remaining = m.results().toArray()
    #expect(remaining.map { $0.group() } == ["22", "33"])
  }

  @Test("Pattern.splitAsStream(_:) on a string with zero matches yields the whole string as the only element")
  func splitAsStreamZeroMatches() throws {
    let p = try java.util.regex.Pattern.compile(",")
    #expect(p.splitAsStream("no delimiter here").toArray() == ["no delimiter here"])
  }

  @Test("Matcher.results() exposes capture groups on each yielded MatchResult")
  func resultsExposesCaptureGroups() throws {
    let p = try java.util.regex.Pattern.compile("(\\w+)=(\\d+)")
    let m = p.matcher("a=1 b=22 c=333")
    let results = m.results().toArray()
    #expect(results.count == 3)
    #expect(results.map { $0.group(1) } == ["a", "b", "c"])
    #expect(results.map { $0.group(2) } == ["1", "22", "333"])
    #expect(results.allSatisfy { $0.groupCount() == 2 })
  }

  @Test("Matcher.results() on a zero-length-matching pattern terminates instead of looping forever")
  func resultsTerminatesOnZeroLengthMatches() throws {
    let p = try java.util.regex.Pattern.compile("x*")
    let m = p.matcher("abc")
    let results = m.results().toArray()
    // One empty match before each character, plus one at the very end -- see
    // the dedicated find() regression coverage in JavApi_util_regex_Tests.swift.
    #expect(results.count == 4)
    #expect(results.allSatisfy { $0.group().isEmpty })
  }
}
