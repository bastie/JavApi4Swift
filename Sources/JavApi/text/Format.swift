/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  /// Abstract base class for formatting locale-sensitive information such as
  /// dates, messages, and numbers.
  ///
  /// Mirrors `java.text.Format`.
  ///
  /// Subclasses must override:
  /// - ``format(_:toAppendTo:pos:)``
  /// - ``parseObject(_:pos:)``
  ///
  /// - Since: Java 1.1
  open class Format {

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Abstract interface (subclasses must override)
    // -------------------------------------------------------------------------

    /// Formats `obj` and appends the result to `toAppendTo`.
    ///
    /// - Parameters:
    ///   - obj: The object to format.
    ///   - toAppendTo: Where the formatted text is appended.
    ///   - pos: A `FieldPosition` that may be used to track the position of a
    ///     field in the output.
    /// - Returns: The `toAppendTo` buffer with formatted text appended.
    open func format(_ obj: Any, toAppendTo: inout String, pos: FieldPosition) -> String {
      fatalError("Subclasses of java.text.Format must override format(_:toAppendTo:pos:)")
    }
    // Note: FieldPosition and ParsePosition are reference types (class) — mutations
    // are visible to the caller without inout. The inout on String is necessary.

    /// Parses `source` starting at the index given by `pos`.
    ///
    /// - Parameters:
    ///   - source: The string to parse.
    ///   - pos: On entry, the index to start parsing; on exit, the index after
    ///     the last character used, or the error index on failure.
    /// - Returns: The parsed object, or `nil` if parsing fails.
    open func parseObject(_ source: String, pos: ParsePosition) -> Any? {
      fatalError("Subclasses of java.text.Format must override parseObject(_:pos:)")
    }

    // -------------------------------------------------------------------------
    // MARK: Concrete convenience methods
    // -------------------------------------------------------------------------

    /// Formats `obj` into a `String`.
    ///
    /// - Parameter obj: The object to format.
    /// - Returns: The formatted string.
    /// - Throws: `IllegalArgumentException` if `obj` cannot be formatted.
    public func format(_ obj: Any) -> String {
      var buf = ""
      let pos = FieldPosition(0)
      return format(obj, toAppendTo: &buf, pos: pos)
    }

    /// Parses `source` from the beginning.
    ///
    /// - Parameter source: The string to parse.
    /// - Returns: The parsed object.
    /// - Throws: `ParseException` if parsing fails.
    public func parseObject(_ source: String) throws -> Any? {
      let pos = ParsePosition(0)
      guard let result = parseObject(source, pos: pos) else {
        throw ParseException(
          "Format.parseObject(String) failed",
          pos.getErrorIndex() >= 0 ? pos.getErrorIndex() : pos.getIndex()
        )
      }
      return result
    }
  }
}
