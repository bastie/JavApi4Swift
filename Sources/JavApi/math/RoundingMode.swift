/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.math {

  /// Specifies a rounding policy for numerical operations, mirroring `java.math.RoundingMode`.
  public enum RoundingMode : Int, CaseIterable, CustomStringConvertible, Sendable {

    /// Round towards positive infinity.
    case UP = 0
    /// Round towards zero.
    case DOWN = 1
    /// Round towards positive infinity (ceiling).
    case CEILING = 2
    /// Round towards negative infinity (floor).
    case FLOOR = 3
    /// Round towards "nearest neighbor"; ties go up.
    case HALF_UP = 4
    /// Round towards "nearest neighbor"; ties go down.
    case HALF_DOWN = 5
    /// Round towards "nearest neighbor"; ties go to even neighbor (banker's rounding).
    case HALF_EVEN = 6
    /// No rounding — throws if result is not exact.
    case UNNECESSARY = 7

    public var description: String {
      switch self {
      case .UP:          return "UP"
      case .DOWN:        return "DOWN"
      case .CEILING:     return "CEILING"
      case .FLOOR:       return "FLOOR"
      case .HALF_UP:     return "HALF_UP"
      case .HALF_DOWN:   return "HALF_DOWN"
      case .HALF_EVEN:   return "HALF_EVEN"
      case .UNNECESSARY: return "UNNECESSARY"
      }
    }

    /// Converts to the corresponding `NSDecimalNumber.RoundingMode`.
    public var nsRoundingMode: NSDecimalNumber.RoundingMode {
      switch self {
      case .UP:          return .up
      case .DOWN:        return .down
      case .CEILING:     return .up      // ceiling = up for positive numbers
      case .FLOOR:       return .down    // floor = down for positive numbers
      case .HALF_UP:     return .plain
      case .HALF_DOWN:   return .down
      case .HALF_EVEN:   return .bankers
      case .UNNECESSARY: return .plain   // caller must verify exactness separately
      }
    }
  }
}
