/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// Parses an input stream into tokens.
  ///
  /// Mirrors `java.io.StreamTokenizer` from Java 1.0. The tokenizer reads
  /// characters from a `Reader` (or a deprecated `InputStream` constructor)
  /// and classifies them as words, numbers, quoted strings, or single
  /// characters. The syntax table is fully configurable.
  ///
  /// After each call to ``nextToken()`` the token type is stored in
  /// ``ttype``, and the token value in ``sval`` (for words and quoted
  /// strings) or ``nval`` (for numbers).
  ///
  /// ```swift
  /// let st = java.io.StreamTokenizer(java.io.StringReader("hello 42 world"))
  /// while (try st.nextToken()) != java.io.StreamTokenizer.TT_EOF {
  ///     if st.ttype == java.io.StreamTokenizer.TT_WORD  { print("word: \(st.sval!)") }
  ///     if st.ttype == java.io.StreamTokenizer.TT_NUMBER { print("num: \(st.nval)") }
  /// }
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  open class StreamTokenizer {

    // MARK: - Token type constants

    /// Token type indicating end of stream.
    public static let TT_EOF: Int   = -1
    /// Token type indicating end of line (when ``eolIsSignificant(_:)`` is `true`).
    public static let TT_EOL: Int   = 10   // '\n'
    /// Token type indicating a numeric token; value is in ``nval``.
    public static let TT_NUMBER: Int = -2
    /// Token type indicating a word token; value is in ``sval``.
    public static let TT_WORD: Int   = -3

    // MARK: - Public fields

    /// The type of the current token (one of the `TT_*` constants or a character code).
    public var ttype: Int = TT_EOF

    /// The string value of the current word or quoted-string token, or `nil`.
    public var sval: String? = nil

    /// The numeric value of the current number token.
    public var nval: Double = 0.0

    // MARK: - Character classification

    private static let CT_WHITESPACE  = 1
    private static let CT_ALPHA       = 2
    private static let CT_NUMERIC     = 4
    private static let CT_QUOTE       = 8
    private static let CT_COMMENT     = 16
    private static let CT_ORDINARY    = 32

    /// Syntax table: one entry per character 0–255.
    private var ct: [Int]

    // MARK: - Configuration flags

    private var eolSignificant: Bool = false
    private var slashSlash: Bool = false
    private var slashStar: Bool = false
    private var lowerCase: Bool = false

    // MARK: - Internal state

    private var reader: java.io.Reader?
    private var lineNumber: Int = 1
    private var pushedBack: Bool = false
    private var peekChar: Int = -2   // -2 = no peek

    // MARK: - Initialisers

    /// Creates a `StreamTokenizer` that reads from `reader`.
    ///
    /// - Parameter reader: The `Reader` to tokenize.
    /// - Since: JavaApi (Java 1.1)
    public init(_ reader: java.io.Reader) {
      ct = [Int](repeating: 0, count: 256)
      self.reader = reader
      setDefaultSyntax()
    }

    /// Creates a `StreamTokenizer` that reads from `inputStream`.
    ///
    /// - Parameter inputStream: The `InputStream` to tokenize.
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.1, use StreamTokenizer(Reader) instead")
    public init(_ inputStream: java.io.InputStream) {
      ct = [Int](repeating: 0, count: 256)
      // Wrap the InputStream in a Reader-compatible adapter
      self.reader = InputStreamReader(inputStream)
      setDefaultSyntax()
    }

    // MARK: - Default syntax

    private func setDefaultSyntax() {
      // Whitespace: 0–32
      for c in 0...32 { ct[c] = StreamTokenizer.CT_WHITESPACE }
      // Alphabetic: A–Z, a–z
      for c in 65...90  { ct[c] = StreamTokenizer.CT_ALPHA }  // A–Z
      for c in 97...122 { ct[c] = StreamTokenizer.CT_ALPHA }  // a–z
      // Extra word chars
      ct[160] = StreamTokenizer.CT_ALPHA  // non-breaking space (treated as alpha by Java)
      for c in 0xA0...0xFF { ct[c] = StreamTokenizer.CT_ALPHA }
      // Numeric: 0–9, '.', '-'
      for c in 48...57 { ct[c] = StreamTokenizer.CT_NUMERIC }  // 0–9
      ct[46] = StreamTokenizer.CT_NUMERIC  // '.'
      ct[45] = StreamTokenizer.CT_NUMERIC  // '-'  (ambiguous, handled in nextToken)
      // Quotes
      ct[34] = StreamTokenizer.CT_QUOTE  // '"'
      ct[39] = StreamTokenizer.CT_QUOTE  // '\''
      // '/' is ordinary by default (slashSlash/slashStar are off)
    }

    // MARK: - Syntax configuration

    /// Sets `ch` as a comment-start character (rest of line is ignored).
    /// - Since: JavaApi (Java 1.0)
    public func commentChar(_ ch: Int) {
      if ch >= 0 && ch < 256 { ct[ch] = StreamTokenizer.CT_COMMENT }
    }

    /// Controls whether end-of-line is a significant token.
    /// - Since: JavaApi (Java 1.0)
    public func eolIsSignificant(_ flag: Bool) {
      eolSignificant = flag
    }

    /// Controls whether `//` starts a line comment.
    /// - Since: JavaApi (Java 1.0)
    public func slashSlashComments(_ flag: Bool) {
      slashSlash = flag
    }

    /// Controls whether `/* … */` starts a block comment.
    /// - Since: JavaApi (Java 1.0)
    public func slashStarComments(_ flag: Bool) {
      slashStar = flag
    }

    /// Controls whether word tokens are lowercased.
    /// - Since: JavaApi (Java 1.0)
    public func lowerCaseMode(_ flag: Bool) {
      lowerCase = flag
    }

    /// Marks `ch` as an ordinary character (not whitespace, word, or numeric).
    /// - Since: JavaApi (Java 1.0)
    public func ordinaryChar(_ ch: Int) {
      if ch >= 0 && ch < 256 { ct[ch] = StreamTokenizer.CT_ORDINARY }
    }

    /// Marks all characters from `low` to `hi` as ordinary.
    /// - Since: JavaApi (Java 1.0)
    public func ordinaryChars(_ low: Int, _ hi: Int) {
      let lo = max(low, 0), h = min(hi, 255)
      if lo <= h { for c in lo...h { ct[c] = StreamTokenizer.CT_ORDINARY } }
    }

    /// Enables number parsing (0–9, '.', '-' become numeric characters).
    /// - Since: JavaApi (Java 1.0)
    public func parseNumbers() {
      for c in 48...57 { ct[c] = StreamTokenizer.CT_NUMERIC }
      ct[46] = StreamTokenizer.CT_NUMERIC
      ct[45] = StreamTokenizer.CT_NUMERIC
    }

    /// Sets `ch` as a quote character.
    /// - Since: JavaApi (Java 1.0)
    public func quoteChar(_ ch: Int) {
      if ch >= 0 && ch < 256 { ct[ch] = StreamTokenizer.CT_QUOTE }
    }

    /// Resets the syntax table to all characters being ordinary.
    /// - Since: JavaApi (Java 1.0)
    public func resetSyntax() {
      for i in 0..<256 { ct[i] = StreamTokenizer.CT_ORDINARY }
    }

    /// Sets characters from `low` to `hi` as whitespace.
    /// - Since: JavaApi (Java 1.0)
    public func whitespaceChars(_ low: Int, _ hi: Int) {
      let lo = max(low, 0), h = min(hi, 255)
      if lo <= h { for c in lo...h { ct[c] = StreamTokenizer.CT_WHITESPACE } }
    }

    /// Sets characters from `low` to `hi` as word characters.
    /// - Since: JavaApi (Java 1.0)
    public func wordChars(_ low: Int, _ hi: Int) {
      let lo = max(low, 0), h = min(hi, 255)
      if lo <= h { for c in lo...h { ct[c] = StreamTokenizer.CT_ALPHA } }
    }

    // MARK: - Tokenising

    /// Causes the next call to ``nextToken()`` to return the current token again.
    /// - Since: JavaApi (Java 1.0)
    public func pushBack() {
      pushedBack = true
    }

    /// Returns the current line number.
    /// - Since: JavaApi (Java 1.0)
    public func lineno() -> Int {
      return lineNumber
    }

    /// Reads the next token from the stream and returns its type.
    ///
    /// Sets ``ttype``, and either ``sval`` or ``nval`` depending on the
    /// token type.
    ///
    /// - Returns: The token type (same value as ``ttype``).
    /// - Since: JavaApi (Java 1.0)
    @discardableResult
    public func nextToken() throws -> Int {
      if pushedBack {
        pushedBack = false
        return ttype
      }
      sval = nil

      var c = peekChar == -2 ? try read() : peekChar
      peekChar = -2

      // Skip whitespace
      while c != -1 && c < 256 && (ct[c] & StreamTokenizer.CT_WHITESPACE) != 0 {
        if c == 13 || c == 10 {  // CR or LF
          if c == 13 {
            c = try read()
            if c != 10 { peekChar = c }
          }
          lineNumber += 1
          if eolSignificant {
            ttype = StreamTokenizer.TT_EOL
            return ttype
          }
        }
        c = try read()
      }

      if c == -1 { ttype = StreamTokenizer.TT_EOF; return ttype }

      let ctype = c < 256 ? ct[c] : StreamTokenizer.CT_ALPHA

      // Comment character
      if (ctype & StreamTokenizer.CT_COMMENT) != 0 {
        while true {
          let next = try read()
          if next == -1 || next == 13 || next == 10 { break }
        }
        lineNumber += 1
        return try nextToken()
      }

      // Slash comments
      if c == 47 && (slashSlash || slashStar) {  // '/'
        let next = try read()
        if next == 47 && slashSlash {
          while true {
            let ch = try read()
            if ch == -1 || ch == 13 || ch == 10 { break }
          }
          lineNumber += 1
          return try nextToken()
        }
        if next == 42 && slashStar {  // '*'
          var prev = 0
          while true {
            let ch = try read()
            if ch == -1 { break }
            if ch == 10 || ch == 13 { lineNumber += 1 }
            if prev == 42 && ch == 47 { break }  // '*/'
            prev = ch
          }
          return try nextToken()
        }
        peekChar = next
      }

      // Quoted string
      if (ctype & StreamTokenizer.CT_QUOTE) != 0 {
        let quote = c
        var buf = ""
        while true {
          let ch = try read()
          if ch == -1 || ch == quote { break }
          if ch == 92 {  // backslash escape
            let esc = try read()
            switch esc {
            case 110: buf.append("\n")
            case 116: buf.append("\t")
            case 114: buf.append("\r")
            default:  buf.append(Character(UnicodeScalar(esc < 0 ? 0 : esc)!))
            }
          } else {
            if ch == 13 || ch == 10 { lineNumber += 1 }
            buf.append(Character(UnicodeScalar(ch)!))
          }
        }
        sval = buf
        ttype = quote
        return ttype
      }

      // Word
      if (ctype & StreamTokenizer.CT_ALPHA) != 0 {
        var buf = ""
        buf.append(Character(UnicodeScalar(c)!))
        while true {
          let ch = try read()
          if ch == -1 { break }
          let ct2 = ch < 256 ? ct[ch] : StreamTokenizer.CT_ALPHA
          if (ct2 & (StreamTokenizer.CT_ALPHA | StreamTokenizer.CT_NUMERIC)) == 0 {
            peekChar = ch
            break
          }
          buf.append(Character(UnicodeScalar(ch)!))
        }
        sval = lowerCase ? buf.lowercased() : buf
        ttype = StreamTokenizer.TT_WORD
        return ttype
      }

      // Number
      if (ctype & StreamTokenizer.CT_NUMERIC) != 0 {
        var buf = ""
        buf.append(Character(UnicodeScalar(c)!))
        while true {
          let ch = try read()
          if ch == -1 { break }
          let ct2 = ch < 256 ? ct[ch] : 0
          if (ct2 & StreamTokenizer.CT_NUMERIC) == 0 {
            peekChar = ch
            break
          }
          buf.append(Character(UnicodeScalar(ch)!))
        }
        if let d = Double(buf) {
          nval = d
          ttype = StreamTokenizer.TT_NUMBER
        } else {
          // Not a valid number — treat as word
          sval = buf
          ttype = StreamTokenizer.TT_WORD
        }
        return ttype
      }

      // Ordinary character
      ttype = c
      return ttype
    }

    /// Returns a string description of the current token.
    /// - Since: JavaApi (Java 1.0)
    public func toString() -> String {
      let lineInfo = ", line \(lineNumber)"
      switch ttype {
      case StreamTokenizer.TT_EOF:    return "EOF\(lineInfo)"
      case StreamTokenizer.TT_EOL:    return "EOL\(lineInfo)"
      case StreamTokenizer.TT_NUMBER: return "n=\(nval)\(lineInfo)"
      case StreamTokenizer.TT_WORD:   return "Word \(sval ?? "")\(lineInfo)"
      default:
        let ch = Character(UnicodeScalar(ttype)!)
        return "'\(ch)'\(lineInfo)"
      }
    }

    // MARK: - Private read helper

    private func read() throws -> Int {
      guard let reader else { return -1 }
      return try reader.read()
    }
  }
}

// MARK: - Internal InputStream→Reader adapter

/// Wraps an `InputStream` as a `Reader` for the deprecated `StreamTokenizer(InputStream)` constructor.
private final class InputStreamReader : java.io.Reader, @unchecked Sendable {
  private let stream: java.io.InputStream

  init(_ stream: java.io.InputStream) {
    self.stream = stream
    super.init()
  }

  override func read(_ buf: inout [Character], _ offset: Int, _ count: Int) throws -> Int {
    guard count > 0 else { return 0 }
    var bytes = [UInt8](repeating: 0, count: count)
    let n = try stream.read(&bytes, 0, count)
    if n <= 0 { return n }
    for i in 0..<n {
      buf[offset + i] = Character(UnicodeScalar(bytes[i]))
    }
    return n
  }

  override func close() throws {
    try stream.close()
  }
}
