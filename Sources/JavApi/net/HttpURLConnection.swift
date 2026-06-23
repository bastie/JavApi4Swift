/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension java.net {

  /// An HTTP-specific URLConnection subclass with HTTP-specific features.
  ///
  /// Java 1.1 `java.net.HttpURLConnection`. This class extends `URLConnection`
  /// with HTTP-specific features like response codes, response messages, and request methods.
  ///
  /// Typical usage:
  /// ```swift
  /// let url = try java.net.URL("https://example.com/api")
  /// let conn = try url.openConnection() as! java.net.HttpURLConnection
  /// try conn.setRequestMethod("GET")
  /// try conn.connect()
  /// let code = try conn.getResponseCode()
  /// let msg = conn.getResponseMessage()
  /// let stream = try conn.getInputStream()
  /// ```
  ///
  /// - Since: Java 1.1
  public class HttpURLConnection: URLConnection, @unchecked Sendable {

    // MARK: - HTTP Status Code Constants

    /// HTTP status code (200) – OK.
    /// - Since: Java 1.1
    public static let HTTP_OK: Int = 200

    /// HTTP status code (201) – Created.
    /// - Since: Java 1.1
    public static let HTTP_CREATED: Int = 201

    /// HTTP status code (202) – Accepted.
    /// - Since: Java 1.1
    public static let HTTP_ACCEPTED: Int = 202

    /// HTTP status code (204) – No Content.
    /// - Since: Java 1.1
    public static let HTTP_NO_CONTENT: Int = 204

    /// HTTP status code (301) – Moved Permanently.
    /// - Since: Java 1.1
    public static let HTTP_MOVED_PERM: Int = 301

    /// HTTP status code (302) – Found (Moved Temporarily).
    /// - Since: Java 1.1
    public static let HTTP_MOVED_TEMP: Int = 302

    /// HTTP status code (304) – Not Modified.
    /// - Since: Java 1.1
    public static let HTTP_NOT_MODIFIED: Int = 304

    /// HTTP status code (400) – Bad Request.
    /// - Since: Java 1.1
    public static let HTTP_BAD_REQUEST: Int = 400

    /// HTTP status code (401) – Unauthorized.
    /// - Since: Java 1.1
    public static let HTTP_UNAUTHORIZED: Int = 401

    /// HTTP status code (403) – Forbidden.
    /// - Since: Java 1.1
    public static let HTTP_FORBIDDEN: Int = 403

    /// HTTP status code (404) – Not Found.
    /// - Since: Java 1.1
    public static let HTTP_NOT_FOUND: Int = 404

    /// HTTP status code (500) – Internal Server Error.
    /// - Since: Java 1.1
    public static let HTTP_INTERNAL_ERROR: Int = 500

    /// HTTP status code (501) – Not Implemented.
    /// - Since: Java 1.1
    public static let HTTP_NOT_IMPLEMENTED: Int = 501

    /// HTTP status code (502) – Bad Gateway.
    /// - Since: Java 1.1
    public static let HTTP_BAD_GATEWAY: Int = 502

    /// HTTP status code (503) – Service Unavailable.
    /// - Since: Java 1.1
    public static let HTTP_UNAVAILABLE: Int = 503

    // MARK: - State

    /// The HTTP request method (GET, POST, PUT, DELETE, etc.).
    /// Default is GET if doOutput is false, POST if doOutput is true.
    /// - Since: Java 1.1
    internal var requestMethod: String = "GET"

    /// Whether to follow redirects automatically. Default is true.
    /// - Since: Java 1.1
    public var instanceFollowRedirects: Bool = HttpURLConnection.followRedirects

    /// Class-level default for following redirects.
    /// - Since: Java 1.1
    nonisolated(unsafe) public static var followRedirects: Bool = true

    // MARK: - Initialization

    /// Creates an HttpURLConnection for the given URL.
    /// Package-internal; instances are created via `URL.openConnection()`.
    /// - Since: Java 1.1
    internal override init(url: java.net.URL) {
      super.init(url: url)
    }

    // MARK: - Request configuration overrides

    /// HTTP-specific request method honouring `setRequestMethod(_:)`.
    internal override var effectiveRequestMethod: String {
      return requestMethod
    }

#if os(Linux)
    /// On Linux the curl-backed `connect()` should follow redirects according
    /// to `instanceFollowRedirects` (matching Java's HttpURLConnection default).
    internal override var instanceFollowsRedirectsForCurl: Bool {
      return instanceFollowRedirects
    }
#endif

    // MARK: - Request Method

    /// Sets the HTTP request method (GET, POST, PUT, DELETE, HEAD, etc.).
    ///
    /// Must be called before ``connect()``.
    ///
    /// - Parameter _newMethod: The HTTP method name (case-sensitive).
    /// - Throws: `java.net.ProtocolException` if called after connection, or if an unsupported method is used.
    /// - Since: Java 1.1
    public func setRequestMethod(_ newMethod: String) throws {
      guard !connected else {
        throw java.net.ProtocolException("Cannot reset method after connection")
      }
      self.requestMethod = newMethod.uppercased()
    }

    /// Returns the HTTP request method.
    /// - Returns: The HTTP method name (GET, POST, etc.).
    /// - Since: Java 1.1
    public func getRequestMethod() -> String {
      return requestMethod
    }

    // MARK: - Response Code and Message

    /// Returns the HTTP response code.
    ///
    /// Automatically calls ``connect()`` if not yet connected.
    /// Returns -1 if not connected or on error.
    ///
    /// - Returns: The HTTP status code (200, 404, 500, etc.), or -1 if unknown.
    /// - Throws: `java.io.IOException` on connection failure.
    /// - Since: Java 1.1
    public override func getResponseCode() throws -> Int {
      if !connected { try connect() }
#if os(WASI)
      return -1
#else
      return try super.getResponseCode()
#endif
    }

    /// Returns the HTTP response message for the status code.
    ///
    /// Examples: "OK", "Not Found", "Internal Server Error".
    /// Returns nil if not connected or the response is not HTTP.
    ///
    /// - Returns: The HTTP response message, or nil if unknown.
    /// - Since: Java 1.1
    public func getResponseMessage() -> String? {
#if os(WASI)
      guard connected else { return nil }
      do {
        let statusCode = try super.getResponseCode()
        guard statusCode >= 0 else { return nil }
        return self.httpStatusCodeDescription(forStatusCode: statusCode)
      }
      catch { return nil }
#else
      guard connected else { return nil }
      do {
        let statusCode = try super.getResponseCode()
        guard statusCode >= 0 else { return nil }
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
      }
      catch { return nil }
#endif
    }

    // MARK: - Disconnection

    /// Closes the connection and releases associated resources.
    ///
    /// After calling this method, the connection cannot be reused.
    /// However, a new connection can be opened by calling ``connect()`` again.
    ///
    /// - Since: Java 1.1
    public func disconnect() {
      connected = false
    }
  }
}
