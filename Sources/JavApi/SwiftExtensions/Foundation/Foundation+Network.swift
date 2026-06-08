/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

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
#endif
