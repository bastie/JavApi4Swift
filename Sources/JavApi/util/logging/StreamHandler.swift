/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.logging {

  /// A `Handler` that writes formatted log records to an output stream.
  ///
  /// Records are formatted using the installed `Formatter` (default:
  /// `SimpleFormatter`), then written as UTF-8 bytes.
  ///
  /// This class mirrors `java.util.logging.StreamHandler` (Java 1.4).
  ///
  /// - Since: Java 1.4
  open class StreamHandler: Handler {

    /// The target output stream — stdout or stderr.
    public enum TargetStream {
      case stdout
      case stderr
    }

    private let _target: TargetStream

    public init(stream: TargetStream = .stderr) {
      _target = stream
      super.init()
      setFormatter(SimpleFormatter())
    }

    open override func publish(_ record: LogRecord) {
      guard isLoggable(record) else { return }
      let text: String
      if let formatter = getFormatter() {
        text = formatter.format(record)
      } else {
        text = (record.getMessage() ?? "") + "\n"
      }
      _write(text)
    }

    open override func flush() {
      // stdout/stderr in Swift are line-buffered; no explicit flush required.
    }

    open override func close() throws {
      flush()
    }

    // MARK: - Internal helpers

    private func _write(_ text: String) {
      guard let data = text.data(using: .utf8) else { return }
      switch _target {
      case .stdout:
        FileHandle.standardOutput.write(data)
      case .stderr:
        FileHandle.standardError.write(data)
      }
    }
  }
}
