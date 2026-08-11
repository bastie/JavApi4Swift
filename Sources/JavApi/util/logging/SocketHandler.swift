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
  /// - Apple / Linux (GLibc, MUSL) / FreeBSD / Android: full POSIX socket support.
  /// - Windows: not yet implemented; `publish` is a no-op.
  /// - WASM: no networking available; `publish` is a no-op.
  ///
  /// The default formatter is `XMLFormatter`, matching Java's behaviour.
  ///
  /// - Since: Java 1.4
  open class SocketHandler: Handler {

    private let _host: String
    private let _port: Int
    private var _socket: Int32 = -1
    private var _connected: Bool = false

    public init(_ host: String, _ port: Int) throws {
      _host = host
      _port = port
      super.init()
      setFormatter(XMLFormatter())
      try _connect()
    }

    // MARK: - Handler

    open override func publish(_ record: LogRecord) {
      guard isLoggable(record), _connected else { return }
      let text: String
      if let fmt = getFormatter() {
        text = fmt.format(record)
      } else {
        text = (record.getMessage() ?? "") + "\n"
      }
      _send(text)
    }

    open override func flush() {}

    open override func close() throws {
      _disconnect()
    }

    // MARK: - POSIX socket helpers

    private func _connect() throws {
#if os(WASM) || os(Windows)
      // Networking not yet implemented on these targets.
      _connected = false
#else
      let portStr = "\(_port)"
      var hints = addrinfo()
      hints.ai_family   = AF_UNSPEC
      hints.ai_socktype = Int32(SOCK_STREAM)
      var res: UnsafeMutablePointer<addrinfo>? = nil
      let rc = getaddrinfo(_host, portStr, &hints, &res)
      guard rc == 0, let ai = res else {
        let errMsg = String(cString: gai_strerror(rc))
        throw java.io.IOException("SocketHandler: cannot resolve \(_host):\(_port) – \(errMsg)")
      }
      defer { freeaddrinfo(res) }

      let fd = socket(ai.pointee.ai_family, ai.pointee.ai_socktype, ai.pointee.ai_protocol)
      guard fd >= 0 else {
        throw java.io.IOException("SocketHandler: socket() failed")
      }
      guard connect(fd, ai.pointee.ai_addr, ai.pointee.ai_addrlen) == 0 else {
        _closefd(fd)
        throw java.io.IOException("SocketHandler: connect() to \(_host):\(_port) failed")
      }
      _socket = fd
      _connected = true
#endif
    }

    private func _send(_ text: String) {
#if !os(WASM) && !os(Windows)
      guard _connected, _socket >= 0 else { return }
      let bytes = Array(text.utf8)
      bytes.withUnsafeBufferPointer { buf in
        _ = send(_socket, buf.baseAddress!, buf.count, 0)
      }
#endif
    }

    private func _disconnect() {
#if !os(WASM) && !os(Windows)
      if _socket >= 0 {
        _closefd(_socket)
        _socket = -1
      }
#endif
      _connected = false
    }

    private func _closefd(_ fd: Int32) {
#if canImport(Darwin)
      Darwin.close(fd)
#elseif canImport(Glibc)
      Glibc.close(fd)
#elseif canImport(Musl)
      Musl.close(fd)
#endif
    }
  }
}
