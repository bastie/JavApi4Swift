/*
 * SPDX-FileCopyrightText: 2024-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(Network)
import Network
#endif

extension java.io {
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public final class FileDescriptor {

    // =========================================================================
    // MARK: - Storage
    // =========================================================================

    /// The underlying Foundation file handle, if any.
    internal var fileHandle: FileHandle?

    /// Tracks whether `sync()` / external `close()` has been called.
    ///
    /// Foundation's `FileHandle.fileDescriptor` property raises an ObjC
    /// exception when accessed on a closed handle — there is no safe way to
    /// query liveness through the public API after `close()`.  We therefore
    /// maintain our own closed-flag and set it from `FileInputStream`,
    /// `FileOutputStream`, and similar wrappers when they close the handle.
    internal var _closed: Bool = false

#if canImport(Network)
    private var connection: NWConnection?
#endif

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public init() {}

    internal init(handle: FileHandle) {
      self.fileHandle = handle
    }

#if canImport(Network)
    internal init(handle: NWConnection) {
      self.connection = handle
    }
#endif

    // =========================================================================
    // MARK: - Java API
    // =========================================================================

    /// Returns `true` when the underlying OS resource is open and usable.
    ///
    /// Mirrors `java.io.FileDescriptor.valid()`.
    ///
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public func valid() -> Bool {
      if fileHandle != nil {
        return !_closed
      }
#if canImport(Network)
      if let connection {
        if case .ready = connection.state { return true }
        return false
      }
#endif
      return false
    }

    /// Marks this descriptor as closed.
    ///
    /// Called by stream wrappers (`FileInputStream`, `FileOutputStream`, …)
    /// after they close the underlying `FileHandle`.
    internal func markClosed() {
      _closed = true
    }
  }
}
