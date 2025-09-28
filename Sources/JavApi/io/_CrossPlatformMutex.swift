/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(Synchronization)
import Synchronization
// Verwende Mutex von Synchronization auf unterstützten Plattformen
public typealias CrossPlatformMutex = Mutex<Sendable>
#else
// Fallback-Implementierung
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
