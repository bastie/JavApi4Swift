/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  /// Interface for writing primitive Java types to a binary stream.
  ///
  /// Mirrors `java.io.DataOutput` from Java 1.0. All multi-byte values are
  /// written in big-endian byte order, matching Java's specification.
  ///
  /// - Since: JavaApi (Java 1.0)
  public protocol DataOutput {

    /// Writes the lowest 8 bits of `b` to the stream.
    func write(_ b: Int) throws

    /// Writes all bytes from `b` to the stream.
    func write(_ b: [UInt8]) throws

    /// Writes `length` bytes from `b` starting at `offset`.
    func write(_ b: [UInt8], _ offset: Int, _ length: Int) throws

    /// Writes a `boolean` as a single byte (1 = true, 0 = false).
    func writeBoolean(_ v: Bool) throws

    /// Writes the lowest 8 bits of `v` as a single byte.
    func writeByte(_ v: Int) throws

    /// Writes the characters of `s` as bytes (low 8 bits of each char).
    func writeBytes(_ s: String) throws

    /// Writes `v` as two bytes, high byte first.
    func writeChar(_ v: Int) throws

    /// Writes every character of `s` as two bytes (big-endian).
    func writeChars(_ s: String) throws

    /// Writes `v` as an 8-byte big-endian IEEE 754 double.
    func writeDouble(_ v: Double) throws

    /// Writes `v` as a 4-byte big-endian IEEE 754 float.
    func writeFloat(_ v: Float) throws

    /// Writes `v` as four bytes, high byte first.
    func writeInt(_ v: Int) throws

    /// Writes `v` as eight bytes, high byte first.
    func writeLong(_ v: Int64) throws

    /// Writes `v` as two bytes, high byte first.
    func writeShort(_ v: Int) throws

    /// Writes `s` in the modified UTF-8 encoding used by Java.
    func writeUTF(_ s: String) throws
  }
}
