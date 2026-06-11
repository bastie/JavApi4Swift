/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

@Suite("java.net.InetAddress")
struct JavApi_net_InetAddress_Tests {

  // MARK: - getHostName

  @Test("getHostName returns hostname for named address")
  func getHostName_returnsHostname() throws {
    let addr = try java.net.InetAddress.getByName("localhost")
    #expect(addr.getHostName() == "localhost")
  }

  @Test("getHostName returns address string for literal IP (no hostname)")
  func getHostName_literalIP_returnsAddressString() throws {
    let addr = try java.net.InetAddress.getByName("127.0.0.1")
    // Literal IPs are stored without a hostname — getHostName() falls back to the address.
    #expect(addr.getHostName() == "127.0.0.1")
  }

  // MARK: - getAddress

  @Test("getAddress returns 4 bytes for IPv4 loopback")
  func getAddress_ipv4Loopback_returns4Bytes() throws {
    let addr = try java.net.InetAddress.getByName("127.0.0.1")
    let bytes = addr.getAddress()
    #expect(bytes.count == 4)
    #expect(bytes[0] == 127)
    #expect(bytes[1] == 0)
    #expect(bytes[2] == 0)
    #expect(bytes[3] == 1)
  }

  @Test("getAddress returns correct bytes for 192.168.0.1")
  func getAddress_privateNetwork_returnsCorrectBytes() throws {
    let addr = try java.net.InetAddress.getByName("192.168.0.1")
    let bytes = addr.getAddress()
    #expect(bytes.count == 4)
    #expect(bytes[0] == 192)
    #expect(bytes[1] == 168)
    #expect(bytes[2] == 0)
    #expect(bytes[3] == 1)
  }

  // MARK: - getHostAddress

  @Test("getHostAddress returns IP string")
  func getHostAddress_returnsIPString() throws {
    let addr = try java.net.InetAddress.getByName("127.0.0.1")
    #expect(addr.getHostAddress() == "127.0.0.1")
  }

  // MARK: - isLoopbackAddress

  @Test("isLoopbackAddress is true for 127.0.0.1")
  func isLoopbackAddress_ipv4() throws {
    let addr = try java.net.InetAddress.getByName("127.0.0.1")
    #expect(addr.isLoopbackAddress())
  }

  @Test("isLoopbackAddress is false for 192.168.0.1")
  func isLoopbackAddress_notLoopback() throws {
    let addr = try java.net.InetAddress.getByName("192.168.0.1")
    #expect(!addr.isLoopbackAddress())
  }
}
