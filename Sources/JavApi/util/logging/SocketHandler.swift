/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.logging {

  /// A `Handler` that sends formatted log records over a TCP socket.
  ///
  /// This class mirrors `java.util.logging.SocketHandler` (Java 1.4).
  ///
  /// **Platform support**
  /// Backed by `java.net.Socket`, which handles all platform differences
  /// internally:
  /// - Apple (Darwin), Linux (GLibc / MUSL), Android, FreeBSD, Windows (WinSDK):
  ///   full TCP support.
  /// - WASI: networking is unavailable in the WASM sandbox. `init` throws
  ///   `IOException` and `publish` is a no-op. Use `ConsoleHandler` or
  ///   `MemoryHandler` on WASM targets instead.
  ///
  /// The default formatter is `XMLFormatter`, matching Java's behaviour.
  ///
  /// - Since: Java 1.4
  open class SocketHandler: Handler {

    private let _host: String
    private let _port: Int
    private var _socket: java.net.Socket?

    public init(_ host: String, _ port: Int) throws {
      _host = host
      _port = port
      super.init()
      setFormatter(XMLFormatter())
      do {
        _socket = try java.net.Socket(host, port)
      } catch let e as java.net.SocketException {
        throw java.io.IOException("SocketHandler: cannot connect to \(host):\(port) – \(e.getMessage() ?? "")")
      } catch {
        throw java.io.IOException("SocketHandler: cannot connect to \(host):\(port) – \(error)")
      }
    }

    // MARK: - Handler

    open override func publish(_ record: LogRecord) {
      guard isLoggable(record), let socket = _socket else { return }
      let text: String
      if let fmt = getFormatter() {
        text = fmt.format(record)
      } else {
        text = (record.getMessage() ?? "") + "\n"
      }
      guard let data = text.data(using: .utf8),
            let out = try? socket.getOutputStream() else { return }
      let bytes: [byte] = Array(data)
      try? out.write(bytes)
    }

    open override func flush() {
      // TCP sockets flush immediately on write; no buffering in this handler.
    }

    open override func close() throws {
      try _socket?.close()
      _socket = nil
    }
  }
}
