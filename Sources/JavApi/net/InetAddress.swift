/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

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

extension java.net {

  /// Represents an IP address (IPv4 or IPv6).
  ///
  /// Java 1.0 `java.net.InetAddress`. DNS resolution is performed synchronously
  /// via POSIX `getaddrinfo`, which is available on all supported platforms
  /// (macOS, iOS, Linux).
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public class InetAddress: @unchecked Sendable {

    private let hostname: String?
    private let addressString: String

    private init(hostname: String?, addressString: String) {
      self.hostname = hostname
      self.addressString = addressString
    }

    // MARK: - Factory methods

    /// Returns the `InetAddress` for the given hostname or literal IP string.
    ///
    /// - Throws: ``UnknownHostException`` if the host cannot be resolved.
    ///   On WASI, DNS resolution is unavailable; only literal IP strings are accepted.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public static func getByName(_ host: String) throws -> InetAddress {
      if isLiteralIP(host) {
        return InetAddress(hostname: nil, addressString: host)
      }
#if os(WASI)
      throw UnknownHostException("DNS resolution is unavailable on WASI: \(host)")
#else
      guard let resolved = resolveFirst(host) else {
        throw UnknownHostException(host)
      }
      return InetAddress(hostname: host, addressString: resolved)
#endif
    }

    /// Returns all `InetAddress` instances for the given hostname.
    ///
    /// - Throws: ``UnknownHostException`` if the host cannot be resolved.
    ///   On WASI, DNS resolution is unavailable; only literal IP strings are accepted.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public static func getAllByName(_ host: String) throws -> [InetAddress] {
      if isLiteralIP(host) {
        return [InetAddress(hostname: nil, addressString: host)]
      }
#if os(WASI)
      throw UnknownHostException("DNS resolution is unavailable on WASI: \(host)")
#else
      let resolved = resolveAll(host)
      guard !resolved.isEmpty else {
        throw UnknownHostException(host)
      }
      return resolved.map { InetAddress(hostname: host, addressString: $0) }
#endif
    }

    /// Returns the `InetAddress` of the local host.
    ///
    /// - Throws: ``UnknownHostException`` if the local hostname cannot be determined.
    ///   On WASI, always throws as there is no local host concept.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public static func getLocalHost() throws -> InetAddress {
#if os(WASI)
      throw UnknownHostException("getLocalHost is unavailable on WASI")
#else
      var buf = [CChar](repeating: 0, count: 256)
#if canImport(WinSDK)
      let hostnameResult = gethostname(&buf, Int32(buf.count))
#else
      let hostnameResult = gethostname(&buf, buf.count)
#endif
      guard hostnameResult == 0 else {
        throw UnknownHostException("localhost")
      }
      let name = String(bytes: buf.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }, encoding: .utf8) ?? ""
      return try getByName(name)
#endif
    }

    // MARK: - Accessors

    /// Returns the hostname, or the IP address string if no hostname is known.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getHostName() -> String {
      return hostname ?? addressString
    }

    /// Returns the IP address as a string (e.g. `"93.184.216.34"`).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getHostAddress() -> String {
      return addressString
    }

    /// Returns the raw address bytes.
    ///
    /// IPv4: 4 bytes. IPv6: 16 bytes.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getAddress() -> [byte] {
      return InetAddress.parseBytes(addressString)
    }

    // MARK: - Address type checks

    /// Returns `true` if this is a loopback address (`127.x.x.x` or `::1`).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func isLoopbackAddress() -> Bool {
      return addressString.hasPrefix("127.") || addressString == "::1"
    }

    /// Returns `true` if this is the wildcard address (`0.0.0.0` or `::`).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func isAnyLocalAddress() -> Bool {
      return addressString == "0.0.0.0" || addressString == "::"
    }

    /// Returns `true` if this is a link-local address.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func isLinkLocalAddress() -> Bool {
      return addressString.hasPrefix("169.254.") || addressString.lowercased().hasPrefix("fe80")
    }

    /// Returns `true` if this is a multicast address.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func isMulticastAddress() -> Bool {
      if let first = addressString.split(separator: ".").first,
         let octet = Int(first), octet >= 224, octet <= 239 {
        return true
      }
      return addressString.lowercased().hasPrefix("ff")
    }

    // MARK: - toString

    /// Returns `"hostname/address"` or just `"/address"` if no hostname is known.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func toString() -> String {
      if let h = hostname { return "\(h)/\(addressString)" }
      return "/\(addressString)"
    }

    // MARK: - Private helpers

    private static func isLiteralIP(_ s: String) -> Bool {
      // IPv4: contains only digits and dots
      if s.allSatisfy({ $0.isNumber || $0 == "." }) && s.contains(".") { return true }
      // IPv6: contains colons
      if s.contains(":") { return true }
      return false
    }

#if !os(WASI)
    private static func resolveAll(_ host: String) -> [String] {
      var results: [String] = []
      var hints = addrinfo()
#if canImport(Darwin) || os(Android)
      hints.ai_socktype = SOCK_STREAM
#elseif canImport(Glibc)
      hints.ai_socktype = numericCast(SOCK_STREAM.rawValue)
#else
      hints.ai_socktype = Int32(SOCK_STREAM)
#endif
      var res: UnsafeMutablePointer<addrinfo>? = nil
      guard getaddrinfo(host, nil, &hints, &res) == 0, let res else { return results }
      defer { freeaddrinfo(res) }
      var ptr: UnsafeMutablePointer<addrinfo>? = res
      while let current = ptr {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let gaiResult: Int32
#if os(Android)
        gaiResult = getnameinfo(
          current.pointee.ai_addr,
          current.pointee.ai_addrlen,
          &hostname,
          Int(NI_MAXHOST),
          nil, 0,
          NI_NUMERICHOST
        )
#elseif canImport(WinSDK)
        gaiResult = platformGetnameinfo(
          current.pointee.ai_addr,
          socklen_t(current.pointee.ai_addrlen),
          &hostname,
          socklen_t(NI_MAXHOST),
          nil, 0,
          NI_NUMERICHOST
        )
#else
        gaiResult = getnameinfo(
          current.pointee.ai_addr,
          current.pointee.ai_addrlen,
          &hostname,
          socklen_t(NI_MAXHOST),
          nil, 0,
          NI_NUMERICHOST
        )
#endif
        if gaiResult == 0 {
          let addr = String(bytes: hostname.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }, encoding: .utf8) ?? ""
          if !results.contains(addr) { results.append(addr) }
        }
        ptr = current.pointee.ai_next
      }
      return results
    }

    private static func resolveFirst(_ host: String) -> String? {
      return resolveAll(host).first
    }
#endif

    private static func parseBytes(_ address: String) -> [byte] {
      // IPv4
      let parts = address.split(separator: ".")
      if parts.count == 4, let bytes = parts.compactMap({ UInt8($0) }) as [UInt8]?,
         bytes.count == 4 {
        return bytes
      }
      // IPv6 — return empty for now (complex parsing)
      return []
    }
  }
}

// MARK: - Equatable / Hashable / CustomStringConvertible

extension java.net.InetAddress: Equatable {
  public static func == (lhs: java.net.InetAddress, rhs: java.net.InetAddress) -> Bool {
    return lhs.addressString == rhs.addressString
  }
}

extension java.net.InetAddress: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(addressString)
  }
}

extension java.net.InetAddress: CustomStringConvertible {
  public var description: String { toString() }
}
