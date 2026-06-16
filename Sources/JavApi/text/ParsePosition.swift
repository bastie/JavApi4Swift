/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  /// Tracks the current position in a string during parsing.
  ///
  /// `ParsePosition` is passed to `Format.parseObject(_:pos:)` to indicate
  /// where parsing should start and to report where it ended — or where it
  /// failed.
  ///
  /// Mirrors `java.text.ParsePosition`.
  ///
  /// - Since: Java 1.1
  open class ParsePosition {

    private var index: Int
    private var errorIndex: Int = -1

    /// Creates a `ParsePosition` with the given initial index.
    public init(_ index: Int) {
      self.index = index
    }

    /// The current parse position (next character to be parsed).
    public func getIndex() -> Int { index }
    public func setIndex(_ index: Int) { self.index = index }

    /// The index at which a parse error occurred, or −1 if no error.
    public func getErrorIndex() -> Int { errorIndex }
    public func setErrorIndex(_ ei: Int) { errorIndex = ei }
  }
}
