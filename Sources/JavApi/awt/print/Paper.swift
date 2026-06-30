/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.print {

  /// Describes the physical characteristics of a piece of paper —
  /// mirrors `java.awt.print.Paper`.
  ///
  /// All measurements are in 1/72nd of an inch (points).
  /// The default size is US Letter (8.5 × 11 inches = 612 × 792 points).
  /// The default imageable area has a 1-inch margin on every side.
  ///
  /// - Since: Java 1.2
  public final class Paper: Cloneable {

    // US Letter in points (1 pt = 1/72 inch)
    private static let DEFAULT_WIDTH:  Double = 612.0   // 8.5"
    private static let DEFAULT_HEIGHT: Double = 792.0   // 11"
    private static let DEFAULT_MARGIN: Double = 72.0    // 1"

    private var _width:           Double
    private var _height:          Double
    private var _imageableX:      Double
    private var _imageableY:      Double
    private var _imageableWidth:  Double
    private var _imageableHeight: Double

    /// Creates a `Paper` with US Letter size and 1-inch margins.
    public init() {
      _width          = Paper.DEFAULT_WIDTH
      _height         = Paper.DEFAULT_HEIGHT
      _imageableX     = Paper.DEFAULT_MARGIN
      _imageableY     = Paper.DEFAULT_MARGIN
      _imageableWidth  = Paper.DEFAULT_WIDTH  - 2 * Paper.DEFAULT_MARGIN
      _imageableHeight = Paper.DEFAULT_HEIGHT - 2 * Paper.DEFAULT_MARGIN
    }

    // -------------------------------------------------------------------------
    // MARK: - Dimensions
    // -------------------------------------------------------------------------

    /// Total physical width of the paper in points.
    public func getWidth() -> Double { _width }

    /// Total physical height of the paper in points.
    public func getHeight() -> Double { _height }

    /// Sets the physical dimensions of the paper.
    ///
    /// - Parameters:
    ///   - width:  Paper width in points.
    ///   - height: Paper height in points.
    public func setSize(_ width: Double, _ height: Double) {
      _width  = width
      _height = height
    }

    // -------------------------------------------------------------------------
    // MARK: - Imageable area
    // -------------------------------------------------------------------------

    /// X coordinate of the top-left corner of the imageable area, in points.
    public func getImageableX() -> Double { _imageableX }

    /// Y coordinate of the top-left corner of the imageable area, in points.
    public func getImageableY() -> Double { _imageableY }

    /// Width of the imageable area in points.
    public func getImageableWidth() -> Double { _imageableWidth }

    /// Height of the imageable area in points.
    public func getImageableHeight() -> Double { _imageableHeight }

    /// Sets the imageable area.
    ///
    /// - Parameters:
    ///   - x:      Left edge of printable area in points.
    ///   - y:      Top edge of printable area in points.
    ///   - width:  Width of printable area in points.
    ///   - height: Height of printable area in points.
    public func setImageableArea(_ x: Double, _ y: Double,
                                 _ width: Double, _ height: Double) {
      _imageableX      = x
      _imageableY      = y
      _imageableWidth  = width
      _imageableHeight = height
    }

    // -------------------------------------------------------------------------
    // MARK: - Cloneable
    // -------------------------------------------------------------------------

    public func clone() -> Paper {
      let copy = Paper()
      copy._width          = _width
      copy._height         = _height
      copy._imageableX     = _imageableX
      copy._imageableY     = _imageableY
      copy._imageableWidth  = _imageableWidth
      copy._imageableHeight = _imageableHeight
      return copy
    }
  }
}
