/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension java.net {

  /// Represents a communication link between an application and a URL.
  ///
  /// Java 1.0 `java.net.URLConnection`. In Java this is an abstract class;
  /// here it is a concrete class backed by `Foundation.URLSession`.
  ///
  /// Typical usage:
  /// ```swift
  /// let url  = try java.net.URL("https://example.com")
  /// let conn = try url.openConnection()
  /// conn.connect()
  /// let stream = try conn.getInputStream()
  /// ```
  ///
  /// - Since: Java 1.0
  public class URLConnection: @unchecked Sendable {

    // MARK: - Global content handler factory

    /// The global content handler factory, set via ``setContentHandlerFactory(_:)``.
    nonisolated(unsafe) private static var _contentHandlerFactory: (any ContentHandlerFactory)? = nil

    /// Sets the global `ContentHandlerFactory`.
    ///
    /// Once set it cannot be replaced (matching Java's behaviour).
    ///
    /// - Throws: `java.io.IOException` if a factory is already registered.
    /// - Since: Java 1.0
    public static func setContentHandlerFactory(_ fac: any ContentHandlerFactory) throws {
      guard _contentHandlerFactory == nil else {
        throw java.io.IOException("ContentHandlerFactory already set")
      }
      _contentHandlerFactory = fac
    }

    /// Returns the content handler for the given MIME type, or `nil` if none registered.
    ///
    /// - Since: Java 1.0
    public static func getContentHandler(for mimetype: String) -> ContentHandler? {
      return _contentHandlerFactory?.createContentHandler(mimetype)
    }

    // MARK: - State

    internal let url: java.net.URL
    private var requestProperties: [String: String] = [:]
    private var doInput: Bool = true
    private var doOutput: Bool = false
    private var useCaches: Bool = true
    private var connectTimeout: Int = 0   // 0 = no timeout (Java default)
    private var readTimeout: Int = 0

    /// Protected access to request properties for subclasses.
    internal var _requestProperties: [String: String] {
      get { requestProperties }
      set { requestProperties = newValue }
    }

    /// Protected access to doInput flag for subclasses.
    internal var _doInput: Bool {
      get { doInput }
      set { doInput = newValue }
    }

    /// Protected access to doOutput flag for subclasses.
    internal var _doOutput: Bool {
      get { doOutput }
      set { doOutput = newValue }
    }

    /// Protected access to useCaches flag for subclasses.
    internal var _useCaches: Bool {
      get { useCaches }
      set { useCaches = newValue }
    }

    // MARK: - Java 1.0 public fields

    /// Default value of `allowUserInteraction` for new connections (class-level).
    /// - Since: Java 1.0
    nonisolated(unsafe) public static var defaultAllowUserInteraction: Bool = false

    /// Whether user interaction (e.g. auth dialogs) is allowed for this connection.
    /// - Since: Java 1.0
    public var allowUserInteraction: Bool = URLConnection.defaultAllowUserInteraction

    /// Default value of `useCaches` for new connections (class-level).
    /// - Since: Java 1.0
    nonisolated(unsafe) public static var defaultUseCaches: Bool = true

    /// If non-zero, only fetches the resource if it was modified after this epoch-millisecond timestamp.
    /// - Since: Java 1.0
    public var ifModifiedSince: Int64 = 0

    private var responseData: Data?
#if !os(WASI)
    private var _httpResponse: HTTPURLResponse?
#endif
    private var _connected: Bool = false

    /// Protected access to connection state for subclasses.
    internal var connected: Bool {
      get { _connected }
      set { _connected = newValue }
    }

#if !os(WASI)
    /// Protected access to HTTP response for subclasses.
    internal var httpResponse: HTTPURLResponse? {
      get { _httpResponse }
      set { _httpResponse = newValue }
    }
#endif

    // MARK: - Init (package-internal, created by URL.openConnection())

    internal init(url: java.net.URL) {
      self.url = url
    }

    // MARK: - connect

    /// Opens a connection to the resource referenced by this URL.
    ///
    /// Performs a synchronous HTTP GET (or HEAD) request using `URLSession`.
    /// Must be called before ``getInputStream()``, ``getContentLength()``, or
    /// ``getHeaderField(_:)``.
    ///
    /// - Throws: `java.io.IOException` if the connection fails.
    /// - Since: Java 1.0
    public func connect() throws {
      guard !connected else { return }
#if os(WASI)
      throw java.io.IOException("URLConnection.connect() is unavailable on WASI")
#else
      var request = URLRequest(url: url.foundationURL)
      for (key, value) in requestProperties {
        request.setValue(value, forHTTPHeaderField: key)
      }
      if connectTimeout > 0 {
        request.timeoutInterval = Double(connectTimeout) / 1000.0
      }
      request.httpMethod = doOutput ? "POST" : "GET"
      if ifModifiedSince > 0 {
        // Convert epoch-milliseconds to HTTP date string
        let date = Date(timeIntervalSince1970: Double(ifModifiedSince) / 1000.0)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Foundation.TimeZone(abbreviation: "GMT") ?? Foundation.TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        request.setValue(formatter.string(from: date), forHTTPHeaderField: "If-Modified-Since")
      }

      let semaphore = DispatchSemaphore(value: 0)
      nonisolated(unsafe) var fetchError: (any Error)?

      let config = URLSessionConfiguration.default
      if !useCaches { config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData }
      let session = URLSession(configuration: config)

      session.dataTask(with: request) { data, response, error in
        self.responseData = data
        self._httpResponse = response as? HTTPURLResponse
        fetchError = error
        semaphore.signal()
      }.resume()

      semaphore.wait()

      if let error = fetchError {
        throw java.io.IOException(error.localizedDescription)
      }
      connected = true
#endif
    }

    // MARK: - Content

    /// Returns the content of this URL connection.
    ///
    /// If a ``ContentHandlerFactory`` is registered and provides a handler for
    /// the connection's MIME type, that handler's ``ContentHandler/getContent(_:)``
    /// is called. Otherwise the raw content is returned as `[UInt8]`.
    ///
    /// - Throws: `java.io.IOException` if the connection fails.
    /// - Since: Java 1.0
    public func getContent() throws -> Any? {
      if !connected { try connect() }
      if let mimeType = getContentType(),
         let handler = URLConnection.getContentHandler(for: mimeType) {
        return try handler.getContent(self)
      }
      return responseData.map { Array($0) }
    }

    // MARK: - Streams

    /// Returns an input stream that reads from this connection.
    ///
    /// Calls ``connect()`` automatically if not yet connected.
    ///
    /// - Throws: `java.io.IOException` if the connection fails or returns no data.
    /// - Since: Java 1.0
    public func getInputStream() throws -> java.io.InputStream {
      if !connected { try connect() }
      guard let data = responseData else {
        throw java.io.IOException("No data received from \(url.toExternalForm())")
      }
      return java.io.ByteArrayInputStream(Array(data))
    }

    // MARK: - Metadata

    /// Returns the URL of this connection.
    ///
    /// - Since: Java 1.0
    public func getURL() -> java.net.URL {
      return url
    }

    /// Returns the value of the `Content-Length` header, or `-1` if unknown.
    ///
    /// - Since: Java 1.0
    public func getContentLength() -> Int {
      guard connected else { return -1 }
      if let value = headerValue("Content-Length"), let length = Int(value) {
        return length
      }
      return responseData.map { $0.count } ?? -1
    }

    /// Returns the value of the `Content-Type` header, or `nil` if unknown.
    ///
    /// - Since: Java 1.0
    public func getContentType() -> String? {
      guard connected else { return nil }
      return headerValue("Content-Type")
    }

    /// Returns the value of the named header field, or `nil` if absent.
    ///
    /// - Since: Java 1.0
    public func getHeaderField(_ name: String) -> String? {
      guard connected else { return nil }
      return headerValue(name)
    }

    /// Cross-platform header lookup (case-insensitive) via `allHeaderFields`.
    /// - Returns optional value of named header
    private func headerValue(_ name: String) -> String? {
#if os(WASI)
      return nil
#else
      guard let headers = _httpResponse?.allHeaderFields else { return nil }
      let lower = name.lowercased()
      for (key, value) in headers {
        if let k = key as? String, k.lowercased() == lower {
          return value as? String
        }
      }
      return nil
#endif
    }

    /// Returns the HTTP status code, or `-1` if not connected or not HTTP.
    ///
    /// - Since: Java 1.0
    open func getResponseCode() throws -> Int {
#if os(WASI)
      return -1
#else
      return _httpResponse?.statusCode ?? -1
#endif
    }

    // MARK: - Request properties

    /// Sets a request header field.
    ///
    /// Must be called before ``connect()``.
    ///
    /// - Since: Java 1.0
    public func setRequestProperty(_ key: String, _ value: String) {
      requestProperties[key] = value
    }

    /// Returns the value of the named request property, or `nil` if not set.
    ///
    /// - Since: Java 1.0
    public func getRequestProperty(_ key: String) -> String? {
      return requestProperties[key]
    }

    // MARK: - Configuration

    /// Sets whether this connection will be used for input. Default: `true`.
    ///
    /// - Since: Java 1.0
    public func setDoInput(_ doInput: Bool) { self.doInput = doInput }

    /// Returns whether this connection is used for input.
    ///
    /// - Since: Java 1.0
    public func getDoInput() -> Bool { return doInput }

    /// Sets whether this connection will be used for output (POST). Default: `false`.
    ///
    /// - Since: Java 1.0
    public func setDoOutput(_ doOutput: Bool) { self.doOutput = doOutput }

    /// Returns whether this connection is used for output.
    ///
    /// - Since: Java 1.0
    public func getDoOutput() -> Bool { return doOutput }

    /// Sets whether caching is used. Default: `true`.
    ///
    /// - Since: Java 1.0
    public func setUseCaches(_ useCaches: Bool) { self.useCaches = useCaches }

    /// Returns whether caching is used.
    ///
    /// - Since: Java 1.0
    public func getUseCaches() -> Bool { return useCaches }

    /// Returns whether user interaction is allowed for this connection.
    ///
    /// - Since: Java 1.0
    public func getAllowUserInteraction() -> Bool { return allowUserInteraction }

    /// Sets whether user interaction is allowed for this connection.
    ///
    /// - Since: Java 1.0
    public func setAllowUserInteraction(_ allow: Bool) { allowUserInteraction = allow }

    /// Returns the default `allowUserInteraction` value for all new connections.
    ///
    /// - Since: Java 1.0
    public static func getDefaultAllowUserInteraction() -> Bool { return defaultAllowUserInteraction }

    /// Sets the default `allowUserInteraction` value for all new connections.
    ///
    /// - Since: Java 1.0
    public static func setDefaultAllowUserInteraction(_ allow: Bool) { defaultAllowUserInteraction = allow }

    /// Returns the default `useCaches` value for all new connections.
    ///
    /// - Since: Java 1.0
    public static func getDefaultUseCaches() -> Bool { return defaultUseCaches }

    /// Sets the default `useCaches` value for all new connections.
    ///
    /// - Since: Java 1.0
    public static func setDefaultUseCaches(_ flag: Bool) { defaultUseCaches = flag }

    /// Returns the `ifModifiedSince` value in epoch milliseconds.
    ///
    /// - Since: Java 1.0
    public func getIfModifiedSince() -> Int64 { return ifModifiedSince }

    /// Sets the `ifModifiedSince` value in epoch milliseconds.
    ///
    /// - Since: Java 1.0
    public func setIfModifiedSince(_ time: Int64) { ifModifiedSince = time }

    /// Sets the connect timeout in milliseconds. `0` means no timeout.
    ///
    /// - Since: Java 1.0
    public func setConnectTimeout(_ timeout: Int) { self.connectTimeout = timeout }

    /// Returns the connect timeout in milliseconds.
    ///
    /// - Since: Java 1.0
    public func getConnectTimeout() -> Int { return connectTimeout }

    /// Sets the read timeout in milliseconds. `0` means no timeout.
    ///
    /// - Since: Java 1.0
    public func setReadTimeout(_ timeout: Int) { self.readTimeout = timeout }

    /// Returns the read timeout in milliseconds.
    ///
    /// - Since: Java 1.0
    public func getReadTimeout() -> Int { return readTimeout }

    // MARK: - toString

    /// Returns a string representation of this connection.
    ///
    /// - Since: Java 1.0
    public func toString() -> String {
      return "\(type(of: self)):\(url.toExternalForm())"
    }
  }
}
