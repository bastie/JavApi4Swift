/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Thrown if one of the `BufferedImageOp` or `RasterOp` filter methods
  /// cannot process the image — mirrors `java.awt.image.ImagingOpException`.
  ///
  /// - Since: Java 1.2
  open class ImagingOpException: java.lang.RuntimeException, @unchecked Sendable {

    public override init() {
      super.init()
    }

    public override init(_ message: String) {
      super.init(message)
    }

    public override init(_ message: String, _ cause: Throwable) {
      super.init(message, cause)
    }

    public override init(_ cause: Throwable) {
      super.init(cause)
    }
  }
}
