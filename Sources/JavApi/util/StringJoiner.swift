/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Constructs a sequence of characters separated by a delimiter and optionally
  /// surrounded by a prefix and suffix.
  ///
  /// Mirrors `java.util.StringJoiner` from Java 8.
  ///
  /// ```swift
  /// let sj = java.util.StringJoiner(", ", "[", "]")
  /// sj.add("a").add("b").add("c")
  /// sj.toString() // "[a, b, c]"
  /// ```
  ///
  /// If no elements are added, ``toString()`` returns `prefix + suffix` (or the
  /// value set via ``setEmptyValue(_:)``).
  ///
  /// - Since: Java 8
  public final class StringJoiner {

    private let delimiter: String
    private let prefix: String
    private let suffix: String
    /// Stored segments — each element is either a single added value or the
    /// pre-joined content of a merged StringJoiner (joined with *its* delimiter).
    private var segments: [String] = []
    private var emptyValue: String? = nil

    // MARK: - Constructors

    /// Creates a ``StringJoiner`` with no prefix or suffix.
    ///
    /// - Parameter delimiter: The sequence of characters used to separate each element.
    public init(_ delimiter: String) {
      self.delimiter = delimiter
      self.prefix = ""
      self.suffix = ""
    }

    /// Creates a ``StringJoiner`` with the given delimiter, prefix, and suffix.
    ///
    /// - Parameters:
    ///   - delimiter: The sequence of characters used between elements.
    ///   - prefix: The character sequence prepended to the string value.
    ///   - suffix: The character sequence appended to the string value.
    public init(_ delimiter: String, _ prefix: String, _ suffix: String) {
      self.delimiter = delimiter
      self.prefix = prefix
      self.suffix = suffix
    }

    // MARK: - Core API

    /// Sets the string to be used when the StringJoiner is empty and no elements have been added.
    ///
    /// If not set, an empty joiner returns `prefix + suffix`.
    ///
    /// - Parameter emptyValue: The characters to return when no elements have been added.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func setEmptyValue(_ emptyValue: String) -> StringJoiner {
      self.emptyValue = emptyValue
      return self
    }

    /// Adds a copy of the given `newElement` as the next element.
    ///
    /// - Parameter newElement: The element to add.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func add(_ newElement: String) -> StringJoiner {
      segments.append(newElement)
      return self
    }

    /// Merges the contents of `other` (without its prefix/suffix) into this joiner.
    ///
    /// If `other` has no elements, this call has no effect.
    /// Elements from `other` are joined with `other`'s own delimiter and inserted
    /// as a single pre-joined segment — preserving `other`'s internal structure
    /// exactly as Java's implementation does.
    ///
    /// - Parameter other: The ``StringJoiner`` whose content to merge.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func merge(_ other: StringJoiner) -> StringJoiner {
      if !other.segments.isEmpty {
        // Join other's segments with other's delimiter (no prefix/suffix),
        // then append as one segment — mirrors Java's StringBuilder.append behaviour.
        let otherContent = other.segments.joined(separator: other.delimiter)
        segments.append(otherContent)
      }
      return self
    }

    /// Returns the length of the current string value.
    ///
    /// Equivalent to `toString().count`.
    ///
    /// - Returns: The number of Unicode scalar values in the string representation.
    public func length() -> Int {
      toString().count
    }

    /// Returns the final string representation.
    ///
    /// - If no elements have been added and ``setEmptyValue(_:)`` was called,
    ///   returns the empty value.
    /// - If no elements have been added and no empty value is set, returns
    ///   `prefix + suffix`.
    /// - Otherwise returns `prefix + element₁ + delimiter + … + elementN + suffix`.
    public func toString() -> String {
      if segments.isEmpty {
        return emptyValue ?? (prefix + suffix)
      }
      return prefix + segments.joined(separator: delimiter) + suffix
    }
  }
}
