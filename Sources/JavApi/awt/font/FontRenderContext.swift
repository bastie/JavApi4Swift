/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.font {

  // ---------------------------------------------------------------------------
  // MARK: - FontRenderContext
  // ---------------------------------------------------------------------------

  /// Encapsulates the information needed to correctly measure text.
  ///
  /// Mirrors `java.awt.font.FontRenderContext`. An instance is obtained from
  /// `Graphics2D.getFontRenderContext()` and passed to font-measurement APIs
  /// such as `Font.getLineMetrics` and `TextLayout`.
  ///
  /// Two hints control rendering quality:
  /// - **antiAliasing** — whether glyph edges are smoothed.
  /// - **fractionalMetrics** — whether advance widths use sub-pixel precision.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class FontRenderContext {

    // =========================================================================
    // MARK: - Hint constants (mirrors java.awt.RenderingHints keys/values)
    // =========================================================================

    /// Antialiasing is off (default / device-pixel rendering).
    public static let AA_OFF      = 0
    /// Antialiasing is on.
    public static let AA_ON       = 1
    /// Antialiasing mode is not specified / default.
    public static let AA_DEFAULT  = 2

    /// Fractional metrics are off (advance widths rounded to integer pixels).
    public static let FM_OFF      = 0
    /// Fractional metrics are on (sub-pixel advance widths).
    public static let FM_ON       = 1
    /// Fractional metrics mode is not specified / default.
    public static let FM_DEFAULT  = 2

    // =========================================================================
    // MARK: - Stored state
    // =========================================================================

    private let _aaHint: Int
    private let _fmHint: Int

    // =========================================================================
    // MARK: - Initialisers
    // =========================================================================

    /// Creates a `FontRenderContext` with explicit hints.
    ///
    /// - Parameters:
    ///   - antiAliasing: One of `AA_OFF`, `AA_ON`, `AA_DEFAULT`.
    ///   - fractionalMetrics: One of `FM_OFF`, `FM_ON`, `FM_DEFAULT`.
    public init(antiAliasing: Int = AA_DEFAULT, fractionalMetrics: Int = FM_DEFAULT) {
      _aaHint = antiAliasing
      _fmHint = fractionalMetrics
    }

    /// Convenience: creates a default `FontRenderContext` (AA and FM unset).
    public convenience init() {
      self.init(antiAliasing: FontRenderContext.AA_DEFAULT,
                fractionalMetrics: FontRenderContext.FM_DEFAULT)
    }

    // =========================================================================
    // MARK: - Accessors
    // =========================================================================

    /// Returns `true` if antialiasing is enabled (not off and not default).
    public func isAntiAliased() -> Bool { _aaHint == FontRenderContext.AA_ON }

    /// Returns `true` if fractional metrics are enabled.
    public func usesFractionalMetrics() -> Bool { _fmHint == FontRenderContext.FM_ON }

    /// Returns the antialiasing hint value.
    public func getAntiAliasingHint() -> Int { _aaHint }

    /// Returns the fractional-metrics hint value.
    public func getFractionalMetricsHint() -> Int { _fmHint }

    // =========================================================================
    // MARK: - Equality
    // =========================================================================

    public func equals(_ other: FontRenderContext) -> Bool {
      _aaHint == other._aaHint && _fmHint == other._fmHint
    }
  }
}
