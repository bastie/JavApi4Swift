/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */

extension java.math {

  /// Immutable object that encapsulates precision and rounding mode settings,
  /// mirroring `java.math.MathContext`.
  /// `Sendable` is safe because all stored properties (`Int` and `RoundingMode`) are `Sendable`.
  public final class MathContext : Equatable, Hashable, CustomStringConvertible, Sendable {

    // MARK: - Predefined contexts

    /// Unlimited precision, no rounding.
    public static let UNLIMITED  = MathContext(0, .HALF_UP)
    /// IEEE 754R Decimal32 format: 7 digits, HALF_EVEN.
    public static let DECIMAL32  = MathContext(7, .HALF_EVEN)
    /// IEEE 754R Decimal64 format: 16 digits, HALF_EVEN.
    public static let DECIMAL64  = MathContext(16, .HALF_EVEN)
    /// IEEE 754R Decimal128 format: 34 digits, HALF_EVEN.
    public static let DECIMAL128 = MathContext(34, .HALF_EVEN)

    // MARK: - Properties

    /// Number of significant digits (0 = unlimited).
    public let precision: Int
    /// Rounding algorithm.
    public let roundingMode: RoundingMode

    // MARK: - Initialisers

    /// Creates a `MathContext` with the given precision and `HALF_UP` rounding.
    public init(_ precision: Int) {
      precondition(precision >= 0, "precision must be >= 0")
      self.precision = precision
      self.roundingMode = .HALF_UP
    }

    /// Creates a `MathContext` with the given precision and rounding mode.
    public init(_ precision: Int, _ roundingMode: RoundingMode) {
      precondition(precision >= 0, "precision must be >= 0")
      self.precision = precision
      self.roundingMode = roundingMode
    }

    /// Parses a `MathContext` from its string representation,
    /// e.g. `"precision=7 roundingMode=HALF_EVEN"`.
    public init(_ val: String) throws(NumberFormatException) {
      let parts = val.split(separator: " ")
      guard parts.count == 2 else { throw NumberFormatException("Invalid MathContext string: \(val)") }
      guard let precPart = parts.first(where: { $0.hasPrefix("precision=") }),
            let modePart = parts.first(where: { $0.hasPrefix("roundingMode=") })
      else { throw NumberFormatException("Invalid MathContext string: \(val)") }

      guard let p = Int(precPart.dropFirst("precision=".count)), p >= 0
      else { throw NumberFormatException("Invalid precision in MathContext: \(val)") }

      let modeStr = String(modePart.dropFirst("roundingMode=".count))
      guard let mode = RoundingMode.allCases.first(where: { $0.description == modeStr })
      else { throw NumberFormatException("Invalid roundingMode in MathContext: \(modeStr)") }

      self.precision = p
      self.roundingMode = mode
    }

    // MARK: - Protocol conformances

    public var description: String {
      "precision=\(precision) roundingMode=\(roundingMode)"
    }

    public static func == (lhs: MathContext, rhs: MathContext) -> Bool {
      lhs.precision == rhs.precision && lhs.roundingMode == rhs.roundingMode
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(precision)
      hasher.combine(roundingMode)
    }

    // MARK: - Java API

    public func equals(_ other: AnyObject) -> Bool {
      guard let other = other as? MathContext else { return false }
      return self == other
    }

    public func hashCode() -> Int {
      var hasher = Hasher()
      hash(into: &hasher)
      return hasher.finalize()
    }

    public func toString() -> String { description }
  }
}
