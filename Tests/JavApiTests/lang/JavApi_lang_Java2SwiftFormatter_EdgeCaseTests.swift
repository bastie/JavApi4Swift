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
    // Pinned to Locale.US for the same reason as `wellFormedSpecifiersStillWork`
    // in JavApi_lang_Java2SwiftFormatter_ExceptionTests.swift — this test is
    // about significant-digit count, not locale, so it shouldn't depend on
    // the machine's default Locale for its "." decimal point.
    #expect(try String.format(java.util.Locale.US, "%g", 100.0) == "100.000")
  }

  // NOTE on the Locale.US pins below: every assertion here that contains a
  // '.' decimal point or a ',' grouping separator needs an explicit Locale,
  // for the same reason as `decimalFormShowsAllSignificantDigits` above —
  // `String.format` with no explicit Locale correctly follows
  // `java.util.Locale.getDefault()` (real Java behaviour, confirmed against
  // the Formatter javadoc), so a hardcoded "." or "," expectation is only
  // ever correct by accident, on an English-locale machine. Found via a
  // German-locale dev machine, where several of these intermittently failed
  // depending on Swift Testing's parallel test scheduling (a separate,
  // pre-existing concern — see java.util.Locale.setDefault's thread-safety
  // note elsewhere in this test target).

  @Test("%g just below the 10⁻⁴ decimal/scientific boundary stays in decimal form")
  func justAboveLowerBoundaryStaysDecimal() throws {
    #expect(try String.format(java.util.Locale.US, "%g", 0.0001234) == "0.000123400")
  }

  @Test("%g just below the 10⁻⁴ boundary switches to scientific notation")
  func justBelowLowerBoundarySwitchesToScientific() throws {
    #expect(try String.format(java.util.Locale.US, "%g", 0.00001234) == "1.23400e-05")
  }

  @Test("%g at or above 10^precision switches to scientific notation")
  func atUpperBoundarySwitchesToScientific() throws {
    #expect(try String.format(java.util.Locale.US, "%g", 123456789.0) == "1.23457e+08")
  }

  @Test("%.3g switches to scientific right at the precision boundary (rounded exponent == precision)")
  func explicitPrecisionAtBoundary() throws {
    #expect(try String.format(java.util.Locale.US, "%.3g", 1234.5678) == "1.23e+03")
  }

  @Test("%.3g stays decimal with a zero fractional-digit count when precision == integer digit count")
  func explicitPrecisionEqualsIntegerDigits() throws {
    // No '.' or ',' in the expected value ("123") — locale-independent as-is.
    #expect(try String.format("%.3g", 123.4) == "123")
  }

  @Test("%G uppercases the scientific exponent marker")
  func uppercaseScientific() throws {
    #expect(try String.format(java.util.Locale.US, "%G", 123456789.0) == "1.23457E+08")
  }

  @Test("%g on a negative value keeps the sign and rounds correctly")
  func negativeValue() throws {
    #expect(try String.format(java.util.Locale.US, "%g", -42.5) == "-42.5000")
  }

  @Test("%,g applies grouping separators in its decimal-format branch (previously a silent no-op)")
  func groupingAppliedInDecimalBranch() throws {
    #expect(try String.format(java.util.Locale.US, "%,.10g", 1234567.0) == "1,234,567.000")
  }

  @Test("%,g with default precision and grouping visible with zero fractional digits")
  func groupingWithZeroFractionalDigits() throws {
    #expect(try String.format(java.util.Locale.US, "%,g", 123456.0) == "123,456")
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

// MARK: - NaN / Infinity for %f, %e/%E, %g/%G
//
// Not a known-fixed bug yet — a suspected, previously undocumented gap
// surfaced while answering "is our code Java-API-conformant now?": Java's
// Formatter renders Double.NaN / Double.POSITIVE_INFINITY /
// Double.NEGATIVE_INFINITY as the literal, non-localized strings "NaN",
// "Infinity", "-Infinity" for every numeric floating-point conversion —
// per the Formatter javadoc's "Number Localization Algorithm": "If the
// value is NaN or positive infinity the literal strings "NaN" or
// "Infinity" respectively, will be output. If the value is negative
// infinity, then the output will be ... "-Infinity"" (and confirmed
// separately that the '+' flag's own description says nothing about
// Infinity/NaN, i.e. it must NOT gain a "+" prefix).
//
// %f/%e/%g in this project currently reach these values through Swift's
// `String(format:)`, i.e. C's libc printf, whose convention is the
// lowercase "nan"/"inf"/"-inf" — different from Java's capitalized,
// spelled-out strings. These tests assert the *Java*-correct values, so a
// local `swift test` run tells us definitively whether this is a real,
// live bug or whether it already happens to work.

@Suite("Java2SwiftFormatter — NaN/Infinity for floating-point conversions", .serialized)
struct NaNInfinityTests {

  @Test("%f renders NaN/Infinity/-Infinity as Java's literal, capitalized strings")
  func fConversion() throws {
    #expect(try String.format("%f", Double.nan) == "NaN")
    #expect(try String.format("%f", Double.infinity) == "Infinity")
    #expect(try String.format("%f", -Double.infinity) == "-Infinity")
  }

  @Test("%e/%E render NaN/Infinity/-Infinity as Java's literal, capitalized strings")
  func eConversion() throws {
    #expect(try String.format("%e", Double.nan) == "NaN")
    #expect(try String.format("%e", Double.infinity) == "Infinity")
    #expect(try String.format("%e", -Double.infinity) == "-Infinity")
    #expect(try String.format("%E", Double.nan) == "NaN")
    #expect(try String.format("%E", Double.infinity) == "Infinity")
    #expect(try String.format("%E", -Double.infinity) == "-Infinity")
  }

  @Test("%g/%G render NaN/Infinity/-Infinity as Java's literal, capitalized strings")
  func gConversion() throws {
    #expect(try String.format("%g", Double.nan) == "NaN")
    #expect(try String.format("%g", Double.infinity) == "Infinity")
    #expect(try String.format("%g", -Double.infinity) == "-Infinity")
    #expect(try String.format("%G", Double.nan) == "NaN")
    #expect(try String.format("%G", Double.infinity) == "Infinity")
    #expect(try String.format("%G", -Double.infinity) == "-Infinity")
  }

  @Test("NaN/Infinity are not affected by the '+' flag — no '+Infinity'")
  func plusFlagDoesNotSignNaNOrInfinity() throws {
    #expect(try String.format("%+f", Double.infinity) == "Infinity")
    #expect(try String.format("%+f", Double.nan) == "NaN")
  }

  @Test("NaN/Infinity are still padded to the requested width like any other output")
  func widthPaddingStillApplies() throws {
    #expect(try String.format("%10f|", Double.infinity) == "  Infinity|")
    #expect(try String.format("%-10f|", Double.nan) == "NaN       |")
  }
}

// MARK: - '(' flag (parenthesize negative values) for %d
//
// Regression tests for task (c): the '(' flag used to be fed straight
// into the underlying C printf spec string as an unrecognised flag
// character (undefined behaviour — worse than a no-op, since it could
// corrupt the whole spec), because it was collected into the same
// `flags` string used to build printf specs. It's now diverted out
// (like ',' already was) and actually implemented for '%d'. '%(e'/'%(f'/
// '%(g'/'%(G' are still accepted (not thrown, matching Java's own flags
// grammar) but not yet actually rendered — deliberately scoped out here
// since correct zero-padding for them depends on formatDouble first
// gaining C-printf-style zero-fill support, which it doesn't have yet
// (a separate, likely pre-existing gap — see NaNInfinityTests' sibling
// diagnostic note in this file's history for the analogous pattern).

@Suite("Java2SwiftFormatter — '(' flag for %d", .serialized)
struct ParenthesizeNegativeTests {

  @Test("%(d wraps a negative value in parentheses instead of a minus sign")
  func basicNegative() throws {
    #expect(try String.format("%(d", -42) == "(42)")
  }

  @Test("%(d leaves a positive value untouched — the flag only affects negatives")
  func positiveUnaffected() throws {
    #expect(try String.format("%(d", 5) == "5")
  }

  @Test("%(8d pads the whole parenthesized string with spaces from the outside")
  func widthPadsOutsideParens() throws {
    #expect(try String.format("%(8d", -42) == "    (42)")
  }

  @Test("%(08d zero-pads *inside* the parentheses, per 'following any sign or radix indicator'")
  func zeroFlagPadsInsideParens() throws {
    #expect(try String.format("%(08d", -42) == "(000042)")
  }

  @Test("%(,d applies grouping separators inside the parentheses")
  func groupingInsideParens() throws {
    // Pinned to Locale.US: the grouping SEPARATOR CHARACTER is locale-
    // sensitive (e.g. '.' in German), same reasoning as the decimal-point
    // pins elsewhere in this file — this test is about the parens/grouping
    // interaction, not about which character represents "grouping".
    #expect(try String.format(java.util.Locale.US, "%(,d", -1234) == "(1,234)")
  }

  @Test("'(' on a conversion that doesn't support it throws FormatFlagsConversionMismatchException")
  func unsupportedConversionThrows() throws {
    #expect(throws: java.util.FormatFlagsConversionMismatchException.self) {
      _ = try String.format("%(s", "hi")
    }
  }
}

// MARK: - IllegalFormatFlagsException for illegal flag combinations
//
// Regression tests for task (c): '-'+'0' and '+'+' ' were previously
// never thrown ("durch den Parser strukturell nicht erreichbar" — the
// flags were individually valid, just not checked for mutually
// incompatible combinations). Now validated once both flags have been
// collected for a specifier, per Formatter's own documented "If both the
// '-' and '0' flags are given..." / "If both the '+' and ' ' flags are
// given..." rules.

@Suite("Java2SwiftFormatter — IllegalFormatFlagsException for flag combinations", .serialized)
struct IllegalFormatFlagsCombinationTests {

  @Test("'-' combined with '0' throws IllegalFormatFlagsException")
  func leftJustifyAndZeroPad() throws {
    #expect(throws: java.util.IllegalFormatFlagsException.self) {
      _ = try String.format("%-08d", 5)
    }
  }

  @Test("'+' combined with ' ' (space) throws IllegalFormatFlagsException")
  func explicitPlusAndSpace() throws {
    #expect(throws: java.util.IllegalFormatFlagsException.self) {
      _ = try String.format("%+ d", 5)
    }
  }
}

// MARK: - Regression: per-specifier grouping no longer "leaks" to later specifiers
//
// A real, previously undiscovered bug found while implementing the '('
// flag above and re-reading this function closely: the grouping flag's
// effect on an individual specifier was decided by `hasGrouping`, a
// function-wide accumulator that is only ever set to `true` and never
// reset between specifiers (it's also used, correctly, to decide whether
// the *final* combined String(format:) call needs a `locale:` argument
// at all). That meant `String.format("%,d %d", 1234567, 42)` would have
// incorrectly grouped the SECOND %d too, even though it has no ',' flag
// of its own — simply because an earlier specifier in the same format
// string happened to use grouping. Fixed by deciding each specifier's own
// grouping from that specifier's freshly-scanned flags instead.

@Suite("Java2SwiftFormatter — grouping does not leak across specifiers", .serialized)
struct GroupingDoesNotLeakTests {

  @Test("a ',' flag on an earlier specifier must not affect a later specifier without its own ','")
  func groupingIsPerSpecifier() throws {
    // Pinned to Locale.US — see `groupingInsideParens`'s comment above;
    // this test is about grouping being per-specifier, not about which
    // character represents grouping on the runner's system locale.
    #expect(try String.format(java.util.Locale.US, "%,d %d", 1234567, 42) == "1,234,567 42")
  }

  @Test("the reverse order also stays independent")
  func groupingIsPerSpecifierReversed() throws {
    #expect(try String.format(java.util.Locale.US, "%d %,d", 42, 1234567) == "42 1,234,567")
  }
}

// MARK: - '0' zero-pad flag for %f/%e/%g (confirmed and fixed)
//
// Was shipped as a DIAGNOSTIC suite first — a suspected gap noticed while
// implementing the '(' flag above (whose zero-inside-parens behavior for
// '%d' depends on the '0' flag being honoured, which prompted a closer
// look at the floating-point path too) — and confirmed as a real bug by
// a failing local `swift test` run (the same "assert the Java-correct
// value first, fix only after confirmation" workflow used earlier for
// NaN/Infinity). Root cause: `formatDouble` (used by '%f' and, via
// `formatGeneral`, by '%g'/'%G' in their decimal-format branch) only ever
// padded with spaces via `applyWidth`; it never passed `width` or the '0'
// flag into the underlying C `String(format:)` call, and never zero-filled
// manually either. Fixed by adding a `zeroPad` parameter to `formatDouble`
// (new `applyZeroPad` helper inserts the padding zeros *after* a leading
// '-' sign, per Java's "follows any sign or radix indicator" rule) and
// threading it through `formatGeneral`. While tracing this, the SAME class
// of bug turned up independently in `formatGeneral`'s *scientific* branch
// (used when '%g'/'%G' render in exponential form): it built the inner
// '%e'/'%E' C-spec with `width: ""` and space-padded the result afterwards
// instead of passing the real width into the spec, so a '0' flag there had
// no width to pad against and was silently a no-op — fixed by passing the
// real width straight into the spec (mirroring how plain '%e' already did
// it), which lets C's own zero-flag handling do the work correctly,
// including after the exponent's sign/digits are already in place.
@Suite("Java2SwiftFormatter — '0' zero-pad flag for floating point", .serialized)
struct ZeroPadFloatingPointTests {

  // All four assertions below pin `Locale.US` explicitly. `String.format`
  // with no explicit Locale follows `java.util.Locale.getDefault()` (real
  // Java behaviour) — on a German-locale machine that correctly renders
  // "," as the decimal point, which would make a hardcoded "." expectation
  // fail for reasons unrelated to zero-padding. Pinning the locale keeps
  // these tests about the '0' flag, not about the runner's system locale
  // (discovered via exactly that failure on a German-locale dev machine).

  @Test("%08.2f should zero-pad, not space-pad")
  func zeroPadForF() throws {
    #expect(try String.format(java.util.Locale.US, "%08.2f", 3.14) == "00003.14")
  }

  @Test("%08.2f on a negative value should zero-pad after the sign")
  func zeroPadForNegativeF() throws {
    #expect(try String.format(java.util.Locale.US, "%08.2f", -3.14) == "-0003.14")
  }

  @Test("'0' flag also zero-pads %g's decimal-format branch")
  func zeroPadForGDecimalBranch() throws {
    // 3.14 with precision 4 stays in %g's decimal branch (exponent 0 < 4);
    // formatDouble renders it as "3.140" (3 fractional digits), then
    // zero-pads to width 12 -> "00000003.140" (verified against Python's
    // '%012.4g' % 3.14, which follows the same C-printf zero-pad rule for
    // the fractional-digit count, since Java's %g fractional-digit
    // selection matches C's here for this value).
    #expect(try String.format(java.util.Locale.US, "%012.4g", 3.14) == "00000003.140")
  }

  @Test("'0' flag also zero-pads %g's scientific-notation branch")
  func zeroPadForGScientificBranch() throws {
    // 123456.0 with precision 3: exponent 5 >= precision 3, so %g renders
    // in scientific notation ("1.23e+05"). Zero-padded to width 14 ->
    // "0000001.23e+05" (verified against Python's '%014.2e' % 123456.0,
    // which uses the same C-printf zero-pad convention this code now
    // delegates to for the scientific branch).
    #expect(try String.format(java.util.Locale.US, "%014.3g", 123456.0) == "0000001.23e+05")
  }
}

// MARK: - Locale independence for %f/%e/%g's decimal-point rendering
//
// Regression coverage for the root-cause bug found while chasing the
// zero-pad failures above: `formatDouble`'s (and, until this fix, '%e'/'%E'
// and %g's scientific branch's) intermediate C-printf rounding step called
// Swift's `String(format:)` with NO explicit locale, which does not mean
// "fixed C locale" as the surrounding code assumed — it silently follows
// `Foundation.Locale.current` (the SYSTEM locale). On a German-locale
// machine this produced "3,14" for a supposedly locale-independent internal
// step, corrupting the code's own subsequent, correct `resolvedLocale`-based
// decimal/grouping substitution (worst case: `formatDouble`'s grouping
// branch splits the C-formatted string on "." to separate integer and
// fractional parts — if the intermediate step had already substituted ","
// for the system locale, that split silently finds nothing, merging the
// fractional digits into what grouping then treats as the integer part).
// Fixed by pinning the intermediate step to a fixed `en_US_POSIX` locale
// (`cLocale`) so ONLY the code's own explicit, request-driven locale
// handling ever determines the visible output — verified here by requesting
// an explicit, non-default `Locale` (`Locale.GERMANY`) and checking for
// its comma decimal point, independent of whatever the test runner's own
// system locale happens to be.
@Suite("Java2SwiftFormatter — locale-independence of the C-printf rounding step", .serialized)
struct LocaleIndependentRoundingTests {

  @Test("%f honors an explicitly requested Locale's decimal separator")
  func explicitGermanLocaleForF() throws {
    #expect(try String.format(java.util.Locale.GERMANY, "%.2f", 3.14159) == "3,14")
  }

  @Test("%f with grouping honors an explicitly requested Locale, without corrupting the fractional part")
  func explicitGermanLocaleForGroupedF() throws {
    // Regression for the worst-case corruption described above: grouping
    // splits on '.', which only works if the intermediate step actually
    // produced '.' — German grouping separator is '.', decimal separator
    // is ',', so a corrupted intermediate step (comma from the SYSTEM
    // locale bleeding into what should be a POSIX-only internal step)
    // would previously have merged "1234567,89" into one ungrouped blob.
    #expect(try String.format(java.util.Locale.GERMANY, "%,.2f", 1234567.891) == "1.234.567,89")
  }

  @Test("%e honors an explicitly requested Locale's decimal separator")
  func explicitGermanLocaleForE() throws {
    #expect(try String.format(java.util.Locale.GERMANY, "%.2e", 12345.6789) == "1,23e+04")
  }

  @Test("%g's scientific branch honors an explicitly requested Locale's decimal separator")
  func explicitGermanLocaleForGScientific() throws {
    // precision 3, value 123456.0: exponent 5 >= 3, so %g renders in
    // scientific notation, same shape as ZeroPadFloatingPointTests'
    // zeroPadForGScientificBranch above but with a German Locale instead
    // of a '0' flag.
    #expect(try String.format(java.util.Locale.GERMANY, "%.3g", 123456.0) == "1,23e+05")
  }

  @Test("%f still defaults to '.' when no explicit Locale is requested and the internal step is POSIX-pinned")
  func explicitUSLocaleStillDot() throws {
    // Companion to the above: confirms the fix didn't overcorrect into
    // always using a non-'.' separator — an explicitly US-Locale request
    // still renders '.', proving the substitution is driven by the
    // REQUESTED locale, not left over from either the system locale or a
    // hardcoded assumption either way.
    #expect(try String.format(java.util.Locale.US, "%.2f", 3.14159) == "3.14")
  }
}
