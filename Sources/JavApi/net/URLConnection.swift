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
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public class URLConnection: @unchecked Sendable {

    // MARK: - State

    internal let url: java.net.URL
    private var requestProperties: [String: String] = [:]
    private var doInput: Bool = true
    private var doOutput: Bool = false
    private var useCaches: Bool = true
    private var connectTimeout: Int = 0   // 0 = no timeout (Java default)
    private var readTimeout: Int = 0

    private var responseData: Data?
    private var httpResponse: HTTPURLResponse?
    private var connected: Bool = false

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
    /// - Throws: ``java.io.IOException`` if the connection fails.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
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

      let semaphore = DispatchSemaphore(value: 0)
      nonisolated(unsafe) var fetchError: (any Error)?

      let config = URLSessionConfiguration.default
      if !useCaches { config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData }
      let session = URLSession(configuration: config)

      session.dataTask(with: request) { data, response, error in
        self.responseData = data
        self.httpResponse = response as? HTTPURLResponse
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

    // MARK: - Streams

    /// Returns an input stream that reads from this connection.
    ///
    /// Calls ``connect()`` automatically if not yet connected.
    ///
    /// - Throws: ``java.io.IOException`` if the connection fails or returns no data.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
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
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getURL() -> java.net.URL {
      return url
    }

    /// Returns the value of the `Content-Length` header, or `-1` if unknown.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getContentLength() -> Int {
      guard connected else { return -1 }
      if let value = headerValue("Content-Length"), let length = Int(value) {
        return length
      }
      return responseData.map { $0.count } ?? -1
    }

    /// Returns the value of the `Content-Type` header, or `nil` if unknown.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getContentType() -> String? {
      guard connected else { return nil }
      return headerValue("Content-Type")
    }

    /// Returns the value of the named header field, or `nil` if absent.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getHeaderField(_ name: String) -> String? {
      guard connected else { return nil }
      return headerValue(name)
    }

    /// Cross-platform header lookup (case-insensitive) via `allHeaderFields`.
    private func headerValue(_ name: String) -> String? {
      guard let headers = httpResponse?.allHeaderFields else { return nil }
      let lower = name.lowercased()
      for (key, value) in headers {
        if let k = key as? String, k.lowercased() == lower {
          return value as? String
        }
      }
      return nil
    }

    /// Returns the HTTP status code, or `-1` if not connected or not HTTP.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getResponseCode() -> Int {
      return httpResponse?.statusCode ?? -1
    }

    // MARK: - Request properties

    /// Sets a request header field.
    ///
    /// Must be called before ``connect()``.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setRequestProperty(_ key: String, _ value: String) {
      requestProperties[key] = value
    }

    /// Returns the value of the named request property, or `nil` if not set.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getRequestProperty(_ key: String) -> String? {
      return requestProperties[key]
    }

    // MARK: - Configuration

    /// Sets whether this connection will be used for input. Default: `true`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setDoInput(_ doInput: Bool) { self.doInput = doInput }

    /// Returns whether this connection is used for input.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getDoInput() -> Bool { return doInput }

    /// Sets whether this connection will be used for output (POST). Default: `false`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setDoOutput(_ doOutput: Bool) { self.doOutput = doOutput }

    /// Returns whether this connection is used for output.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getDoOutput() -> Bool { return doOutput }

    /// Sets whether caching is used. Default: `true`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setUseCaches(_ useCaches: Bool) { self.useCaches = useCaches }

    /// Returns whether caching is used.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getUseCaches() -> Bool { return useCaches }

    /// Sets the connect timeout in milliseconds. `0` means no timeout.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setConnectTimeout(_ timeout: Int) { self.connectTimeout = timeout }

    /// Returns the connect timeout in milliseconds.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getConnectTimeout() -> Int { return connectTimeout }

    /// Sets the read timeout in milliseconds. `0` means no timeout.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func setReadTimeout(_ timeout: Int) { self.readTimeout = timeout }

    /// Returns the read timeout in milliseconds.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func getReadTimeout() -> Int { return readTimeout }

    // MARK: - toString

    /// Returns a string representation of this connection.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public func toString() -> String {
      return "\(type(of: self)):\(url.toExternalForm())"
    }
  }
}
