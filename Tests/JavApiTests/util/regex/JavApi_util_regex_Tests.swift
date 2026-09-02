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
    #expect(try m.replaceAll("N") == "aNbNcN")
  }

  @Test("replaceFirst replaces only first")
  func replaceFirst() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("a1b22c333")
    #expect(try m.replaceFirst("N") == "aNb22c333")
  }

  @Test("replaceAll with $1 backreference")
  func replaceAllBackref() throws {
    let m = try java.util.regex.Pattern.compile("(\\w+)@(\\w+)").matcher("user@host")
    #expect(try m.replaceAll("$2:$1") == "host:user")
  }

  @Test("replaceAll with $0 whole-match backreference")
  func replaceAllBackref0() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("val=42")
    #expect(try m.replaceAll("[$0]") == "val=[42]")
  }

  @Test("escape in replacement: \\$ literal dollar")
  func escapedDollar() throws {
    let m = try java.util.regex.Pattern.compile("price").matcher("the price is right")
    #expect(try m.replaceAll("\\$price") == "the $price is right")
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
      try m.appendReplacement(sb, "N")
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

// MARK: - Matcher.pattern() / hitEnd() / requireEnd()
//
// These three methods were confirmed missing (commit a1f8cc39 claimed
// "implement java.util.regex" but they were not present) — see
// Util-Implementierung.md, Java-1.5-regex section.

@Suite("java.util.regex.Matcher – pattern()")
struct MatcherPatternGetterTests {

  @Test("pattern() returns the Pattern this Matcher was created from")
  func returnsOriginatingPattern() throws {
    let p = try java.util.regex.Pattern.compile("\\d+")
    let m = p.matcher("abc123")
    #expect(m.pattern() === p)
  }

  @Test("pattern() reflects usePattern(_:) after switching")
  func reflectsUsePattern() throws {
    let p1 = try java.util.regex.Pattern.compile("\\d+")
    let p2 = try java.util.regex.Pattern.compile("[a-z]+")
    let m = p1.matcher("abc123")
    m.usePattern(p2)
    #expect(m.pattern() === p2)
  }
}

@Suite("java.util.regex.Matcher – hitEnd()")
struct MatcherHitEndTests {

  @Test("hitEnd() is false before any match has been attempted")
  func falseBeforeMatchAttempt() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("abc123")
    #expect(m.hitEnd() == false)
  }

  @Test("hitEnd() is true when find() reaches the end of the input")
  func trueWhenMatchReachesEnd() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("abc123")
    #expect(m.find() == true)
    #expect(m.hitEnd() == true)
  }

  @Test("hitEnd() is false when find() matches before the end of the input")
  func falseWhenMatchLeavesTrailingInput() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("123abc")
    #expect(m.find() == true)
    #expect(m.hitEnd() == false)
  }

  @Test("hitEnd() is true when no match is found at all")
  func trueWhenNoMatchFound() throws {
    let m = try java.util.regex.Pattern.compile("xyz").matcher("abc123")
    #expect(m.find() == false)
    #expect(m.hitEnd() == true)
  }
}

@Suite("java.util.regex.Matcher – requireEnd()")
struct MatcherRequireEndTests {

  @Test("requireEnd() is false when hitEnd() is false")
  func falseWhenNotAtEnd() throws {
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("123abc")
    #expect(m.find() == true)
    #expect(m.hitEnd() == false)
    #expect(m.requireEnd() == false)
  }

  @Test("requireEnd() is false when a trailing match at the end could not be invalidated by more input")
  func falseWhenMatchIsStable() throws {
    // "123" is followed only by a non-digit-class probe in the check, and
    // \d+ does not depend on what comes after — the match cannot be lost.
    let m = try java.util.regex.Pattern.compile("\\d+").matcher("abc123")
    #expect(m.find() == true)
    #expect(m.hitEnd() == true)
    #expect(m.requireEnd() == false)
  }

  @Test("requireEnd() is true when a trailing word boundary could be invalidated by more input")
  func trueWhenWordBoundaryAtRisk() throws {
    // \d+\b matches "123" at the very end of the input; if more (word-
    // forming) characters followed, the trailing \b would no longer hold
    // there, so this exact match would be lost.
    let m = try java.util.regex.Pattern.compile("\\d+\\b").matcher("abc123")
    #expect(m.find() == true)
    #expect(m.group() == "123")
    #expect(m.hitEnd() == true)
    #expect(m.requireEnd() == true)
  }

  @Test("requireEnd() is false for matches() on a pattern with no boundary dependency")
  func falseForMatchesWithoutBoundaryDependency() throws {
    // "a.*" against "aaa" (matches() requires the whole region): the
    // trailing ".*" absorbs any additional character, so appending more
    // input can never turn this positive match into a negative one.
    let m = try java.util.regex.Pattern.compile("a.*").matcher("aaa")
    #expect(m.matches() == true)
    #expect(m.hitEnd() == true)
    #expect(m.requireEnd() == false)
  }
}

// MARK: - Matcher.quoteReplacement / Pattern.quote

@Suite("java.util.regex.Matcher.quoteReplacement")
struct MatcherQuoteReplacementTests {

  @Test("a string without '\\' or '$' is returned unchanged")
  func plainStringUnchanged() {
    #expect(java.util.regex.Matcher.quoteReplacement("hello world") == "hello world")
  }

  @Test("'$' is escaped so group references are not expanded")
  func dollarIsEscaped() {
    #expect(java.util.regex.Matcher.quoteReplacement("$1 and $2") == "\\$1 and \\$2")
  }

  @Test("'\\\\' is escaped")
  func backslashIsEscaped() {
    #expect(java.util.regex.Matcher.quoteReplacement("a\\b") == "a\\\\b")
  }

  @Test("quoted replacement round-trips through appendReplacement/replaceAll literally")
  func roundTripsThroughReplaceAll() throws {
    let m = try java.util.regex.Pattern.compile("X").matcher("X-X")
    let literal = java.util.regex.Matcher.quoteReplacement("$1\\end")
    #expect(try m.replaceAll(literal) == "$1\\end-$1\\end")
  }
}

@Suite("java.util.regex.Pattern.quote")
struct PatternQuoteTests {

  @Test("wraps a plain string in \\\\Q...\\\\E")
  func wrapsInQE() {
    #expect(java.util.regex.Pattern.quote("a.b*c") == "\\Qa.b*c\\E")
  }

  @Test("the quoted string matches its input literally, metacharacters included")
  func quotedPatternMatchesLiterally() throws {
    let literal = "a.b*c?"
    let p = try java.util.regex.Pattern.compile(java.util.regex.Pattern.quote(literal))
    #expect(p.matcher(literal).matches() == true)
    #expect(p.matcher("axbxxc?").matches() == false)
  }

  @Test("an embedded \\\\E is closed and reopened instead of terminating the quote early")
  func embeddedSlashEIsHandled() throws {
    let literal = "a\\Eb"
    let quoted = java.util.regex.Pattern.quote(literal)
    let p = try java.util.regex.Pattern.compile(quoted)
    #expect(p.matcher(literal).matches() == true)
  }
}

// MARK: - Matcher region-boundary flags

@Suite("java.util.regex.Matcher anchoring/transparent bounds")
struct MatcherBoundsFlagsTests {

  @Test("defaults match the JDK: anchoring bounds true, transparent bounds false")
  func defaults() throws {
    let m = try java.util.regex.Pattern.compile("x").matcher("x")
    #expect(m.hasAnchoringBounds() == true)
    #expect(m.hasTransparentBounds() == false)
  }

  @Test("useAnchoringBounds/useTransparentBounds are remembered and are fluent")
  func settersAreRememberedAndFluent() throws {
    let m = try java.util.regex.Pattern.compile("x").matcher("x")
    #expect(m.useAnchoringBounds(false) === m)
    #expect(m.hasAnchoringBounds() == false)
    #expect(m.useTransparentBounds(true) === m)
    #expect(m.hasTransparentBounds() == true)

    m.useAnchoringBounds(true)
    m.useTransparentBounds(false)
    #expect(m.hasAnchoringBounds() == true)
    #expect(m.hasTransparentBounds() == false)
  }
}

// MARK: - Matcher.group(String) — named capture groups

@Suite("java.util.regex.Matcher – named groups")
struct MatcherNamedGroupTests {

  @Test("group(name) returns the named capture's substring")
  func namedGroupReturnsSubstring() throws {
    let m = try java.util.regex.Pattern.compile("(?<year>\\d{4})-(?<month>\\d{2})").matcher("2026-09")
    #expect(m.matches() == true)
    #expect(try m.group("year") == "2026")
    #expect(try m.group("month") == "09")
  }

  @Test("group(name) returns nil for a named group that didn't participate")
  func namedGroupNotParticipating() throws {
    let m = try java.util.regex.Pattern.compile("(?<a>x)|(?<b>y)").matcher("y")
    #expect(m.matches() == true)
    #expect(try m.group("a") == nil)
    #expect(try m.group("b") == "y")
  }

  @Test("group(name) throws IllegalArgumentException for an unknown group name")
  func unknownNamedGroupThrows() throws {
    let m = try java.util.regex.Pattern.compile("(?<year>\\d{4})").matcher("2026")
    #expect(m.matches() == true)
    #expect(throws: IllegalArgumentException.self) {
      _ = try m.group("nope")
    }
  }

  @Test("${name} in a replacement template resolves the named group")
  func namedGroupInReplacement() throws {
    let m = try java.util.regex.Pattern.compile("(?<year>\\d{4})-(?<month>\\d{2})").matcher("2026-09")
    #expect(try m.replaceAll("${month}/${year}") == "09/2026")
  }

  @Test("an unknown ${name} in a replacement template throws IllegalArgumentException")
  func unknownNamedGroupInReplacementThrows() throws {
    let m = try java.util.regex.Pattern.compile("(?<year>\\d{4})").matcher("2026")
    #expect(throws: IllegalArgumentException.self) {
      _ = try m.replaceAll("${nope}")
    }
  }
}

// MARK: - Harmony-style edge-case coverage: character classes, quantifiers,
// backreferences, non-capturing groups, lookaround, split-with-capture.
//
// Apache Harmony's java.util.regex test suite (PatternTest/Pattern2Test/
// MatcherTest in the historical Harmony/Android libcore sources) exercises
// these constructs far more exhaustively than the suites above; this block
// adds a representative, still-bounded slice of the same categories rather
// than a full port.

@Suite("java.util.regex.Pattern – character classes and alternation")
struct PatternCharacterClassTests {

  @Test("a simple character class [abc]")
  func simpleClass() throws {
    let p = try java.util.regex.Pattern.compile("[abc]")
    #expect(p.matcher("b").matches() == true)
    #expect(p.matcher("d").matches() == false)
  }

  @Test("a negated character class [^abc]")
  func negatedClass() throws {
    let p = try java.util.regex.Pattern.compile("[^abc]")
    #expect(p.matcher("d").matches() == true)
    #expect(p.matcher("a").matches() == false)
  }

  @Test("a range character class [a-z0-9]")
  func rangeClass() throws {
    let p = try java.util.regex.Pattern.compile("[a-z0-9]+")
    #expect(p.matcher("abc123").matches() == true)
    #expect(p.matcher("ABC").matches() == false)
  }

  @Test("alternation matches either branch")
  func alternation() throws {
    let p = try java.util.regex.Pattern.compile("cat|dog")
    #expect(p.matcher("cat").matches() == true)
    #expect(p.matcher("dog").matches() == true)
    #expect(p.matcher("bird").matches() == false)
  }
}

@Suite("java.util.regex.Pattern – quantifiers")
struct PatternQuantifierTests {

  @Test("bounded quantifier {2,4}")
  func boundedQuantifier() throws {
    let p = try java.util.regex.Pattern.compile("a{2,4}")
    #expect(p.matcher("a").matches() == false)
    #expect(p.matcher("aa").matches() == true)
    #expect(p.matcher("aaaa").matches() == true)
    #expect(p.matcher("aaaaa").matches() == false)
  }

  @Test("greedy quantifier consumes as much as possible")
  func greedyQuantifier() throws {
    let m = try java.util.regex.Pattern.compile("a.*b").matcher("axxbxxb")
    #expect(m.find() == true)
    #expect(m.group() == "axxbxxb")
  }

  @Test("reluctant quantifier consumes as little as possible")
  func reluctantQuantifier() throws {
    let m = try java.util.regex.Pattern.compile("a.*?b").matcher("axxbxxb")
    #expect(m.find() == true)
    #expect(m.group() == "axxb")
  }

  @Test("optional quantifier ?")
  func optionalQuantifier() throws {
    let p = try java.util.regex.Pattern.compile("colou?r")
    #expect(p.matcher("color").matches() == true)
    #expect(p.matcher("colour").matches() == true)
  }
}

@Suite("java.util.regex.Pattern – backreferences")
struct PatternBackreferenceTests {

  @Test("\\1 matches the same text as group 1")
  func simpleBackreference() throws {
    let p = try java.util.regex.Pattern.compile("(\\w)\\1")
    #expect(p.matcher("aa").matches() == true)
    #expect(p.matcher("ab").matches() == false)
  }

  @Test("backreference to a word-repeated pattern")
  func repeatedWordBackreference() throws {
    let p = try java.util.regex.Pattern.compile("(\\w+) \\1")
    #expect(p.matcher("hello hello").matches() == true)
    #expect(p.matcher("hello world").matches() == false)
  }
}

@Suite("java.util.regex.Pattern – non-capturing groups and lookaround")
struct PatternNonCapturingLookaroundTests {

  @Test("non-capturing group (?:...) does not increase groupCount")
  func nonCapturingGroupDoesNotCount() throws {
    let p = try java.util.regex.Pattern.compile("(?:abc)(def)")
    #expect(p.groupCount() == 1)
    #expect(p.matcher("abcdef").matches() == true)
  }

  @Test("positive lookahead (?=...) constrains without capturing")
  func positiveLookahead() throws {
    let p = try java.util.regex.Pattern.compile("\\d+(?=px)")
    #expect(p.groupCount() == 0)
    let m = p.matcher("10px")
    #expect(m.find() == true)
    #expect(m.group() == "10")
  }

  @Test("negative lookahead (?!...) rejects the following text")
  func negativeLookahead() throws {
    let p = try java.util.regex.Pattern.compile("\\d+(?!px)")
    let m = p.matcher("10em")
    #expect(m.find() == true)
    #expect(m.group() == "10")
    #expect(p.matcher("10px").matches() == false)
  }

  @Test("positive lookbehind (?<=...) constrains without capturing")
  func positiveLookbehind() throws {
    // `(?<=...)` is valid Java syntax and JavApi4Swift passes it through to
    // Swift's native Regex engine unchanged. That engine only gained
    // lookbehind support via SE-0448, which additionally requires a new
    // stdlib *runtime*, not just a new compiler — on Apple platforms the
    // regex engine ships with the OS, so this can throw PatternSyntaxException
    // at test-run time on an OS whose bundled Swift runtime predates that
    // update, even though the pattern itself is valid and unmodified.
    // See the "Known differences / limitations" note on Pattern for detail.
    // Treat exactly that failure as a known, environment-dependent issue so
    // the suite doesn't hard-fail on such a runtime, while any other
    // assertion failure below still fails the test normally.
    // Note: `body` must be passed as a plain (non-trailing) closure argument
    // here — trailing-closure syntax binds to the *last* parameter, which
    // would attach it to `matching` instead of `body` and fails to compile
    // ("unnamed argument must precede argument 'matching'").
    try withKnownIssue(
      "requires a Swift runtime with SE-0448 lookbehind support",
      {
        let p = try java.util.regex.Pattern.compile("(?<=\\$)\\d+")
        #expect(p.groupCount() == 0)
        let m = p.matcher("$100")
        #expect(m.find() == true)
        #expect(m.group() == "100")
      },
      matching: { $0.error is java.util.regex.PatternSyntaxException }
    )
  }

  @Test("named capture inside an alternation is counted once per branch")
  func namedGroupsInAlternationCounted() throws {
    let p = try java.util.regex.Pattern.compile("(?<a>x)|(?<b>y)")
    #expect(p.groupCount() == 2)
  }
}

@Suite("java.util.regex.Pattern – split with a capturing delimiter")
struct PatternSplitCapturingGroupTests {

  @Test("a capturing group in the delimiter pattern is not included in the result (matches Java, unlike JS)")
  func splitExcludesCapturedDelimiter() throws {
    let p = try java.util.regex.Pattern.compile("(,)")
    #expect(p.split("a,b,c") == ["a", "b", "c"])
  }

  @Test("splitting on whitespace collapses consecutive separators per match, not per character")
  func splitOnWhitespaceClass() throws {
    let p = try java.util.regex.Pattern.compile("\\s+")
    #expect(p.split("a  b   c") == ["a", "b", "c"])
  }
}

// MARK: - Matcher region()/regionStart()/regionEnd() and multi-group offsets
//
// Deepens coverage (per Harmony-style combinatorial testing) of Matcher
// surface that already existed and was already exercised indirectly
// elsewhere, but had no dedicated regression tests of its own: restricting
// the search region, multi-group start(int)/end(int) offsets, and the
// toMatchResult() frozen snapshot.

@Suite("java.util.regex.Matcher – region()")
struct MatcherRegionTests {

  @Test("region() restricts find() to the given character-offset window")
  func regionRestrictsSearch() throws {
    let p = try java.util.regex.Pattern.compile("\\d+")
    let m = p.matcher("12 34 56")
    // Restrict the region to "34" only (offsets 3..5).
    m.region(3, 5)
    #expect(m.find() == true)
    #expect(m.group() == "34")
    // No further match inside the region.
    #expect(m.find() == false)
  }

  @Test("regionStart()/regionEnd() report the offsets passed to region()")
  func regionStartEndReportOffsets() throws {
    let p = try java.util.regex.Pattern.compile("x")
    let m = p.matcher("abcxyz")
    m.region(2, 5)
    #expect(m.regionStart() == 2)
    #expect(m.regionEnd() == 5)
  }

  @Test("region() defaults span the whole input before it is called")
  func regionDefaultsSpanWholeInput() throws {
    let p = try java.util.regex.Pattern.compile("x")
    let m = p.matcher("abcxyz")
    #expect(m.regionStart() == 0)
    #expect(m.regionEnd() == 6)
  }

  @Test("region() implicitly resets prior match state, like Java")
  func regionResetsMatchState() throws {
    let p = try java.util.regex.Pattern.compile("\\d+")
    let m = p.matcher("12 34")
    #expect(m.find() == true)
    #expect(m.group() == "12")
    // Narrowing the region discards the previous match.
    m.region(3, 5)
    #expect(m.find() == true)
    #expect(m.group() == "34")
  }
}

@Suite("java.util.regex.Matcher – multi-group start(int)/end(int)")
struct MatcherMultiGroupOffsetsTests {

  @Test("start(group)/end(group) report per-group character offsets")
  func perGroupOffsets() throws {
    let p = try java.util.regex.Pattern.compile("(\\w+)@(\\w+)")
    let m = p.matcher("user@host")
    #expect(m.find() == true)
    #expect(m.start(1) == 0)
    #expect(m.end(1) == 4)
    #expect(m.start(2) == 5)
    #expect(m.end(2) == 9)
    // Group 0 is the whole match.
    #expect(m.start(0) == 0)
    #expect(m.end(0) == 9)
  }

  @Test("start(group)/end(group) return -1 for a non-participating optional group")
  func nonParticipatingGroupOffsets() throws {
    let p = try java.util.regex.Pattern.compile("(a)(b)?")
    let m = p.matcher("a")
    #expect(m.find() == true)
    #expect(m.group(1) == "a")
    #expect(m.group(2) == nil)
    #expect(m.start(2) == -1)
    #expect(m.end(2) == -1)
  }
}

@Suite("java.util.regex.Matcher – toMatchResult()")
struct MatcherToMatchResultTests {

  @Test("toMatchResult() snapshot reflects the match at the time it was taken")
  func snapshotReflectsCurrentMatch() throws {
    let p = try java.util.regex.Pattern.compile("(\\d+)")
    let m = p.matcher("ab 42 cd")
    #expect(m.find() == true)
    let snapshot = m.toMatchResult()
    #expect(snapshot.group() == "42")
    #expect(snapshot.group(1) == "42")
    #expect(snapshot.start() == 3)
    #expect(snapshot.end() == 5)
    #expect(snapshot.groupCount() == 1)
  }

  @Test("toMatchResult() snapshot is independent of subsequent matcher state changes")
  func snapshotIsIndependentOfLaterMatches() throws {
    let p = try java.util.regex.Pattern.compile("\\d+")
    let m = p.matcher("11 22")
    #expect(m.find() == true)
    let first = m.toMatchResult()
    #expect(m.find() == true)   // advances the matcher to "22"
    // The earlier snapshot must still report the first match.
    #expect(first.group() == "11")
    #expect(m.group() == "22")
  }
}
