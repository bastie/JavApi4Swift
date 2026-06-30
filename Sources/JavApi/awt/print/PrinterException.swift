/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.print {

  /// Signals that an error occurred during printing —
  /// mirrors `java.awt.print.PrinterException`.
  ///
  /// - Since: Java 1.2
  public class PrinterException: java.lang.Exception, @unchecked Sendable {

    public override init(_ message: String = "") {
      super.init(message)
    }
  }

  /// Thrown when a print job is aborted, either by the user or the system —
  /// mirrors `java.awt.print.PrinterAbortException`.
  ///
  /// - Since: Java 1.2
  public final class PrinterAbortException: PrinterException, @unchecked Sendable {

    public override init(_ message: String = "") {
      super.init(message)
    }
  }

  /// Wraps an I/O error that occurred during printing —
  /// mirrors `java.awt.print.PrinterIOException`.
  ///
  /// - Since: Java 1.2
  public final class PrinterIOException: PrinterException, @unchecked Sendable {

    public let ioException: java.io.IOException

    public init(_ exception: java.io.IOException) {
      self.ioException = exception
      super.init(exception.getMessage() ?? "I/O error during printing")
    }
  }
}
