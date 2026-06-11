/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(Darwin)
import Darwin
#elseif os(Windows)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

extension java.lang {

  /// Represents the runtime environment of the running application.
  ///
  /// Every application has a single `Runtime` instance obtained via
  /// `Runtime.getRuntime()`. This Swift implementation delegates to
  /// `Foundation.Process` for process execution and `ProcessInfo` for
  /// memory and CPU queries.
  ///
  /// - Since: Java 1.0
  public final class Runtime {

    // MARK: - Singleton

    nonisolated(unsafe) private static let instance = Runtime()
    private init() {}

    /// Returns the runtime object associated with the current application.
    ///
    /// - Returns: The single `Runtime` instance.
    /// - Since: Java 1.0
    public static func getRuntime() -> Runtime {
      return instance
    }

    // MARK: - Process execution

    /// Executes the specified string command in a separate process.
    ///
    /// - Parameter command: The command to execute.
    /// - Returns: A `Process` object representing the running process.
    /// - Throws: `java.io.IOException` if the command cannot be started.
    /// - Since: Java 1.0
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

    // MARK: - Processors

    /// Returns the number of processors available to the runtime.
    ///
    /// - Returns: The number of logical CPUs available to the process.
    /// - Since: Java 1.4
    public func availableProcessors() -> Int {
      return ProcessInfo.processInfo.processorCount
    }

    // MARK: - Memory

    /// Returns the amount of free memory available to the runtime (bytes).
    ///
    /// Computed as `maxMemory() - totalMemory()`. Returns `-1` on platforms
    /// where the current memory usage cannot be determined (e.g. WASM/WASI).
    ///
    /// - Returns: Free memory in bytes, or `-1` if not measurable.
    /// - Since: Java 1.0
    public func freeMemory() -> Int64 {
      let total = totalMemory()
      guard total >= 0 else { return -1 }
      return maxMemory() - total
    }

    /// Returns the current resident memory usage of the process (bytes).
    ///
    /// Platform mapping:
    /// - Apple platforms: `task_info` / `phys_footprint`
    /// - Linux / Android: `/proc/self/status` → `VmRSS`
    /// - FreeBSD: `sysctl` → `ki_rssize`
    /// - Windows: `GetProcessMemoryInfo` → `WorkingSetSize`
    /// - WASM/WASI: `-1` (not available)
    ///
    /// - Returns: Resident memory in bytes, or `-1` if not measurable.
    /// - Since: Java 1.0
    public func totalMemory() -> Int64 {
#if os(WASI)
      return -1
#elseif canImport(Darwin)
      var info = task_vm_info_data_t()
      var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
      let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
          task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
        }
      }
      return result == KERN_SUCCESS ? Int64(info.phys_footprint) : -1
#elseif os(Windows)
      var pmc = PROCESS_MEMORY_COUNTERS()
      pmc.cb = DWORD(MemoryLayout<PROCESS_MEMORY_COUNTERS>.size)
      return K32GetProcessMemoryInfo(GetCurrentProcess(), &pmc, pmc.cb)
        ? Int64(pmc.WorkingSetSize) : -1
#elseif os(FreeBSD)
      // FreeBSD: use sysctl kern.proc.pid.<pid> → ki_rssize (pages)
      var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, Int32(getpid())]
      var kinfo = kinfo_proc()
      var size = MemoryLayout<kinfo_proc>.size
      let rc = sysctl(&mib, 4, &kinfo, &size, nil, 0)
      return rc == 0 ? Int64(kinfo.ki_rssize) * Int64(PAGE_SIZE) : -1
#elseif os(Linux) || os(Android)
      // Linux/Android: read VmRSS from /proc/self/status
      guard let content = try? String(contentsOfFile: "/proc/self/status", encoding: .utf8) else {
        return -1
      }
      for line in content.split(separator: "\n") {
        if line.hasPrefix("VmRSS:") {
          let parts = line.split(separator: " ")
          if let kb = Int64(parts.last(where: { Int64($0) != nil }) ?? "") {
            return kb * 1024
          }
        }
      }
      return -1
#else
      return -1
#endif
    }

    /// Returns the maximum amount of memory the runtime will attempt to use (bytes).
    ///
    /// Maps to the total physical memory of the device via `ProcessInfo`.
    ///
    /// - Returns: Physical memory of the device in bytes.
    /// - Since: Java 1.4
    public func maxMemory() -> Int64 {
      return Int64(ProcessInfo.processInfo.physicalMemory)
    }

    // MARK: - GC / exit

    /// Runs the garbage collector. No-op in Swift (ARC).
    ///
    /// - Since: Java 1.0
    public func gc() {}

    /// Terminates the current process with the given status code.
    ///
    /// - Parameter status: The exit status.
    /// - Since: Java 1.0
    public func exit(_ status: Int) {
      Foundation.exit(Int32(status))
    }
  }
}
