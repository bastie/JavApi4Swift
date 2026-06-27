/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  /// A pre-computed sort key for a string under a specific ``Collator``.
  ///
  /// `CollationKey` objects are obtained from ``Collator/getCollationKey(_:)``
  /// and can be compared with ``compareTo(_:)`` more efficiently than repeated
  /// calls to ``Collator/compare(_:_:)`` when the same string is compared many
  /// times.
  ///
  /// - Since: Java 1.1
  open class CollationKey : Comparable {

    /// The original source string.
    private let source: String

    /// The normalised sort key string (locale-folded).
    let sortKey: String

    // -------------------------------------------------------------------------
    // MARK: Initialiser (package-internal — created by Collator)
    // -------------------------------------------------------------------------

    init(source: String, sortKey: String) {
      self.source  = source
      self.sortKey = sortKey
    }

    // -------------------------------------------------------------------------
    // MARK: API
    // -------------------------------------------------------------------------

    /// Returns the original string this key was created from.
    public func getSourceString() -> String { source }

    /// Compares this key with `other`.
    ///
    /// - Returns: A negative value, zero, or a positive value as this key is
    ///   less than, equal to, or greater than `other`.
    public func compareTo(_ other: CollationKey) -> Int {
      if sortKey < other.sortKey { return -1 }
      if sortKey > other.sortKey { return  1 }
      return 0
    }

    // -------------------------------------------------------------------------
    // MARK: Comparable / Equatable
    // -------------------------------------------------------------------------

    public static func < (lhs: CollationKey, rhs: CollationKey) -> Bool {
      return lhs.sortKey < rhs.sortKey
    }

    public static func == (lhs: CollationKey, rhs: CollationKey) -> Bool {
      return lhs.sortKey == rhs.sortKey
    }
  }
}
