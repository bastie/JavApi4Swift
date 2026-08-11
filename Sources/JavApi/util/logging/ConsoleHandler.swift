/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {

  /// A `Handler` that writes formatted log records to `stderr`.
  ///
  /// The default level is `Level.INFO` and the default formatter is
  /// `SimpleFormatter`, matching `java.util.logging.ConsoleHandler` (Java 1.4).
  ///
  /// Output goes to the standard error stream (`stderr`) so it does not
  /// interfere with program output on `stdout`.
  ///
  /// - Since: Java 1.4
  open class ConsoleHandler: StreamHandler {

    public init() {
      super.init(stream: .stderr)
      setLevel(Level.INFO)
      setFormatter(SimpleFormatter())
    }

    open override func close() throws {
      flush()
      // Do NOT close stderr.
    }
  }
}
