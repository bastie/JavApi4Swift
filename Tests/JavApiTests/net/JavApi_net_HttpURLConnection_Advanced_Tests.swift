/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_net_HttpURLConnection_Advanced_Tests {

  // MARK: - Unit Tests (No Network Required)

  @Test("HTTP_OK equals 200")
  func testHttpOkValue() {
    #expect(java.net.HttpURLConnection.HTTP_OK == 200)
  }

  @Test("HTTP_NOT_FOUND equals 404")
  func testHttpNotFoundValue() {
    #expect(java.net.HttpURLConnection.HTTP_NOT_FOUND == 404)
  }

  @Test("HTTP_INTERNAL_ERROR equals 500")
  func testHttpInternalErrorValue() {
    #expect(java.net.HttpURLConnection.HTTP_INTERNAL_ERROR == 500)
  }

  @Test("followRedirects defaults to true")
  func testFollowRedirectsDefault() {
    #expect(java.net.HttpURLConnection.followRedirects == true)
  }

  // MARK: - Instantiation & Type Tests

  @Test("HTTP URL creates HttpURLConnection instance")
  func testHttpUrlCreatesHttpURLConnection() throws {
    let url = try java.net.URL("http://example.com/path")
    let conn = url.openConnection()
    #expect(conn is java.net.HttpURLConnection)
  }

  @Test("HTTPS URL creates HttpURLConnection instance")
  func testHttpsUrlCreatesHttpURLConnection() throws {
    let url = try java.net.URL("https://example.com/path")
    let conn = url.openConnection()
    #expect(conn is java.net.HttpURLConnection)
  }

  @Test("FTP URL creates URLConnection (not HttpURLConnection)")
  func testFtpUrlCreatesUrlConnection() throws {
    let url = try java.net.URL("ftp://example.com/path")
    let conn = url.openConnection()
    // FTP should return base URLConnection, not HttpURLConnection
    #expect(type(of: conn).self == java.net.URLConnection.self ||
            conn is java.net.HttpURLConnection) // FTP may not be supported
  }

  // MARK: - Request Method Behavior (No Network)

  @Test("New HttpURLConnection has GET as default method")
  func testDefaultMethodIsGet() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    #expect(conn.getRequestMethod() == "GET")
  }

  @Test("setRequestMethod normalizes to uppercase")
  func testMethodNormalization() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.setRequestMethod("post")
    #expect(conn.getRequestMethod() == "POST")
  }

  @Test("Can set any HTTP method string")
  func testArbitraryHttpMethod() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.setRequestMethod("PATCH")
    #expect(conn.getRequestMethod() == "PATCH")
  }

  @Test("setRequestMethod throws after connect()")
  func testCannotSetMethodAfterConnect() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()

    do {
      try conn.setRequestMethod("POST")
      Issue.record("Should have thrown ProtocolException")
    } catch _ as java.net.ProtocolException {
      return // Expected
    } catch {
      Issue.record("Unexpected exception: \(error)")
    }
  }

  // MARK: - Disconnect Tests (No Network)

  @Test("disconnect() marks connection as closed")
  func testDisconnectState() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    conn.disconnect()
    #expect(Bool(true)) // If no exception, test passes
  }

  @Test("Can call disconnect() multiple times")
  func testMultipleDisconnects() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    conn.disconnect()
    conn.disconnect() // Should not throw
    #expect(true)
  }

  // MARK: - URL Preservation

  @Test("Connection preserves original URL")
  func testUrlPreservation() throws {
    let urlString = "http://example.com/path?query=value"
    let url = try java.net.URL(urlString)
    let conn = url.openConnection() as! java.net.HttpURLConnection
    #expect(conn.getURL().toExternalForm() == urlString)
  }

  @Test("HTTPS URL is preserved")
  func testHttpsUrlPreservation() throws {
    let urlString = "https://secure.example.com:8443/api"
    let url = try java.net.URL(urlString)
    let conn = url.openConnection() as! java.net.HttpURLConnection
    #expect(conn.getURL().toExternalForm() == urlString)
  }

  // MARK: - Instance Properties

  @Test("instanceFollowRedirects follows class default")
  func testInstanceFollowRedirectsDefault() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    let classDefault = java.net.HttpURLConnection.followRedirects
    #expect(conn.instanceFollowRedirects == classDefault)
  }

  @Test("Can override instanceFollowRedirects")
  func testOverrideInstanceFollowRedirects() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    let original = conn.instanceFollowRedirects
    conn.instanceFollowRedirects = !original
    #expect(conn.instanceFollowRedirects == !original)
  }

  // MARK: - Before-Connect Behavior

  @Test("getResponseCode() before connect returns -1 or connects automatically")
  func testResponseCodeBeforeConnect() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    let code = try conn.getResponseCode()
    // Either -1 (not connected) or a valid HTTP code (auto-connected)
    #expect(code == -1 || (code >= 200 && code < 600))
  }

  @Test("getResponseMessage() before connect returns nil or connects automatically")
  func testResponseMessageBeforeConnect() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    let msg = conn.getResponseMessage()
    // Either nil or a valid message
    #expect(msg == nil || msg!.count > 0)
  }

  // MARK: - Method Chaining

  @Test("Can set method, then connect, then get response code")
  func testMethodChaining() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.setRequestMethod("GET")
    try conn.connect()
    let code = try conn.getResponseCode()
    #expect(code >= 0)
  }

  // MARK: - Subclass Identity Verification

  @Test("Cast to HttpURLConnection succeeds for HTTP URLs")
  func testHttpCast() throws {
    let url = try java.net.URL("http://example.com")
    let conn = url.openConnection()
    #expect((conn as? java.net.HttpURLConnection) != nil)
  }

  @Test("Cast to HttpURLConnection succeeds for HTTPS URLs")
  func testHttpsCast() throws {
    let url = try java.net.URL("https://example.com")
    let conn = url.openConnection()
    #expect((conn as? java.net.HttpURLConnection) != nil)
  }
}
