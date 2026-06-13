/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreText)
import CoreText // module-level import inside conditional compilation
#endif

extension java.awt.font {

  // ---------------------------------------------------------------------------
  // MARK: - LineMetrics
  // ---------------------------------------------------------------------------

  /// Provides access to per-line font metrics for a specific string.
  ///
  /// Mirrors `java.awt.font.LineMetrics`. Obtain an instance via
  /// `Font.getLineMetrics(_:frc:)`.
  ///
  /// All values are in user-space units (typically points / logical pixels).
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  open class LineMetrics {

    // =========================================================================
    // MARK: - Abstract accessors (subclasses must override)
    // =========================================================================

    /// Number of characters in the string for which metrics were computed.
    open func getNumChars() -> Int { fatalError("abstract") }

    // -------------------------------------------------------------------------
    // Vertical metrics
    // -------------------------------------------------------------------------

    /// Distance from the baseline to the top of the tallest glyph (positive).
    open func getAscent()   -> Swift.Float { fatalError("abstract") }

    /// Distance from the baseline downward to the lowest descender (positive).
    open func getDescent()  -> Swift.Float { fatalError("abstract") }

    /// Recommended extra whitespace between lines.
    open func getLeading()  -> Swift.Float { fatalError("abstract") }

    /// Total line height = ascent + descent + leading.
    public final func getHeight() -> Swift.Float {
      getAscent() + getDescent() + getLeading()
    }

    // -------------------------------------------------------------------------
    // Baseline
    // -------------------------------------------------------------------------

    /// Index of the dominant baseline (0 = ROMAN, 1 = CENTER, 2 = HANGING).
    open func getBaselineIndex() -> Int { 0 }

    /// Offsets from the dominant baseline to each of the three standard baselines.
    open func getBaselineOffsets() -> [Swift.Float] { [0, 0, 0] }

    // -------------------------------------------------------------------------
    // Strikethrough
    // -------------------------------------------------------------------------

    /// Offset from baseline to centre of strikethrough (negative = above baseline).
    open func getStrikethroughOffset()    -> Swift.Float { fatalError("abstract") }

    /// Thickness of the strikethrough stroke.
    open func getStrikethroughThickness() -> Swift.Float { fatalError("abstract") }

    // -------------------------------------------------------------------------
    // Underline
    // -------------------------------------------------------------------------

    /// Offset from baseline to centre of underline (positive = below baseline).
    open func getUnderlineOffset()    -> Swift.Float { fatalError("abstract") }

    /// Thickness of the underline stroke.
    open func getUnderlineThickness() -> Swift.Float { fatalError("abstract") }
  }

  // ---------------------------------------------------------------------------
  // MARK: - DefaultLineMetrics (concrete implementation)
  // ---------------------------------------------------------------------------

  /// Concrete `LineMetrics` returned by `Font.getLineMetrics`.
  ///
  /// On Apple platforms values come from CoreText; on other platforms a
  /// proportional approximation based on the font size is used.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public final class DefaultLineMetrics: LineMetrics {

    private let _numChars:              Int
    private let _ascent:                Swift.Float
    private let _descent:               Swift.Float
    private let _leading:               Swift.Float
    private let _strikethroughOffset:   Swift.Float
    private let _strikethroughThickness: Swift.Float
    private let _underlineOffset:       Swift.Float
    private let _underlineThickness:    Swift.Float

    public init(numChars:              Int,
                ascent:                Swift.Float,
                descent:               Swift.Float,
                leading:               Swift.Float,
                strikethroughOffset:   Swift.Float,
                strikethroughThickness: Swift.Float,
                underlineOffset:       Swift.Float,
                underlineThickness:    Swift.Float) {
      _numChars               = numChars
      _ascent                 = ascent
      _descent                = descent
      _leading                = leading
      _strikethroughOffset    = strikethroughOffset
      _strikethroughThickness = strikethroughThickness
      _underlineOffset        = underlineOffset
      _underlineThickness     = underlineThickness
    }

    public override func getNumChars()               -> Int          { _numChars }
    public override func getAscent()                 -> Swift.Float  { _ascent }
    public override func getDescent()                -> Swift.Float  { _descent }
    public override func getLeading()                -> Swift.Float  { _leading }
    public override func getStrikethroughOffset()    -> Swift.Float  { _strikethroughOffset }
    public override func getStrikethroughThickness() -> Swift.Float  { _strikethroughThickness }
    public override func getUnderlineOffset()        -> Swift.Float  { _underlineOffset }
    public override func getUnderlineThickness()     -> Swift.Float  { _underlineThickness }

    // =========================================================================
    // MARK: - Factory
    // =========================================================================

    /// Creates a `DefaultLineMetrics` for the given font and string length.
    ///
    /// On Apple platforms CoreText is used for precise values; elsewhere a
    /// proportional fallback based on `font.size` is applied.
    public static func make(for font: java.awt.Font,
                            numChars: Int) -> DefaultLineMetrics {
#if canImport(CoreText)
      return makeCoreText(font: font, numChars: numChars)
#else
      return makeProportional(font: font, numChars: numChars)
#endif
    }

    // -------------------------------------------------------------------------
    // CoreText-backed factory (Apple platforms)
    // -------------------------------------------------------------------------

#if canImport(CoreText)

    private static func makeCoreText(font: java.awt.Font,
                                     numChars: Int) -> DefaultLineMetrics {
      let ctFont = CTFontCreateWithName(font.platformName as CFString,
                                       CGFloat(font.size), nil)
      let ascent  = Swift.Float(CTFontGetAscent(ctFont))
      let descent = Swift.Float(CTFontGetDescent(ctFont))
      let leading = Swift.Float(CTFontGetLeading(ctFont))
      let sz      = Swift.Float(font.size)
      return DefaultLineMetrics(
        numChars:               numChars,
        ascent:                 ascent,
        descent:                descent,
        leading:                leading,
        strikethroughOffset:    -(ascent * 0.35),
        strikethroughThickness: Swift.max(1, sz * 0.05),
        underlineOffset:        Swift.Float(CTFontGetUnderlinePosition(ctFont)),
        underlineThickness:     Swift.Float(CTFontGetUnderlineThickness(ctFont)))
    }
#endif

    // -------------------------------------------------------------------------
    // Proportional fallback (Linux / Windows / headless)
    // -------------------------------------------------------------------------

    private static func makeProportional(font: java.awt.Font,
                                         numChars: Int) -> DefaultLineMetrics {
      let sz      = Swift.Float(font.size)
      let ascent  = sz * 0.75
      let descent = sz * 0.20
      let leading = sz * 0.10
      return DefaultLineMetrics(
        numChars:               numChars,
        ascent:                 ascent,
        descent:                descent,
        leading:                leading,
        strikethroughOffset:    -(ascent * 0.35),
        strikethroughThickness: Swift.max(1, sz * 0.05),
        underlineOffset:        descent * 0.5,
        underlineThickness:     Swift.max(1, sz * 0.05))
    }
  }
}
