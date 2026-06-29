/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

// MARK: - Pure-Swift IPv4 formatting (platform independent)

/// Formats an IPv4 `in_addr` as a dotted-quad string without using `inet_ntop`.
///
/// `inet_ntop` is not reliably exported by the `SwiftGlibc` module overlay on
/// FreeBSD: it is gated behind `_BSD_VISIBLE` in `<arpa/inet.h>`, so on FreeBSD
/// the symbol is reported as "cannot find 'inet_ntop' in scope" even though
/// `socket`, `bind`, and `inet_pton` resolve fine. A manual implementation
/// behaves identically on every platform (Darwin, Linux, Musl, Android,
/// Windows, FreeBSD) and avoids the C buffer dance entirely.
///
/// - Parameter sAddr: The raw `s_addr` value of an IPv4 `in_addr`, in network
///   byte order (big endian). Taking `UInt32` rather than `in_addr` keeps this
///   independent of the platform's address struct (`in_addr` vs. Windows
///   `IN_ADDR`).
/// - Returns: The dotted-quad representation, e.g. `"192.168.0.1"`.
@inline(__always)
public func platformIPv4String(_ sAddr: UInt32) -> String {
  // sAddr is in network byte order (big endian); normalise to host order
  // then extract the four octets most-significant first.
  let host = UInt32(bigEndian: sAddr)
  let b0 = (host >> 24) & 0xFF
  let b1 = (host >> 16) & 0xFF
  let b2 = (host >> 8) & 0xFF
  let b3 = host & 0xFF
  return "\(b0).\(b1).\(b2).\(b3)"
}

/// Parses a dotted-quad IPv4 string into a network-byte-order `s_addr` value.
///
/// Pure-Swift counterpart to `inet_pton(AF_INET, …)`. Used to avoid relying on
/// `inet_pton`/`inet_ntop` being visible in the `SwiftGlibc` overlay on
/// FreeBSD. Returns `nil` if the string is not a valid dotted-quad address.
///
/// - Parameter text: e.g. `"192.168.0.1"`.
/// - Returns: The `s_addr` value (network byte order) or `nil` if invalid.
@inline(__always)
public func platformParseIPv4(_ text: String) -> UInt32? {
  let parts = text.split(separator: ".", omittingEmptySubsequences: false)
  guard parts.count == 4 else { return nil }
  var octets: [UInt32] = []
  octets.reserveCapacity(4)
  for part in parts {
    guard let value = UInt32(part), value <= 255 else { return nil }
    octets.append(value)
  }
  let host = (octets[0] << 24) | (octets[1] << 16) | (octets[2] << 8) | octets[3]
  // Return in network byte order, matching in_addr.s_addr.
  return host.bigEndian
}

#if os(Android)
// Android's Bionic libc exposes POSIX symbols via the Android module rather
// than Foundation. These shims provide platform-agnostic wrappers so the
// rest of the codebase does not need per-file #if os(Android) guards.
import Android

// MARK: - Missing Bionic constants

public let INADDR_ANY: UInt32 = 0x00000000
public let SO_RCVTIMEO: Int32 = 20

// MARK: - File descriptor

// close(2) — Foundation.close does not exist on Android
@discardableResult
@inline(__always)
public func platformClose(_ fd: Int32) -> Int32 {
  return close(fd)
}

// MARK: - Socket

// connect(2)
@discardableResult
@inline(__always)
public func platformConnect(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 {
  return connect(fd, addr, len)
}

// bind(2)
@discardableResult
@inline(__always)
public func platformBind(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 {
  return bind(fd, addr, len)
}

// accept(2)
@inline(__always)
public func platformAccept(_ fd: Int32, _ addr: UnsafeMutablePointer<sockaddr>!, _ len: UnsafeMutablePointer<socklen_t>!) -> Int32 {
  return accept(fd, addr, len)
}

#elseif canImport(Darwin)
import Darwin

@discardableResult @inline(__always)
public func platformClose(_ fd: Int32) -> Int32 { close(fd) }
@discardableResult @inline(__always)
public func platformConnect(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 { connect(fd, addr, len) }
@discardableResult @inline(__always)
public func platformBind(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 { bind(fd, addr, len) }
@inline(__always)
public func platformAccept(_ fd: Int32, _ addr: UnsafeMutablePointer<sockaddr>!, _ len: UnsafeMutablePointer<socklen_t>!) -> Int32 { accept(fd, addr, len) }

#elseif canImport(Glibc)
import Glibc

@discardableResult @inline(__always)
public func platformClose(_ fd: Int32) -> Int32 { close(fd) }
@discardableResult @inline(__always)
public func platformConnect(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 { connect(fd, addr, len) }
@discardableResult @inline(__always)
public func platformBind(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 { bind(fd, addr, len) }
@inline(__always)
public func platformAccept(_ fd: Int32, _ addr: UnsafeMutablePointer<sockaddr>!, _ len: UnsafeMutablePointer<socklen_t>!) -> Int32 { accept(fd, addr, len) }

#elseif canImport(Musl)
import Musl

@discardableResult @inline(__always)
public func platformClose(_ fd: Int32) -> Int32 { close(fd) }
@discardableResult @inline(__always)
public func platformConnect(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 { connect(fd, addr, len) }
@discardableResult @inline(__always)
public func platformBind(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 { bind(fd, addr, len) }
@inline(__always)
public func platformAccept(_ fd: Int32, _ addr: UnsafeMutablePointer<sockaddr>!, _ len: UnsafeMutablePointer<socklen_t>!) -> Int32 { accept(fd, addr, len) }

#elseif canImport(WinSDK)
import WinSDK

// MARK: - Missing Winsock constants / types

// INADDR_ANY is defined in WinSDK as UInt32 — no redefinition needed.
// SO_RCVTIMEO on Windows is 0x1006
public let SO_RCVTIMEO: Int32 = 0x1006

// sa_family_t does not exist in WinSDK; ADDRESS_FAMILY (UInt16) is the equivalent.
public typealias sa_family_t = ADDRESS_FAMILY

// timeval field names on Windows are Long (Int32), same as POSIX Int32 —
// but the Swift overlay spells them differently. Provide a shim init.
extension timeval {
  public init(tv_sec: Int32, tv_usec: Int32) {
    self.init()
    self.tv_sec  = tv_sec
    self.tv_usec = tv_usec
  }
}

// MARK: - sockaddr_in helpers

// WinSDK's IN_ADDR does not expose `s_addr` directly; it goes through S_un.S_addr.
// Provide a mutable computed property so existing code can write addr.sin_addr.s_addr.
extension IN_ADDR {
  public var s_addr: UInt32 {
    get { return S_un.S_addr }
    set { S_un.S_addr = newValue }
  }
}

// MARK: - Winsock wrappers that accept/return Int32 file descriptors

// socket(2) — returns Int32 (-1 on failure)
@inline(__always)
public func platformSocket(_ domain: Int32, _ type: Int32, _ proto: Int32) -> Int32 {
  let s = WinSDK.socket(domain, type, proto)
  return s == INVALID_SOCKET ? -1 : Int32(bitPattern: UInt32(s & 0xFFFF_FFFF))
}

// setsockopt(2)
@discardableResult @inline(__always)
public func platformSetsockopt(_ fd: Int32, _ level: Int32, _ optname: Int32,
                                _ optval: UnsafeRawPointer!, _ optlen: socklen_t) -> Int32 {
  return WinSDK.setsockopt(SOCKET(bitPattern: Int64(fd)), level, optname,
                           optval.assumingMemoryBound(to: CChar.self), optlen)
}

// getsockopt(2)
@discardableResult @inline(__always)
public func platformGetsockopt(_ fd: Int32, _ level: Int32, _ optname: Int32,
                                _ optval: UnsafeMutableRawPointer!, _ optlen: UnsafeMutablePointer<socklen_t>!) -> Int32 {
  return WinSDK.getsockopt(SOCKET(bitPattern: Int64(fd)), level, optname,
                           optval.assumingMemoryBound(to: CChar.self), optlen)
}

// getsockname(2)
@discardableResult @inline(__always)
public func platformGetsockname(_ fd: Int32, _ addr: UnsafeMutablePointer<sockaddr>!,
                                 _ len: UnsafeMutablePointer<Int32>!) -> Int32 {
  return WinSDK.getsockname(SOCKET(bitPattern: Int64(fd)), addr, len)
}

// listen(2)
@discardableResult @inline(__always)
public func platformListen(_ fd: Int32, _ backlog: Int32) -> Int32 {
  return WinSDK.listen(SOCKET(bitPattern: Int64(fd)), backlog)
}

// recv(2)
@discardableResult @inline(__always)
public func platformRecv(_ fd: Int32, _ buf: UnsafeMutableRawPointer!, _ len: Int, _ flags: Int32) -> Int {
  let n = WinSDK.recv(SOCKET(bitPattern: Int64(fd)),
                      buf.assumingMemoryBound(to: CChar.self), Int32(len), flags)
  return n == SOCKET_ERROR ? -1 : Int(n)
}

// send(2)
@discardableResult @inline(__always)
public func platformSend(_ fd: Int32, _ buf: UnsafeRawPointer!, _ len: Int, _ flags: Int32) -> Int {
  let n = WinSDK.send(SOCKET(bitPattern: Int64(fd)),
                      buf.assumingMemoryBound(to: CChar.self), Int32(len), flags)
  return n == SOCKET_ERROR ? -1 : Int(n)
}

// sendto(2)
@discardableResult @inline(__always)
public func platformSendto(_ fd: Int32, _ buf: UnsafeRawPointer!, _ len: Int, _ flags: Int32,
                            _ dest: UnsafePointer<sockaddr>!, _ destLen: socklen_t) -> Int {
  let n = WinSDK.sendto(SOCKET(bitPattern: Int64(fd)),
                        buf.assumingMemoryBound(to: CChar.self), Int32(len), flags, dest, Int32(destLen))
  return n == SOCKET_ERROR ? -1 : Int(n)
}

// recvfrom(2)
@discardableResult @inline(__always)
public func platformRecvfrom(_ fd: Int32, _ buf: UnsafeMutableRawPointer!, _ len: Int, _ flags: Int32,
                              _ src: UnsafeMutablePointer<sockaddr>!,
                              _ srcLen: UnsafeMutablePointer<socklen_t>!) -> Int {
  var addrLen = Int32(srcLen?.pointee ?? 0)
  let n = WinSDK.recvfrom(SOCKET(bitPattern: Int64(fd)),
                          buf.assumingMemoryBound(to: CChar.self), Int32(len), flags, src, &addrLen)
  srcLen?.pointee = socklen_t(addrLen)
  return n == SOCKET_ERROR ? -1 : Int(n)
}

// inet_ntop — same signature as POSIX but result is optional
@discardableResult @inline(__always)
public func platformInet_ntop(_ af: Int32, _ src: UnsafeRawPointer!,
                               _ dst: UnsafeMutablePointer<CChar>!, _ size: socklen_t) -> UnsafePointer<CChar>? {
  return WinSDK.inet_ntop(af, src, dst, Int(size))
}

// getnameinfo — 4th param is DWORD on Windows, socklen_t (Int32) elsewhere
@discardableResult @inline(__always)
public func platformGetnameinfo(_ addr: UnsafePointer<sockaddr>!, _ addrLen: socklen_t,
                                 _ host: UnsafeMutablePointer<CChar>!, _ hostLen: socklen_t,
                                 _ serv: UnsafeMutablePointer<CChar>!, _ servLen: socklen_t,
                                 _ flags: Int32) -> Int32 {
  return WinSDK.getnameinfo(addr, addrLen, host, DWORD(hostLen), serv, DWORD(servLen), flags)
}

// MARK: - File descriptor / close

@discardableResult @inline(__always)
public func platformClose(_ fd: Int32) -> Int32 {
  return Int32(closesocket(SOCKET(bitPattern: Int64(fd))))
}

// MARK: - Higher-level socket wrappers

@discardableResult @inline(__always)
public func platformConnect(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 {
  return WinSDK.connect(SOCKET(bitPattern: Int64(fd)), addr, Int32(len))
}

@discardableResult @inline(__always)
public func platformBind(_ fd: Int32, _ addr: UnsafePointer<sockaddr>!, _ len: socklen_t) -> Int32 {
  return WinSDK.bind(SOCKET(bitPattern: Int64(fd)), addr, Int32(len))
}

@inline(__always)
public func platformAccept(_ fd: Int32, _ addr: UnsafeMutablePointer<sockaddr>!, _ len: UnsafeMutablePointer<socklen_t>!) -> Int32 {
  var addrLen = Int32(len?.pointee ?? 0)
  let result = WinSDK.accept(SOCKET(bitPattern: Int64(fd)), addr, &addrLen)
  len?.pointee = socklen_t(addrLen)
  return result == INVALID_SOCKET ? -1 : Int32(result)
}
#endif
