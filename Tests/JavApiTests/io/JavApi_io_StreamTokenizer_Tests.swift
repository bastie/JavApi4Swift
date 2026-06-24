/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_io_StreamTokenizer_Tests {

  // MARK: - Hilfsfunktion

  private func tokenizer(_ input: String) -> java.io.StreamTokenizer {
    let reader = java.io.StringReader(input)
    return java.io.StreamTokenizer(reader)
  }

  // MARK: - TT_EOF

  @Test("Leerer Input liefert sofort TT_EOF")
  func testEOFOnEmpty() throws {
    let st = tokenizer("")
    let tt = try st.nextToken()
    #expect(tt == java.io.StreamTokenizer.TT_EOF)
    #expect(st.ttype == java.io.StreamTokenizer.TT_EOF)
  }

  // MARK: - TT_WORD

  @Test("Einzelnes Wort wird als TT_WORD erkannt")
  func testSingleWord() throws {
    let st = tokenizer("hello")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "hello")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_EOF)
  }

  @Test("Mehrere Wörter werden korrekt getrennt")
  func testMultipleWords() throws {
    let st = tokenizer("one two three")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "one")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "two")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "three")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_EOF)
  }

  @Test("Leerzeichen, Tab, Newline als Whitespace – TT_WORD")
  func testWhitespaceVariants() throws {
    let st = tokenizer("a\tb\nc")
    var words: [String] = []
    while (try st.nextToken()) == java.io.StreamTokenizer.TT_WORD {
      words.append(st.sval!)
    }
    #expect(words == ["a", "b", "c"])
  }

  // MARK: - TT_NUMBER

  @Test("Ganzzahl wird als TT_NUMBER erkannt")
  func testInteger() throws {
    let st = tokenizer("42")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_NUMBER)
    #expect(st.nval == 42.0)
  }

  @Test("Dezimalzahl wird als TT_NUMBER erkannt")
  func testDecimal() throws {
    let st = tokenizer("3.14")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_NUMBER)
    #expect(st.nval == 3.14)
  }

  @Test("Negative Zahl wird als TT_NUMBER erkannt")
  func testNegativeNumber() throws {
    let st = tokenizer("-7")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_NUMBER)
    #expect(st.nval == -7.0)
  }

  @Test("Gemischte Token: Wörter und Zahlen")
  func testMixedTokens() throws {
    let st = tokenizer("hello 42 world 3.14")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "hello")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_NUMBER)
    #expect(st.nval == 42.0)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "world")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_NUMBER)
    #expect(st.nval == 3.14)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_EOF)
  }

  // MARK: - Quoted Strings

  @Test("Doppelt-gequoteter String wird als ttype=34 erkannt")
  func testDoubleQuotedString() throws {
    let st = tokenizer("\"hello world\"")
    let tt = try st.nextToken()
    #expect(tt == 34)        // '"' = ASCII 34
    #expect(st.sval == "hello world")
  }

  @Test("Einfach-gequoteter String wird als ttype=39 erkannt")
  func testSingleQuotedString() throws {
    let st = tokenizer("'test'")
    let tt = try st.nextToken()
    #expect(tt == 39)        // '\'' = ASCII 39
    #expect(st.sval == "test")
  }

  @Test("Quoted string mit Escape \\n")
  func testQuotedStringEscape() throws {
    let st = tokenizer("\"line1\\nline2\"")
    _ = try st.nextToken()
    #expect(st.sval == "line1\nline2")
  }

  // MARK: - Kommentare

  @Test("commentChar: Rest der Zeile wird ignoriert")
  func testCommentChar() throws {
    let st = tokenizer("hello # ignored\nworld")
    st.commentChar(Int(Character("#").asciiValue!))
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "hello")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "world")
  }

  @Test("slashSlashComments: // ignoriert bis Zeilenende")
  func testSlashSlashComments() throws {
    let st = tokenizer("hello // ignored\nworld")
    st.slashSlashComments(true)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "hello")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "world")
  }

  @Test("slashStarComments: /* … */ wird ignoriert")
  func testSlashStarComments() throws {
    let st = tokenizer("before /* skip this */ after")
    st.slashStarComments(true)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "before")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "after")
  }

  // MARK: - eolIsSignificant

  @Test("eolIsSignificant(false): Zeilenenden sind kein Token")
  func testEolNotSignificant() throws {
    let st = tokenizer("a\nb")
    st.eolIsSignificant(false)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "a")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "b")
  }

  @Test("eolIsSignificant(true): Zeilenende erzeugt TT_EOL")
  func testEolSignificant() throws {
    let st = tokenizer("a\nb")
    st.eolIsSignificant(true)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "a")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_EOL)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "b")
  }

  // MARK: - lowerCaseMode

  @Test("lowerCaseMode(true): Wörter werden kleingeschrieben")
  func testLowerCaseMode() throws {
    let st = tokenizer("Hello WORLD")
    st.lowerCaseMode(true)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "hello")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "world")
  }

  @Test("lowerCaseMode(false): Groß-/Kleinschreibung bleibt erhalten")
  func testLowerCaseModeOff() throws {
    let st = tokenizer("Hello WORLD")
    st.lowerCaseMode(false)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "Hello")
  }

  // MARK: - pushBack

  @Test("pushBack: nächster nextToken()-Aufruf liefert dasselbe Token nochmal")
  func testPushBack() throws {
    let st = tokenizer("hello 42")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "hello")
    st.pushBack()
    // Nächster Aufruf liefert dieselbe Word-Token
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "hello")
    // Danach kommt die Zahl
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_NUMBER)
    #expect(st.nval == 42.0)
  }

  // MARK: - lineno

  @Test("lineno() startet bei 1")
  func testLinenoStart() throws {
    let st = tokenizer("hello")
    #expect(st.lineno() == 1)
    _ = try st.nextToken()
    #expect(st.lineno() == 1)
  }

  @Test("lineno() zählt Zeilenumbrüche")
  func testLinenoIncrement() throws {
    let st = tokenizer("a\nb\nc")
    st.eolIsSignificant(true)
    _ = try st.nextToken()  // a
    #expect(st.lineno() == 1)
    _ = try st.nextToken()  // EOL
    _ = try st.nextToken()  // b
    #expect(st.lineno() == 2)
    _ = try st.nextToken()  // EOL
    _ = try st.nextToken()  // c
    #expect(st.lineno() == 3)
  }

  // MARK: - ordinaryChar / ordinaryChars

  @Test("ordinaryChar: Zeichen wird als normales Zeichen behandelt (kein Wort mehr)")
  func testOrdinaryChar() throws {
    let st = tokenizer("a.b")
    // Per Default ist '.' numerisch; als ordinary: eigenes Token
    st.ordinaryChar(Int(Character(".").asciiValue!))
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "a")
    let dotToken = try st.nextToken()
    #expect(dotToken == Int(Character(".").asciiValue!))
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "b")
  }

  @Test("ordinaryChars: Bereich als ordinary gesetzt")
  func testOrdinaryChars() throws {
    let st = tokenizer("a1b")
    // Ziffern als ordinary → keine Zahlen mehr, sondern einzelne Zeichen
    st.ordinaryChars(48, 57)  // '0'–'9'
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "a")
    let digit = try st.nextToken()
    #expect(digit == Int(Character("1").asciiValue!))
  }

  // MARK: - wordChars

  @Test("wordChars: Ziffern werden Teil von Wörtern")
  func testWordChars() throws {
    let st = tokenizer("abc123")
    // '0'–'9' zu Wortzeichen machen (überschreibt CT_NUMERIC)
    st.wordChars(48, 57)
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "abc123")
  }

  // MARK: - resetSyntax

  @Test("resetSyntax: alle Zeichen werden ordinary")
  func testResetSyntax() throws {
    let st = tokenizer("a")
    st.resetSyntax()
    let tt = try st.nextToken()
    #expect(tt == Int(Character("a").asciiValue!))  // ordinary char token
  }

  // MARK: - toString

  @Test("toString nach TT_EOF enthält 'EOF'")
  func testToStringEOF() throws {
    let st = tokenizer("")
    _ = try st.nextToken()
    #expect(st.toString().contains("EOF"))
  }

  @Test("toString nach TT_WORD enthält 'Word' und sval")
  func testToStringWord() throws {
    let st = tokenizer("swift")
    _ = try st.nextToken()
    let s = st.toString()
    #expect(s.contains("Word"))
    #expect(s.contains("swift"))
  }

  @Test("toString nach TT_NUMBER enthält nval")
  func testToStringNumber() throws {
    let st = tokenizer("99")
    _ = try st.nextToken()
    let s = st.toString()
    #expect(s.contains("99"))
  }

  @Test("toString enthält immer Zeilennummer")
  func testToStringLineNumber() throws {
    let st = tokenizer("x")
    _ = try st.nextToken()
    #expect(st.toString().contains("line 1"))
  }

  // MARK: - Vergleich mit StringTokenizer

  @Test("StreamTokenizer vs StringTokenizer: gleiche Wörter aus 'hello world'")
  func testVsStringTokenizer() throws {
    // StringTokenizer aus java.util
    let strtok = java.util.StringTokenizer("hello world")
    var strWords: [String] = []
    while strtok.hasMoreTokens() {
      strWords.append(try strtok.nextToken())
    }

    // StreamTokenizer aus java.io
    let stream = tokenizer("hello world")
    var streamWords: [String] = []
    while (try stream.nextToken()) == java.io.StreamTokenizer.TT_WORD {
      streamWords.append(stream.sval!)
    }

    #expect(strWords == streamWords)
  }

  @Test("StreamTokenizer erkennt Zahlen, StringTokenizer nicht")
  func testStreamRecognizesNumbers() throws {
    // StringTokenizer behandelt '42' als String-Token
    let strtok = java.util.StringTokenizer("a 42 b")
    var strTokens: [String] = []
    while strtok.hasMoreTokens() {
      strTokens.append(try strtok.nextToken())
    }
    #expect(strTokens == ["a", "42", "b"])  // alles Strings

    // StreamTokenizer unterscheidet Wort vs. Zahl
    let stream = tokenizer("a 42 b")
    var types: [Int] = []
    var tt = try stream.nextToken()
    while tt != java.io.StreamTokenizer.TT_EOF {
      types.append(tt)
      tt = try stream.nextToken()
    }
    #expect(types[0] == java.io.StreamTokenizer.TT_WORD)
    #expect(types[1] == java.io.StreamTokenizer.TT_NUMBER)
    #expect(types[2] == java.io.StreamTokenizer.TT_WORD)
  }

  @Test("StreamTokenizer unterstützt Quotes, StringTokenizer nicht")
  func testStreamSupportsQuotes() throws {
    let stream = tokenizer("\"hello world\"")
    _ = try stream.nextToken()
    // Der gesamte Inhalt des Strings ist ein einziges Token
    #expect(stream.sval == "hello world")

    // StringTokenizer würde das als zwei Tokens behandeln (nach Whitespace)
    let strtok = java.util.StringTokenizer("\"hello world\"")
    var count = 0
    while strtok.hasMoreTokens() {
      _ = try strtok.nextToken()
      count += 1
    }
    #expect(count == 2)  // "\"hello" und "world\""
  }

  // MARK: - Grenzfälle & Robustheit

  @Test("Nur Whitespace liefert direkt TT_EOF")
  func testOnlyWhitespace() throws {
    let st = tokenizer("   \t  ")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_EOF)
  }

  @Test("Punkt allein ist kein TT_NUMBER (kein gültiger Double)")
  func testDotAlone() throws {
    // "." allein → Double(".") schlägt fehl → soll als TT_WORD zurückkommen
    let st = tokenizer(".")
    let tt = try st.nextToken()
    // Entweder TT_WORD (mit sval=".") oder ordinary char; in keinem Fall TT_NUMBER
    #expect(tt != java.io.StreamTokenizer.TT_NUMBER)
  }

  @Test("Bindestrich allein ist kein TT_NUMBER")
  func testMinusAlone() throws {
    // "-" ohne nachfolgende Ziffer → kein gültiger Double
    let st = tokenizer("- hello")
    let tt = try st.nextToken()
    #expect(tt != java.io.StreamTokenizer.TT_NUMBER)
  }

  @Test("quoteChar: selbst definierter Quote-Delimiter")
  func testCustomQuoteChar() throws {
    let st = tokenizer("|hello world|")
    st.quoteChar(Int(Character("|").asciiValue!))
    let tt = try st.nextToken()
    #expect(tt == Int(Character("|").asciiValue!))
    #expect(st.sval == "hello world")
  }

  @Test("whitespaceChars: Semikolon als Whitespace")
  func testWhitespaceChars() throws {
    let st = tokenizer("a;b;c")
    st.whitespaceChars(Int(Character(";").asciiValue!), Int(Character(";").asciiValue!))
    var words: [String] = []
    while (try st.nextToken()) == java.io.StreamTokenizer.TT_WORD {
      words.append(st.sval!)
    }
    #expect(words == ["a", "b", "c"])
  }

  @Test("parseNumbers nach resetSyntax: Ziffern werden wieder als Zahlen erkannt")
  func testParseNumbersAfterReset() throws {
    let st = tokenizer("42")
    st.resetSyntax()
    st.parseNumbers()
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_NUMBER)
    #expect(st.nval == 42.0)
  }

  @Test("Leere Quoted-String liefert leeres sval")
  func testEmptyQuotedString() throws {
    let st = tokenizer("\"\"")
    _ = try st.nextToken()
    #expect(st.sval == "")
  }

  @Test("pushBack auf TT_EOF funktioniert")
  func testPushBackEOF() throws {
    let st = tokenizer("")
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_EOF)
    st.pushBack()
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_EOF)
  }

  @Test("Mehrfaches pushBack ohne nextToken dazwischen: zweiter pushBack überschreibt ersten nicht")
  func testPushBackTwice() throws {
    let st = tokenizer("a b")
    _ = try st.nextToken()  // "a"
    st.pushBack()
    st.pushBack()  // zweiter pushBack – soll kein Crash verursachen
    #expect(try st.nextToken() == java.io.StreamTokenizer.TT_WORD)
    #expect(st.sval == "a")
  }

  @Test("Block-Kommentar /* */ über mehrere Zeilen zählt Zeilenumbrüche")
  func testBlockCommentLineCount() throws {
    let st = tokenizer("a\n/* line2\nline3 */\nb")
    st.slashStarComments(true)
    _ = try st.nextToken()  // "a"
    #expect(st.lineno() == 1)
    _ = try st.nextToken()  // "b"
    // Nach zwei Zeilenumbrüchen im Kommentar muss lineno >= 3 sein
    #expect(st.lineno() >= 3)
  }

  @Test("Ordinary char nach ordinaryChar() liefert ASCII-Wert als ttype")
  func testOrdinaryCharReturnValue() throws {
    let st = tokenizer("!")
    st.ordinaryChar(Int(Character("!").asciiValue!))
    let tt = try st.nextToken()
    #expect(tt == 33)  // '!' = ASCII 33
    #expect(st.sval == nil)
  }

  @Test("Realistischer Anwendungsfall: einfacher Key=Value-Parser")
  func testKeyValueParsing() throws {
    let st = tokenizer("width = 100\nheight = 200")
    st.ordinaryChar(Int(Character("=").asciiValue!))

    var pairs: [(String, Double)] = []
    var tt = try st.nextToken()
    while tt != java.io.StreamTokenizer.TT_EOF {
      if tt == java.io.StreamTokenizer.TT_WORD {
        let key = st.sval!
        _ = try st.nextToken()  // '=' ordinary
        _ = try st.nextToken()  // Zahl
        pairs.append((key, st.nval))
      }
      tt = try st.nextToken()
    }
    #expect(pairs.count == 2)
    #expect(pairs[0].0 == "width")
    #expect(pairs[0].1 == 100.0)
    #expect(pairs[1].0 == "height")
    #expect(pairs[1].1 == 200.0)
  }
}
