/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// MARK: - PatternSyntaxException

@Suite("java.util.regex.PatternSyntaxException")
struct PatternSyntaxExceptionTests {

  @Test("stores description, pattern, index")
  func storedFields() {
    let ex = java.util.regex.PatternSyntaxException("Unclosed group", "(abc", 4)
    #expect(ex.getDescription() == "Unclosed group")
    #expect(ex.getPattern() == "(abc")
    #expect(ex.getIndex() == 4)
  }

  @Test("getMessage contains description and pattern")
  func messageContent() {
    let ex = java.util.regex.PatternSyntaxException("Bad escape", "\\q", 1)
    let msg = ex.getMessage() ?? ""
    #expect(msg.contains("Bad escape"))
    #expect(msg.contains("\\q"))
  }

  @Test("invalid pattern throws PatternSyntaxException")
  func invalidPatternThrows() throws {
    #expect(throws: java.util.regex.PatternSyntaxException.self) {
      try java.util.regex.Pattern.compile("(unclosed")
    }
  }
}

// MARK: - Pattern.compile / flags / groupCount

@Suite("java.util.regex.Pattern – compile and properties")
struct PatternCompileTests {

  @Test("pattern() returns original string")
  func patternString() throws {
    let p = try java.util.regex.Pattern.compile("\\d+")
    #expect(p.pattern() == "\\d+")
  }

  @Test("flags() returns supplied flags")
  func flagsRoundtrip() throws {
    let flags = java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.DOTALL
    let p = try java.util.regex.Pattern.compile(".*", flags)
    #expect(p.flags() == flags)
  }

  @Test("groupCount() counts capturing groups")
  func groupCount() throws {
    let p = try java.util.regex.Pattern.compile("(a)(b)(c)")
    #expect(p.groupCount() == 3)
  }

  @Test("groupCount() is 0 for no groups")
  func groupCountZero() throws {
    let p = try java.util.regex.Pattern.compile("abc")
    #expect(p.groupCount() == 0)
  }
}

// MARK: - Pattern.matches (static)

@Suite("java.util.regex.Pattern.matches")
struct PatternMatchesTests {

  @Test("matches full string")
  func wholeMatch() throws {
    #expect(try java.util.regex.Pattern.matches("\\d{3}", "123") == true)
  }

  @Test("does not match partial string")
  func partialNoMatch() throws {
    #expect(try java.util.regex.Pattern.matches("\\d{3}", "1234") == false)
  }

  @Test("case-insensitive via inline flag")
  func inlineFlag() throws {
    #expect(try java.util.regex.Pattern.matches("(?i)hello", "HELLO") == true)
  }
}

// MARK: - Pattern.split

@Suite("java.util.regex.Pattern.split")
struct PatternSplitTests {

  @Test("basic split on comma")
  func basicSplit() throws {
    let p = try java.util.regex.Pattern.compile(",")
    let parts = p.split("a,b,c")
    #expect(parts == ["a", "b", "c"])
  }

  @Test("trailing empty strings removed when limit == 0")
  func trailingEmptyRemoved() throws {
    let p = try java.util.regex.Pattern.compile(",")
    let parts = p.split("a,b,,", 0)
    #expect(parts == ["a", "b"])
  }

  @Test("limit -1 keeps trailing empty strings")
  func limitNegativeKeepsEmpty() throws {
    let p = try java.util.regex.Pattern.compile(",")
    let parts = p.split("a,b,,", -1)
    #expect(parts == ["a", "b", "", ""])
  }

  @Test("limit 2 produces at most 2 parts")
  func limitTwo() throws {
    let p = try java.util.regex.Pattern.compile(",")
    let parts = p.split("a,b,c", 2)
    #expect(parts == ["a", "b,c"])
  }

  @Test("split on whitespace")
  func splitWhitespace() throws {
    let p = try java.util.regex.Pattern.compile("\\s+")
    let parts = p.split("  foo   bar  baz  ")
    #expect(parts == ["", "foo", "bar", "baz"])
  }
}

// MARK: - Matcher.matches / lookingAt / find

@Suite("java.util.regex.Matcher – basic matching")
struct MatcherBasicTests {

  @Test("matches() whole input")
  func matchesWhole() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("12345")
    #expect(m.matches() == true)
  }

  @Test("matches() fails on partial")
  func matchesFails() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("123abc")
    #expect(m.matches() == false)
  }

  @Test("lookingAt() matches prefix")
  func lookingAt() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("123abc")
    #expect(m.lookingAt() == true)
  }

  @Test("find() locates first occurrence")
  func findFirst() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("abc 42 def")
    #expect(m.find() == true)
    #expect(m.group() == "42")
  }

  @Test("find() iterates through all occurrences")
  func findAll() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("1 22 333")
    var tokens: [String] = []
    while m.find() { tokens.append(m.group()) }
    #expect(tokens == ["1", "22", "333"])
  }

  @Test("find(start) resets to given position")
  func findFromStart() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("a1b2c3")
    #expect(m.find(3) == true)
    #expect(m.group() == "2")
  }
}

// MARK: - Matcher.group / start / end

@Suite("java.util.regex.Matcher – groups, start, end")
struct MatcherGroupTests {

  @Test("group(0) equals group()")
  func group0() throws {
    let m = try java.util.regex.Pattern.compile("(\\d+)-(\\w+)").matcher("42-hello")
    #expect(m.matches() == true)
    #expect(m.group(0) == m.group())
    #expect(m.group(0) == "42-hello")
  }

  @Test("numbered capture groups")
  func numberedGroups() throws {
    let m = try java.util.regex.Pattern.compile("(\\d+)-(\\w+)").matcher("42-hello")
    #expect(m.matches() == true)
    #expect(m.group(1) == "42")
    #expect(m.group(2) == "hello")
  }

  @Test("start() and end() are correct")
  func startEnd() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("abc123def")
    #expect(m.find() == true)
    #expect(m.start() == 3)
    #expect(m.end() == 6)
  }

  @Test("start(n) and end(n) for capture group")
  func startEndGroup() throws {
    let m = try java.util.regex.Pattern.compile("a(\\d+)b").matcher("a99b")
    #expect(m.matches() == true)
    #expect(m.start(1) == 1)
    #expect(m.end(1) == 3)
  }

  @Test("groupCount() matches pattern")
  func groupCount() throws {
    let m = try java.util.regex.Pattern.compile("(a)(b)(c)").matcher("abc")
    _ = m.matches()
    #expect(m.groupCount() == 3)
  }
}

// MARK: - Matcher.replaceAll / replaceFirst

@Suite("java.util.regex.Matcher – replacement")
struct MatcherReplacementTests {

  @Test("replaceAll replaces every occurrence")
  func replaceAll() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("a1b22c333")
    #expect(m.replaceAll("N") == "aNbNcN")
  }

  @Test("replaceFirst replaces only first")
  func replaceFirst() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("a1b22c333")
    #expect(m.replaceFirst("N") == "aNb22c333")
  }

  @Test("replaceAll with $1 backreference")
  func replaceAllBackref() throws {
    let m = try java.util.regex.Pattern.compile("(\\w+)@(\\w+)").matcher("user@host")
    #expect(m.replaceAll("$2:$1") == "host:user")
  }

  @Test("replaceAll with $0 whole-match backreference")
  func replaceAllBackref0() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("val=42")
    #expect(m.replaceAll("[$0]") == "val=[42]")
  }

  @Test("escape in replacement: \\$ literal dollar")
  func escapedDollar() throws {
    let m = try java.util.regex.Pattern.compile("price").matcher("the price is right")
    #expect(m.replaceAll("\\$price") == "the $price is right")
  }
}

// MARK: - Matcher.reset

@Suite("java.util.regex.Matcher – reset")
struct MatcherResetTests {

  @Test("reset() restarts find from beginning")
  func resetRestart() throws {
    let m = try java.util.regex.Pattern.compile("\\d").matcher("1 2 3")
    #expect(m.find() == true)
    #expect(m.group() == "1")
    m.reset()
    #expect(m.find() == true)
    #expect(m.group() == "1")
  }

  @Test("reset(input) changes input")
  func resetInput() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("abc")
    #expect(m.find() == false)
    m.reset("99")
    #expect(m.find() == true)
    #expect(m.group() == "99")
  }
}

// MARK: - Flags: CASE_INSENSITIVE, MULTILINE, DOTALL

@Suite("java.util.regex.Pattern – flags")
struct PatternFlagsTests {

  @Test("CASE_INSENSITIVE flag")
  func caseInsensitive() throws {
    let p = try java.util.regex.Pattern.compile("hello", java.util.regex.Pattern.CASE_INSENSITIVE)
    #expect(p.matcher("HELLO").matches() == true)
    #expect(p.matcher("Hello").matches() == true)
  }

  @Test("DOTALL flag: dot matches newline")
  func dotAll() throws {
    let p = try java.util.regex.Pattern.compile("a.b", java.util.regex.Pattern.DOTALL)
    #expect(p.matcher("a\nb").matches() == true)
  }

  @Test("without DOTALL, dot does not match newline")
  func noDotAll() throws {
    let p = try java.util.regex.Pattern.compile("a.b")
    #expect(p.matcher("a\nb").matches() == false)
  }

  @Test("MULTILINE: ^ matches after newline")
  func multiline() throws {
    let p = try java.util.regex.Pattern.compile("^\\d+", java.util.regex.Pattern.MULTILINE)
    let m = p.matcher("abc\n123\ndef")
    var found = false
    while m.find() {
      if m.group() == "123" { found = true }
    }
    #expect(found == true)
  }
}

// MARK: - Pattern._escapeLiteral / \Q...\E

@Suite("java.util.regex.Pattern – literal quoting")
struct PatternLiteralTests {

  @Test("LITERAL flag: metacharacters treated literally")
  func literalFlag() throws {
    let p = try java.util.regex.Pattern.compile("a.b", java.util.regex.Pattern.LITERAL)
    #expect(p.matcher("a.b").matches() == true)
    #expect(p.matcher("axb").matches() == false)
  }

  @Test("\\Q...\\E in pattern")
  func literalQuoting() throws {
    let p = try java.util.regex.Pattern.compile("\\Q(a+b)\\E")
    #expect(p.matcher("(a+b)").matches() == true)
    #expect(p.matcher("xab").matches() == false)
  }

  @Test("\\Q without \\E escapes to end")
  func literalQuotingNoClose() throws {
    let p = try java.util.regex.Pattern.compile("\\Qa.b")
    #expect(p.matcher("a.b").matches() == true)
    #expect(p.matcher("axb").matches() == false)
  }
}

// MARK: - appendReplacement / appendTail

@Suite("java.util.regex.Matcher – appendReplacement/appendTail")
struct AppendReplacementTests {

  @Test("loop-style replacement with appendReplacement/appendTail")
  func loopReplacement() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("a1b22c333")
    let sb = StringBuffer()
    while m.find() {
      m.appendReplacement(sb, "N")
    }
    m.appendTail(sb)
    #expect(sb.toString() == "aNbNcN")
  }
}

// MARK: - asPredicate / asMatchPredicate

@Suite("java.util.regex.Pattern – predicates")
struct PatternPredicateTests {

  @Test("asPredicate finds match anywhere in string")
  func asPredicate() throws {
    let pred = try java.util.regex.Pattern.compile("\\d+").asPredicate()
    #expect(pred("abc123"))
    #expect(!pred("abcdef"))
  }

  @Test("asMatchPredicate requires full match")
  func asMatchPredicate() throws {
    let pred = try java.util.regex.Pattern.compile("\\d+").asMatchPredicate()
    #expect(pred("123"))
    #expect(!pred("123abc"))
  }
}

// MARK: - usePattern

@Suite("java.util.regex.Matcher – usePattern")
struct UsePatternTests {

  @Test("usePattern changes the matching pattern")
  func usePatternSwitch() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("abc 42 def")
    #expect(m.find() == true)
    #expect(m.group() == "42")

    let p2 = try java.util.regex.Pattern.compile("[a-z]+")
    m.usePattern(p2)
    // usePattern preserves the current search position (Java semantics).
    // The next find() continues after "42", so it finds "def".
    #expect(m.find() == true)
    #expect(m.group() == "def")
  }
}
