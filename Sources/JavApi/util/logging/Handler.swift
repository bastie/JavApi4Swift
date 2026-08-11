/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class Handler {
    
    public init() {}

    private var _level: Level = Level.ALL
    private var _filter: Filter? = nil
    private var _formatter: Formatter? = nil
    private var _encoding: String? = nil

    // MARK: - Level

    open func setLevel(_ newLevel: Level) { _level = newLevel }
    open func getLevel() -> Level { _level }

    // MARK: - Filter

    open func getFilter() -> Filter? { _filter }
    open func setFilter(_ filter: Filter?) { _filter = filter }

    // MARK: - Formatter

    open func getFormatter() -> Formatter? { _formatter }
    open func setFormatter(_ formatter: Formatter?) { _formatter = formatter }

    // MARK: - Encoding

    open func getEncoding() -> String? { _encoding }
    open func setEncoding(_ encoding: String?) throws { _encoding = encoding }

    // MARK: - isLoggable

    /// Returns `true` if the record's level meets this handler's threshold
    /// and the installed `Filter` (if any) accepts the record.
    open func isLoggable(_ record: LogRecord) -> Bool {
      guard record.getLevel().intValue() >= _level.intValue() else { return false }
      return _filter?.isLoggable(record) ?? true
    }

    /// Publishes a `LogRecord`. Subclasses must override this.
    open func publish(_ record: LogRecord) {}

    /// Flushes any buffered output.
    open func flush() {}

    /// Closes the handler and frees any associated resources.
    open func close() throws {}

  }
}

