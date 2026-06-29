/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_net_URI_Tests {

  // MARK: - init(_ uriString)

  @Test("init parses absolute URI")
  func testInitAbsolute() throws {
    let uri = try java.net.URI("https://www.example.com/path?q=1#frag")
    #expect(uri.getScheme() == "https")
    #expect(uri.getHost() == "www.example.com")
    #expect(uri.getPath() == "/path")
    #expect(uri.getQuery() == "q=1")
    #expect(uri.getFragment() == "frag")
  }

  @Test("init parses relative URI")
  func testInitRelative() throws {
    let uri = try java.net.URI("/path/to/resource")
    #expect(uri.getScheme() == nil)
    #expect(uri.getPath() == "/path/to/resource")
  }

  @Test("init with port")
  func testInitWithPort() throws {
    let uri = try java.net.URI("http://localhost:8080/api")
    #expect(uri.getPort() == 8080)
    #expect(uri.getHost() == "localhost")
  }

  @Test("init returns -1 for absent port")
  func testInitNoPort() throws {
    let uri = try java.net.URI("http://example.com/")
    #expect(uri.getPort() == -1)
  }

  @Test("init with userInfo")
  func testInitUserInfo() throws {
    let uri = try java.net.URI("ftp://user@ftp.example.com/pub")
    #expect(uri.getUserInfo() == "user")
    #expect(uri.getHost() == "ftp.example.com")
  }

  // MARK: - init components

  @Test("component init builds correct URI string")
  func testComponentInit() throws {
    let uri = try java.net.URI("https", nil, "example.com", 443, "/path", "k=v", "sec")
    #expect(uri.getScheme() == "https")
    #expect(uri.getHost() == "example.com")
    #expect(uri.getPort() == 443)
    #expect(uri.getPath() == "/path")
    #expect(uri.getQuery() == "k=v")
    #expect(uri.getFragment() == "sec")
  }

  @Test("component init with port -1 omits port")
  func testComponentInitNoPort() throws {
    let uri = try java.net.URI("http", nil, "example.com", -1, "/", nil, nil)
    #expect(uri.getPort() == -1)
  }

  // MARK: - create()

  @Test("create() returns URI for valid string")
  func testCreate() {
    let uri = java.net.URI.create("https://example.com")
    #expect(uri.getScheme() == "https")
    #expect(uri.toString() == "https://example.com")
  }

  // MARK: - isAbsolute()

  @Test("isAbsolute() true when scheme present")
  func testIsAbsoluteTrue() throws {
    let uri = try java.net.URI("https://example.com")
    #expect(uri.isAbsolute() == true)
  }

  @Test("isAbsolute() false when no scheme")
  func testIsAbsoluteFalse() throws {
    let uri = try java.net.URI("/relative/path")
    #expect(uri.isAbsolute() == false)
  }

  // MARK: - isOpaque()

  @Test("isOpaque() true for opaque URI")
  func testIsOpaqueTrue() throws {
    let uri = try java.net.URI("mailto:user@example.com")
    #expect(uri.isOpaque() == true)
  }

  @Test("isOpaque() false for hierarchical URI")
  func testIsOpaqueFalse() throws {
    let uri = try java.net.URI("https://example.com/path")
    #expect(uri.isOpaque() == false)
  }

  @Test("isOpaque() false for relative URI")
  func testIsOpaqueRelative() throws {
    let uri = try java.net.URI("/path")
    #expect(uri.isOpaque() == false)
  }

  // MARK: - normalize()

  @Test("normalize() removes dot segments")
  func testNormalize() throws {
    let uri = try java.net.URI("http://example.com/a/b/../c/./d")
    let n = uri.normalize()
    #expect(n.getPath() == "/a/c/d")
  }

  @Test("normalize() returns same instance when nothing to normalize")
  func testNormalizeNoOp() throws {
    let uri = try java.net.URI("http://example.com/clean/path")
    let n = uri.normalize()
    #expect(n.getPath() == "/clean/path")
  }

  // MARK: - resolve()

  @Test("resolve() absolute URI returns it unchanged")
  func testResolveAbsolute() throws {
    let base = try java.net.URI("http://example.com/base/")
    let other = try java.net.URI("https://other.com/page")
    let resolved = base.resolve(other)
    #expect(resolved.toString() == "https://other.com/page")
  }

  @Test("resolve() relative path against base")
  func testResolveRelative() throws {
    let base = try java.net.URI("http://example.com/a/b/c")
    let rel  = try java.net.URI("d")
    let resolved = base.resolve(rel)
    #expect(resolved.getScheme() == "http")
    #expect(resolved.getHost() == "example.com")
    #expect(resolved.getPath().hasSuffix("d"))
  }

  @Test("resolve(String) works identically to resolve(URI)")
  func testResolveString() throws {
    let base = try java.net.URI("http://example.com/base/")
    let resolved = base.resolve("page.html")
    #expect(resolved.getScheme() == "http")
    #expect(resolved.getPath().contains("page.html"))
  }

  // MARK: - relativize()

  @Test("relativize() removes common prefix")
  func testRelativize() throws {
    let base   = try java.net.URI("http://example.com/a/b/")
    let target = try java.net.URI("http://example.com/a/b/c/d")
    let rel = base.relativize(target)
    #expect(rel.getPath() == "c/d")
    #expect(rel.isAbsolute() == false)
  }

  @Test("relativize() returns target when no common prefix")
  func testRelativizeDifferentHost() throws {
    let base   = try java.net.URI("http://example.com/a/")
    let target = try java.net.URI("http://other.com/a/b")
    let rel = base.relativize(target)
    #expect(rel.toString() == "http://other.com/a/b")
  }

  // MARK: - toString() / toASCIIString()

  @Test("toString() returns original URI string")
  func testToString() throws {
    let raw = "https://example.com/path?q=1#f"
    let uri = try java.net.URI(raw)
    #expect(uri.toString() == raw)
  }

  @Test("toASCIIString() returns non-empty string")
  func testToASCIIString() throws {
    let uri = try java.net.URI("https://example.com/path")
    #expect(!uri.toASCIIString().isEmpty)
  }

  // MARK: - toURL()

  @Test("toURL() succeeds for absolute URI")
  func testToURLAbsolute() throws {
    let uri = try java.net.URI("http://example.com/index.html")
    let url = try uri.toURL()
    #expect(url.toString().contains("example.com"))
  }

  @Test("toURL() throws for relative URI")
  func testToURLRelativeThrows() throws {
    let uri = try java.net.URI("/relative")
    #expect(throws: java.net.MalformedURLException.self) {
      _ = try uri.toURL()
    }
  }

  // MARK: - compareTo() / Equatable / Comparable

  @Test("compareTo() equal URIs return 0")
  func testCompareToEqual() throws {
    let a = try java.net.URI("http://example.com")
    let b = try java.net.URI("http://example.com")
    #expect(try a.compareTo(b) == 0)
  }

  @Test("compareTo() lesser URI returns negative")
  func testCompareToLesser() throws {
    let a = try java.net.URI("http://a.com")
    let b = try java.net.URI("http://b.com")
    #expect(try a.compareTo(b) < 0)
  }

  @Test("== returns true for equal URI strings")
  func testEquality() throws {
    let a = try java.net.URI("https://example.com/path")
    let b = try java.net.URI("https://example.com/path")
    #expect(a == b)
  }

  @Test("== returns false for different URIs")
  func testInequality() throws {
    let a = try java.net.URI("https://example.com/a")
    let b = try java.net.URI("https://example.com/b")
    #expect(a != b)
  }

  @Test("< works as lexicographic comparison")
  func testLessThan() throws {
    let a = try java.net.URI("http://a.com")
    let b = try java.net.URI("http://b.com")
    #expect(a < b)
  }

  // MARK: - getAuthority()

  @Test("getAuthority() returns host for URI without port")
  func testGetAuthorityHostOnly() throws {
    let uri = try java.net.URI("http://example.com/path")
    #expect(uri.getAuthority() == "example.com")
  }

  @Test("getAuthority() includes port when present")
  func testGetAuthorityWithPort() throws {
    let uri = try java.net.URI("http://example.com:9090/path")
    let auth = uri.getAuthority()
    #expect(auth?.contains("9090") == true)
  }

  @Test("getAuthority() includes userInfo when present")
  func testGetAuthorityWithUser() throws {
    let uri = try java.net.URI("ftp://user@ftp.example.com/pub")
    let auth = uri.getAuthority()
    #expect(auth?.contains("user") == true)
    #expect(auth?.contains("ftp.example.com") == true)
  }

  // MARK: - Error cases

  @Test("init throws URISyntaxException for invalid URI")
  func testInitInvalidThrows() throws {
    #expect(throws: java.net.URISyntaxException.self) {
      _ = try java.net.URI("http://[invalid")
    }
  }

  // MARK: - normalize() edge cases

  @Test("normalize() collapses leading double-dot")
  func testNormalizeLeadingDoubleDot() throws {
    let uri = try java.net.URI("http://example.com/../a")
    let n = uri.normalize()
    #expect(!n.getPath().contains(".."))
  }

  @Test("normalize() handles multiple consecutive dots")
  func testNormalizeMultipleDoubleDots() throws {
    let uri = try java.net.URI("http://example.com/a/b/../../c")
    let n = uri.normalize()
    #expect(n.getPath() == "/c")
  }

  @Test("normalize() preserves trailing slash")
  func testNormalizeTrailingSlash() throws {
    let uri = try java.net.URI("http://example.com/a/b/../c/")
    let n = uri.normalize()
    #expect(n.getPath().hasSuffix("/"))
  }

  // MARK: - resolve() edge cases

  @Test("resolve() empty string returns normalized self")
  func testResolveEmptyString() throws {
    let base = try java.net.URI("http://example.com/a/b")
    let resolved = base.resolve("")
    #expect(resolved.getScheme() == "http")
  }

  @Test("resolve() absolute path replaces path only")
  func testResolveAbsolutePath() throws {
    let base = try java.net.URI("http://example.com/a/b")
    let rel  = try java.net.URI("/new/path")
    let resolved = base.resolve(rel)
    #expect(resolved.getPath() == "/new/path")
    #expect(resolved.getHost() == "example.com")
  }

  // MARK: - getSchemeSpecificPart()

  @Test("getSchemeSpecificPart() returns path+query for hierarchical URI")
  func testGetSchemeSpecificPart() throws {
    let uri = try java.net.URI("http://example.com/path?q=1")
    let ssp = uri.getSchemeSpecificPart()
    #expect(ssp.contains("/path"))
    #expect(ssp.contains("q=1"))
  }

  @Test("getSchemeSpecificPart() returns opaque part for mailto URI")
  func testGetSchemeSpecificPartOpaque() throws {
    let uri = try java.net.URI("mailto:user@example.com")
    let ssp = uri.getSchemeSpecificPart()
    #expect(ssp.contains("user@example.com"))
  }

  // MARK: - fragment-only URI

  @Test("fragment-only URI has no scheme and no path")
  func testFragmentOnly() throws {
    let uri = try java.net.URI("#section")
    #expect(uri.getScheme() == nil)
    #expect(uri.getFragment() == "section")
    #expect(uri.isAbsolute() == false)
  }
}
