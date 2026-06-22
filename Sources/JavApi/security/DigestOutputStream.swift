/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// A transparent stream filter that passes bytes to a `MessageDigest` while
  /// they are written.
  ///
  /// When digest mode is on (the default), every byte passed to `write` is
  /// fed into the underlying `MessageDigest` before being forwarded to the
  /// wrapped output stream.
  ///
  /// Mirrors `java.security.DigestOutputStream` (Java 1.1).
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public class DigestOutputStream: java.io.FilterOutputStream, @unchecked Sendable {

    // MARK: - State

    private var digest: MessageDigest
    private var digestOn: Bool = true

    // MARK: - Constructor

    /// Creates a digest output stream using the given underlying stream and
    /// message digest.
    ///
    /// - Parameters:
    ///   - stream: The underlying output stream.
    ///   - digest: The message digest to associate with this stream.
    public init(_ stream: java.io.OutputStream, _ digest: MessageDigest) {
      self.digest = digest
      super.init(stream)
    }

    // MARK: - Digest access

    /// Returns the message digest associated with this stream.
    public func getMessageDigest() -> MessageDigest { digest }

    /// Replaces the message digest associated with this stream.
    public func setMessageDigest(_ digest: MessageDigest) { self.digest = digest }

    // MARK: - Digest on/off

    /// Returns whether the digest function is on.
    public func isOn() -> Bool { digestOn }

    /// Turns the digest function on (`true`) or off (`false`).
    public func on(_ on: Bool) { self.digestOn = on }

    // MARK: - Write overrides

    /// Writes one byte to the underlying stream and, if digest mode is on,
    /// updates the digest.
    public override func write(_ oneByte: Int) throws {
      if digestOn {
        digest.update(UInt8(oneByte & 0xFF))
      }
      try out.write(oneByte)
    }

    /// Writes `length` bytes from `buffer` starting at `offset` to the
    /// underlying stream, updating the digest (if digest mode is on).
    public override func write(_ buffer: [UInt8], _ offset: Int, _ length: Int) throws {
      if digestOn && length > 0 {
        digest.update(Array(buffer[offset..<offset + length]))
      }
      try out.write(buffer, offset, length)
    }
  }
}
