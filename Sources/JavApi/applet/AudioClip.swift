/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.applet {
  /// Interface for playing audio clips.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public protocol AudioClip {
    /// Starts playing the audio clip once.
    func play()
    /// Starts playing the audio clip in a loop.
    func loop()
    /// Stops playing the audio clip.
    func stop()
  }
}
