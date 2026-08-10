/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.regex {

  /// The result of a match operation on a character sequence.
  ///
  /// All index values are measured in code units (UTF-16 in Java; Unicode
  /// scalar values in Swift). In practice, for BMP-only input the values are
  /// identical.
  ///
  /// Mirrors `java.util.regex.MatchResult` (Java 1.4).
  ///
  /// - Since: Java 1.4
  public protocol MatchResult {

    /// Returns the start index of the match.
    func start() -> Int

    /// Returns the start index of the subsequence captured by group `group`.
    ///
    /// Group 0 denotes the entire pattern; capture groups are numbered from 1.
    /// Returns `-1` if the group did not participate in the match.
    func start(_ group: Int) -> Int

    /// Returns the offset *after* the last matched character.
    func end() -> Int

    /// Returns the offset *after* the last character captured by group `group`.
    ///
    /// Returns `-1` if the group did not participate in the match.
    func end(_ group: Int) -> Int

    /// Returns the input subsequence matched by the previous match.
    func group() -> String

    /// Returns the input subsequence captured by group `group`, or `nil` if
    /// the group did not participate in the match.
    func group(_ group: Int) -> String?

    /// Returns the number of capturing groups in the pattern.
    func groupCount() -> Int
  }
}
