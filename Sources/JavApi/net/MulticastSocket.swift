/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if !os(WASI)
import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Android)
import Android
#elseif canImport(WinSDK)
import WinSDK
#endif
#endif

extension java.net {

  /// A UDP socket that supports IP multicast group membership.
  ///
  /// Mirrors `java.net.MulticastSocket`.  On WASI all operations throw
  /// ``SocketException`` because raw sockets are unavailable.  On Darwin and
  /// Linux POSIX `IP_ADD_MEMBERSHIP` / `IP_DROP_MEMBERSHIP` are used directly.
  /// On Windows the same Winsock2 options are invoked via ``platformSetsockopt``.
  ///
  /// Typical usage:
  /// ```swift
  /// let ms = try java.net.MulticastSocket(9999)
  /// let group = try java.net.InetAddress.getByName("224.0.0.1")
  /// try ms.joinGroup(group)
  /// // … receive packets …
  /// try ms.leaveGroup(group)
  /// try ms.close()
  /// ```
  ///
  /// - Since: Java 1.1
  public class MulticastSocket: DatagramSocket, @unchecked Sendable {

    // MARK: - Constructors

    /// Creates a multicast socket not bound to any port.
    ///
    /// - Throws: ``SocketException`` on failure or on WASI.
    /// - Since: Java 1.1
    public override init() throws {
      try super.init()
    }

    /// Creates a multicast socket bound to the given port.
    ///
    /// - Parameter port: Local port to bind to.
    /// - Throws: ``SocketException`` / ``BindException`` on failure or on WASI.
    /// - Since: Java 1.1
    public override init(_ port: Int) throws {
      try super.init(port)
    }

    // MARK: - Group membership

    /// Joins the multicast group at the given address.
    ///
    /// - Parameter mcastaddr: The multicast group address (224.x.x.x – 239.x.x.x).
    /// - Throws: ``SocketException`` on failure or on WASI.
    /// - Since: Java 1.1
    public func joinGroup(_ mcastaddr: InetAddress) throws {
#if os(WASI)
      throw SocketException("MulticastSocket.joinGroup() is not supported on WASI")
#else
      try setMulticastMembership(mcastaddr, join: true)
#endif
    }

    /// Leaves the multicast group at the given address.
    ///
    /// - Parameter mcastaddr: The multicast group address.
    /// - Throws: ``SocketException`` on failure or on WASI.
    /// - Since: Java 1.1
    public func leaveGroup(_ mcastaddr: InetAddress) throws {
#if os(WASI)
      throw SocketException("MulticastSocket.leaveGroup() is not supported on WASI")
#else
      try setMulticastMembership(mcastaddr, join: false)
#endif
    }

    // MARK: - Private helpers

#if !os(WASI)
    private func setMulticastMembership(_ group: InetAddress, join: Bool) throws {
      var mreq = ip_mreq()
      inet_pton(AF_INET, group.getHostAddress(), &mreq.imr_multiaddr)
      mreq.imr_interface.s_addr = INADDR_ANY.bigEndian
#if canImport(Darwin)
      let option = join ? IP_ADD_MEMBERSHIP : IP_DROP_MEMBERSHIP
#else
      let option = join ? Int32(IP_ADD_MEMBERSHIP) : Int32(IP_DROP_MEMBERSHIP)
#endif
      let result = withUnsafePointer(to: &mreq) { ptr -> Int32 in
#if canImport(WinSDK)
        platformSetsockopt(
          self.fd,
          Int32(IPPROTO_IP),
          option,
          UnsafeRawPointer(ptr),
          socklen_t(MemoryLayout<ip_mreq>.size)
        )
#else
        setsockopt(
          self.fd,
          Int32(IPPROTO_IP),
          option,
          ptr,
          socklen_t(MemoryLayout<ip_mreq>.size)
        )
#endif
      }
      guard result == 0 else {
        throw SocketException("MulticastSocket.\(join ? "join" : "leave")Group() failed")
      }
    }
#endif
  }
}
