/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.regex {

  /// Thrown when a syntactically incorrect regular expression pattern is
  /// compiled by `Pattern.compile(_:)`.
  ///
  /// Mirrors `java.util.regex.PatternSyntaxException` (Java 1.4).
  ///
  /// - Since: Java 1.4
  open class PatternSyntaxException: IllegalArgumentException, @unchecked Sendable {

    private let _description: String
    private let _pattern: String
    private let _index: Int

    /// Creates a new exception.
    ///
    /// - Parameters:
    ///   - desc:  Human-readable description of the error.
    ///   - regex: The offending pattern string.
    ///   - index: The approximate index in the pattern where the error was
    ///            detected, or `-1` if the index is not known.
    public init(_ desc: String, _ regex: String, _ index: Int) {
      _description = desc
      _pattern = regex
      _index = index
      super.init(Self._buildMessage(desc, regex, index))
    }

    // MARK: - Accessors

    /// A description of the syntax error.
    public func getDescription() -> String { _description }

    /// The erroneous pattern.
    public func getPattern() -> String { _pattern }

    /// The approximate index in the pattern of the error, or `-1`.
    public func getIndex() -> Int { _index }

    // MARK: - Private helpers

    private static func _buildMessage(_ desc: String, _ pattern: String, _ index: Int) -> String {
      var msg = desc + "\n"
      msg += pattern + "\n"
      if index >= 0 {
        msg += String(repeating: " ", count: index) + "^"
      }
      return msg
    }
  }
}
