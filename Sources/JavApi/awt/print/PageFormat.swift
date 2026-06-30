/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.print {

  /// Describes the size and orientation of a page to be printed —
  /// mirrors `java.awt.print.PageFormat`.
  ///
  /// All measurements are in 1/72nd of an inch (points).
  ///
  /// - Since: Java 1.2
  public final class PageFormat: Cloneable {

    // -------------------------------------------------------------------------
    // MARK: - Orientation constants
    // -------------------------------------------------------------------------

    /// Portrait orientation (default): top of page is at minimum y.
    public static let PORTRAIT:          Int = 0
    /// Landscape orientation: top of page is at maximum x.
    public static let LANDSCAPE:         Int = 1
    /// Reverse-landscape orientation: top of page is at minimum x.
    public static let REVERSE_LANDSCAPE: Int = 2

    // -------------------------------------------------------------------------
    // MARK: - Fields
    // -------------------------------------------------------------------------

    private var _paper:       Paper
    private var _orientation: Int

    /// Creates a `PageFormat` with US Letter paper and portrait orientation.
    public init() {
      _paper       = Paper()
      _orientation = PageFormat.PORTRAIT
    }

    // -------------------------------------------------------------------------
    // MARK: - Paper & orientation
    // -------------------------------------------------------------------------

    public func getPaper() -> Paper { _paper.clone() }

    public func setPaper(_ paper: Paper) { _paper = paper.clone() }

    public func getOrientation() -> Int { _orientation }

    public func setOrientation(_ orientation: Int) { _orientation = orientation }

    // -------------------------------------------------------------------------
    // MARK: - Dimensions (orientation-aware)
    // -------------------------------------------------------------------------

    /// Page width in the current orientation, in points.
    public func getWidth() -> Double {
      switch _orientation {
      case PageFormat.LANDSCAPE, PageFormat.REVERSE_LANDSCAPE:
        return _paper.getHeight()
      default:
        return _paper.getWidth()
      }
    }

    /// Page height in the current orientation, in points.
    public func getHeight() -> Double {
      switch _orientation {
      case PageFormat.LANDSCAPE, PageFormat.REVERSE_LANDSCAPE:
        return _paper.getWidth()
      default:
        return _paper.getHeight()
      }
    }

    /// X coordinate of the imageable area origin, in points.
    public func getImageableX() -> Double {
      switch _orientation {
      case PageFormat.LANDSCAPE:
        return _paper.getImageableY()
      case PageFormat.REVERSE_LANDSCAPE:
        return _paper.getHeight()
             - _paper.getImageableY()
             - _paper.getImageableHeight()
      default:
        return _paper.getImageableX()
      }
    }

    /// Y coordinate of the imageable area origin, in points.
    public func getImageableY() -> Double {
      switch _orientation {
      case PageFormat.LANDSCAPE:
        return _paper.getWidth()
             - _paper.getImageableX()
             - _paper.getImageableWidth()
      case PageFormat.REVERSE_LANDSCAPE:
        return _paper.getImageableX()
      default:
        return _paper.getImageableY()
      }
    }

    /// Width of the imageable area in the current orientation, in points.
    public func getImageableWidth() -> Double {
      switch _orientation {
      case PageFormat.LANDSCAPE, PageFormat.REVERSE_LANDSCAPE:
        return _paper.getImageableHeight()
      default:
        return _paper.getImageableWidth()
      }
    }

    /// Height of the imageable area in the current orientation, in points.
    public func getImageableHeight() -> Double {
      switch _orientation {
      case PageFormat.LANDSCAPE, PageFormat.REVERSE_LANDSCAPE:
        return _paper.getImageableWidth()
      default:
        return _paper.getImageableHeight()
      }
    }

    // -------------------------------------------------------------------------
    // MARK: - Cloneable
    // -------------------------------------------------------------------------

    public func clone() -> PageFormat {
      let copy = PageFormat()
      copy._paper       = _paper.clone()
      copy._orientation = _orientation
      return copy
    }
  }
}
