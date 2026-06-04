/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.lang {

  /// Represents a native process started by the runtime.
  ///
  /// Mirrors `java.lang.Process` from Java 1.0. In Java, `Process` is an
  /// abstract class returned by `Runtime.exec(...)`. This Swift implementation
  /// is a concrete class backed by `Foundation.Process`.
  ///
  /// Typical usage via `java.lang.Runtime`:
  /// ```swift
  /// let p = try java.lang.Runtime.getRuntime().exec("ls -la")
  /// let status = try p.waitFor()
  /// ```
  ///
  /// - Note: `getInputStream`, `getOutputStream`, and `getErrorStream` are
  ///   partially implemented — standard output and error are captured via
  ///   `Pipe`; standard input can be written through the returned `OutputStream`.
  ///
  /// - Since: JavaApi (Java 1.0)
  public class Process {

    // MARK: - Delegate

    internal let delegate: Foundation.Process
    private let stdoutPipe = Pipe()
    private let stderrPipe = Pipe()
    private let stdinPipe  = Pipe()

    // MARK: - Internal init (used by Runtime.exec)

    internal init(_ process: Foundation.Process) {
      self.delegate = process
      process.standardOutput = stdoutPipe
      process.standardError  = stderrPipe
      process.standardInput  = stdinPipe
    }

    // MARK: - Java 1.0 API

    /// Returns an `InputStream` connected to the standard output of the process.
    ///
    /// - Returns: An `InputStream` reading from the process stdout.
    /// - Since: JavaApi (Java 1.0)
    public func getInputStream() -> java.io.InputStream {
      return PipeInputStream(pipe: stdoutPipe)
    }

    /// Returns an `InputStream` connected to the standard error of the process.
    ///
    /// - Returns: An `InputStream` reading from the process stderr.
    /// - Since: JavaApi (Java 1.0)
    public func getErrorStream() -> java.io.InputStream {
      return PipeInputStream(pipe: stderrPipe)
    }

    /// Returns an `OutputStream` connected to the standard input of the process.
    ///
    /// - Returns: An `OutputStream` writing to the process stdin.
    /// - Since: JavaApi (Java 1.0)
    public func getOutputStream() -> java.io.OutputStream {
      return PipeOutputStream(pipe: stdinPipe)
    }

    /// Waits for the process to finish and returns its exit value.
    ///
    /// - Returns: Exit status of the process (0 typically means success).
    /// - Throws: `java.lang.InterruptedException` if the current thread is
    ///   interrupted while waiting.
    /// - Since: JavaApi (Java 1.0)
    @discardableResult
    public func waitFor() throws -> Int {
      delegate.waitUntilExit()
      return Int(delegate.terminationStatus)
    }

    /// Returns the exit value of the process.
    ///
    /// - Returns: Exit status of the process.
    /// - Throws: `java.lang.IllegalThreadStateException` if the process has
    ///   not yet terminated.
    /// - Since: JavaApi (Java 1.0)
    public func exitValue() throws -> Int {
      guard !delegate.isRunning else {
        throw java.lang.IllegalThreadStateException("process has not terminated")
      }
      return Int(delegate.terminationStatus)
    }

    /// Kills the process.
    /// - Since: JavaApi (Java 1.0)
    public func destroy() {
      delegate.terminate()
    }
  }
}

// MARK: - Internal stream adapters

/// Wraps a `Pipe`'s read end as a `java.io.InputStream`.
internal final class PipeInputStream : java.io.InputStream {
  private let pipe: Pipe
  private var buffer: Data = Data()
  private var offset: Int = 0

  init(pipe: Pipe) {
    self.pipe = pipe
  }

  public override func read() throws -> Int {
    if offset >= buffer.count {
      buffer = pipe.fileHandleForReading.availableData
      offset = 0
      if buffer.isEmpty { return -1 }
    }
    let byte = Int(buffer[offset])
    offset += 1
    return byte
  }
}

/// Wraps a `Pipe`'s write end as a `java.io.OutputStream`.
internal final class PipeOutputStream : java.io.OutputStream {
  private let pipe: Pipe

  init(pipe: Pipe) {
    self.pipe = pipe
  }

  public override func write(_ b: Int) throws {
    let byte = UInt8(b & 0xFF)
    pipe.fileHandleForWriting.write(Data([byte]))
  }
}
