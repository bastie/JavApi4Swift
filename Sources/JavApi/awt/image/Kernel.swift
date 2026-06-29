/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// A matrix of floating-point values used by `ConvolveOp` —
  /// mirrors `java.awt.image.Kernel`.
  ///
  /// The kernel is `width × height` floats stored in row-major order.
  /// The origin (hot-spot) is at `(xOrigin, yOrigin)`, which defaults to
  /// the geometric centre `((width-1)/2, (height-1)/2)`.
  ///
  /// - Since: Java 1.2
  public final class Kernel: @unchecked Sendable {

    public let width:   Int
    public let height:  Int
    public let xOrigin: Int
    public let yOrigin: Int

    private let data: [Float]

    // -------------------------------------------------------------------------
    // MARK: Java getter methods
    // -------------------------------------------------------------------------

    public func getWidth()   -> Int { width }
    public func getHeight()  -> Int { height }
    public func getXOrigin() -> Int { xOrigin }
    public func getYOrigin() -> Int { yOrigin }

    /// Creates a kernel from a flat row-major float array.
    ///
    /// - Parameters:
    ///   - width:  Number of columns.
    ///   - height: Number of rows.
    ///   - data:   Coefficients in row-major order (`width * height` elements).
    public init(_ width: Int, _ height: Int, _ data: [Float]) {
      self.width   = width
      self.height  = height
      self.xOrigin = (width  - 1) / 2
      self.yOrigin = (height - 1) / 2
      self.data    = Array(data.prefix(width * height))
    }

    /// Returns a copy of the kernel data.
    public func getKernelData(_ data: inout [Float]) -> [Float] {
      self.data
    }

    /// Returns the coefficient at column `x`, row `y`.
    public func getElement(_ x: Int, _ y: Int) -> Float {
      guard x >= 0, x < width, y >= 0, y < height else { return 0 }
      return data[y * width + x]
    }
  }
}
