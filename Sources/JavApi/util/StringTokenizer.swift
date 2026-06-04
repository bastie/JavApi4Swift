/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// A simple string tokenizer that breaks a string into tokens.
  ///
  /// Mirrors `java.util.StringTokenizer` from Java 1.0. Tokens are delimited
  /// by one or more delimiter characters. By default the delimiters are the
  /// whitespace characters space (`' '`), tab (`'\t'`), newline (`'\n'`),
  /// carriage return (`'\r'`), and form feed (`'\f'`).
  ///
  /// `StringTokenizer` implements `java.util.Enumeration` so it can be used
  /// wherever an `Enumeration<String>` is expected. In addition the Swiftify
  /// extension makes it conform to `Sequence`, enabling Swift `for`-`in` loops:
  ///
  /// ```swift
  /// let st = java.util.StringTokenizer("one two three")
  /// for token in st {
  ///     print(token)   // one, two, three
  /// }
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  public final class StringTokenizer {

    // MARK: - State

    private let source: String
    private var delimiters: String
    private let returnDelimiters: Bool
    private var currentIndex: String.Index

    // MARK: - Initialisers

    /// Creates a tokenizer for `str` using whitespace as delimiters.
    ///
    /// - Parameter str: The string to tokenize.
    /// - Since: JavaApi (Java 1.0)
    public init(_ str: String) {
      self.source = str
      self.delimiters = " \t\n\r\u{0C}"  // space, tab, LF, CR, FF
      self.returnDelimiters = false
      self.currentIndex = str.startIndex
    }

    /// Creates a tokenizer for `str` using the characters in `delim` as delimiters.
    ///
    /// - Parameters:
    ///   - str: The string to tokenize.
    ///   - delim: A string whose characters are each treated as a delimiter.
    /// - Since: JavaApi (Java 1.0)
    public init(_ str: String, _ delim: String) {
      self.source = str
      self.delimiters = delim
      self.returnDelimiters = false
      self.currentIndex = str.startIndex
    }

    /// Creates a tokenizer for `str` with full control over delimiter handling.
    ///
    /// - Parameters:
    ///   - str: The string to tokenize.
    ///   - delim: A string whose characters are each treated as a delimiter.
    ///   - returnDelims: If `true`, delimiter characters are returned as
    ///     single-character tokens; if `false` they are silently skipped.
    /// - Since: JavaApi (Java 1.0)
    public init(_ str: String, _ delim: String, _ returnDelims: Bool) {
      self.source = str
      self.delimiters = delim
      self.returnDelimiters = returnDelims
      self.currentIndex = str.startIndex
    }

    // MARK: - Private helpers

    private func isDelimiter(_ c: Character) -> Bool {
      return delimiters.contains(c)
    }

    /// Skips delimiter characters at `currentIndex`.
    private func skipDelimiters() {
      while currentIndex < source.endIndex && isDelimiter(source[currentIndex]) {
        currentIndex = source.index(after: currentIndex)
      }
    }

    // MARK: - Java 1.0 API

    /// Returns `true` if more tokens are available.
    /// - Since: JavaApi (Java 1.0)
    public func hasMoreTokens() -> Bool {
      if returnDelimiters {
        return currentIndex < source.endIndex
      }
      let saved = currentIndex
      skipDelimiters()
      let result = currentIndex < source.endIndex
      currentIndex = saved
      return result
    }

    /// Returns the next token using the current delimiter set.
    ///
    /// - Returns: The next token.
    /// - Throws: `java.util.NoSuchElementException` if no more tokens exist.
    /// - Since: JavaApi (Java 1.0)
    public func nextToken() throws -> String {
      if !returnDelimiters {
        skipDelimiters()
      }
      guard currentIndex < source.endIndex else {
        throw java.util.NoSuchElementException()
      }
      let start = currentIndex
      if returnDelimiters && isDelimiter(source[currentIndex]) {
        // Return single delimiter character as token
        currentIndex = source.index(after: currentIndex)
      } else {
        // Advance until next delimiter or end
        while currentIndex < source.endIndex && !isDelimiter(source[currentIndex]) {
          currentIndex = source.index(after: currentIndex)
        }
      }
      return String(source[start..<currentIndex])
    }

    /// Returns the next token after switching to a new delimiter set.
    ///
    /// The new delimiter set remains active for subsequent calls.
    /// - Parameter delim: The new delimiter string.
    /// - Returns: The next token.
    /// - Throws: `java.util.NoSuchElementException` if no more tokens exist.
    /// - Since: JavaApi (Java 1.0)
    public func nextToken(_ delim: String) throws -> String {
      self.delimiters = delim
      return try nextToken()
    }

    /// Returns the number of remaining tokens using the current delimiter set.
    ///
    /// This method does not advance the current position.
    /// - Returns: Number of remaining tokens.
    /// - Since: JavaApi (Java 1.0)
    public func countTokens() -> Int {
      let saved = currentIndex
      var count = 0
      while hasMoreTokens() {
        _ = try? nextToken()
        count += 1
      }
      currentIndex = saved
      return count
    }

    // MARK: - Enumeration conformance (delegating to token methods)

    /// Returns `true` if more elements are available. Alias for ``hasMoreTokens()``.
    /// - Since: JavaApi (Java 1.0)
    public func hasMoreElements() -> Bool {
      return hasMoreTokens()
    }

    /// Returns the next element. Alias for ``nextToken()``.
    /// - Throws: `java.util.NoSuchElementException` if no more elements exist.
    /// - Since: JavaApi (Java 1.0)
    public func nextElement() throws -> String {
      return try nextToken()
    }
  }
}
