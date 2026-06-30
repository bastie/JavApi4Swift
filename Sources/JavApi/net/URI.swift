/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.net {

  /// A Uniform Resource Identifier (URI) reference.
  ///
  /// Mirrors `java.net.URI` (Java 1.4).  Parsing follows RFC 2396 / RFC 2732
  /// using Foundation's `URLComponents` as the underlying engine.
  ///
  /// **Supported operations**
  /// - All component accessors (`getScheme`, `getHost`, `getPort`, `getPath`,
  ///   `getQuery`, `getFragment`, `getUserInfo`, `getAuthority`,
  ///   `getSchemeSpecificPart`)
  /// - `isAbsolute()`, `isOpaque()`
  /// - `normalize()`, `resolve(_:)`, `relativize(_:)`
  /// - `toURL()`, `toString()`, `toASCIIString()`
  /// - `compareTo(_:)`, `==`, `<`
  /// - Static factory `create(_:)` (non-throwing, throws `fatalError` on
  ///   invalid input — matching Java's `URI.create`)
  ///
  /// - Since: Java 1.4
  public final class URI : ComparableJ {

    // -------------------------------------------------------------------------
    // MARK: - Storage
    // -------------------------------------------------------------------------

    private let _uriString: String

    /// Parsed components (nil when the URI could not be decomposed).
    private let _components: URLComponents?

    // -------------------------------------------------------------------------
    // MARK: - ComparableJ / Equatable / Comparable
    // -------------------------------------------------------------------------

    public typealias ComparableJ = URI

    public static func == (lhs: URI, rhs: URI) -> Bool {
      lhs._uriString == rhs._uriString
    }

    public static func < (lhs: URI, rhs: URI) -> Bool {
      lhs._uriString < rhs._uriString
    }

    public func compareTo(_ other: java.net.URI?) throws -> Int {
      guard let other else { throw java.lang.NullPointerException() }
      return _uriString < other._uriString ? -1 : (_uriString > other._uriString ? 1 : 0)
    }

    // -------------------------------------------------------------------------
    // MARK: - Constructors
    // -------------------------------------------------------------------------

    /// Creates a URI by parsing `uriString`.
    /// - Throws: `URISyntaxException` when `uriString` is not a valid URI.
    public init(_ uriString: String) throws {
      guard let comps = URLComponents(string: uriString) else {
        throw java.net.URISyntaxException(uriString, "Malformed URI")
      }
      self._uriString = uriString
      self._components = comps
    }

    /// Creates a hierarchical URI from components.
    /// - Parameters:
    ///   - scheme: optional scheme
    ///   - userInfo: optional user-info
    ///   - host: optional host
    ///   - port: port (-1 = absent)
    ///   - path: path (may be empty)
    ///   - query: optional query
    ///   - fragment: optional fragment
    /// - Throws: `URISyntaxException` when the combination is invalid.
    public convenience init(
      _ scheme: String?,
      _ userInfo: String?,
      _ host: String?,
      _ port: Int,
      _ path: String,
      _ query: String?,
      _ fragment: String?
    ) throws {
      var comps = URLComponents()
      comps.scheme   = scheme
      comps.user     = userInfo
      comps.host     = host
      comps.port     = port >= 0 ? port : nil
      comps.path     = path
      comps.query    = query
      comps.fragment = fragment
      guard let str = comps.string else {
        throw java.net.URISyntaxException("", "Cannot construct URI from given components")
      }
      try self.init(str)
    }

    /// Creates a hierarchical URI without authority.
    public convenience init(
      _ scheme: String?,
      _ path: String,
      _ fragment: String?
    ) throws {
      var comps = URLComponents()
      comps.scheme   = scheme
      comps.path     = path
      comps.fragment = fragment
      guard let str = comps.string else {
        throw java.net.URISyntaxException("", "Cannot construct URI from given components")
      }
      try self.init(str)
    }

    /// Creates a URI with scheme, scheme-specific-part and fragment.
    public convenience init(
      _ scheme: String?,
      _ ssp: String,
      _ fragment: String?,
      _ opaque: Bool   // disambiguator — pass `true` to select this overload
    ) throws {
      var raw = ""
      if let s = scheme { raw += s + ":" }
      raw += ssp
      if let f = fragment { raw += "#" + f }
      try self.init(raw)
    }

    // -------------------------------------------------------------------------
    // MARK: - Static factory
    // -------------------------------------------------------------------------

    /// Creates a URI from `str`, calling `fatalError` on invalid input.
    /// Matches Java's `URI.create(String)`.
    public static func create(_ str: String) -> URI {
      guard let comps = URLComponents(string: str) else {
        fatalError("java.net.URI.create: illegal URI '\(str)'")
      }
      let uri = URI._unchecked(str, comps)
      return uri
    }

    /// Internal unchecked constructor (avoids double-parsing in `create`).
    private static func _unchecked(_ raw: String, _ comps: URLComponents) -> URI {
      // Use the throwing init but wrap — we already validated above.
      return (try? URI(raw)) ?? { fatalError("URI._unchecked: should never fail") }()
    }

    // -------------------------------------------------------------------------
    // MARK: - Component accessors
    // -------------------------------------------------------------------------

    /// Returns the scheme component, or `nil` if undefined.
    public func getScheme() -> String? { _components?.scheme }

    /// Returns the scheme-specific part of this URI.
    public func getSchemeSpecificPart() -> String {
      guard let c = _components else { return _uriString }
      var ssp = ""
      if let auth = _authority(c) { ssp += "//\(auth)" }
      ssp += c.path
      if let q = c.query { ssp += "?\(q)" }
      return ssp
    }

    /// Returns the raw (encoded) scheme-specific part.
    public func getRawSchemeSpecificPart() -> String { getSchemeSpecificPart() }

    /// Returns the authority component (`userInfo@host:port`), or `nil`.
    public func getAuthority() -> String? {
      guard let c = _components else { return nil }
      return _authority(c)
    }

    /// Returns the raw authority component, or `nil`.
    public func getRawAuthority() -> String? { getAuthority() }

    /// Returns the user-info component, or `nil`.
    public func getUserInfo() -> String? { _components?.user }

    /// Returns the raw user-info component, or `nil`.
    public func getRawUserInfo() -> String? { getUserInfo() }

    /// Returns the host component, or `nil`.
    public func getHost() -> String? { _components?.host }

    /// Returns the port, or `-1` if not specified.
    public func getPort() -> Int { _components?.port ?? -1 }

    /// Returns the decoded path component.
    public func getPath() -> String { _components?.path ?? "" }

    /// Returns the raw (encoded) path component.
    public func getRawPath() -> String { getPath() }

    /// Returns the decoded query component, or `nil`.
    public func getQuery() -> String? { _components?.query }

    /// Returns the raw (encoded) query component, or `nil`.
    public func getRawQuery() -> String? { getQuery() }

    /// Returns the decoded fragment component, or `nil`.
    public func getFragment() -> String? { _components?.fragment }

    /// Returns the raw (encoded) fragment component, or `nil`.
    public func getRawFragment() -> String? { getFragment() }

    // -------------------------------------------------------------------------
    // MARK: - Predicates
    // -------------------------------------------------------------------------

    /// Returns `true` if this URI has a scheme component (is absolute).
    public func isAbsolute() -> Bool { getScheme() != nil }

    /// Returns `true` if this URI is opaque (scheme-specific part does not
    /// begin with `/`).
    public func isOpaque() -> Bool {
      guard isAbsolute() else { return false }
      return !getSchemeSpecificPart().hasPrefix("/")
    }

    // -------------------------------------------------------------------------
    // MARK: - Normalization, resolution, relativization
    // -------------------------------------------------------------------------

    /// Returns a normalized URI (resolves `.` and `..` segments).
    public func normalize() -> URI {
      let path = getPath()
      guard !path.isEmpty else { return self }
      let normalized = _normalizePath(path)
      if normalized == path { return self }
      // Rebuild
      var c = _components ?? URLComponents()
      c.path = normalized
      let raw = c.string ?? _uriString
      return (try? URI(raw)) ?? self
    }

    /// Resolves `uri` against this URI.
    public func resolve(_ uri: URI) -> URI {
      if uri.isAbsolute() || isOpaque() { return uri }
      if uri._uriString.isEmpty { return self.normalize() }

      var result = URLComponents()
      result.scheme = getScheme()

      if uri.getAuthority() != nil {
        result.host     = uri.getHost()
        result.user     = uri.getUserInfo()
        result.port     = uri.getPort() >= 0 ? uri.getPort() : nil
        result.path     = _normalizePath(uri.getPath())
        result.query    = uri.getQuery()
      } else {
        result.host     = getHost()
        result.user     = getUserInfo()
        let selfPort    = getPort()
        result.port     = selfPort >= 0 ? selfPort : nil

        if uri.getPath().isEmpty {
          result.path   = getPath()
          result.query  = uri.getQuery() ?? getQuery()
        } else {
          let p = uri.getPath().hasPrefix("/")
            ? uri.getPath()
            : _merge(getPath(), uri.getPath())
          result.path   = _normalizePath(p)
          result.query  = uri.getQuery()
        }
      }
      result.fragment = uri.getFragment()
      let raw = result.string ?? _uriString
      return (try? URI(raw)) ?? self
    }

    /// Resolves the string `other` against this URI.
    public func resolve(_ other: String) -> URI {
      guard let uri = try? URI(other) else { return self }
      return resolve(uri)
    }

    /// Relativizes `uri` against this URI.
    public func relativize(_ uri: URI) -> URI {
      if isOpaque() || uri.isOpaque() { return uri }
      if getScheme() != uri.getScheme() { return uri }
      if getAuthority() != uri.getAuthority() { return uri }

      let base = getPath()
      let target = uri.getPath()

      // Find common prefix up to last '/'
      let prefix = base.hasSuffix("/") ? base : (base as NSString).deletingLastPathComponent + "/"
      guard target.hasPrefix(prefix) else { return uri }

      let rel = String(target.dropFirst(prefix.count))
      var c = URLComponents()
      c.path     = rel
      c.query    = uri.getQuery()
      c.fragment = uri.getFragment()
      let raw = c.string ?? rel
      return (try? URI(raw)) ?? uri
    }

    // -------------------------------------------------------------------------
    // MARK: - Conversion
    // -------------------------------------------------------------------------

    /// Converts this URI to a `java.net.URL`.
    /// - Throws: `MalformedURLException` when the URI is not absolute or
    ///   cannot be converted.
    public func toURL() throws -> java.net.URL {
      guard isAbsolute() else {
        throw java.net.MalformedURLException("URI is not absolute: \(_uriString)")
      }
      return try java.net.URL(_uriString)
    }

    /// Returns the string form of this URI.
    public func toString() -> String { _uriString }

    /// Returns the ASCII-encoded string form of this URI.
    public func toASCIIString() -> String {
      _uriString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? _uriString
    }

    // -------------------------------------------------------------------------
    // MARK: - Private helpers
    // -------------------------------------------------------------------------

    private func _authority(_ c: URLComponents) -> String? {
      var auth = ""
      if let u = c.user { auth += u + "@" }
      if let h = c.host { auth += h }
      if let p = c.port { auth += ":\(p)" }
      return auth.isEmpty ? nil : auth
    }

    /// Removes `.` and `..` segments from `path` (RFC 3986 §5.2.4).
    private func _normalizePath(_ path: String) -> String {
      let parts = path.components(separatedBy: "/")
      var result: [String] = []
      let leadingSlash = path.hasPrefix("/")
      let trailingSlash = path.hasSuffix("/") && path.count > 1
      for part in parts {
        switch part {
        case ".":
          break
        case "..":
          if !result.isEmpty { result.removeLast() }
        default:
          result.append(part)
        }
      }
      var out = result.joined(separator: "/")
      if leadingSlash && !out.hasPrefix("/") { out = "/" + out }
      if trailingSlash && !out.hasSuffix("/") { out += "/" }
      return out
    }

    /// Merges base path with relative path.
    private func _merge(_ base: String, _ relative: String) -> String {
      let dir = base.hasSuffix("/") ? base : (base as NSString).deletingLastPathComponent + "/"
      return dir + relative
    }
  }
}
