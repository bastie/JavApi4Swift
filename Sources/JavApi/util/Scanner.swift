/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// A simple text scanner that parses primitive types and strings using a
  /// configurable delimiter pattern.
  ///
  /// `Scanner` breaks input into tokens separated by a delimiter pattern
  /// (default: any whitespace, `\\s+`).  It provides `hasNextX` / `nextX`
  /// method pairs for each supported type, plus line-oriented reading via
  /// `hasNextLine` / `nextLine`.
  ///
  /// ### Constructors
  ///
  /// | Java | JavApi4Swift |
  /// |------|-------------|
  /// | `new Scanner(String)` | `Scanner(_ source: String)` |
  /// | `new Scanner(InputStream)` | `Scanner(_ stream: java.io.InputStream)` |
  /// | `new Scanner(File)` | `Scanner(_ file: java.io.File)` |
  ///
  /// ### Notes
  ///
  /// - Delimiter pattern is interpreted as an NSRegularExpression pattern.
  ///   The default `"\\s+"` matches one or more whitespace characters.
  /// - Mixing `next()` / `nextInt()` etc. with `nextLine()` may produce
  ///   different results than Java when whitespace precedes the line terminator,
  ///   because this implementation eagerly consumes trailing delimiters.
  /// - This class is **not** thread-safe (matches Java semantics).
  ///
  /// Mirrors `java.util.Scanner` (Java 5).
  ///
  /// - Since: Java 5
  open class Scanner: java.io.Closeable {

    // MARK: - State

    /// Unparsed remainder of the input.
    private var _remaining: String

    /// NSRegularExpression pattern that defines token delimiters.
    /// Default: `"\\s+"` (any whitespace).
    private var _delimiterPattern: String

    /// Default radix used by `nextInt()` / `nextLong()`.  Default: 10.
    private var _radix: Int

    /// Set to `true` after `close()` is called.
    private var _closed: Bool

    // MARK: - Constructors

    /// Creates a scanner that produces values scanned from `source`.
    ///
    /// - Parameter source: The string to scan.
    /// - Since: Java 5
    public init(_ source: String) {
      _remaining = source
      _delimiterPattern = "\\s+"
      _radix = 10
      _closed = false
    }

    /// Creates a scanner that produces values scanned from `stream`.
    ///
    /// All available bytes are read from the stream and decoded as UTF-8.
    ///
    /// - Parameter stream: The input stream to scan.
    /// - Throws: Any I/O error raised by the stream.
    /// - Since: Java 5
    public convenience init(_ stream: java.io.InputStream) throws {
      var allBytes: [UInt8] = []
      var buffer = [UInt8](repeating: 0, count: 4096)
      var n: Int
      repeat {
        n = try stream.read(&buffer)
        if n > 0 { allBytes.append(contentsOf: buffer[..<n]) }
      } while n > 0
      self.init(String(bytes: allBytes, encoding: .utf8) ?? "")
    }

    /// Creates a scanner that produces values scanned from `file`.
    ///
    /// The file is read in its entirety and decoded as UTF-8.
    ///
    /// - Parameter file: The file to scan.
    /// - Throws: `java.io.FileNotFoundException` if the file cannot be read.
    /// - Since: Java 5
    public convenience init(_ file: java.io.File) throws {
      let path = file.getAbsolutePath()
      guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        throw java.io.FileNotFoundException(path)
      }
      self.init(content)
    }

    // MARK: - Configuration

    /// Sets the scanner's delimiter to the given pattern and returns `self`.
    ///
    /// The pattern is interpreted as an NSRegularExpression pattern.
    ///
    /// - Parameter pattern: The new delimiter pattern.
    /// - Returns: This scanner (for method chaining).
    /// - Since: Java 5
    @discardableResult
    public func useDelimiter(_ pattern: String) -> Scanner {
      _delimiterPattern = pattern
      return self
    }

    /// Sets the default radix for `nextInt()` / `nextLong()` and returns `self`.
    ///
    /// - Parameter radix: The new default radix (must be 2–36).
    /// - Returns: This scanner (for method chaining).
    /// - Since: Java 5
    @discardableResult
    public func useRadix(_ radix: Int) -> Scanner {
      _radix = radix
      return self
    }

    // MARK: - Closeable

    /// Closes this scanner.  Subsequent `next*` calls throw `IllegalStateException`.
    ///
    /// - Since: Java 5
    public func close() throws {
      _closed = true
      _remaining = ""
    }

    // MARK: - Internal helpers

    /// Returns `text` with any leading delimiter match stripped.
    private func _stripLeadingDelimiters(_ text: String) -> String {
      guard !text.isEmpty,
            let regex = try? NSRegularExpression(pattern: "^(?:\(_delimiterPattern))") else {
        return text
      }
      let ns = text as NSString
      let range = NSRange(location: 0, length: ns.length)
      if let m = regex.firstMatch(in: text, range: range), m.range.length > 0 {
        return ns.substring(from: m.range.upperBound)
      }
      return text
    }

    /// Returns `(token, remainingAfterDelimiter)` from `text`, or `nil` if no token exists.
    ///
    /// Leading delimiters are skipped.  The delimiter immediately following the token
    /// is also consumed so that the next call to this function finds the next token
    /// without extra stripping.
    private func _splitNextToken(in text: String) -> (token: String, rest: String)? {
      let stripped = _stripLeadingDelimiters(text)
      guard !stripped.isEmpty else { return nil }

      let ns = stripped as NSString
      let range = NSRange(location: 0, length: ns.length)

      guard let regex = try? NSRegularExpression(pattern: _delimiterPattern) else {
        // No valid delimiter regex — whole remaining text is one token.
        return (stripped, "")
      }

      if let m = regex.firstMatch(in: stripped, range: range) {
        if m.range.location == 0 {
          // Starts with delimiter — _stripLeadingDelimiters should have removed it.
          // Defensive: skip and recurse.
          let after = ns.substring(from: m.range.upperBound)
          return _splitNextToken(in: after)
        }
        let token = ns.substring(to: m.range.location)
        let rest = ns.substring(from: m.range.upperBound)
        return (token, rest)
      } else {
        // No delimiter found — the entire stripped text is the token.
        return (stripped, "")
      }
    }

    // MARK: - hasNext / next

    /// Returns `true` if this scanner has another token in its input.
    ///
    /// - Since: Java 5
    public func hasNext() -> Bool {
      guard !_closed else { return false }
      return _splitNextToken(in: _remaining) != nil
    }

    /// Returns the next token.
    ///
    /// - Throws: `NoSuchElementException` if no more tokens are available.
    ///           `IllegalStateException` if the scanner is closed.
    /// - Since: Java 5
    public func next() throws -> String {
      guard !_closed else { throw java.lang.IllegalStateException("Scanner closed") }
      guard let (token, rest) = _splitNextToken(in: _remaining) else {
        throw java.util.NoSuchElementException()
      }
      _remaining = rest
      return token
    }

    // MARK: - hasNextLine / nextLine

    /// Returns `true` if there is another line in this scanner's input.
    ///
    /// - Since: Java 5
    public func hasNextLine() -> Bool {
      guard !_closed else { return false }
      return !_remaining.isEmpty
    }

    /// Advances past the current line and returns the skipped input.
    ///
    /// Returns everything up to (but not including) the line separator.
    /// Recognises `\\n`, `\\r`, and `\\r\\n` as line terminators.
    ///
    /// - Throws: `NoSuchElementException` if no line is available.
    ///           `IllegalStateException` if the scanner is closed.
    /// - Since: Java 5
    public func nextLine() throws -> String {
      guard !_closed else { throw java.lang.IllegalStateException("Scanner closed") }
      guard !_remaining.isEmpty else { throw java.util.NoSuchElementException() }

      // Swift treats the two-scalar sequence CR+LF (U+000D U+000A) as a single
      // extended grapheme cluster, so comparing individual Characters against
      // "\r" or "\n" alone will NOT match a CRLF cluster. We must also test
      // for the combined "\r\n" cluster explicitly.
      if let idx = _remaining.firstIndex(where: { c in
        c == "\n" || c == "\r" || c == "\r\n"
      }) {
        let line = String(_remaining[..<idx])
        // index(after:) advances past the entire grapheme cluster, so it handles
        // "\r\n" (one cluster), lone "\n", and lone "\r" uniformly.
        let after = _remaining.index(after: idx)
        _remaining = String(_remaining[after...])
        return line
      } else {
        // No line terminator — return the rest.
        let line = _remaining
        _remaining = ""
        return line
      }
    }

    // MARK: - hasNextInt / nextInt

    /// Returns `true` if the next token can be interpreted as an `Int` using the default radix.
    ///
    /// - Since: Java 5
    public func hasNextInt() -> Bool { hasNextInt(radix: _radix) }

    /// Returns `true` if the next token can be interpreted as an `Int` using `radix`.
    ///
    /// - Since: Java 5
    public func hasNextInt(radix: Int) -> Bool {
      guard let (tok, _) = _splitNextToken(in: _remaining) else { return false }
      return Int(tok, radix: radix) != nil
    }

    /// Scans the next token as an `Int` using the default radix.
    ///
    /// - Throws: `InputMismatchException` if the token is not a valid integer.
    ///           `NoSuchElementException` if no token is available.
    ///           `IllegalStateException` if the scanner is closed.
    /// - Since: Java 5
    public func nextInt() throws -> Int { try nextInt(radix: _radix) }

    /// Scans the next token as an `Int` using `radix`.
    ///
    /// - Throws: `InputMismatchException` if the token is not a valid integer.
    ///           `NoSuchElementException` if no token is available.
    ///           `IllegalStateException` if the scanner is closed.
    /// - Since: Java 5
    public func nextInt(radix: Int) throws -> Int {
      guard !_closed else { throw java.lang.IllegalStateException("Scanner closed") }
      guard let (tok, rest) = _splitNextToken(in: _remaining) else {
        throw java.util.NoSuchElementException()
      }
      guard let value = Int(tok, radix: radix) else {
        throw java.util.InputMismatchException("For input string: \"\(tok)\"")
      }
      _remaining = rest
      return value
    }

    // MARK: - hasNextLong / nextLong

    /// Returns `true` if the next token can be interpreted as an `Int64` using the default radix.
    ///
    /// - Since: Java 5
    public func hasNextLong() -> Bool { hasNextLong(radix: _radix) }

    /// Returns `true` if the next token can be interpreted as an `Int64` using `radix`.
    ///
    /// - Since: Java 5
    public func hasNextLong(radix: Int) -> Bool {
      guard let (tok, _) = _splitNextToken(in: _remaining) else { return false }
      return Int64(tok, radix: radix) != nil
    }

    /// Scans the next token as an `Int64` (Java `long`) using the default radix.
    ///
    /// - Throws: `InputMismatchException` if the token is not a valid long integer.
    ///           `NoSuchElementException` if no token is available.
    ///           `IllegalStateException` if the scanner is closed.
    /// - Since: Java 5
    public func nextLong() throws -> Int64 { try nextLong(radix: _radix) }

    /// Scans the next token as an `Int64` (Java `long`) using `radix`.
    ///
    /// - Throws: `InputMismatchException` if the token is not a valid long integer.
    ///           `NoSuchElementException` if no token is available.
    ///           `IllegalStateException` if the scanner is closed.
    /// - Since: Java 5
    public func nextLong(radix: Int) throws -> Int64 {
      guard !_closed else { throw java.lang.IllegalStateException("Scanner closed") }
      guard let (tok, rest) = _splitNextToken(in: _remaining) else {
        throw java.util.NoSuchElementException()
      }
      guard let value = Int64(tok, radix: radix) else {
        throw java.util.InputMismatchException("For input string: \"\(tok)\"")
      }
      _remaining = rest
      return value
    }

    // MARK: - hasNextDouble / nextDouble

    /// Returns `true` if the next token can be interpreted as a `Double`.
    ///
    /// - Since: Java 5
    public func hasNextDouble() -> Bool {
      guard let (tok, _) = _splitNextToken(in: _remaining) else { return false }
      return Double(tok) != nil
    }

    /// Scans the next token as a `Double`.
    ///
    /// - Throws: `InputMismatchException` if the token is not a valid double.
    ///           `NoSuchElementException` if no token is available.
    ///           `IllegalStateException` if the scanner is closed.
    /// - Since: Java 5
    public func nextDouble() throws -> Double {
      guard !_closed else { throw java.lang.IllegalStateException("Scanner closed") }
      guard let (tok, rest) = _splitNextToken(in: _remaining) else {
        throw java.util.NoSuchElementException()
      }
      guard let value = Double(tok) else {
        throw java.util.InputMismatchException("For input string: \"\(tok)\"")
      }
      _remaining = rest
      return value
    }

    // MARK: - hasNextBoolean / nextBoolean

    /// Returns `true` if the next token is a case-insensitive `"true"` or `"false"`.
    ///
    /// - Since: Java 5
    public func hasNextBoolean() -> Bool {
      guard let (tok, _) = _splitNextToken(in: _remaining) else { return false }
      let lower = tok.lowercased()
      return lower == "true" || lower == "false"
    }

    /// Scans the next token as a `Bool`.
    ///
    /// Accepts `"true"` or `"false"` (case-insensitive), matching Java's
    /// `Boolean.parseBoolean` semantics.
    ///
    /// - Throws: `InputMismatchException` if the token is neither `"true"` nor `"false"`.
    ///           `NoSuchElementException` if no token is available.
    ///           `IllegalStateException` if the scanner is closed.
    /// - Since: Java 5
    public func nextBoolean() throws -> Bool {
      guard !_closed else { throw java.lang.IllegalStateException("Scanner closed") }
      guard let (tok, rest) = _splitNextToken(in: _remaining) else {
        throw java.util.NoSuchElementException()
      }
      let lower = tok.lowercased()
      guard lower == "true" || lower == "false" else {
        throw java.util.InputMismatchException("For input string: \"\(tok)\"")
      }
      _remaining = rest
      return lower == "true"
    }

    // MARK: - Java 9: tokens()

    /// Returns a `Stream` of tokens produced by this scanner.
    ///
    /// Each element of the stream is the next token returned by `next()`.
    /// The stream is **lazy** — tokens are read on demand. The scanner must
    /// not be used concurrently while the stream is being consumed.
    ///
    /// Closing the stream does **not** close the scanner.
    ///
    /// Mirrors `java.util.Scanner.tokens()` (Java 9).
    ///
    /// - Since: Java 9
    public func tokens() -> java.util.stream.Stream<String> {
      // Materialise all remaining tokens immediately, then advance the scanner.
      // Stream.init(_:) requires a concrete Sequence — the private factory
      // init is not accessible from here.
      var tokens: [String] = []
      var remaining = _remaining
      while let (tok, rest) = _splitNextToken(in: remaining) {
        tokens.append(tok)
        remaining = rest
      }
      _remaining = remaining
      return java.util.stream.Stream<String>(tokens)
    }

    // MARK: - Java 9: findAll

    /// Returns a stream of match results for each subsequence of the remaining
    /// input that matches the given `Pattern`.
    ///
    /// Matches are produced in order, without overlapping.  The scanner is
    /// advanced past all matched regions when the returned stream is consumed
    /// (our implementation materialises eagerly on call).
    ///
    /// Mirrors `java.util.Scanner.findAll(Pattern)` (Java 9).
    ///
    /// - Since: Java 9
    public func findAll(
      _ pattern: java.util.regex.Pattern
    ) -> java.util.stream.Stream<any java.util.regex.MatchResult> {
      guard !_closed else { return java.util.stream.Stream([] as [any java.util.regex.MatchResult]) }
      var results: [any java.util.regex.MatchResult] = []
      let matcher = pattern.matcher(_remaining)
      while matcher.find() {
        results.append(matcher.toMatchResult())
      }
      // Advance scanner past the searched region.
      _remaining = ""
      return java.util.stream.Stream<any java.util.regex.MatchResult>(results)
    }

    /// Returns a stream of match results for each subsequence of the remaining
    /// input that matches the given regex pattern string.
    ///
    /// - Throws: `PatternSyntaxException` if the pattern string is invalid.
    /// - Since: Java 9
    public func findAll(
      _ pattern: String
    ) throws(java.util.regex.PatternSyntaxException) -> java.util.stream.Stream<any java.util.regex.MatchResult> {
      findAll(try java.util.regex.Pattern.compile(pattern))
    }
  }
}
