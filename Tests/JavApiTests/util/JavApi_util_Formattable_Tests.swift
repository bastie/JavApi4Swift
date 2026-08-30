/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// MARK: - Test double

/// Captures the flags/width/precision it was called with, and renders
/// `text` (optionally uppercased) into the given `Formatter`.
private final class SpyFormattable: java.util.Formattable, @unchecked Sendable {
  let text: String
  private(set) var lastFlags: Int?
  private(set) var lastWidth: Int?
  private(set) var lastPrecision: Int?

  init(_ text: String) { self.text = text }

  func formatTo(_ formatter: java.util.Formatter, _ flags: Int, _ width: Int, _ precision: Int) throws {
    lastFlags = flags
    lastWidth = width
    lastPrecision = precision
    var s = text
    if flags & java.util.FormattableFlags.UPPERCASE != 0 { s = s.uppercased() }
    _ = try formatter.out().append(s)
  }
}

/// A `Formattable` whose `formatTo` always throws, used to verify that
/// `Java2SwiftFormatter` degrades gracefully instead of crashing.
private struct ThrowingFormattable: java.util.Formattable {
  func formatTo(_ formatter: java.util.Formatter, _ flags: Int, _ width: Int, _ precision: Int) throws {
    throw RuntimeException("boom")
  }
}

// MARK: - java.util.Formattable
//
// Was previously entirely missing — see Text-Implementierung.md, Java-1.5
// section ("Formattable-Protokoll (formatTo) — fehlt komplett").

@Suite("java.util.Formattable")
struct FormattableTests {

  @Test("%s delegates to formatTo instead of using toString()")
  func delegatesToFormatTo() {
    let spy = SpyFormattable("hi")
    #expect(String.format("%s", spy) == "hi")
  }

  @Test("%S sets the UPPERCASE flag and the implementation applies it")
  func upperFlagPropagatesAndIsHonoured() {
    let spy = SpyFormattable("hi")
    #expect(String.format("%S", spy) == "HI")
    #expect(spy.lastFlags! & java.util.FormattableFlags.UPPERCASE != 0)
  }

  @Test("'-' flag sets LEFT_JUSTIFY and width is passed through")
  func leftJustifyFlagAndWidthPropagate() {
    let spy = SpyFormattable("hi")
    _ = String.format("%-5s", spy)
    #expect(spy.lastFlags! & java.util.FormattableFlags.LEFT_JUSTIFY != 0)
    #expect(spy.lastWidth == 5)
  }

  @Test("'#' flag sets ALTERNATE")
  func alternateFlagPropagates() {
    let spy = SpyFormattable("hi")
    _ = String.format("%#s", spy)
    #expect(spy.lastFlags! & java.util.FormattableFlags.ALTERNATE != 0)
  }

  @Test("precision is passed through, -1 when not specified")
  func precisionPassedThrough() {
    let spy = SpyFormattable("hi")
    _ = String.format("%s", spy)
    #expect(spy.lastPrecision == -1)

    let spy2 = SpyFormattable("hi")
    _ = String.format("%.3s", spy2)
    #expect(spy2.lastPrecision == 3)
  }

  @Test("width is -1 when not specified")
  func widthDefaultsToMinusOneWhenAbsent() {
    let spy = SpyFormattable("hi")
    _ = String.format("%s", spy)
    #expect(spy.lastWidth == -1)
  }

  @Test("non-Formattable arguments still use plain toString()-style rendering")
  func nonFormattableArgumentsUnaffected() {
    #expect(String.format("%s", 42) == "42")
    #expect(String.format("%S", "abc") == "ABC")
  }

  @Test("a throwing formatTo falls back to default rendering instead of crashing")
  func throwingFormatToDoesNotCrash() {
    // Java2SwiftFormatter.format(...) is not itself `throws` yet (see the
    // corresponding Text-Implementierung.md TODO), so an error from
    // formatTo cannot be propagated — it must degrade gracefully instead.
    let result = String.format("%s", ThrowingFormattable())
    #expect(result.contains("ThrowingFormattable"))
  }

  @Test("Formattable works via java.util.Formatter directly, not just String.format")
  func worksThroughFormatterDirectly() throws {
    let spy = SpyFormattable("hi")
    let f = java.util.Formatter()
    try f.format("[%s]", spy)
    #expect(try f.toString() == "[hi]")
  }
}
