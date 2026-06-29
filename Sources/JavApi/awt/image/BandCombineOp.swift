/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Performs an arbitrary linear combination of the bands of a `Raster` using
  /// a matrix — mirrors `java.awt.image.BandCombineOp`.
  ///
  /// For each output band `b`:
  ///   `dst[b] = matrix[b][0]*src[0] + matrix[b][1]*src[1] + … + [optional bias matrix[b][numSrcBands]]`
  ///
  /// The matrix must be `numDstBands × numSrcBands` or `numDstBands × (numSrcBands + 1)`
  /// (the extra column is added as a constant bias).
  ///
  /// Only operates on `Raster` (no packed-pixel `BufferedImage` variant),
  /// matching the Java API.
  ///
  /// - Since: Java 1.2
  public final class BandCombineOp: RasterOp, @unchecked Sendable {

    private let matrix: [[Float]]
    private let hints:  java.awt.RenderingHints?

    public init(_ matrix: [[Float]], _ hints: java.awt.RenderingHints? = nil) {
      self.matrix = matrix
      self.hints  = hints
    }

    public func getMatrix() -> [[Float]] { matrix }
    public func getRenderingHints() -> java.awt.RenderingHints? { hints }

    // -------------------------------------------------------------------------
    // MARK: RasterOp
    // -------------------------------------------------------------------------

    public func filter(_ src: Raster, _ dst: WritableRaster?) throws -> WritableRaster {
      let numSrc = src.getNumBands()
      let numDst = matrix.count
      let dest   = dst ?? createCompatibleDestRaster(src)

      for y in 0 ..< src.height {
        for x in 0 ..< src.width {
          let px = x + src.minX, py = y + src.minY
          let samples = src.getPixel(px, py, nil)
          var out = [Int](repeating: 0, count: numDst)
          for b in 0 ..< numDst {
            var v: Float = 0
            let row = matrix[b]
            for s in 0 ..< numSrc {
              if s < row.count { v += row[s] * Float(samples[s]) }
            }
            // Optional bias (last column)
            if row.count > numSrc { v += row[numSrc] }
            out[b] = Int(max(0, min(255, v)))
          }
          dest.setPixel(x + dest.minX, y + dest.minY, out)
        }
      }
      return dest
    }

    public func createCompatibleDestRaster(_ src: Raster) -> WritableRaster {
      // Destination has as many bands as matrix rows
      let numDst = matrix.count
      if numDst == src.getNumBands() {
        return src.createCompatibleWritableRaster()
      }
      let sm = BandedSampleModel(
        dataType: src.sampleModel.dataType,
        width: src.width, height: src.height,
        numBands: numDst)
      let db = sm.createDataBuffer()
      return WritableRaster(sampleModel: sm, dataBuffer: db,
                            minX: src.minX, minY: src.minY)
    }
  }
}
