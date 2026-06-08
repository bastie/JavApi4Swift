/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if (os(macOS) && swift(>=6.0)) || (os(iOS) && swift(>=6.0)) || (os(tvOS) && swift(>=6.0)) || (os(visionOS) && swift(>=6.0))
import Synchronization
// Verwende Mutex von Synchronization auf unterstützten Plattformen
public typealias CrossPlatformMutex = Mutex<Sendable>
#elseif os(WASI)
// WASM/WASI: kein Dispatch, kein NSLock – Single-threaded, kein echter Mutex nötig
/// WARNING DO NOT USE THIS CLASS DIRECT
public final class CrossPlatformMutex : @unchecked Sendable {
  public init(_ lockObject: Sendable) {}
  public init(_ value: Int) {}

  public func withLock<T>(_ body: (Sendable) throws -> T) rethrows -> T {
    // WASI ist single-threaded, kein Locking erforderlich
    return try body(0 as Sendable)
  }
}
#else
// Fallback-Implementierung für watchOS und andere Plattformen
import Foundation
import Dispatch

/// WARNING DO NOT USE THIS CLASS DIRECT
public final class CrossPlatformMutex : @unchecked Sendable {
  private let lock: NSLock

  public init(_ lockObject: Sendable) {
    self.lock = NSLock()
  }

  public init(_ value: Int) {
    self.lock = NSLock()
  }

  public func withLock<T>(_ body: (Sendable) throws -> T) rethrows -> T {
    lock.lock()
    defer { lock.unlock() }
    // return Dummy for compatibility
    return try body(lock)
  }
}
#endif
