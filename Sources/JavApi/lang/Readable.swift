/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// ``Readable`` type
/// - Since: Java 1.5
public protocol Readable {
  
  /// - Parameter cb : `java.nio.CharBuffer`to read into
  /// - Note: did not throws `NullPointerException` like Java because parameter is not optional
  /// - Returns: Returns number of bytes read or -1 if source is ended before read. Zero can be return.
  /// - Throws:
  ///   - `java.nio.ReadOnlyBufferException` if read-only charbuffer is parameter
  ///   - `java.io.IOException` on other IO errors
  /// - Since Java 1.5
  func read (_ cb : java.nio.CharBuffer) throws -> Int
  
  associatedtype Readable: java.lang.Readable
}
