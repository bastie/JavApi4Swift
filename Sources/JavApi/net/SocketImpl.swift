/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// Abstract base class for socket implementations.
  ///
  /// Java 1.0 `java.net.SocketImpl`. Application code rarely uses this class
  /// directly — it exists so that ported Java code referencing it compiles.
  /// Subclass and override all `open` methods to provide a custom transport.
  ///
  /// JavApi⁴Swift's ``Socket`` and ``ServerSocket`` are backed directly by
  /// POSIX file descriptors and do not delegate to `SocketImpl`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open class SocketImpl: @unchecked Sendable {

    // MARK: - Protected fields (public in Swift for subclass access)

    /// The file descriptor of this socket (stored as Int32; -1 = not connected).
    public var fd: Int32 = -1

    /// The remote IP address this socket is connected to.
    public var address: InetAddress? = nil

    /// The remote port this socket is connected to.
    public var port: Int = 0

    /// The local port this socket is bound to.
    public var localport: Int = 0

    // MARK: - Init

    public init() {}

    // MARK: - Abstract methods (throw by default; subclasses must override)

    /// Creates either a stream or a datagram socket.
    ///
    /// - Parameter stream: `true` for TCP (stream), `false` for UDP (datagram).
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func create(_ stream: Bool) throws {
      throw java.io.IOException("SocketImpl.create() must be overridden by subclass")
    }

    /// Connects this socket to the given host and port.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func connect(_ host: String, _ port: Int) throws {
      throw java.io.IOException("SocketImpl.connect() must be overridden by subclass")
    }

    /// Connects this socket to the given address and port.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func connect(_ address: InetAddress, _ port: Int) throws {
      throw java.io.IOException("SocketImpl.connect() must be overridden by subclass")
    }

    /// Binds this socket to the given local address and port.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func bind(_ host: InetAddress, _ port: Int) throws {
      throw java.io.IOException("SocketImpl.bind() must be overridden by subclass")
    }

    /// Sets the maximum queue length for incoming connections.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func listen(_ backlog: Int) throws {
      throw java.io.IOException("SocketImpl.listen() must be overridden by subclass")
    }

    /// Accepts a connection into `s`.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func accept(_ s: SocketImpl) throws {
      throw java.io.IOException("SocketImpl.accept() must be overridden by subclass")
    }

    /// Returns an input stream for this socket.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getInputStream() throws -> java.io.InputStream {
      throw java.io.IOException("SocketImpl.getInputStream() must be overridden by subclass")
    }

    /// Returns an output stream for this socket.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getOutputStream() throws -> java.io.OutputStream {
      throw java.io.IOException("SocketImpl.getOutputStream() must be overridden by subclass")
    }

    /// Returns the number of bytes that can be read without blocking.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func available() throws -> Int {
      throw java.io.IOException("SocketImpl.available() must be overridden by subclass")
    }

    /// Closes this socket.
    ///
    /// - Throws: ``java.io.IOException`` – subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func close() throws {
      throw java.io.IOException("SocketImpl.close() must be overridden by subclass")
    }

    // MARK: - Concrete accessors

    /// Returns the remote `InetAddress`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getInetAddress() -> InetAddress? { return address }

    /// Returns the remote port.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getPort() -> Int { return port }

    /// Returns the local port.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getLocalPort() -> Int { return localport }

    /// Returns the file descriptor as Int32 (`-1` if not connected).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getFileDescriptor() -> Int32 { return fd }

    /// Returns a string representation of this socket implementation.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func toString() -> String {
      return "SocketImpl[addr=\(address?.getHostAddress() ?? "null"),port=\(port),localport=\(localport)]"
    }
  }
}
