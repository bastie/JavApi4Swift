/*
 * SPDX-FileCopyrightText: 2023 - 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.math {

  /// A Swift implementation of `java.math.BigDecimal`.
  ///
  /// Internally delegates arithmetic to `Foundation.Decimal` (`_value`) while
  /// preserving the Java-specified scale (`_scale`) separately.  This is
  /// necessary because `Foundation.Decimal` normalises trailing zeros — e.g.
  /// `Decimal(string: "1.000")` stores the value as `1` with exponent `0`,
  /// losing the information that the original string had three decimal places.
  ///
  /// The delegate pattern means:
  ///  - All arithmetic is correct (Foundation.Decimal is a high-precision
  ///    decimal type).
  ///  - `scale()` returns the Java-correct value (number of decimal places in
  ///    the original string / set via `setScale`).
  ///  - `precision()` returns the Java-correct significant-digit count.
  ///
  /// `Sendable` is safe because both stored properties are value types and
  /// immutable (`let`).
  public struct BigDecimal: CustomStringConvertible, Sendable {

    // MARK: - Internal storage

    /// The numeric value, delegated to Foundation.Decimal for arithmetic.
    internal let _value: Decimal

    /// The scale: number of digits to the right of the decimal point.
    /// Matches Java's `BigDecimal.scale()` contract, including trailing zeros.
    internal let _scale: Int

    // MARK: - Initialisers

    /// Primary string initialiser — preserves trailing zeros for correct scale.
    ///
    /// Matches `new BigDecimal("1.000")` — scale is 3.
    public init(_ val: String) throws(NumberFormatException) {
      guard let d = Decimal(string: val, locale: Locale(identifier: "en_US_POSIX")) else {
        throw NumberFormatException("Not a valid BigDecimal: \(val)")
      }
      self._value = d
      self._scale = BigDecimal._parseScale(val)
    }

    /// Initialises from a `Foundation.Decimal` with an explicit scale.
    /// Used internally when the scale is already known (e.g. after arithmetic).
    internal init(_ value: Decimal, scale: Int) {
      self._value = value
      self._scale = Swift.max(0, scale)
    }

    /// Convenience: wraps a `Foundation.Decimal`, inferring scale from its
    /// internal representation (no trailing-zero preservation).
    internal init(_ value: Decimal) {
      self._value = value
      // Foundation.Decimal exponent < 0 means digits after decimal point
      let exp = value.exponent
      self._scale = exp < 0 ? -Int(exp) : 0
    }

    /// Initialises from a `Double`.
    ///
    /// - Note: Same caveat as Java: using `Double` loses precision.
    ///   Prefer `valueOf(_:String)`.
    public init(_ val: Double) {
      let d = Decimal(val)
      self._value = d
      let exp = d.exponent
      self._scale = exp < 0 ? -Int(exp) : 0
    }

    /// Initialises from an `Int`.
    public init(_ val: Int) {
      self._value = Decimal(val)
      self._scale = 0
    }

    /// Initialises from an `Int64`.
    public init(_ val: Int64) {
      self._value = Decimal(val)
      self._scale = 0
    }

    /// Default initialiser: zero with scale 0.
    public init() {
      self._value = Decimal.zero
      self._scale = 0
    }

    // MARK: - Scale parsing helper

    /// Extracts the number of decimal places from a numeric string.
    ///
    /// `"1.000"` → 3, `"42"` → 0, `"-0.10"` → 2.
    internal static func _parseScale(_ s: String) -> Int {
      // strip optional sign and whitespace
      var str = s.trimmingCharacters(in: .whitespaces)
      if str.hasPrefix("-") || str.hasPrefix("+") {
        str = String(str.dropFirst())
      }
      // handle engineering / scientific notation: "1.5E+2" → scale = max(0, 1 - 2) = 0
      if let eRange = str.range(of: "E", options: .caseInsensitive) {
        let mantissa = String(str[str.startIndex..<eRange.lowerBound])
        let expPart  = String(str[eRange.upperBound...])
        let mantissaScale = mantissa.contains(".") ? mantissa.distance(
          from: mantissa.index(after: mantissa.firstIndex(of: ".")!),
          to: mantissa.endIndex) : 0
        let exponent = Int(expPart) ?? 0
        return Swift.max(0, mantissaScale - exponent)
      }
      guard let dotIndex = str.firstIndex(of: ".") else { return 0 }
      return str.distance(from: str.index(after: dotIndex), to: str.endIndex)
    }

    // MARK: - CustomStringConvertible

    public var description: String { toString() }
  }
}

// MARK: - Equatable

extension java.math.BigDecimal: Equatable {
  /// Numerical equality — ignores scale, matching Swift convention and Java's `compareTo() == 0`.
  ///
  /// This means `BigDecimal("2.0") == BigDecimal("2.00")` is `true`, consistent with
  /// how `Foundation.Decimal` and Java's `compareTo` work.
  ///
  /// For Java's scale-sensitive `equals()` use the `equals(_:)` method.
  public static func == (lhs: java.math.BigDecimal, rhs: java.math.BigDecimal) -> Bool {
    return lhs._value == rhs._value
  }
}

// MARK: - Comparable

extension java.math.BigDecimal: Comparable {
  public static func < (lhs: java.math.BigDecimal, rhs: java.math.BigDecimal) -> Bool {
    return lhs._value < rhs._value
  }
}

// MARK: - Hashable

extension java.math.BigDecimal: Hashable {
  /// Hash is based on numerical value only (consistent with `==`).
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_value)
  }
}

