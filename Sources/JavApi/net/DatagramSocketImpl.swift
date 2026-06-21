/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// Abstract base class for datagram and multicast socket implementations.
  ///
  /// Mirrors `java.net.DatagramSocketImpl`.  Application code rarely uses this
  /// class directly — it exists so that ported Java code referencing it
  /// compiles.  Subclass and override all `open` methods to provide a custom
  /// UDP transport.
  ///
  /// JavApi⁴Swift's ``DatagramSocket`` is backed directly by POSIX file
  /// descriptors and does not delegate to `DatagramSocketImpl`.
  ///
  /// - Since: Java 1.1
  open class DatagramSocketImpl: @unchecked Sendable {

    // MARK: - Protected fields (public in Swift for subclass access)

    /// The file descriptor of this socket (-1 = not open).
    public var fd: Int32 = -1

    /// The local port this socket is bound to (-1 = not bound).
    public var localPort: Int = -1

    // MARK: - Init

    public init() {}

    // MARK: - Abstract methods (throw by default; subclasses must override)

    /// Creates a datagram socket.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func create() throws {
      throw java.io.IOException("DatagramSocketImpl.create() must be overridden by subclass")
    }

    /// Binds a datagram socket to a local port and address.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func bind(_ lport: Int, _ laddr: InetAddress) throws {
      throw java.io.IOException("DatagramSocketImpl.bind() must be overridden by subclass")
    }

    /// Sends a datagram packet.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func send(_ p: DatagramPacket) throws {
      throw java.io.IOException("DatagramSocketImpl.send() must be overridden by subclass")
    }

    /// Receives a datagram packet.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func receive(_ p: DatagramPacket) throws {
      throw java.io.IOException("DatagramSocketImpl.receive() must be overridden by subclass")
    }

    /// Connects this socket to the given address and port.
    ///
    /// Default implementation does nothing (connectionless UDP).
    open func connect(_ address: InetAddress, _ port: Int) throws {
      // default: connectionless UDP — no-op
    }

    /// Disconnects this socket.
    ///
    /// Default implementation does nothing.
    open func disconnect() {
      // default: no-op
    }

    /// Sets the time-to-live (TTL) for multicast packets.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func setTTL(_ ttl: UInt8) throws {
      throw java.io.IOException("DatagramSocketImpl.setTTL() must be overridden by subclass")
    }

    /// Returns the time-to-live (TTL) for multicast packets.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func getTTL() throws -> UInt8 {
      throw java.io.IOException("DatagramSocketImpl.getTTL() must be overridden by subclass")
    }

    /// Joins a multicast group.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func join(_ inetaddr: InetAddress) throws {
      throw java.io.IOException("DatagramSocketImpl.join() must be overridden by subclass")
    }

    /// Leaves a multicast group.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func leave(_ inetaddr: InetAddress) throws {
      throw java.io.IOException("DatagramSocketImpl.leave() must be overridden by subclass")
    }

    /// Peeks at the source address of the next incoming packet.
    ///
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    open func peek(_ i: InetAddress) throws -> Int {
      throw java.io.IOException("DatagramSocketImpl.peek() must be overridden by subclass")
    }

    /// Closes this socket.
    open func close() {
      // default: no-op
    }

    /// Returns the local port this socket is bound to.
    public func getLocalPort() -> Int {
      return localPort
    }
  }
}
