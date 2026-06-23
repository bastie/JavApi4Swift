/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Implements the Porter-Duff compositing rules with an optional alpha value.
  ///
  /// Mirrors `java.awt.AlphaComposite`.
  ///
  /// ```swift
  /// let ac = java.awt.AlphaComposite.getInstance(java.awt.AlphaComposite.SRC_OVER, 0.5)
  /// ```
  ///
  /// - Since: Java 1.2
  public final class AlphaComposite: java.awt.Composite, java.awt.Transparency {

    // =========================================================================
    // MARK: - Rule constants
    // =========================================================================

    /// Clears the destination.
    public static let CLEAR    = 1
    /// Copies source over destination (α-blending).
    public static let SRC      = 2
    /// Keeps destination as-is.
    public static let DST      = 9
    /// Source over destination (default blending).
    public static let SRC_OVER = 3
    /// Destination over source.
    public static let DST_OVER = 4
    /// Source inside destination.
    public static let SRC_IN   = 5
    /// Destination inside source.
    public static let DST_IN   = 6
    /// Source outside destination.
    public static let SRC_OUT  = 7
    /// Destination outside source.
    public static let DST_OUT  = 8
    /// Source atop destination.
    public static let SRC_ATOP = 10
    /// Destination atop source.
    public static let DST_ATOP = 11
    /// Exclusive-or of source and destination.
    public static let XOR      = 12

    // =========================================================================
    // MARK: - Singleton instances (alpha = 1.0)
    // =========================================================================

    nonisolated(unsafe) public static let Clear   = AlphaComposite(CLEAR)
    nonisolated(unsafe) public static let Src     = AlphaComposite(SRC)
    nonisolated(unsafe) public static let Dst     = AlphaComposite(DST)
    nonisolated(unsafe) public static let SrcOver = AlphaComposite(SRC_OVER)
    nonisolated(unsafe) public static let DstOver = AlphaComposite(DST_OVER)
    nonisolated(unsafe) public static let SrcIn   = AlphaComposite(SRC_IN)
    nonisolated(unsafe) public static let DstIn   = AlphaComposite(DST_IN)
    nonisolated(unsafe) public static let SrcOut  = AlphaComposite(SRC_OUT)
    nonisolated(unsafe) public static let DstOut  = AlphaComposite(DST_OUT)
    nonisolated(unsafe) public static let SrcAtop = AlphaComposite(SRC_ATOP)
    nonisolated(unsafe) public static let DstAtop = AlphaComposite(DST_ATOP)
    nonisolated(unsafe) public static let Xor     = AlphaComposite(XOR)

    // =========================================================================
    // MARK: - Properties
    // =========================================================================

    /// The Porter-Duff compositing rule (one of the `*` constants).
    public let rule: Int

    /// The constant alpha value (0.0–1.0). Default is `1.0`.
    public let alpha: Float

    // =========================================================================
    // MARK: - Factory
    // =========================================================================

    /// Returns an `AlphaComposite` with the given rule and alpha = 1.0.
    public static func getInstance(_ rule: Int) -> AlphaComposite {
      AlphaComposite(rule)
    }

    /// Returns an `AlphaComposite` with the given rule and alpha.
    public static func getInstance(_ rule: Int, _ alpha: Float) -> AlphaComposite {
      AlphaComposite(rule, alpha)
    }

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    private init(_ rule: Int, _ alpha: Float = 1.0) {
      self.rule = rule
      self.alpha = Swift.max(0, Swift.min(1, alpha))
    }

    // =========================================================================
    // MARK: - Transparency
    // =========================================================================

    public func getTransparency() -> Int {
      switch rule {
      case AlphaComposite.SRC_OVER, AlphaComposite.DST_OVER,
           AlphaComposite.SRC_IN, AlphaComposite.DST_IN,
           AlphaComposite.SRC_ATOP, AlphaComposite.DST_ATOP:
        return alpha == 1.0
          ? java.awt.Color.OPAQUE
          : java.awt.Color.TRANSLUCENT
      default:
        return java.awt.Color.TRANSLUCENT
      }
    }

    // =========================================================================
    // MARK: - Derived composite
    // =========================================================================

    /// Returns a new `AlphaComposite` with the same rule but different alpha.
    public func derive(_ alpha: Float) -> AlphaComposite {
      AlphaComposite(rule, alpha)
    }
  }
}
