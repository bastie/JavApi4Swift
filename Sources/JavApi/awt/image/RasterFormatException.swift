/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Thrown to indicate that the creation of a `Raster` fails due to an
  /// invalid argument — mirrors `java.awt.image.RasterFormatException`.
  ///
  /// - Since: Java 1.2
  open class RasterFormatException: java.lang.RuntimeException, @unchecked Sendable {

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
