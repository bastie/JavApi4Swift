/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_StringTokenizer_Tests {

  // MARK: - Konstruktor: Standard-Delimiter (Whitespace)

  @Test("Default-Delimiter: Leerzeichen trennt Tokens")
  func testDefaultDelimiterSpace() throws {
    let st = java.util.StringTokenizer("one two three")
    #expect(st.countTokens() == 3)
    #expect(try st.nextToken() == "one")
    #expect(try st.nextToken() == "two")
    #expect(try st.nextToken() == "three")
    #expect(st.hasMoreTokens() == false)
  }

  @Test("Default-Delimiter: Tab, Newline, CR, FF werden als Whitespace behandelt")
  func testDefaultDelimiterWhitespaceVariants() throws {
    let st = java.util.StringTokenizer("a\tb\nc\rd\u{0C}e")
    #expect(st.countTokens() == 5)
    #expect(try st.nextToken() == "a")
    #expect(try st.nextToken() == "b")
    #expect(try st.nextToken() == "c")
    #expect(try st.nextToken() == "d")
    #expect(try st.nextToken() == "e")
  }

  @Test("Default-Delimiter: Mehrfache Whitespace-Zeichen hintereinander")
  func testMultipleConsecutiveDelimiters() throws {
    let st = java.util.StringTokenizer("  hello   world  ")
    #expect(st.countTokens() == 2)
    #expect(try st.nextToken() == "hello")
    #expect(try st.nextToken() == "world")
  }

  // MARK: - Konstruktor: Eigener Delimiter

  @Test("Eigener Delimiter: Komma")
  func testCustomDelimiterComma() throws {
    let st = java.util.StringTokenizer("a,b,c", ",")
    #expect(st.countTokens() == 3)
    #expect(try st.nextToken() == "a")
    #expect(try st.nextToken() == "b")
    #expect(try st.nextToken() == "c")
  }

  @Test("Eigener Delimiter: Mehrere Delimiter-Zeichen")
  func testCustomDelimiterMultipleChars() throws {
    let st = java.util.StringTokenizer("a,b;c|d", ",;|")
    #expect(st.countTokens() == 4)
    #expect(try st.nextToken() == "a")
    #expect(try st.nextToken() == "b")
    #expect(try st.nextToken() == "c")
    #expect(try st.nextToken() == "d")
  }

  // MARK: - Konstruktor: returnDelimiters = true

  @Test("returnDelimiters=true: Delimiter-Zeichen als eigene Tokens zurückgeben")
  func testReturnDelimiters() throws {
    let st = java.util.StringTokenizer("a,b", ",", true)
    #expect(st.countTokens() == 3)
    #expect(try st.nextToken() == "a")
    #expect(try st.nextToken() == ",")
    #expect(try st.nextToken() == "b")
    #expect(st.hasMoreTokens() == false)
  }

  @Test("returnDelimiters=true: Aufeinanderfolgende Delimiter je einzeln")
  func testReturnDelimitersConsecutive() throws {
    let st = java.util.StringTokenizer("a,,b", ",", true)
    #expect(try st.nextToken() == "a")
    #expect(try st.nextToken() == ",")
    #expect(try st.nextToken() == ",")
    #expect(try st.nextToken() == "b")
    #expect(st.hasMoreTokens() == false)
  }

  // MARK: - hasMoreTokens / hasMoreElements

  @Test("hasMoreTokens: leerer String hat keine Tokens")
  func testEmptyString() {
    let st = java.util.StringTokenizer("")
    #expect(st.hasMoreTokens() == false)
    #expect(st.countTokens() == 0)
  }

  @Test("hasMoreTokens: nur Delimiter-Zeichen hat keine Tokens")
  func testOnlyDelimiters() {
    let st = java.util.StringTokenizer("   \t\n")
    #expect(st.hasMoreTokens() == false)
    #expect(st.countTokens() == 0)
  }

  @Test("hasMoreElements ist Alias für hasMoreTokens")
  func testHasMoreElements() throws {
    let st = java.util.StringTokenizer("x y")
    #expect(st.hasMoreElements() == true)
    _ = try st.nextToken()
    _ = try st.nextToken()
    #expect(st.hasMoreElements() == false)
  }

  // MARK: - nextToken(delim): Delimiter wechseln

  @Test("nextToken(delim): Cursor steht auf altem Delimiter — dieser wird Teil des nächsten Tokens")
  func testNextTokenWithNewDelimiter() throws {
    // Nach nextToken() steht der Cursor auf dem Delimiter-Zeichen.
    // Wird der Delimiter gewechselt, ist das alte Zeichen kein Delimiter mehr
    // und wird daher Bestandteil des nächsten Tokens.
    // "a,b c" mit ",": nach "a" steht Cursor auf ",". Wechsel zu " " → Token ist ",b".
    let st = java.util.StringTokenizer("a,b c", ",")
    #expect(try st.nextToken() == "a")
    #expect(try st.nextToken(" ") == ",b")
    #expect(try st.nextToken() == "c")
  }

  @Test("nextToken(delim): Neuer Delimiter bleibt für Folgeaufrufe aktiv")
  func testNextTokenNewDelimiterPersists() throws {
    // Wechsel zu einem Delimiter, der im Rest nicht vorkommt → Rest als ein Token
    let st = java.util.StringTokenizer("a-b-c", "-")
    #expect(try st.nextToken() == "a")
    // Wechsel zu "+": kein "+" mehr vorhanden → "-b-c" als ein Token
    #expect(try st.nextToken("+") == "-b-c")
    #expect(st.hasMoreTokens() == false)
  }

  // MARK: - countTokens

  @Test("countTokens verändert Position nicht")
  func testCountTokensDoesNotAdvance() throws {
    let st = java.util.StringTokenizer("x y z")
    #expect(st.countTokens() == 3)
    #expect(st.countTokens() == 3)   // zweiter Aufruf liefert dasselbe
    _ = try st.nextToken()
    #expect(st.countTokens() == 2)
  }

  // MARK: - nextElement (Enumeration-Alias)

  @Test("nextElement ist Alias für nextToken")
  func testNextElement() throws {
    let st = java.util.StringTokenizer("p q")
    #expect(try st.nextElement() == "p")
    #expect(try st.nextElement() == "q")
  }

  // MARK: - NoSuchElementException

  @Test("nextToken wirft NoSuchElementException wenn keine Tokens mehr vorhanden")
  func testNextTokenThrowsWhenExhausted() throws {
    let st = java.util.StringTokenizer("only")
    _ = try st.nextToken()
    #expect(throws: java.util.NoSuchElementException.self) {
      try st.nextToken()
    }
  }

  @Test("nextToken wirft NoSuchElementException bei leerem String")
  func testNextTokenThrowsOnEmptyString() {
    let st = java.util.StringTokenizer("")
    #expect(throws: java.util.NoSuchElementException.self) {
      try st.nextToken()
    }
  }

  // MARK: - Swift Sequence / for-in

  @Test("for-in liefert alle Tokens")
  func testSequenceForIn() {
    let st = java.util.StringTokenizer("one two three")
    var result: [String] = []
    for token in st {
      result.append(token)
    }
    #expect(result == ["one", "two", "three"])
  }

  @Test("for-in mit eigenem Delimiter")
  func testSequenceForInCustomDelimiter() {
    let st = java.util.StringTokenizer("a,b,c", ",")
    let result = Array(st)
    #expect(result == ["a", "b", "c"])
  }

  // MARK: - Einzelner Token ohne Delimiter

  @Test("Einzelner Token ohne Delimiter im String")
  func testSingleToken() throws {
    let st = java.util.StringTokenizer("hello")
    #expect(st.countTokens() == 1)
    #expect(try st.nextToken() == "hello")
    #expect(st.hasMoreTokens() == false)
  }

  // MARK: - Apache Harmony Referenztests

  /// Adaptiert aus dem Apache Harmony luni-Testfall `test_nextTokenLjava_lang_String`.
  /// Zeigt das komplexe Zusammenspiel von Cursor-Position, Delimiter-Wechsel und Persistenz:
  /// Nach `nextToken("tr")` steht der Cursor auf "t"; dieses "t" gehört zum Delimiter "tr"
  /// und wird beim nächsten `nextToken()` übersprungen.
  @Test("Harmony: nextToken(delim) – Cursor + Delimiter-Persistenz (\" is a \")")
  func testHarmonyNextTokenDelimiterPersistence() throws {
    let st = java.util.StringTokenizer("This is a test String")
    // Delimiter " " explizit gesetzt: "This" bis zum ersten Leerzeichen
    #expect(try st.nextToken(" ") == "This")
    // Cursor steht auf " "; neuer Delimiter "tr": Leerzeichen ≠ t/r → Token " is a "
    #expect(try st.nextToken("tr") == " is a ")
    // Delimiter "tr" bleibt aktiv; Cursor auf "t" → t wird übersprungen → "es"
    #expect(try st.nextToken() == "es")
  }

  /// Adaptiert aus `test_ConstructorLjava_lang_StringLjava_lang_StringZ`:
  /// countTokens() nach einem nextElement()-Aufruf mit returnDelimiters=true.
  @Test("Harmony: countTokens nach erstem nextElement bei returnDelimiters=true")
  func testHarmonyCountTokensAfterFirstElementReturnDelims() throws {
    let st = java.util.StringTokenizer("This:is:a:test:String", ":", true)
    // Gesamttokens: "This",":","is",":","a",":","test",":","String" = 9
    _ = try st.nextElement()    // konsumiert "This"
    #expect(st.countTokens() == 8)
    #expect(try st.nextElement() == ":")
  }

  // MARK: - Unicode: CJK / Japanisch

  @Test("CJK-Zeichen als Tokens mit ASCII-Delimiter")
  func testCJKTokensWithASCIIDelimiter() throws {
    let st = java.util.StringTokenizer("東京,大阪,京都", ",")
    #expect(st.countTokens() == 3)
    #expect(try st.nextToken() == "東京")
    #expect(try st.nextToken() == "大阪")
    #expect(try st.nextToken() == "京都")
  }

  @Test("Standard-Whitespace trennt japanische Tokens korrekt")
  func testJapaneseTokensDefaultDelimiter() throws {
    let st = java.util.StringTokenizer("東京 大阪 京都")
    #expect(st.countTokens() == 3)
    #expect(try st.nextToken() == "東京")
    #expect(try st.nextToken() == "大阪")
    #expect(try st.nextToken() == "京都")
  }

  @Test("Japanisches Satzzeichen (U+3001 ，) als Delimiter")
  func testIdeographicCommaAsDelimiter() throws {
    // U+3001 = IDEOGRAPHIC COMMA ，
    let st = java.util.StringTokenizer("東京\u{3001}大阪\u{3001}京都", "\u{3001}")
    #expect(st.countTokens() == 3)
    #expect(try st.nextToken() == "東京")
    #expect(try st.nextToken() == "大阪")
    #expect(try st.nextToken() == "京都")
  }

  // MARK: - Unicode: Ogham

  /// U+1680 OGHAM SPACE MARK sieht wie ein Leerzeichen aus, ist aber KEIN ASCII-Whitespace.
  /// Die Standard-Delimiter enthalten nur " \t\n\r\u{0C}" – Java-kompatibles Verhalten.
  @Test("Ogham Space Mark (U+1680) ist kein Standard-Delimiter")
  func testOghamSpaceMarkNotDefaultDelimiter() throws {
    // U+1680 trennt hier NICHT – der gesamte String ist ein Token
    let st = java.util.StringTokenizer("word1\u{1680}word2")
    #expect(st.countTokens() == 1)
    #expect(try st.nextToken() == "word1\u{1680}word2")
  }

  @Test("Ogham-Zeichen als Tokens mit Ogham Space Mark als Delimiter")
  func testOghamTextWithOghamSpaceDelimiter() throws {
    // ᚁᚂ (U+1681 U+1682) + Ogham Space Mark + ᚃᚄ (U+1683 U+1684)
    let st = java.util.StringTokenizer("\u{1681}\u{1682}\u{1680}\u{1683}\u{1684}", "\u{1680}")
    #expect(st.countTokens() == 2)
    #expect(try st.nextToken() == "\u{1681}\u{1682}")
    #expect(try st.nextToken() == "\u{1683}\u{1684}")
  }

  // MARK: - Unicode: Grapheme Cluster & Normalisierung

  @Test("Emoji-Grapheme-Cluster als Token-Inhalt")
  func testEmojiInTokens() throws {
    // Emoji sind einzelne Grapheme Cluster – Swift String.Index behandelt sie korrekt
    let st = java.util.StringTokenizer("hello 👋 world")
    #expect(st.countTokens() == 3)
    #expect(try st.nextToken() == "hello")
    #expect(try st.nextToken() == "👋")
    #expect(try st.nextToken() == "world")
  }

  @Test("Emoji-Flag (zweiteiliger Grapheme Cluster) als Delimiter")
  func testEmojiFlagAsDelimiter() throws {
    // 🇩🇪 = U+1F1E9 U+1F1EA (zwei Regional Indicator Symbols → ein Grapheme Cluster)
    // Swift Character-Vergleich und String.contains arbeiten auf Grapheme-Cluster-Ebene
    let st = java.util.StringTokenizer("Deutsch🇩🇪Englisch", "🇩🇪")
    #expect(st.countTokens() == 2)
    #expect(try st.nextToken() == "Deutsch")
    #expect(try st.nextToken() == "Englisch")
  }

  /// Swift-spezifisch: Character-Gleichheit nutzt kanonische Unicode-Äquivalenz.
  /// NFD (e + combining accent U+0301) == NFC (é U+00E9) als Delimiter.
  /// Java StringTokenizer würde dies NICHT so behandeln (code-unit-basierter Vergleich).
  @Test("NFC/NFD-Kanonisierung: é als Delimiter (Swift-spezifisches Verhalten)")
  func testNFCNFDNormalizationInDelimiter() throws {
    // Quelle enthält NFD-é (e + combining accent), Delimiter-String NFC-é
    let st = java.util.StringTokenizer("caf\u{0065}\u{0301} au lait", "\u{00E9} ")
    // Swift behandelt NFD-é und NFC-é als kanonisch äquivalent
    #expect(st.countTokens() == 3)
    #expect(try st.nextToken() == "caf")
    #expect(try st.nextToken() == "au")
    #expect(try st.nextToken() == "lait")
  }
}
