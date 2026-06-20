/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Performs locale-sensitive string comparison and collation-key generation.
  ///
  /// Mirrors `java.text.Collator`.
  ///
  /// Use the factory methods to obtain an instance:
  /// ```swift
  /// let c = java.text.Collator.getInstance(java.util.Locale.GERMANY)
  /// c.setStrength(java.text.Collator.PRIMARY)
  /// let result = c.compare("ä", "a")  // 0 at PRIMARY strength (both map to 'a')
  /// ```
  ///
  /// ## Strength levels
  ///
  /// | Constant      | Value | Ignores |
  /// |---------------|-------|---------|
  /// | `PRIMARY`     | 0     | Case and accents |
  /// | `SECONDARY`   | 1     | Case |
  /// | `TERTIARY`    | 2     | Nothing (default) |
  /// | `IDENTICAL`   | 3     | Nothing; also compares code points |
  ///
  /// ## Implementation note
  ///
  /// Uses `Foundation.Locale` (via `java.util.Locale.delegate`) and Swift's
  /// built-in `String.compare(_:options:locale:)` — no NS/CF types are exposed
  /// in the public API.
  ///
  /// - Since: Java 1.1
  open class Collator {

    // -------------------------------------------------------------------------
    // MARK: Strength constants
    // -------------------------------------------------------------------------

    public static let PRIMARY:   Int = 0
    public static let SECONDARY: Int = 1
    public static let TERTIARY:  Int = 2
    public static let IDENTICAL: Int = 3

    // -------------------------------------------------------------------------
    // MARK: Decomposition constants
    // -------------------------------------------------------------------------

    public static let NO_DECOMPOSITION:       Int = 0
    public static let CANONICAL_DECOMPOSITION: Int = 1
    public static let FULL_DECOMPOSITION:     Int = 2

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var strength:     Int
    private var decomposition: Int
    let locale: Foundation.Locale

    // -------------------------------------------------------------------------
    // MARK: Initialisers (protected — use factory methods)
    // -------------------------------------------------------------------------

    init(locale: Foundation.Locale, strength: Int = TERTIARY, decomposition: Int = CANONICAL_DECOMPOSITION) {
      self.locale        = locale
      self.strength      = strength
      self.decomposition = decomposition
    }

    // -------------------------------------------------------------------------
    // MARK: Factory methods
    // -------------------------------------------------------------------------

    /// Returns the set of locales for which `Collator` instances are available.
    ///
    /// - Since: Java 1.2
    public static func getAvailableLocales() -> [java.util.Locale] {
      return Foundation.Locale.availableIdentifiers.map { java.util.Locale($0) }
    }

    /// Returns a `Collator` for the default locale.
    public static func getInstance() -> Collator {
      return getInstance(java.util.Locale.getDefault())
    }

    /// Returns a `Collator` for `locale`.
    public static func getInstance(_ locale: java.util.Locale) -> Collator {
      return Collator(locale: locale.delegate ?? Foundation.Locale.current)
    }

    // -------------------------------------------------------------------------
    // MARK: Strength / decomposition
    // -------------------------------------------------------------------------

    public func getStrength() -> Int { strength }
    public func setStrength(_ s: Int) { strength = s }

    public func getDecomposition() -> Int { decomposition }
    public func setDecomposition(_ d: Int) { decomposition = d }

    // -------------------------------------------------------------------------
    // MARK: Comparison
    // -------------------------------------------------------------------------

    /// Compares `source` and `target` according to the collation rules.
    ///
    /// - Returns: A negative value, zero, or a positive value as `source` is
    ///   less than, equal to, or greater than `target`.
    open func compare(_ source: String, _ target: String) -> Int {
      let options = compareOptions()
      let result  = source.compare(target, options: options, locale: locale)
      switch result {
      case .orderedAscending:  return -1
      case .orderedSame:
        // IDENTICAL additionally compares Unicode code-point order
        if strength == Self.IDENTICAL && source != target {
          return source < target ? -1 : 1
        }
        return 0
      case .orderedDescending: return 1
      }
    }

    /// Returns `true` if `source` and `target` are considered equal.
    open func equals(_ source: String, _ target: String) -> Bool {
      return compare(source, target) == 0
    }

    // -------------------------------------------------------------------------
    // MARK: CollationKey
    // -------------------------------------------------------------------------

    /// Returns a ``CollationKey`` for `source`.
    ///
    /// The key can be compared with other keys from the **same** `Collator`
    /// more efficiently than repeated ``compare(_:_:)`` calls.
    open func getCollationKey(_ source: String) -> CollationKey {
      return CollationKey(source: source, sortKey: normalise(source))
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    private func compareOptions() -> String.CompareOptions {
      var options: String.CompareOptions = [.caseInsensitive]
      switch strength {
      case Self.PRIMARY:
        // Ignore accents and case — diacritic-insensitive + case-insensitive
        options = [.diacriticInsensitive, .caseInsensitive]
      case Self.SECONDARY:
        // Ignore case, respect accents
        options = [.caseInsensitive]
      case Self.TERTIARY, Self.IDENTICAL:
        // Respect case and accents
        options = []
      default:
        options = []
      }
      return options
    }

    /// Produces a normalised string suitable for use as a sort key.
    func normalise(_ s: String) -> String {
      switch strength {
      case Self.PRIMARY:
        // Fold to ASCII-like form: remove diacritics, lowercase
        return s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: locale)
      case Self.SECONDARY:
        return s.folding(options: [.caseInsensitive], locale: locale)
      default:
        return s
      }
    }
  }
}
