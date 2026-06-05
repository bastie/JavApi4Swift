/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// A UDP datagram packet.
  ///
  /// Java 1.0 `java.net.DatagramPacket`. A pure data container — no I/O is
  /// performed by this class. Use ``DatagramSocket`` to send and receive packets.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public final class DatagramPacket: @unchecked Sendable {

    internal var buf: [byte]
    internal var offset: Int
    internal var length: Int
    internal var address: InetAddress?
    internal var port: Int = -1

    // MARK: - Constructors (receive)

    /// Creates a packet for receiving data into `buf` (up to `length` bytes).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ buf: [byte], _ length: Int) {
      self.buf = buf
      self.offset = 0
      self.length = min(length, buf.count)
    }

    /// Creates a packet for receiving data into `buf` starting at `offset`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ buf: [byte], _ offset: Int, _ length: Int) {
      self.buf = buf
      self.offset = offset
      self.length = min(length, buf.count - offset)
    }

    // MARK: - Constructors (send)

    /// Creates a packet for sending `length` bytes from `buf` to the given address and port.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ buf: [byte], _ length: Int, _ address: InetAddress, _ port: Int) {
      self.buf = buf
      self.offset = 0
      self.length = min(length, buf.count)
      self.address = address
      self.port = port
    }

    /// Creates a packet for sending data from `buf` starting at `offset` to the given address and port.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ buf: [byte], _ offset: Int, _ length: Int, _ address: InetAddress, _ port: Int) {
      self.buf = buf
      self.offset = offset
      self.length = min(length, buf.count - offset)
      self.address = address
      self.port = port
    }

    // MARK: - Getters

    /// Returns the data buffer of this packet.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getData() -> [byte] { return buf }

    /// Returns the offset into the buffer.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getOffset() -> Int { return offset }

    /// Returns the length of the data.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getLength() -> Int { return length }

    /// Returns the destination/source address, or `nil` if not set.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getAddress() -> InetAddress? { return address }

    /// Returns the destination/source port, or `-1` if not set.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getPort() -> Int { return port }

    // MARK: - Setters

    /// Replaces the data buffer.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setData(_ buf: [byte]) {
      self.buf = buf
      self.offset = 0
      self.length = buf.count
    }

    /// Replaces the data buffer with offset and length.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setData(_ buf: [byte], _ offset: Int, _ length: Int) {
      self.buf = buf
      self.offset = offset
      self.length = min(length, buf.count - offset)
    }

    /// Sets the destination address.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setAddress(_ address: InetAddress) { self.address = address }

    /// Sets the destination port.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setPort(_ port: Int) { self.port = port }

    /// Sets the data length.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setLength(_ length: Int) {
      self.length = min(length, buf.count - offset)
    }
  }
}
