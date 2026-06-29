/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Android)
import Android
#elseif canImport(WinSDK)
import WinSDK
#endif

extension java.net {

  /// A TCP server socket that listens for incoming connections.
  ///
  /// Java 1.0 `java.net.ServerSocket`. Backed by POSIX socket APIs.
  /// Available on macOS, iOS, Linux; not available on WASI.
  ///
  /// Typical usage:
  /// ```swift
  /// let server = try java.net.ServerSocket(8080)
  /// defer { try? server.close() }
  ///
  /// while true {
  ///   let client = try server.accept()
  ///   let input  = try client.getInputStream()
  ///   // ... handle client ...
  ///   try client.close()
  /// }
  /// ```
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public class ServerSocket: @unchecked Sendable {

    private var fd: Int32 = -1
    private var _localPort: Int
    private var _closed: Bool = false
    private var soTimeout: Int = 0

    // MARK: - Constructors

    /// Creates an unbound server socket.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init() {
      self._localPort = -1
    }

    /// Creates a server socket bound to the given port with a default backlog of 50.
    ///
    /// - Throws: ``BindException`` if the port is already in use or cannot be bound.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ port: Int) throws {
      self._localPort = port
      try bind(port: port, backlog: 50)
    }

    /// Creates a server socket bound to the given port with the specified backlog.
    ///
    /// - Throws: ``BindException`` if the port is already in use or cannot be bound.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ port: Int, _ backlog: Int) throws {
      self._localPort = port
      try bind(port: port, backlog: backlog)
    }

    /// Creates a server socket bound to the given port, backlog and local address.
    ///
    /// - Throws: ``BindException`` if the port is already in use or cannot be bound.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ port: Int, _ backlog: Int, _ bindAddr: InetAddress) throws {
      self._localPort = port
      try bind(port: port, backlog: backlog, bindAddr: bindAddr)
    }

    // MARK: - Bind (private)

    private func bind(port: Int, backlog: Int, bindAddr: InetAddress? = nil) throws {
#if os(WASI)
      throw SocketException("ServerSocket is unavailable on WASI")
#else
#if canImport(Darwin) || os(Android) || os(FreeBSD)
      let sockFd = socket(AF_INET, SOCK_STREAM, 0)
#elseif canImport(Glibc)
      let sockFd = socket(AF_INET, numericCast(SOCK_STREAM.rawValue), 0)
#elseif canImport(WinSDK)
      let sockFd = platformSocket(AF_INET, Int32(SOCK_STREAM), 0)
#else
      let sockFd = socket(AF_INET, Int32(SOCK_STREAM), 0)
#endif
      guard sockFd >= 0 else {
        throw BindException("Cannot create socket")
      }

      var reuse: Int32 = 1
#if canImport(WinSDK)
      platformSetsockopt(sockFd, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))
#else
      setsockopt(sockFd, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))
#endif

      var addr = sockaddr_in()
      addr.sin_family = sa_family_t(AF_INET)
      addr.sin_port = UInt16(port).bigEndian
      if let bindAddr {
        addr.sin_addr.s_addr = platformParseIPv4(bindAddr.getHostAddress()) ?? INADDR_ANY.bigEndian
      } else {
        addr.sin_addr.s_addr = INADDR_ANY.bigEndian
      }

      let bindResult = withUnsafePointer(to: &addr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          platformBind(sockFd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
      }
      guard bindResult == 0 else {
        platformClose(sockFd)
        throw BindException("Address already in use: \(port)")
      }

#if canImport(WinSDK)
      guard platformListen(sockFd, Int32(backlog)) == 0 else {
        platformClose(sockFd)
        throw SocketException("listen() failed on port \(port)")
      }
#else
      guard listen(sockFd, Int32(backlog)) == 0 else {
        platformClose(sockFd)
        throw SocketException("listen() failed on port \(port)")
      }
#endif

      self.fd = sockFd
#endif
    }

    // MARK: - accept

    /// Waits for and accepts an incoming connection, returning a connected ``Socket``.
    ///
    /// Blocks until a connection arrives or the SO_TIMEOUT expires.
    ///
    /// - Throws: ``SocketException`` if the socket is closed or an error occurs.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func accept() throws -> Socket {
      guard !_closed, fd >= 0 else {
        throw SocketException("Socket is closed")
      }
#if os(WASI)
      throw SocketException("ServerSocket.accept() is unavailable on WASI")
#else
      var clientAddr = sockaddr_in()
      var addrLen = socklen_t(MemoryLayout<sockaddr_in>.size)

      let clientFd = withUnsafeMutablePointer(to: &clientAddr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          platformAccept(fd, $0, &addrLen)
        }
      }

      guard clientFd >= 0 else {
        throw SocketException("accept() failed")
      }

      // Remote address string (pure-Swift, avoids inet_ntop — see platformIPv4String)
      let remoteIP = platformIPv4String(clientAddr.sin_addr.s_addr)
      let remotePort = Int(clientAddr.sin_port.bigEndian)

      // Local port (may differ from _localPort if bound to 0)
      var localAddr = sockaddr_in()
#if canImport(WinSDK)
      var localLen = Int32(MemoryLayout<sockaddr_in>.size)
      _ = withUnsafeMutablePointer(to: &localAddr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          platformGetsockname(clientFd, $0, &localLen)
        }
      }
#else
      var localLen = socklen_t(MemoryLayout<sockaddr_in>.size)
      _ = withUnsafeMutablePointer(to: &localAddr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          getsockname(clientFd, $0, &localLen)
        }
      }
#endif
      let localPort = Int(localAddr.sin_port.bigEndian)

      let remoteAddress = try InetAddress.getByName(remoteIP)
      return Socket(fd: clientFd, remoteAddress: remoteAddress, remotePort: remotePort, localPort: localPort)
#endif
    }

    // MARK: - close

    /// Closes this server socket.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func close() throws {
      guard !_closed, fd >= 0 else { return }
#if !os(WASI)
      platformClose(fd)
#endif
      _closed = true
      fd = -1
    }

    // MARK: - Accessors

    /// Returns the local port this socket is bound to.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getLocalPort() -> Int { return _localPort }

    /// Returns `true` if this socket has been closed.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func isClosed() -> Bool { return _closed }

    /// Sets the SO_TIMEOUT in milliseconds (`0` = no timeout).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setSoTimeout(_ timeout: Int) {
      soTimeout = timeout
#if !os(WASI)
      if fd >= 0 {
#if canImport(WinSDK)
        var tv = timeval()
        tv.tv_sec = Int32(timeout / 1000)
        tv.tv_usec = Int32((timeout % 1000) * 1000)
        platformSetsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
#else
        var tv = timeval()
        tv.tv_sec = numericCast(timeout / 1000)
        tv.tv_usec = numericCast((timeout % 1000) * 1000)
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
#endif
      }
#endif
    }

    /// Returns the SO_TIMEOUT in milliseconds.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getSoTimeout() -> Int { return soTimeout }

    /// Returns a string representation of this server socket.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func toString() -> String {
      return "ServerSocket[addr=0.0.0.0,localport=\(_localPort)]"
    }
  }
}
