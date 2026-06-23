/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.net.DatagramSocket — Java 1.1 additions")
struct JavApi_net_DatagramSocket_1_1_Tests {

  // MARK: - getLocalAddress

  @Test("getLocalAddress() returns non-nil after bind")
  func getLocalAddress_returnsNonNil() throws {
    #if os(WASI)
    throw XCTSkip("DatagramSocket not available on WASI")
    #else
    let socket = try java.net.DatagramSocket()
    defer { socket.close() }
    let addr = socket.getLocalAddress()
    #expect(addr != nil)
    #endif
  }

  @Test("getLocalAddress() returns a valid IP string")
  func getLocalAddress_validIPString() throws {
    #if os(WASI)
    throw XCTSkip("DatagramSocket not available on WASI")
    #else
    let socket = try java.net.DatagramSocket()
    defer { socket.close() }
    let addr = socket.getLocalAddress()
    let ip = addr?.getHostAddress() ?? ""
    // Should be either 0.0.0.0 (INADDR_ANY) or 127.0.0.1 / some real interface
    #expect(!ip.isEmpty)
    let parts = ip.split(separator: ".").compactMap { Int($0) }
    #expect(parts.count == 4)
    for part in parts {
      #expect(part >= 0 && part <= 255)
    }
    #endif
  }

  @Test("getLocalAddress() bound to specific address reflects that address")
  func getLocalAddress_boundToSpecificAddress() throws {
    #if os(WASI)
    throw XCTSkip("DatagramSocket not available on WASI")
    #else
    let loopback = try java.net.InetAddress.getByName("127.0.0.1")
    let socket   = try java.net.DatagramSocket(0, loopback)
    defer { socket.close() }
    let addr = socket.getLocalAddress()
    #expect(addr?.getHostAddress() == "127.0.0.1")
    #endif
  }

  // MARK: - Constructor (int port, InetAddress laddr)

  @Test("Constructor(port, laddr) binds to given port and address")
  func constructor_portAndAddress() throws {
    #if os(WASI)
    throw XCTSkip("DatagramSocket not available on WASI")
    #else
    let loopback = try java.net.InetAddress.getByName("127.0.0.1")
    let socket   = try java.net.DatagramSocket(0, loopback)
    defer { socket.close() }
    #expect(socket.getLocalPort() > 0)
    #expect(socket.getLocalAddress()?.getHostAddress() == "127.0.0.1")
    #endif
  }

  // MARK: - getSoTimeout / setSoTimeout

  @Test("getSoTimeout() returns 0 by default")
  func getSoTimeout_defaultIsZero() throws {
    #if os(WASI)
    throw XCTSkip("DatagramSocket not available on WASI")
    #else
    let socket = try java.net.DatagramSocket()
    defer { socket.close() }
    #expect(socket.getSoTimeout() == 0)
    #endif
  }

  @Test("setSoTimeout/getSoTimeout roundtrip")
  func setSoTimeout_roundtrip() throws {
    #if os(WASI)
    throw XCTSkip("DatagramSocket not available on WASI")
    #else
    let socket = try java.net.DatagramSocket()
    defer { socket.close() }
    socket.setSoTimeout(500)
    #expect(socket.getSoTimeout() == 500)
    socket.setSoTimeout(0)
    #expect(socket.getSoTimeout() == 0)
    #endif
  }
}
