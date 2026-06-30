/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// A `ComponentSampleModel` where all bands are stored in a single bank with
  /// pixel samples interleaved (R,G,B,A,R,G,B,A,…) —
  /// mirrors `java.awt.image.PixelInterleavedSampleModel`.
  ///
  /// - Since: Java 1.2
  public final class PixelInterleavedSampleModel: ComponentSampleModel {

    public override init(dataType: Int, width: Int, height: Int,
                pixelStride: Int, scanlineStride: Int,
                bandOffsets: [Int]) {
      super.init(dataType: dataType, width: width, height: height,
                 pixelStride: pixelStride, scanlineStride: scanlineStride,
                 bandOffsets: bandOffsets)
    }
  }
}
