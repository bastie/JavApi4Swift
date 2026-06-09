/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.lang {

  /// Represents the runtime environment of the running application.
  ///
  /// Java 1.0 `java.lang.Runtime`. In Java every application has a single
  /// `Runtime` instance obtained via `Runtime.getRuntime()`. This Swift
  /// implementation delegates to `Foundation.Process` for process execution.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public final class Runtime {

    // MARK: - Singleton

    nonisolated(unsafe) private static let instance = Runtime()
    private init() {}

    /// Returns the runtime object associated with the current application.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public static func getRuntime() -> Runtime {
      return instance
    }

    // MARK: - Process execution

    /// Executes the specified string command in a separate process.
    ///
    /// - Throws: `java.io.IOException` if the command cannot be started.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func exec(_ command: String) throws -> java.lang.Process {
#if os(WASI)
      throw java.io.IOException("exec() is unavailable on WASI")
#elseif canImport(Foundation) && (os(macOS) || os(Linux) || os(FreeBSD))
      let fp = Foundation.Process()
      fp.executableURL = URL(fileURLWithPath: "/bin/sh")
      fp.arguments = ["-c", command]
      do {
        try fp.run()
      } catch {
        throw java.io.IOException(error.localizedDescription)
      }
      return java.lang.Process(fp)
#else
      throw java.lang.UnsupportedOperationException("exec() is not supported on this platform")
#endif
    }

    // MARK: - Memory

    /// Returns the amount of free memory (bytes) in the Swift/Foundation heap.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func freeMemory() -> Int64 {
      return Int64(ProcessInfo.processInfo.physicalMemory / 2) // approximation
    }

    /// Returns the total memory currently available to the runtime (bytes).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func totalMemory() -> Int64 {
      return Int64(ProcessInfo.processInfo.physicalMemory)
    }

    // MARK: - GC / exit

    /// Runs the garbage collector. No-op in Swift (ARC).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func gc() {}

    /// Terminates the current process with the given status code.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func exit(_ status: Int) {
      Foundation.exit(Int32(status))
    }
  }
}
