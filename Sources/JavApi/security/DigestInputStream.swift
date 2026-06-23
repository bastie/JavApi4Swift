/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// A transparent stream filter that passes bytes to a `MessageDigest` while
  /// they are read.
  ///
  /// When digest mode is on (the default), every byte returned by `read` is
  /// fed into the underlying `MessageDigest`.  Call `getMessageDigest().digest()`
  /// at the end of the stream to retrieve the computed hash.
  ///
  /// Mirrors `java.security.DigestInputStream` (Java 1.1).
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public class DigestInputStream: java.io.FilterInputStream, @unchecked Sendable {

    // MARK: - State

    private var digest: MessageDigest
    private var digestOn: Bool = true

    // MARK: - Constructor

    /// Creates a digest input stream using the given underlying stream and
    /// message digest.
    ///
    /// - Parameters:
    ///   - stream: The underlying input stream.
    ///   - digest: The message digest to associate with this stream.
    public init(_ stream: java.io.InputStream, _ digest: MessageDigest) {
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

    // MARK: - Read overrides

    /// Reads one byte and, if digest mode is on, updates the digest.
    ///
    /// - Returns: The byte read as an unsigned value (0–255), or -1 at EOF.
    public override func read() throws -> Int {
      let b = try self.in.read()
      if digestOn && b != -1 {
        digest.update(UInt8(b & 0xFF))
      }
      return b
    }

    /// Reads up to `length` bytes into `array` starting at `offset`, updating
    /// the digest with the bytes actually read (if digest mode is on).
    ///
    /// - Returns: The number of bytes read, or -1 at EOF.
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      let n = try self.in.read(&array, offset, length)
      if digestOn && n > 0 {
        digest.update(Array(array[offset..<offset + n]))
      }
      return n
    }
  }
}
