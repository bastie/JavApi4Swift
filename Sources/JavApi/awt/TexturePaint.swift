/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Fills a shape by tiling a `BufferedImage` across an anchor rectangle —
  /// mirrors `java.awt.TexturePaint`.
  ///
  /// The `anchor` rectangle defines the position and size of one texture
  /// tile in user space; the image is replicated infinitely in both
  /// directions from there, aligned to the anchor's grid.
  ///
  /// Rendering support:
  /// - **CoreGraphics** (Apple): `CGPattern` (tiling draw callback);
  ///   built from `BufferedImage.toCGImage()`.
  /// - **GDI** (Windows): `CreatePatternBrush(HBITMAP)` — native classic-GDI
  ///   tiling brush.
  /// - **X11** (Linux/FreeBSD): `XSetFillStyle(FillTiled)` + `XSetTile` with
  ///   a `Pixmap` — native core-Xlib tiling, no extension library required.
  ///
  /// - Since: Java 1.2
  public final class TexturePaint: Paint {

    private let image:  java.awt.image.BufferedImage
    private let anchor:  java.awt.geom.Rectangle2D

    /// Creates a texture paint.
    ///
    /// - Parameters:
    ///   - image:  The image to tile.
    ///   - anchor: Position and size (in user space) of a single tile.
    public init(_ image: java.awt.image.BufferedImage,
                _ anchor: java.awt.geom.Rectangle2D) {
      self.image  = image
      self.anchor = anchor
    }

    /// The image being tiled.
    public func getImage() -> java.awt.image.BufferedImage { image }

    /// The anchor rectangle (position + size of one tile, in user space).
    public func getAnchorRect() -> java.awt.geom.Rectangle2D { anchor }

    /// Returns the image's transparency.
    ///
    /// - Note: `java.awt.image.ColorModel` in this port does not expose a
    ///   transparency mode (no per-model alpha-support flag), so this
    ///   conservatively reports `TRANSLUCENT` rather than scanning every
    ///   pixel's alpha channel. Callers that need an exact opaque/translucent
    ///   distinction should inspect `getImage()` directly.
    public func getTransparency() -> Int {
      java.awt.Color.TRANSLUCENT
    }
  }
}
