/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {

  /// A `Handler` that buffers log records in a ring buffer and pushes them to
  /// a *target* `Handler` when a trigger level is reached.
  ///
  /// This class mirrors `java.util.logging.MemoryHandler` (Java 1.4).
  ///
  /// **Buffer semantics**
  /// - The buffer holds at most `size` records (oldest discarded when full).
  /// - After every `publish`, the handler checks whether the record's level is
  ///   ≥ the push level; if so, all buffered records are forwarded to the
  ///   target and the buffer is cleared.
  /// - `push()` forces a flush unconditionally.
  ///
  /// - Since: Java 1.4
  open class MemoryHandler: Handler {

    private let _target: Handler
    private let _size: Int
    private var _pushLevel: Level
    private var _buffer: [LogRecord]

    /// Creates a new `MemoryHandler`.
    ///
    /// - Parameters:
    ///   - target:    The handler records are pushed to when the push level is
    ///                reached.
    ///   - size:      Maximum number of records to buffer.
    ///   - pushLevel: The level that triggers an automatic push.
    public init(_ target: Handler, _ size: Int, _ pushLevel: Level) {
      _target = target
      _size   = max(1, size)
      _pushLevel = pushLevel
      _buffer = []
      _buffer.reserveCapacity(_size)
      super.init()
    }

    open func getPushLevel() -> Level { _pushLevel }
    open func setPushLevel(_ level: Level) { _pushLevel = level }

    open override func publish(_ record: LogRecord) {
      guard isLoggable(record) else { return }
      if _buffer.count >= _size { _buffer.removeFirst() }
      _buffer.append(record)
      if record.getLevel().intValue() >= _pushLevel.intValue() {
        push()
      }
    }

    /// Pushes all buffered records to the target handler immediately.
    open func push() {
      for record in _buffer { _target.publish(record) }
      _buffer.removeAll(keepingCapacity: true)
      _target.flush()
    }

    open override func flush() {
      _target.flush()
    }

    open override func close() throws {
      push()
      try _target.close()
    }
  }
}
