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

    /// Parses the string representation of a URL into a ``URL`` object.
    ///
    /// The default implementation delegates to `Foundation.URL` for parsing.
    /// Subclasses can override this to handle custom protocol syntax.
    ///
    /// Java signature: `parseURL(URL u, String spec, int start, int limit)`
    ///
    /// - Parameters:
    ///   - u: The URL context (ignored by the default implementation).
    ///   - spec: The string to parse.
    ///   - start: Index in `spec` at which parsing should begin.
    ///   - limit: Index in `spec` at which parsing should stop (exclusive).
    /// - Returns: A new ``URL`` parsed from the substring, or `nil` if unparseable.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func parseURL(_ u: java.net.URL, _ spec: String, _ start: Int, _ limit: Int) -> java.net.URL? {
      let sub = String(spec[spec.index(spec.startIndex, offsetBy: start)..<spec.index(spec.startIndex, offsetBy: limit)])
      return try? java.net.URL(sub)
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
