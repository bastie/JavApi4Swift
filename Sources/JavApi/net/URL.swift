/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.net {

  /// Java 1.0 `java.net.URL` — a Uniform Resource Locator.
  ///
  /// Backed by `Foundation.URL`. Parsing and validation is delegated to
  /// Foundation; any URL that Foundation cannot parse throws
  /// ``MalformedURLException``.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public class URL: @unchecked Sendable {

    internal let foundationURL: Foundation.URL

    // MARK: - Constructors

    /// Creates a URL from the given string.
    ///
    /// - Throws: ``MalformedURLException`` if the string is not a valid URL.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ spec: String) throws {
      guard let url = Foundation.URL(string: spec) else {
        throw MalformedURLException("no protocol: \(spec)")
      }
      self.foundationURL = url
    }

    /// Creates a URL from protocol, host and file components.
    ///
    /// - Throws: ``MalformedURLException`` if the resulting string is not valid.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ protocol_: String, _ host: String, _ file: String) throws {
      let spec = "\(`protocol_`)://\(host)\(file)"
      guard let url = Foundation.URL(string: spec) else {
        throw MalformedURLException("no protocol: \(spec)")
      }
      self.foundationURL = url
    }

    /// Creates a URL from protocol, host, port and file components.
    ///
    /// Pass `-1` for `port` to omit it from the URL.
    ///
    /// - Throws: ``MalformedURLException`` if the resulting string is not valid.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ protocol_: String, _ host: String, _ port: Int, _ file: String) throws {
      let spec = port == -1
        ? "\(`protocol_`)://\(host)\(file)"
        : "\(`protocol_`)://\(host):\(port)\(file)"
      guard let url = Foundation.URL(string: spec) else {
        throw MalformedURLException("no protocol: \(spec)")
      }
      self.foundationURL = url
    }

    /// Creates a URL by resolving `spec` relative to the given `context` URL.
    ///
    /// - Throws: ``MalformedURLException`` if the resulting URL is not valid.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public init(_ context: URL, _ spec: String) throws {
      guard let relative = Foundation.URL(string: spec, relativeTo: context.foundationURL) else {
        throw MalformedURLException("no protocol: \(spec)")
      }
      self.foundationURL = relative.absoluteURL
    }

    /// Internal initialiser from a Foundation URL (used by URLConnection etc.)
    internal init(foundationURL: Foundation.URL) {
      self.foundationURL = foundationURL
    }

    // MARK: - Protocol / host / port

    /// Returns the protocol component of this URL (e.g. `"https"`).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getProtocol() -> String {
      return foundationURL.scheme ?? ""
    }

    /// Returns the host component of this URL.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getHost() -> String {
      return foundationURL.host ?? ""
    }

    /// Returns the port, or `-1` if the port is not explicitly set.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getPort() -> Int {
      return foundationURL.port ?? -1
    }

    /// Returns the default port for the protocol, or `-1` if unknown.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getDefaultPort() -> Int {
      switch foundationURL.scheme?.lowercased() {
      case "http":   return 80
      case "https":  return 443
      case "ftp":    return 21
      case "smtp":   return 25
      case "pop3":   return 110
      case "imap":   return 143
      case "telnet": return 23
      default:       return -1
      }
    }

    // MARK: - Path / file / query / fragment

    /// Returns the file component (path + query) of this URL.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getFile() -> String {
      var file = foundationURL.path
      if let query = foundationURL.query {
        file += "?" + query
      }
      return file
    }

    /// Returns the path component of this URL.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getPath() -> String {
      return foundationURL.path
    }

    /// Returns the query component, or `nil` if absent.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getQuery() -> String? {
      return foundationURL.query
    }

    /// Returns the fragment (anchor / ref) component, or `nil` if absent.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getRef() -> String? {
      return foundationURL.fragment
    }

    /// Returns the authority component (`host:port`), or an empty string.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getAuthority() -> String {
      var authority = foundationURL.host ?? ""
      if let port = foundationURL.port {
        authority += ":\(port)"
      }
      return authority
    }

    /// Returns the user-info component, or `nil` if absent.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getUserInfo() -> String? {
      return foundationURL.user.map { user in
        if let password = foundationURL.password {
          return "\(user):\(password)"
        }
        return user
      }
    }

    // MARK: - Comparison

    /// Returns `true` if both URLs refer to the same file (ignoring fragment).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func sameFile(_ other: URL) -> Bool {
      var lhs = foundationURL
      var rhs = other.foundationURL
      // strip fragment for comparison
      if var c = URLComponents(url: lhs, resolvingAgainstBaseURL: false) {
        c.fragment = nil
        lhs = c.url ?? lhs
      }
      if var c = URLComponents(url: rhs, resolvingAgainstBaseURL: false) {
        c.fragment = nil
        rhs = c.url ?? rhs
      }
      return lhs.absoluteString.lowercased() == rhs.absoluteString.lowercased()
    }

    // MARK: - String representation

    /// Returns the external form of this URL as a String.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func toExternalForm() -> String {
      return foundationURL.absoluteString
    }

    /// Returns the string representation of this URL.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func toString() -> String {
      return toExternalForm()
    }

    // MARK: - Stream / connection

    /// Opens a connection to this URL and returns a ``URLConnection``.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func openConnection() -> URLConnection {
      return URLConnection(url: self)
    }

    /// Opens a connection to this URL and returns an input stream for reading.
    ///
    /// - Throws: `java.io.IOException` if the connection cannot be opened.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func openStream() throws -> java.io.InputStream {
      let data: Data
      do {
        data = try Data(contentsOf: foundationURL)
      } catch {
        throw java.io.IOException(error.localizedDescription)
      }
      return java.io.ByteArrayInputStream(Array(data))
    }
  }
}

// MARK: - Equatable / Hashable / CustomStringConvertible

extension java.net.URL: Equatable {
  public static func == (lhs: java.net.URL, rhs: java.net.URL) -> Bool {
    return lhs.foundationURL.absoluteString.lowercased() ==
           rhs.foundationURL.absoluteString.lowercased()
  }
}

extension java.net.URL: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(foundationURL.absoluteString.lowercased())
  }
}

extension java.net.URL: CustomStringConvertible {
  public var description: String { toExternalForm() }
}
