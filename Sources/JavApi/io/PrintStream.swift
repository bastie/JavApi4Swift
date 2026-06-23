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
    @discardableResult
    public func printf(_ format: String, _ args: Any?...) -> java.io.PrintStream {
      print(Java2SwiftFormatter.format(format, args: args))
      return self
    }

    /// Array-overload for callers that already have an `[Any?]` argument list.
    @discardableResult
    public func printf(_ format: String, args: [Any?]) -> java.io.PrintStream {
      print(Java2SwiftFormatter.format(format, args: args))
      return self
    }

    /// `format` is an alias for `printf` in Java's `PrintStream`.
    @discardableResult
    public func format(_ format: String, _ args: Any?...) -> java.io.PrintStream {
      print(Java2SwiftFormatter.format(format, args: args))
      return self
    }
  } // EOT

} // EOP
