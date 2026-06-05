/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - AffineTransform
  // ---------------------------------------------------------------------------

  /// A 2D affine transformation matrix.
  ///
  /// Mirrors `java.awt.geom.AffineTransform`. The transform is stored as a
  /// 3×3 matrix with an implicit last row of `[0, 0, 1]`:
  ///
  /// ```
  /// [ m00  m01  m02 ]   [ scaleX  shearX  translateX ]
  /// [ m10  m11  m12 ] = [ shearY  scaleY  translateY ]
  /// [  0    0    1  ]
  /// ```
  ///
  /// Point transformation: `x' = m00·x + m01·y + m02`, `y' = m10·x + m11·y + m12`
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class AffineTransform {

    // =========================================================================
    // MARK: - Type constants
    // =========================================================================

    public static let TYPE_IDENTITY          = 0
    public static let TYPE_TRANSLATION       = 1
    public static let TYPE_UNIFORM_SCALE     = 2
    public static let TYPE_GENERAL_SCALE     = 4
    public static let TYPE_MASK_SCALE        = 6
    public static let TYPE_FLIP              = 64
    public static let TYPE_QUADRANT_ROTATION = 8
    public static let TYPE_GENERAL_ROTATION  = 16
    public static let TYPE_MASK_ROTATION     = 24
    public static let TYPE_GENERAL_TRANSFORM = 32

    // =========================================================================
    // MARK: - Matrix elements (internal so CG bridge can read them)
    // =========================================================================

    var m00: Double   // scaleX
    var m10: Double   // shearY
    var m01: Double   // shearX
    var m11: Double   // scaleY
    var m02: Double   // translateX
    var m12: Double   // translateY

    // =========================================================================
    // MARK: - Constructors
    // =========================================================================

    /// Creates the identity transform.
    public init() {
      m00 = 1; m10 = 0; m01 = 0; m11 = 1; m02 = 0; m12 = 0
    }

    /// Creates a transform with the given matrix elements.
    public init(_ m00: Double, _ m10: Double,
                _ m01: Double, _ m11: Double,
                _ m02: Double, _ m12: Double) {
      self.m00 = m00; self.m10 = m10
      self.m01 = m01; self.m11 = m11
      self.m02 = m02; self.m12 = m12
    }

    /// Creates a transform from a flat array `[m00, m10, m01, m11]` (4 elements)
    /// or `[m00, m10, m01, m11, m02, m12]` (6 elements).
    public convenience init(_ flatMatrix: [Double]) {
      if flatMatrix.count >= 6 {
        self.init(flatMatrix[0], flatMatrix[1], flatMatrix[2],
                  flatMatrix[3], flatMatrix[4], flatMatrix[5])
      } else {
        self.init(flatMatrix[0], flatMatrix[1],
                  flatMatrix[2], flatMatrix[3], 0, 0)
      }
    }

    /// Copy constructor.
    public convenience init(_ tx: AffineTransform) {
      self.init(tx.m00, tx.m10, tx.m01, tx.m11, tx.m02, tx.m12)
    }

    // =========================================================================
    // MARK: - Static factory methods
    // =========================================================================

    /// Returns a translation transform.
    public static func getTranslateInstance(_ tx: Double,
                                             _ ty: Double) -> AffineTransform {
      AffineTransform(1, 0, 0, 1, tx, ty)
    }

    /// Returns a scaling transform.
    public static func getScaleInstance(_ sx: Double,
                                         _ sy: Double) -> AffineTransform {
      AffineTransform(sx, 0, 0, sy, 0, 0)
    }

    /// Returns a rotation transform (counter-clockwise for positive theta).
    public static func getRotateInstance(_ theta: Double) -> AffineTransform {
      let c = cos(theta), s = sin(theta)
      return AffineTransform(c, s, -s, c, 0, 0)
    }

    /// Returns a rotation around an anchor point.
    public static func getRotateInstance(_ theta: Double,
                                          _ anchorX: Double,
                                          _ anchorY: Double) -> AffineTransform {
      let at = getRotateInstance(theta)
      at.m02 = anchorX - at.m00 * anchorX - at.m01 * anchorY
      at.m12 = anchorY - at.m10 * anchorX - at.m11 * anchorY
      return at
    }

    /// Returns a shearing transform.
    public static func getShearInstance(_ shx: Double,
                                         _ shy: Double) -> AffineTransform {
      AffineTransform(1, shy, shx, 1, 0, 0)
    }

    // =========================================================================
    // MARK: - Accessors
    // =========================================================================

    public func getScaleX()     -> Double { m00 }
    public func getShearY()     -> Double { m10 }
    public func getShearX()     -> Double { m01 }
    public func getScaleY()     -> Double { m11 }
    public func getTranslateX() -> Double { m02 }
    public func getTranslateY() -> Double { m12 }

    /// Returns `true` if this is the identity transform.
    public func isIdentity() -> Bool {
      m00 == 1 && m11 == 1 && m01 == 0 && m10 == 0 && m02 == 0 && m12 == 0
    }

    /// Returns the determinant of the linear (non-translation) part.
    public func getDeterminant() -> Double { m00 * m11 - m01 * m10 }

    /// Returns a bitmask of `TYPE_*` constants describing this transform.
    public func getType() -> Int {
      let hasT = m02 != 0 || m12 != 0
      let tBit = hasT ? AffineTransform.TYPE_TRANSLATION : 0
      if m01 == 0 && m10 == 0 {
        if m00 == 1 && m11 == 1 {
          return hasT ? AffineTransform.TYPE_TRANSLATION : AffineTransform.TYPE_IDENTITY
        }
        return (m00 == m11
          ? AffineTransform.TYPE_UNIFORM_SCALE
          : AffineTransform.TYPE_GENERAL_SCALE) | tBit
      }
      // Rotation: m00==m11, m01==-m10, |det|==1
      if m00 == m11 && m01 == -m10 && abs(abs(getDeterminant()) - 1) < 1e-10 {
        return AffineTransform.TYPE_GENERAL_ROTATION | tBit
      }
      return AffineTransform.TYPE_GENERAL_TRANSFORM
    }

    /// Fills `flatMatrix` with `[m00, m10, m01, m11]` (4 elements) or
    /// `[m00, m10, m01, m11, m02, m12]` (6 elements).
    public func getMatrix(_ flatMatrix: inout [Double]) {
      flatMatrix[0] = m00; flatMatrix[1] = m10
      flatMatrix[2] = m01; flatMatrix[3] = m11
      if flatMatrix.count > 4 {
        flatMatrix[4] = m02; flatMatrix[5] = m12
      }
    }

    // =========================================================================
    // MARK: - setTo… (replace this transform in place)
    // =========================================================================

    public func setToIdentity() {
      m00 = 1; m10 = 0; m01 = 0; m11 = 1; m02 = 0; m12 = 0
    }

    public func setToTranslation(_ tx: Double, _ ty: Double) {
      m00 = 1; m10 = 0; m01 = 0; m11 = 1; m02 = tx; m12 = ty
    }

    public func setToScale(_ sx: Double, _ sy: Double) {
      m00 = sx; m10 = 0; m01 = 0; m11 = sy; m02 = 0; m12 = 0
    }

    public func setToRotation(_ theta: Double) {
      let c = cos(theta), s = sin(theta)
      m00 = c; m10 = s; m01 = -s; m11 = c; m02 = 0; m12 = 0
    }

    public func setToRotation(_ theta: Double, _ anchorX: Double, _ anchorY: Double) {
      setToRotation(theta)
      m02 = anchorX - m00 * anchorX - m01 * anchorY
      m12 = anchorY - m10 * anchorX - m11 * anchorY
    }

    public func setToShear(_ shx: Double, _ shy: Double) {
      m00 = 1; m10 = shy; m01 = shx; m11 = 1; m02 = 0; m12 = 0
    }

    public func setTransform(_ m00: Double, _ m10: Double,
                               _ m01: Double, _ m11: Double,
                               _ m02: Double, _ m12: Double) {
      self.m00 = m00; self.m10 = m10
      self.m01 = m01; self.m11 = m11
      self.m02 = m02; self.m12 = m12
    }

    public func setTransform(_ tx: AffineTransform) {
      m00 = tx.m00; m10 = tx.m10; m01 = tx.m01
      m11 = tx.m11; m02 = tx.m02; m12 = tx.m12
    }

    // =========================================================================
    // MARK: - Concatenation (in-place, this = this × Tx)
    // =========================================================================

    /// Translates by `(tx, ty)` — equivalent to `concatenate(translate(tx, ty))`.
    public func translate(_ tx: Double, _ ty: Double) {
      m02 += m00 * tx + m01 * ty
      m12 += m10 * tx + m11 * ty
    }

    /// Scales by `(sx, sy)`.
    public func scale(_ sx: Double, _ sy: Double) {
      m00 *= sx; m10 *= sx
      m01 *= sy; m11 *= sy
    }

    /// Rotates by `theta` radians.
    public func rotate(_ theta: Double) {
      let c = cos(theta), s = sin(theta)
      let n00 = m00 * c + m01 * s;  let n01 = -m00 * s + m01 * c
      let n10 = m10 * c + m11 * s;  let n11 = -m10 * s + m11 * c
      m00 = n00; m01 = n01; m10 = n10; m11 = n11
    }

    /// Rotates by `theta` around an anchor point.
    public func rotate(_ theta: Double, _ anchorX: Double, _ anchorY: Double) {
      translate(anchorX, anchorY); rotate(theta); translate(-anchorX, -anchorY)
    }

    /// Shears by `(shx, shy)`.
    public func shear(_ shx: Double, _ shy: Double) {
      let n00 = m00 + m01 * shy;  let n01 = m00 * shx + m01
      let n10 = m10 + m11 * shy;  let n11 = m10 * shx + m11
      m00 = n00; m01 = n01; m10 = n10; m11 = n11
    }

    /// Post-concatenates `Tx` — applies `Tx` first, then `this`.
    /// `this = this × Tx`
    public func concatenate(_ Tx: AffineTransform) {
      let n00 = m00 * Tx.m00 + m01 * Tx.m10
      let n01 = m00 * Tx.m01 + m01 * Tx.m11
      let n02 = m00 * Tx.m02 + m01 * Tx.m12 + m02
      let n10 = m10 * Tx.m00 + m11 * Tx.m10
      let n11 = m10 * Tx.m01 + m11 * Tx.m11
      let n12 = m10 * Tx.m02 + m11 * Tx.m12 + m12
      m00 = n00; m01 = n01; m02 = n02
      m10 = n10; m11 = n11; m12 = n12
    }

    /// Pre-concatenates `Tx` — applies `this` first, then `Tx`.
    /// `this = Tx × this`
    public func preConcatenate(_ Tx: AffineTransform) {
      let n00 = Tx.m00 * m00 + Tx.m01 * m10
      let n01 = Tx.m00 * m01 + Tx.m01 * m11
      let n02 = Tx.m00 * m02 + Tx.m01 * m12 + Tx.m02
      let n10 = Tx.m10 * m00 + Tx.m11 * m10
      let n11 = Tx.m10 * m01 + Tx.m11 * m11
      let n12 = Tx.m10 * m02 + Tx.m11 * m12 + Tx.m12
      m00 = n00; m01 = n01; m02 = n02
      m10 = n10; m11 = n11; m12 = n12
    }

    // =========================================================================
    // MARK: - Inversion
    // =========================================================================

    /// Returns the inverse of this transform.
    /// - Throws: `NoninvertibleTransformException` if `det == 0`.
    public func createInverse() throws -> AffineTransform {
      let det = getDeterminant()
      guard abs(det) > Double.leastNormalMagnitude else {
        throw java.awt.geom.NoninvertibleTransformException()
      }
      return AffineTransform(
         m11 / det,
        -m10 / det,
        -m01 / det,
         m00 / det,
        (m01 * m12 - m11 * m02) / det,
        (m10 * m02 - m00 * m12) / det
      )
    }

    /// Inverts this transform in place.
    public func invert() throws { setTransform(try createInverse()) }

    // =========================================================================
    // MARK: - Point transformation
    // =========================================================================

    /// Transforms `srcPt` and writes the result into `dstPt` (or a new point).
    @discardableResult
    public func transform(_ srcPt: java.awt.geom.Point2D,
                           _ dstPt: java.awt.geom.Point2D? = nil)
    -> java.awt.geom.Point2D {
      let x = srcPt.getX(), y = srcPt.getY()
      let out = dstPt ?? java.awt.geom.Point2D.Double()
      out.setLocation(m00 * x + m01 * y + m02, m10 * x + m11 * y + m12)
      return out
    }

    /// Applies the inverse transform to `srcPt`.
    @discardableResult
    public func inverseTransform(_ srcPt: java.awt.geom.Point2D,
                                  _ dstPt: java.awt.geom.Point2D? = nil)
    throws -> java.awt.geom.Point2D {
      return try createInverse().transform(srcPt, dstPt)
    }

    /// Transforms the vector `srcPt` (ignoring translation).
    @discardableResult
    public func deltaTransform(_ srcPt: java.awt.geom.Point2D,
                                _ dstPt: java.awt.geom.Point2D? = nil)
    -> java.awt.geom.Point2D {
      let x = srcPt.getX(), y = srcPt.getY()
      let out = dstPt ?? java.awt.geom.Point2D.Double()
      out.setLocation(m00 * x + m01 * y, m10 * x + m11 * y)
      return out
    }

    /// Transforms an array of coordinate pairs in place.
    public func transform(_ srcPts: [Double], _ srcOff: Int,
                           _ dstPts: inout [Double], _ dstOff: Int,
                           _ numPts: Int) {
      for i in 0..<numPts {
        let x = srcPts[srcOff + i*2], y = srcPts[srcOff + i*2 + 1]
        dstPts[dstOff + i*2]     = m00 * x + m01 * y + m02
        dstPts[dstOff + i*2 + 1] = m10 * x + m11 * y + m12
      }
    }

    // =========================================================================
    // MARK: - Clone / equality
    // =========================================================================

    public func clone() -> AffineTransform { AffineTransform(self) }

    public func equals(_ obj: AnyObject) -> Bool {
      guard let other = obj as? AffineTransform else { return false }
      return m00 == other.m00 && m10 == other.m10
          && m01 == other.m01 && m11 == other.m11
          && m02 == other.m02 && m12 == other.m12
    }
  }
}
