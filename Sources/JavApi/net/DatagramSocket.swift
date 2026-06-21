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

  /// A UDP socket for sending and receiving datagram packets.
  ///
  /// Java 1.0 `java.net.DatagramSocket`. Backed by a POSIX `SOCK_DGRAM` socket.
  /// Available on macOS, iOS, Linux; not available on WASI.
  ///
  /// Typical send:
  /// ```swift
  /// let socket = try java.net.DatagramSocket()
  /// let addr   = try java.net.InetAddress.getByName("example.com")
  /// let data   = Array("hello".utf8)
  /// let packet = java.net.DatagramPacket(data, data.count, addr, 9)
  /// try socket.send(packet)
  /// try socket.close()
  /// ```
  ///
  /// Typical receive:
  /// ```swift
  /// let socket = try java.net.DatagramSocket(9)
  /// var buf    = [byte](repeating: 0, count: 1024)
  /// let packet = java.net.DatagramPacket(buf, buf.count)
  /// try socket.receive(packet)   // blocks
  /// print(String(bytes: packet.getData().prefix(packet.getLength()), encoding: .utf8) ?? "")
  /// try socket.close()
  /// ```
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public class DatagramSocket: @unchecked Sendable {

    internal var fd: Int32 = -1
    private var _localPort: Int = -1
    private var _closed: Bool = false
    private var soTimeout: Int = 0

    // MARK: - Constructors

    /// Creates a datagram socket bound to any available local port.
    ///
    /// - Throws: ``SocketException`` on failure.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init() throws {
      try bindSocket(port: 0, address: nil)
    }

    /// Creates a datagram socket bound to the given port.
    ///
    /// - Throws: ``SocketException`` / ``BindException`` on failure.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ port: Int) throws {
      try bindSocket(port: port, address: nil)
    }

    /// Creates a datagram socket bound to the given port and local address.
    ///
    /// - Throws: ``SocketException`` / ``BindException`` on failure.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ port: Int, _ laddr: InetAddress) throws {
      try bindSocket(port: port, address: laddr)
    }

    // MARK: - Bind (private)

    private func bindSocket(port: Int, address: InetAddress?) throws {
#if os(WASI)
      throw SocketException("DatagramSocket is unavailable on WASI")
#else
#if canImport(Darwin) || os(Android)
      let sockFd = socket(AF_INET, SOCK_DGRAM, 0)
#elseif canImport(Glibc)
      let sockFd = socket(AF_INET, numericCast(SOCK_DGRAM.rawValue), 0)
#elseif canImport(WinSDK)
      let sockFd = platformSocket(AF_INET, Int32(SOCK_DGRAM), 0)
#else
      let sockFd = socket(AF_INET, Int32(SOCK_DGRAM), 0)
#endif
      guard sockFd >= 0 else {
        throw SocketException("Cannot create datagram socket")
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
      if let address {
        inet_pton(AF_INET, address.getHostAddress(), &addr.sin_addr)
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
        throw BindException("Cannot bind datagram socket to port \(port)")
      }

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

      self.fd = sockFd
      self._localPort = Int(localAddr.sin_port.bigEndian)
#endif
    }

    // MARK: - Send

    /// Sends a datagram packet.
    ///
    /// The packet must have a destination address and port set.
    ///
    /// - Throws: ``SocketException`` if the socket is closed or the send fails.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func send(_ packet: DatagramPacket) throws {
      guard !_closed, fd >= 0 else {
        throw SocketException("Socket is closed")
      }
#if os(WASI)
      throw SocketException("DatagramSocket.send() is unavailable on WASI")
#else
      guard let address = packet.getAddress() else {
        throw SocketException("Packet has no destination address")
      }
      let port = packet.getPort()
      guard port > 0 else {
        throw SocketException("Packet has no destination port")
      }

      var dest = sockaddr_in()
      dest.sin_family = sa_family_t(AF_INET)
      dest.sin_port = UInt16(port).bigEndian
      inet_pton(AF_INET, address.getHostAddress(), &dest.sin_addr)

      let data = packet.getData()
      let offset = packet.getOffset()
      let length = packet.getLength()

      let sent = data.withUnsafeBytes { ptr in
        withUnsafePointer(to: &dest) {
          $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
#if canImport(WinSDK)
            platformSendto(fd, ptr.baseAddress! + offset, length, 0, $0,
                           socklen_t(MemoryLayout<sockaddr_in>.size))
#else
            sendto(fd, ptr.baseAddress! + offset, length, 0, $0,
                   socklen_t(MemoryLayout<sockaddr_in>.size))
#endif
          }
        }
      }
      guard sent >= 0 else {
        throw SocketException("send() failed")
      }
#endif
    }

    // MARK: - Receive

    /// Receives a datagram packet (blocks until data arrives or timeout expires).
    ///
    /// The packet's buffer, offset, length, address and port are updated
    /// with the received data and sender information.
    ///
    /// - Throws: ``SocketException`` if the socket is closed or the receive fails.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func receive(_ packet: DatagramPacket) throws {
      guard !_closed, fd >= 0 else {
        throw SocketException("Socket is closed")
      }
#if os(WASI)
      throw SocketException("DatagramSocket.receive() is unavailable on WASI")
#else
      var sender = sockaddr_in()
      var senderLen = socklen_t(MemoryLayout<sockaddr_in>.size)

      let received = packet.buf.withUnsafeMutableBytes { ptr in
        withUnsafeMutablePointer(to: &sender) {
          $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
#if canImport(WinSDK)
            platformRecvfrom(fd, ptr.baseAddress! + packet.offset, packet.length, 0, $0, &senderLen)
#else
            recvfrom(fd, ptr.baseAddress! + packet.offset, packet.length, 0, $0, &senderLen)
#endif
          }
        }
      }
      guard received >= 0 else {
        throw SocketException("receive() failed")
      }

      packet.length = received

      var addrBuf = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
#if canImport(WinSDK)
      platformInet_ntop(AF_INET, &sender.sin_addr, &addrBuf, socklen_t(INET_ADDRSTRLEN))
#else
      inet_ntop(AF_INET, &sender.sin_addr, &addrBuf, socklen_t(INET_ADDRSTRLEN))
#endif
      let senderIP = String(bytes: addrBuf.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }, encoding: .utf8) ?? "0.0.0.0"
      packet.port = Int(sender.sin_port.bigEndian)
      packet.address = try InetAddress.getByName(senderIP)
#endif
    }

    // MARK: - Close

    /// Closes this socket.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func close() {
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

    /// Sets the send buffer size in bytes.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setSendBufferSize(_ size: Int) {
#if !os(WASI)
      var s = Int32(size)
#if canImport(WinSDK)
      platformSetsockopt(fd, SOL_SOCKET, SO_SNDBUF, &s, socklen_t(MemoryLayout<Int32>.size))
#else
      setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &s, socklen_t(MemoryLayout<Int32>.size))
#endif
#endif
    }

    /// Sets the receive buffer size in bytes.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setReceiveBufferSize(_ size: Int) {
#if !os(WASI)
      var s = Int32(size)
#if canImport(WinSDK)
      platformSetsockopt(fd, SOL_SOCKET, SO_RCVBUF, &s, socklen_t(MemoryLayout<Int32>.size))
#else
      setsockopt(fd, SOL_SOCKET, SO_RCVBUF, &s, socklen_t(MemoryLayout<Int32>.size))
#endif
#endif
    }
  }
}
