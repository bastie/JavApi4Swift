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

    // MARK: - Global file name map (Java 1.1)

    /// Built-in default `FileNameMap` with common extension-to-MIME mappings.
    private final class DefaultFileNameMap: java.net.FileNameMap, @unchecked Sendable {
      func getContentTypeFor(_ fileName: String) -> String? {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "html", "htm": return "text/html"
        case "txt", "text": return "text/plain"
        case "css":         return "text/css"
        case "js":          return "application/javascript"
        case "json":        return "application/json"
        case "xml":         return "application/xml"
        case "gif":         return "image/gif"
        case "png":         return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "svg":         return "image/svg+xml"
        case "pdf":         return "application/pdf"
        case "zip":         return "application/zip"
        case "gz":          return "application/gzip"
        default:            return nil
        }
      }
    }

    /// The global file name map, replaceable via ``setFileNameMap(_:)``.
    nonisolated(unsafe) private static var _fileNameMap: any java.net.FileNameMap = DefaultFileNameMap()

    /// Returns the file name map used to guess content types from file names.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public static func getFileNameMap() -> any java.net.FileNameMap {
      return _fileNameMap
    }

    /// Replaces the global file name map.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public static func setFileNameMap(_ map: any java.net.FileNameMap) {
      _fileNameMap = map
    }

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

    /// The HTTP method to use for the request. Overridden by `HttpURLConnection`
    /// to honour `setRequestMethod(_:)`. The base class derives it from `doOutput`.
    internal var effectiveRequestMethod: String {
      return doOutput ? "POST" : "GET"
    }

    /// Opens a connection to the resource referenced by this URL.
    ///
    /// Performs a synchronous HTTP request and stores the response body and
    /// headers. Must be called before ``getInputStream()``,
    /// ``getContentLength()``, or ``getHeaderField(_:)``.
    ///
    /// - Platform note: On Apple platforms the request is performed with
    ///   `Foundation.URLSession`. On Linux `URLSession` is **not** used here:
    ///   swift-corelibs-foundation's libcurl-backed `URLSession` has a known
    ///   bug where the internal `_MultiHandle` tears down its socket
    ///   `DispatchSource` before the cancellation handler runs, leaving a
    ///   non-zero retain count and aborting the process (signal 6). See
    ///   swift-corelibs-foundation issue #4791. To avoid that crash we shell
    ///   out to the synchronous `curl` command-line tool on Linux, which does
    ///   not exercise the broken `_MultiHandle` teardown path.
    ///
    /// - FIXME: Remove the Linux-only `curl` workaround (the `#elseif os(Linux)`
    ///   branch here plus `connectViaCurl()` and its helpers) and let Linux use
    ///   the regular `URLSession` path once swift-corelibs-foundation issue
    ///   #4791 (`_MultiHandle` deallocated with non-zero retain count) is fixed
    ///   by Apple. Also drop the `#elseif os(Linux)` branches in
    ///   `headerValue(_:)` and `getResponseCode()`, the Linux override in
    ///   `HttpURLConnection.swift`, and the `_linuxStatusCode` / `_linuxHeaders`
    ///   storage once the upstream fix is available.
    ///
    /// - Throws: `java.io.IOException` if the connection fails.
    /// - Since: Java 1.0
    public func connect() throws {
      guard !connected else { return }
#if os(WASI)
      throw java.io.IOException("URLConnection.connect() is unavailable on WASI")
#elseif os(Linux)
      try connectViaCurl()
      connected = true
#else
      var request = URLRequest(url: url.foundationURL)
      for (key, value) in requestProperties {
        request.setValue(value, forHTTPHeaderField: key)
      }
      if connectTimeout > 0 {
        request.timeoutInterval = Double(connectTimeout) / 1000.0
      }
      request.httpMethod = effectiveRequestMethod
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

      session.dataTask(with: request) { [weak self] data, response, error in
        self?.responseData = data
        self?._httpResponse = response as? HTTPURLResponse
        fetchError = error
        semaphore.signal()
      }.resume()

      semaphore.wait()
      session.finishTasksAndInvalidate()

      if let error = fetchError {
        throw java.io.IOException(error.localizedDescription)
      }
      connected = true
#endif
    }

#if os(Linux)
    /// Linux-only synchronous HTTP fetch via the `curl` command-line tool.
    ///
    /// This deliberately avoids `Foundation.URLSession` on Linux to work around
    /// swift-corelibs-foundation issue #4791 (`_MultiHandle` deallocated with
    /// non-zero retain count → SIGABRT). `Foundation.Process` runs `curl`
    /// synchronously and we parse the response headers and body ourselves.
    private func connectViaCurl() throws {
      let process = Foundation.Process()
      process.executableURL = Foundation.URL(fileURLWithPath: "/usr/bin/curl")

      var args: [String] = [
        "-sS",            // silent but still report errors
        "-i",             // include response headers in output
        "-X", effectiveRequestMethod,
      ]
      if instanceFollowsRedirectsForCurl {
        args.append("-L")   // follow redirects; curl does not by default
      }
      for (key, value) in requestProperties {
        args.append("-H")
        args.append("\(key): \(value)")
      }
      if connectTimeout > 0 {
        args.append("--connect-timeout")
        args.append(String(Double(connectTimeout) / 1000.0))
      }
      if readTimeoutForCurl > 0 {
        args.append("--max-time")
        args.append(String(Double(readTimeoutForCurl) / 1000.0))
      }
      if ifModifiedSince > 0 {
        let date = Date(timeIntervalSince1970: Double(ifModifiedSince) / 1000.0)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Foundation.TimeZone(abbreviation: "GMT") ?? Foundation.TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        args.append("-H")
        args.append("If-Modified-Since: \(formatter.string(from: date))")
      }
      args.append(url.toExternalForm())
      process.arguments = args

      let stdoutPipe = Pipe()
      let stderrPipe = Pipe()
      process.standardOutput = stdoutPipe
      process.standardError = stderrPipe

      do {
        try process.run()
      } catch {
        throw java.io.IOException("Failed to launch curl: \(error.localizedDescription)")
      }

      // Read fully BEFORE waitUntilExit to avoid deadlock on large pipe buffers.
      let outData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
      let errData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
      process.waitUntilExit()

      guard process.terminationStatus == 0 else {
        let msg = String(data: errData, encoding: .utf8) ?? "curl exited with status \(process.terminationStatus)"
        throw java.io.IOException(msg.isEmpty ? "curl exited with status \(process.terminationStatus)" : msg)
      }

      try parseCurlResponse(outData)
    }

    /// Splits curl's `-i` output (possibly several header blocks across
    /// redirects) into the final header block and the response body, then
    /// stores them on this connection.
    ///
    /// The header/body boundary is located on the raw bytes (so the body is
    /// preserved byte-exact, never re-encoded), while the header block itself is
    /// decoded as text for parsing. HTTP headers are ASCII, so decoding them is
    /// always safe. Both `\r\n\r\n` and `\n\n` separators are handled.
    private func parseCurlResponse(_ raw: Data) throws {
      let crlfcrlf = Data([0x0D, 0x0A, 0x0D, 0x0A]) // \r\n\r\n
      let lflf = Data([0x0A, 0x0A])                 // \n\n
      let httpPrefix = Data("HTTP/".utf8)

      // Locate the boundary (lowerBound = end of header block,
      // upperBound = start of body) of the FINAL header block. curl -i prints
      // [headers]<sep>[headers]<sep>...[final headers]<sep>[body], and every
      // header block begins with "HTTP/".
      func nextBoundary(from index: Data.Index) -> Range<Data.Index>? {
        let crlf = raw.range(of: crlfcrlf, in: index..<raw.endIndex)
        let lf = raw.range(of: lflf, in: index..<raw.endIndex)
        switch (crlf, lf) {
        case let (.some(a), .some(b)): return a.lowerBound <= b.lowerBound ? a : b
        case let (.some(a), .none):    return a
        case let (.none, .some(b)):    return b
        case (.none, .none):           return nil
        }
      }

      var blockStart = raw.startIndex
      var bestRange: Range<Data.Index>? = nil
      var bestStart = raw.startIndex
      var cursor = raw.startIndex
      while let boundary = nextBoundary(from: cursor) {
        if raw[blockStart...].starts(with: httpPrefix) {
          bestRange = boundary
          bestStart = blockStart
        }
        cursor = boundary.upperBound
        blockStart = boundary.upperBound
        if !raw[cursor...].starts(with: httpPrefix) { break }
      }

      let headerData: Data
      let bodyData: Data
      if let boundary = bestRange {
        headerData = raw.subdata(in: bestStart..<boundary.lowerBound)
        bodyData = raw.subdata(in: boundary.upperBound..<raw.endIndex)
      } else {
        headerData = Data()
        bodyData = raw
      }

      self.responseData = bodyData
      // Headers are ASCII; normalise CRLF→LF for line-based parsing.
      let headerBlock = String(decoding: headerData, as: UTF8.self)
        .replacingOccurrences(of: "\r\n", with: "\n")
      self._linuxStatusCode = parseStatusCode(from: headerBlock)
      self._linuxHeaders = parseHeaders(from: headerBlock)
    }

    private func parseStatusCode(from headerBlock: String) -> Int {
      // First line looks like: "HTTP/1.1 200 OK" or "HTTP/2 200 ".
      guard let firstLine = headerBlock.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true).first
      else { return -1 }
      // split(separator:) omits empty subsequences, so a trailing space is fine.
      let parts = firstLine.split(separator: " ")
      guard parts.count >= 2, let code = Int(parts[1]) else { return -1 }
      return code
    }

    private func parseHeaders(from headerBlock: String) -> [String: String] {
      var headers: [String: String] = [:]
      let lines = headerBlock.split(separator: "\n", omittingEmptySubsequences: true)
      for line in lines.dropFirst() { // skip status line
        guard let colon = line.firstIndex(of: ":") else { continue }
        let key = line[line.startIndex..<colon].trimmingCharacters(in: .whitespaces)
        let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        if !key.isEmpty { headers[key] = value }
      }
      return headers
    }

    /// Linux-side storage for the parsed status code (URLSession path uses `_httpResponse`).
    nonisolated(unsafe) private var _linuxStatusCode: Int = -1
    /// Linux-side storage for the parsed response headers.
    nonisolated(unsafe) private var _linuxHeaders: [String: String] = [:]

    /// Linux status-code accessor for subclasses / `getResponseCode()`.
    internal var linuxStatusCode: Int { _linuxStatusCode }
    /// Linux header accessor used by `headerValue(_:)`.
    internal var linuxHeaders: [String: String] { _linuxHeaders }

    /// Whether curl should follow redirects. Base class never redirects;
    /// `HttpURLConnection` overrides this from `instanceFollowRedirects`.
    internal var instanceFollowsRedirectsForCurl: Bool { false }
    /// Read timeout in ms exposed to the curl path (base class has no public getter override need).
    private var readTimeoutForCurl: Int { getReadTimeout() }
#endif

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

    /// Cross-platform header lookup (case-insensitive).
    /// - Returns optional value of named header
    private func headerValue(_ name: String) -> String? {
#if os(WASI)
      return nil
#elseif os(Linux)
      let lower = name.lowercased()
      for (key, value) in linuxHeaders where key.lowercased() == lower {
        return value
      }
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
#elseif os(Linux)
      return linuxStatusCode
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
