/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.io {
  open class PrintStream : FilterOutputStream {

    public func print (_ s : String) {
      do {
        try self.write([UInt8] (s.data(using: .utf8)!))
      }
      catch {
        // ignored
      }
    }
    public func println (_ s : String) {
      let withLineBreak = s.appending("\n");
      do {
        try self.write([UInt8] (withLineBreak.data(using: .utf8)!))
      }
      catch {
        // ignored
      }
    }

    // -------------------------------------------------------------------------
    // MARK: printf / format — Java-compatible formatted output
    // -------------------------------------------------------------------------

    /// Writes a formatted string to this stream.
    ///
    /// Equivalent to Java's `PrintStream.printf(String, Object...)`.
    ///
    /// - Parameters:
    ///   - format: A Java-style format string.
    ///   - args:   Arguments referenced by the format specifiers.
    /// - Returns: `self` (Java convention; allows chaining).
    /// - Throws: An appropriate `java.util.IllegalFormatException` subclass
    ///   if `format` is malformed or `args` does not match it. In real Java
    ///   these are unchecked `RuntimeException`s that `printf`/`format`
    ///   don't declare but still propagate; this port makes that failure
    ///   explicit via `throws` instead of via `fatalError`/silent swallowing
    ///   (see Java2Swift.md's throws-not-fatalError convention).
    @discardableResult
    public func printf(_ format: String, _ args: Any?...) throws -> java.io.PrintStream {
      print(try Java2SwiftFormatter.format(format, args: args))
      return self
    }

    /// Array-overload for callers that already have an `[Any?]` argument list.
    ///
    /// - Throws: See ``printf(_:_:)``.
    @discardableResult
    public func printf(_ format: String, args: [Any?]) throws -> java.io.PrintStream {
      print(try Java2SwiftFormatter.format(format, args: args))
      return self
    }

    /// `format` is an alias for `printf` in Java's `PrintStream`.
    ///
    /// - Throws: See ``printf(_:_:)``.
    @discardableResult
    public func format(_ format: String, _ args: Any?...) throws -> java.io.PrintStream {
      print(try Java2SwiftFormatter.format(format, args: args))
      return self
    }
  } // EOT

} // EOP
