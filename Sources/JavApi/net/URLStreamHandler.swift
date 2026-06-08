/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// Abstract class for URL stream protocol handlers.
  ///
  /// Java 1.0 `java.net.URLStreamHandler`. Subclass this to implement a
  /// custom protocol handler and register it via a ``URLStreamHandlerFactory``.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open class URLStreamHandler {

    public init() {}

    /// Opens a connection to the given URL.
    ///
    /// - Parameter u: The URL to connect to.
    /// - Returns: A ``URLConnection`` for the given URL.
    /// - Throws: `java.io.IOException` if an I/O error occurs.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func openConnection(_ u: java.net.URL) throws -> java.net.URLConnection {
      throw java.io.IOException("URLStreamHandler.openConnection not implemented")
    }

    /// Converts the URL to its external String representation.
    ///
    /// The default implementation builds the string from the URL's components.
    ///
    /// - Parameter u: The URL to convert.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func toExternalForm(_ u: java.net.URL) -> String {
      var result = u.getProtocol() + ":"
      let host = u.getHost()
      if !host.isEmpty {
        result += "//" + host
        let port = u.getPort()
        if port != -1 {
          result += ":\(port)"
        }
      }
      result += u.getFile()
      if let ref = u.getRef() {
        result += "#" + ref
      }
      return result
    }
  }
}
