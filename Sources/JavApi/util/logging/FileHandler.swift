/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.logging {

  /// A `Handler` that writes formatted log records to a (rotating) file.
  ///
  /// Mirrors `java.util.logging.FileHandler` (Java 1.4).
  ///
  /// ## Pattern substitutions
  /// | Token | Meaning |
  /// |-------|---------|
  /// | `%h`  | User's home directory (`FileManager` home) |
  /// | `%t`  | System temporary directory |
  /// | `%g`  | Rotation generation number (0-based) |
  /// | `%u`  | Unique conflict-avoidance number (always `0` in this port) |
  /// | `%%`  | Literal `%` |
  ///
  /// ## Rotation
  /// When `limit > 0` and `count > 1`, the handler rotates through
  /// `count` files (`%g` = 0 … count-1).  When the current file exceeds
  /// `limit` bytes, it closes the file and opens the next generation
  /// (wrapping around to 0 when the maximum is reached).
  ///
  /// - Since: Java 1.4
  open class FileHandler: Handler {

    // MARK: - Configuration

    private let _pattern: String
    private let _limit:   Int    // 0 = unlimited
    private let _count:   Int    // number of rotating files
    private let _append:  Bool

    // MARK: - Runtime state

    private var _fileHandle:    FileHandle?
    private var _generation:    Int = 0
    private var _bytesWritten:  Int = 0

    // MARK: - Initialisers

    /// Opens a single log file (no rotation).
    ///
    /// - Parameters:
    ///   - pattern: Path to the log file.  Pattern tokens are substituted.
    ///   - append:  When `true` (default) output is appended; `false` truncates.
    public init(_ pattern: String, _ append: Bool = true) throws {
      _pattern = pattern
      _limit   = 0
      _count   = 1
      _append  = append
      super.init()
      setFormatter(SimpleFormatter())
      try _openFile()
    }

    /// Opens a rotating log file.
    ///
    /// - Parameters:
    ///   - pattern: Path pattern; may include `%g`, `%u`, `%h`, `%t`, `%%`.
    ///   - limit:   Maximum bytes per file before rotation.  `0` = unlimited.
    ///   - count:   Number of rotating files (≥ 1).
    ///   - append:  Append to existing files (`true`) or truncate (`false`).
    public init(_ pattern: String, _ limit: Int, _ count: Int, _ append: Bool = false) throws {
      _pattern = pattern
      _limit   = max(0, limit)
      _count   = max(1, count)
      _append  = append
      super.init()
      setFormatter(SimpleFormatter())
      try _openFile()
    }

    // MARK: - Handler

    open override func publish(_ record: LogRecord) {
      guard isLoggable(record), let fh = _fileHandle else { return }
      let text: String
      if let formatter = getFormatter() {
        text = formatter.format(record)
      } else {
        text = (record.getMessage() ?? "") + "\n"
      }
      guard let data = text.data(using: .utf8) else { return }
      fh.write(data)
      _bytesWritten += data.count

      // Rotate if limit exceeded and rotation is configured
      if _limit > 0 && _count > 1 && _bytesWritten >= _limit {
        try? _rotate()
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

    // MARK: - Private helpers

    /// Resolves the file path for the given generation number.
    private func _path(generation: Int) -> String {
      let home = FileManager.default.homeDirectoryForCurrentUser.path
      let tmp  = FileManager.default.temporaryDirectory.path
      var path = _pattern
      path = path.replacingOccurrences(of: "%%", with: "\u{0}")   // protect %%
      path = path.replacingOccurrences(of: "%h", with: home)
      path = path.replacingOccurrences(of: "%t", with: tmp)
      path = path.replacingOccurrences(of: "%g", with: "\(generation)")
      path = path.replacingOccurrences(of: "%u", with: "0")
      path = path.replacingOccurrences(of: "\u{0}", with: "%")    // restore %%
      return path
    }

    /// Opens the file for the current generation.
    private func _openFile() throws {
      let path = _path(generation: _generation)
      let fm = FileManager.default
      if !fm.fileExists(atPath: path) {
        fm.createFile(atPath: path, contents: nil)
      }
      guard let fh = FileHandle(forWritingAtPath: path) else {
        throw java.io.IOException("Cannot open log file: \(path)")
      }
      if _append {
        let endOffset = fh.seekToEndOfFile()
        _bytesWritten = Int(endOffset)
      } else {
        fh.truncateFile(atOffset: 0)
        _bytesWritten = 0
      }
      _fileHandle = fh
    }

    /// Closes the current file and opens the next generation.
    private func _rotate() throws {
      flush()
      try _fileHandle?.close()
      _fileHandle = nil
      _generation = (_generation + 1) % _count
      // Next generation is always opened fresh (truncated)
      let path = _path(generation: _generation)
      let fm = FileManager.default
      if !fm.fileExists(atPath: path) {
        fm.createFile(atPath: path, contents: nil)
      }
      guard let fh = FileHandle(forWritingAtPath: path) else {
        throw java.io.IOException("Cannot open log file for rotation: \(path)")
      }
      fh.truncateFile(atOffset: 0)
      _bytesWritten = 0
      _fileHandle = fh
    }
  }
}
