/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.geom {
  /// Thrown when an `AffineTransform` that has no inverse is asked to invert.
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class NoninvertibleTransformException: Exception, @unchecked Sendable {
    public override init(_ message: String = "AffineTransform is not invertible") {
      super.init(message)
    }
  }
}
