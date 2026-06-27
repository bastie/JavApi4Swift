/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  /// Identifies a field in a formatted output.
  ///
  /// `FieldPosition` is used by `Format` subclasses to track the start and
  /// end index of a particular field in a formatted string.
  ///
  /// - Since: Java 1.1
  open class FieldPosition {

    private let field: Int
    private var beginIndex: Int = 0
    private var endIndex: Int = 0

    /// Creates a `FieldPosition` for the given field identifier.
    public init(_ field: Int) {
      self.field = field
    }

    /// Returns the field identifier.
    public func getField() -> Int { field }

    /// Returns the start index of the field in the formatted string.
    public func getBeginIndex() -> Int { beginIndex }

    /// Returns the end index (exclusive) of the field in the formatted string.
    public func getEndIndex() -> Int { endIndex }

    /// Sets the start index of the field.
    public func setBeginIndex(_ bi: Int) { beginIndex = bi }

    /// Sets the end index of the field.
    public func setEndIndex(_ ei: Int) { endIndex = ei }
  }
}
