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

// `linger` is named `linger` on POSIX (Glibc/Musl/Android) but `LINGER` on
// Windows. Use a single alias so the non-Windows code path can refer to one name.
#if !canImport(WinSDK) && !os(WASI)
private typealias linger_t = linger
#endif

extension java.net {

  /// A TCP client socket, Java 1.0 `java.net.Socket`.
  ///
  /// Backed by a POSIX file descriptor. Available on macOS, iOS, Linux and
  /// Windows; not available on WASI (throws ``SocketException`` on init).
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public class Socket: @unchecked Sendable {

    internal var fd: Int32 = -1
    private var _inetAddress: InetAddress?
    private var _port: Int = -1
    private var _localPort: Int = -1
    private var _closed: Bool = false
    private var soTimeout: Int = 0

    // MARK: - Constructors

    /// Creates an unconnected socket.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init() {}

    /// Creates a socket and connects it to the given host and port.
    ///
    /// - Throws: ``SocketException`` / ``UnknownHostException`` on failure.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ host: String, _ port: Int) throws {
#if os(WASI)
      throw SocketException("Socket is unavailable on WASI")
#else
      let addr = try InetAddress.getByName(host)
      try connect(addr, port)
#endif
    }

    /// Creates a socket and connects it to the given address and port.
    ///
    /// - Throws: ``SocketException`` on failure.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ address: InetAddress, _ port: Int) throws {
#if os(WASI)
      throw SocketException("Socket is unavailable on WASI")
#else
      try connect(address, port)
#endif
    }

    /// Internal init used by ServerSocket.accept()
    internal init(fd: Int32, remoteAddress: InetAddress, remotePort: Int, localPort: Int) {
      self.fd = fd
      self._inetAddress = remoteAddress
      self._port = remotePort
      self._localPort = localPort
    }

    // MARK: - Connect

#if !os(WASI)
    private func connect(_ address: InetAddress, _ port: Int) throws {
#if canImport(Darwin) || os(Android)
      let sockFd = socket(AF_INET, SOCK_STREAM, 0)
#elseif canImport(Glibc)
      let sockFd = socket(AF_INET, numericCast(SOCK_STREAM.rawValue), 0)
#elseif canImport(WinSDK)
      let sockFd = platformSocket(AF_INET, Int32(SOCK_STREAM), 0)
#else
      let sockFd = socket(AF_INET, Int32(SOCK_STREAM), 0)
#endif
      guard sockFd >= 0 else {
        throw SocketException("Cannot create socket")
      }

      var addr = sockaddr_in()
      addr.sin_family = sa_family_t(AF_INET)
      addr.sin_port = UInt16(port).bigEndian
      inet_pton(AF_INET, address.getHostAddress(), &addr.sin_addr)

      let result = withUnsafePointer(to: &addr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          platformConnect(sockFd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
      }
      guard result == 0 else {
        platformClose(sockFd)
        throw ConnectException("Connection refused: \(address.getHostAddress()):\(port)")
      }

      self.fd = sockFd
      self._inetAddress = address
      self._port = port

      // get local port
      var localAddr = sockaddr_in()
#if canImport(WinSDK)
      var len = Int32(MemoryLayout<sockaddr_in>.size)
      _ = withUnsafeMutablePointer(to: &localAddr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          platformGetsockname(sockFd, $0, &len)
        }
      }
#else
      var len = socklen_t(MemoryLayout<sockaddr_in>.size)
      _ = withUnsafeMutablePointer(to: &localAddr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          getsockname(sockFd, $0, &len)
        }
      }
#endif
      self._localPort = Int(localAddr.sin_port.bigEndian)
    }
#endif

    // MARK: - Streams

    /// Returns an input stream for reading from this socket.
    ///
    /// - Throws: ``SocketException`` if the socket is closed.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getInputStream() throws -> java.io.InputStream {
      guard !_closed, fd >= 0 else {
        throw SocketException("Socket is closed")
      }
      return SocketInputStream(fd: fd)
    }

    /// Returns an output stream for writing to this socket.
    ///
    /// - Throws: ``SocketException`` if the socket is closed.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getOutputStream() throws -> java.io.OutputStream {
      guard !_closed, fd >= 0 else {
        throw SocketException("Socket is closed")
      }
      return SocketOutputStream(fd: fd)
    }

    // MARK: - Close

    /// Closes this socket.
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

    /// Returns the remote `InetAddress`, or `nil` if not connected.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getInetAddress() -> InetAddress? { return _inetAddress }

    /// Returns the remote port, or `-1` if not connected.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getPort() -> Int { return _port }

    /// Returns the local port, or `-1` if not bound.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getLocalPort() -> Int { return _localPort }

    /// Returns `true` if the socket has been closed.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func isClosed() -> Bool { return _closed }

    /// Returns `true` if the socket is connected.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func isConnected() -> Bool { return !_closed && fd >= 0 }

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

    /// Enables/disables SO_LINGER with the specified linger time in seconds.
    ///
    /// If `on` is `false`, SO_LINGER is disabled. If `true`, the socket will
    /// block on ``close()`` for up to `linger` seconds until all data is sent.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setSoLinger(_ on: Bool, _ linger: Int) throws {
#if !os(WASI)
      guard fd >= 0 else { throw SocketException("Socket is closed") }
#if canImport(WinSDK)
      var l = LINGER()
      l.l_onoff  = on ? 1 : 0
      l.l_linger = UInt16(linger)
      platformSetsockopt(fd, SOL_SOCKET, SO_LINGER, &l, socklen_t(MemoryLayout<LINGER>.size))
#else
      var l = linger_t()
      l.l_onoff  = on ? 1 : 0
      l.l_linger = Int32(linger)
      setsockopt(fd, SOL_SOCKET, SO_LINGER, &l, socklen_t(MemoryLayout<linger_t>.size))
#endif
#endif
    }

    /// Returns the SO_LINGER setting in seconds, or `-1` if disabled.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getSoLinger() throws -> Int {
#if os(WASI)
      return -1
#elseif canImport(WinSDK)
      guard fd >= 0 else { throw SocketException("Socket is closed") }
      var l = LINGER()
      var len = socklen_t(MemoryLayout<LINGER>.size)
      platformGetsockopt(fd, SOL_SOCKET, SO_LINGER, &l, &len)
      return l.l_onoff != 0 ? Int(l.l_linger) : -1
#else
      guard fd >= 0 else { throw SocketException("Socket is closed") }
      var l = linger_t()
      var len = socklen_t(MemoryLayout<linger_t>.size)
      getsockopt(fd, SOL_SOCKET, SO_LINGER, &l, &len)
      return l.l_onoff != 0 ? Int(l.l_linger) : -1
#endif
    }

    /// Enables/disables TCP_NODELAY (Nagle's algorithm).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setTcpNoDelay(_ on: Bool) throws {
#if !os(WASI)
      guard fd >= 0 else { throw SocketException("Socket is closed") }
      var flag: Int32 = on ? 1 : 0
#if canImport(WinSDK)
      platformSetsockopt(fd, IPPROTO_TCP.rawValue, TCP_NODELAY, &flag, socklen_t(MemoryLayout<Int32>.size))
#else
      setsockopt(fd, Int32(IPPROTO_TCP), TCP_NODELAY, &flag, socklen_t(MemoryLayout<Int32>.size))
#endif
#endif
    }

    /// Returns whether TCP_NODELAY is enabled.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getTcpNoDelay() throws -> Bool {
#if os(WASI)
      return false
#else
      guard fd >= 0 else { throw SocketException("Socket is closed") }
      var flag: Int32 = 0
      var len = socklen_t(MemoryLayout<Int32>.size)
#if canImport(WinSDK)
      platformGetsockopt(fd, IPPROTO_TCP.rawValue, TCP_NODELAY, &flag, &len)
#else
      getsockopt(fd, Int32(IPPROTO_TCP), TCP_NODELAY, &flag, &len)
#endif
      return flag != 0
#endif
    }
  }
}

// MARK: - SocketInputStream

/// An InputStream backed by a POSIX socket file descriptor.
internal class SocketInputStream: java.io.InputStream {
  private let fd: Int32

  init(fd: Int32) { self.fd = fd }

  public override func read() throws -> Int {
#if os(WASI)
    return -1
#else
    var byte: UInt8 = 0
#if canImport(WinSDK)
    let n = platformRecv(fd, &byte, 1, 0)
#else
    let n = recv(fd, &byte, 1, 0)
#endif
    if n == 0 { return -1 }  // EOF
    if n < 0 { throw java.io.IOException("Socket read error") }
    return Int(byte)
#endif
  }

  public override func read(_ buffer: inout [byte]) throws -> Int {
    return try read(&buffer, 0, buffer.count)
  }

  public override func read(_ buffer: inout [byte], _ offset: Int, _ length: Int) throws -> Int {
#if os(WASI)
    return -1
#else
    guard length > 0 else { return 0 }
#if canImport(WinSDK)
    let n = buffer.withUnsafeMutableBytes { ptr in
      platformRecv(fd, ptr.baseAddress! + offset, length, 0)
    }
#else
    let n = buffer.withUnsafeMutableBytes { ptr in
      recv(fd, ptr.baseAddress! + offset, length, 0)
    }
#endif
    if n == 0 { return -1 }
    if n < 0 { throw java.io.IOException("Socket read error") }
    return n
#endif
  }
}

// MARK: - SocketOutputStream

/// An OutputStream backed by a POSIX socket file descriptor.
internal class SocketOutputStream: java.io.OutputStream {
  private let fd: Int32

  init(fd: Int32) { self.fd = fd }

  public override func write(_ b: Int) throws {
#if !os(WASI)
    var byte = UInt8(b & 0xFF)
#if canImport(WinSDK)
    let n = platformSend(fd, &byte, 1, 0)
#else
    let n = send(fd, &byte, 1, 0)
#endif
    if n < 0 { throw java.io.IOException("Socket write error") }
#endif
  }

  public override func write(_ buffer: [byte]) throws {
    try write(buffer, 0, buffer.count)
  }

  public override func write(_ buffer: [byte], _ offset: Int, _ length: Int) throws {
#if !os(WASI)
    guard length > 0 else { return }
#if canImport(WinSDK)
    let n = buffer.withUnsafeBytes { ptr in
      platformSend(fd, ptr.baseAddress! + offset, length, 0)
    }
#else
    let n = buffer.withUnsafeBytes { ptr in
      send(fd, ptr.baseAddress! + offset, length, 0)
    }
#endif
    if n < 0 { throw java.io.IOException("Socket write error") }
#endif
  }
}
