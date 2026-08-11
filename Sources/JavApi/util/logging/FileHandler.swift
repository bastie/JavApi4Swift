/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.logging {

  /// A `Handler` that writes formatted log records to a file.
  ///
  /// The file is opened in append mode by default.  Log rotation
  /// (`count`, `limit`) is not implemented in this port.
  ///
  /// This class mirrors `java.util.logging.FileHandler` (Java 1.4).
  ///
  /// - Since: Java 1.4
  open class FileHandler: Handler {

    private let _path: String
    private var _fileHandle: FileHandle?

    /// Opens (or creates) the file at `pattern` for writing.
    ///
    /// - Parameters:
    ///   - pattern: Path to the log file.
    ///   - append:  When `true` (default) output is appended; when `false` the
    ///              file is truncated on open.
    public init(_ pattern: String, _ append: Bool = true) throws {
      _path = pattern
      super.init()
      setFormatter(SimpleFormatter())
      let fm = FileManager.default
      if !fm.fileExists(atPath: pattern) {
        fm.createFile(atPath: pattern, contents: nil)
      }
      guard let fh = FileHandle(forWritingAtPath: pattern) else {
        throw java.io.IOException("Cannot open log file: \(pattern)")
      }
      if append {
        fh.seekToEndOfFile()
      } else {
        fh.truncateFile(atOffset: 0)
      }
      _fileHandle = fh
    }

    open override func publish(_ record: LogRecord) {
      guard isLoggable(record), let fh = _fileHandle else { return }
      let text: String
      if let formatter = getFormatter() {
        text = formatter.format(record)
      } else {
        text = (record.getMessage() ?? "") + "\n"
      }
      if let data = text.data(using: .utf8) {
        fh.write(data)
      }
    }

    open override func flush() {
      _fileHandle?.synchronizeFile()
    }

    open override func close() throws {
      flush()
      try _fileHandle?.close()
      _fileHandle = nil
    }
  }
}
