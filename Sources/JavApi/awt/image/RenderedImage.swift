/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  // ---------------------------------------------------------------------------
  // MARK: - TileObserver
  // ---------------------------------------------------------------------------

  /// Receives notification when a tile of a `WritableRenderedImage` becomes
  /// writable or ceases to be writable —
  /// mirrors `java.awt.image.TileObserver`.
  ///
  /// - Since: Java 1.2
  public protocol TileObserver: AnyObject {

    /// Called when the writability of a tile changes.
    ///
    /// - Parameters:
    ///   - source:   The image whose tile changed.
    ///   - tileX:    Column index of the tile.
    ///   - tileY:    Row index of the tile.
    ///   - willBeWritable: `true` if the tile is becoming writable,
    ///                     `false` if it is reverting to read-only.
    func tileUpdate(_ source: any WritableRenderedImage,
                    _ tileX: Int, _ tileY: Int,
                    _ willBeWritable: Bool)
  }

  // ---------------------------------------------------------------------------
  // MARK: - RenderedImage
  // ---------------------------------------------------------------------------

  /// A common interface for objects that contain or can produce image data in
  /// the form of `Raster`s — mirrors `java.awt.image.RenderedImage`.
  ///
  /// - Since: Java 1.2
  public protocol RenderedImage: AnyObject {

    /// Returns the `ColorModel` associated with this image.
    func getColorModel() -> ColorModel

    /// Returns the `SampleModel` associated with this image.
    func getSampleModel() -> SampleModel

    /// Width of the image in pixels.
    func getWidth() -> Int

    /// Height of the image in pixels.
    func getHeight() -> Int

    /// X coordinate of the left-most column of the image.
    func getMinX() -> Int

    /// Y coordinate of the top-most row of the image.
    func getMinY() -> Int

    // -------------------------------------------------------------------------
    // MARK: Tile layout
    // -------------------------------------------------------------------------

    /// Number of tiles in the X direction.
    func getNumXTiles() -> Int

    /// Number of tiles in the Y direction.
    func getNumYTiles() -> Int

    /// X index of the minimum tile.
    func getMinTileX() -> Int

    /// Y index of the minimum tile.
    func getMinTileY() -> Int

    /// Width of a tile in pixels.
    func getTileWidth() -> Int

    /// Height of a tile in pixels.
    func getTileHeight() -> Int

    /// X offset of the tile grid (origin of tile (0,0)).
    func getTileGridXOffset() -> Int

    /// Y offset of the tile grid (origin of tile (0,0)).
    func getTileGridYOffset() -> Int

    /// Returns the tile at the given tile indices.
    func getTile(_ tileX: Int, _ tileY: Int) -> Raster

    // -------------------------------------------------------------------------
    // MARK: Data access
    // -------------------------------------------------------------------------

    /// Returns the image as one large `Raster`.
    func getData() -> Raster

    /// Returns a copy of an arbitrary rectangular region.
    func getData(_ rect: java.awt.Rectangle) -> Raster

    /// Copies pixel data into `raster` (or creates a compatible one if `nil`).
    func copyData(_ raster: WritableRaster?) -> WritableRaster

    // -------------------------------------------------------------------------
    // MARK: Sources and properties
    // -------------------------------------------------------------------------

    /// Returns the immediate sources of this image (may be empty).
    func getSources() -> [any RenderedImage]

    /// Returns the value of the named property, or `nil` if not defined.
    func getProperty(_ name: String) -> Any?

    /// Returns the names of all recognised properties.
    func getPropertyNames() -> [String]
  }

  // ---------------------------------------------------------------------------
  // MARK: - WritableRenderedImage
  // ---------------------------------------------------------------------------

  /// A `RenderedImage` that can also be written to —
  /// mirrors `java.awt.image.WritableRenderedImage`.
  ///
  /// - Since: Java 1.2
  public protocol WritableRenderedImage: RenderedImage {

    /// Checks out the tile at `(tileX, tileY)` for writing.
    func getWritableTile(_ tileX: Int, _ tileY: Int) -> WritableRaster

    /// Relinquishes the write lock on the tile at `(tileX, tileY)`.
    func releaseWritableTile(_ tileX: Int, _ tileY: Int)

    /// Returns `true` if the tile at `(tileX, tileY)` is currently checked out.
    func isTileWritable(_ tileX: Int, _ tileY: Int) -> Bool

    /// Returns the indices of all currently writable tiles, or `nil` if none.
    func getWritableTileIndices() -> [[Int]]?

    /// Returns `true` if any tile is currently checked out for writing.
    func hasTileWriters() -> Bool

    /// Registers a `TileObserver`.
    func addTileObserver(_ to: any TileObserver)

    /// Removes a previously registered `TileObserver`.
    func removeTileObserver(_ to: any TileObserver)
  }
}

// =============================================================================
// MARK: - Default implementations for RenderedImage
// =============================================================================

extension java.awt.image.RenderedImage {

  // Single-tile images: reasonable defaults
  public func getNumXTiles()      -> Int { 1 }
  public func getNumYTiles()      -> Int { 1 }
  public func getMinTileX()       -> Int { 0 }
  public func getMinTileY()       -> Int { 0 }
  public func getTileWidth()      -> Int { getWidth() }
  public func getTileHeight()     -> Int { getHeight() }
  public func getTileGridXOffset() -> Int { getMinX() }
  public func getTileGridYOffset() -> Int { getMinY() }
  public func getMinX()           -> Int { 0 }
  public func getMinY()           -> Int { 0 }
  public func getSources()        -> [any java.awt.image.RenderedImage] { [] }
  public func getPropertyNames()  -> [String] { [] }
  public func getProperty(_ name: String) -> Any? { nil }

  public func getTile(_ tileX: Int, _ tileY: Int) -> java.awt.image.Raster {
    getData()
  }

  public func getData(_ rect: java.awt.Rectangle) -> java.awt.image.Raster {
    // Return a sub-raster of the full data
    let full = getData()
    return full.createChild(parentX: rect.x, parentY: rect.y,
                            width: rect.width, height: rect.height,
                            childMinX: rect.x, childMinY: rect.y)
  }

  public func copyData(_ raster: java.awt.image.WritableRaster?) -> java.awt.image.WritableRaster {
    let src  = getData()
    let dest = raster ?? src.createCompatibleWritableRaster()
    dest.setRect(src)
    return dest
  }
}
