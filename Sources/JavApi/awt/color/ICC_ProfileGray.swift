/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.color {

  /// An ICC profile that describes a grey-scale colour space —
  /// mirrors `java.awt.color.ICC_ProfileGray`.
  ///
  /// - Since: Java 1.2
  public final class ICC_ProfileGray: ICC_Profile, @unchecked Sendable {

    /// Returns the media white point Y value of this grey profile.
    ///
    /// Always 1.0 for the predefined linear-grey profile.
    public func getMediaWhitePoint() -> Float { 1.0 }

    /// Returns the gamma value of the grey TRC (transfer response curve).
    ///
    /// Always 1.0 (linear) for the predefined grey colour space.
    public func getGamma() -> Float { 1.0 }
  }
}
