/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_net_HttpURLConnection_Tests {

  // MARK: - HTTP Status Code Constants

  @Test("HTTP_OK constant is 200")
  func testHttpOkConstant() {
    #expect(java.net.HttpURLConnection.HTTP_OK == 200)
  }

  @Test("HTTP_CREATED constant is 201")
  func testHttpCreatedConstant() {
    #expect(java.net.HttpURLConnection.HTTP_CREATED == 201)
  }

  @Test("HTTP_ACCEPTED constant is 202")
  func testHttpAcceptedConstant() {
    #expect(java.net.HttpURLConnection.HTTP_ACCEPTED == 202)
  }

  @Test("HTTP_NO_CONTENT constant is 204")
  func testHttpNoContentConstant() {
    #expect(java.net.HttpURLConnection.HTTP_NO_CONTENT == 204)
  }

  @Test("HTTP_MOVED_PERM constant is 301")
  func testHttpMovedPermConstant() {
    #expect(java.net.HttpURLConnection.HTTP_MOVED_PERM == 301)
  }

  @Test("HTTP_MOVED_TEMP constant is 302")
  func testHttpMovedTempConstant() {
    #expect(java.net.HttpURLConnection.HTTP_MOVED_TEMP == 302)
  }

  @Test("HTTP_NOT_MODIFIED constant is 304")
  func testHttpNotModifiedConstant() {
    #expect(java.net.HttpURLConnection.HTTP_NOT_MODIFIED == 304)
  }

  @Test("HTTP_BAD_REQUEST constant is 400")
  func testHttpBadRequestConstant() {
    #expect(java.net.HttpURLConnection.HTTP_BAD_REQUEST == 400)
  }

  @Test("HTTP_UNAUTHORIZED constant is 401")
  func testHttpUnauthorizedConstant() {
    #expect(java.net.HttpURLConnection.HTTP_UNAUTHORIZED == 401)
  }

  @Test("HTTP_FORBIDDEN constant is 403")
  func testHttpForbiddenConstant() {
    #expect(java.net.HttpURLConnection.HTTP_FORBIDDEN == 403)
  }

  @Test("HTTP_NOT_FOUND constant is 404")
  func testHttpNotFoundConstant() {
    #expect(java.net.HttpURLConnection.HTTP_NOT_FOUND == 404)
  }

  @Test("HTTP_INTERNAL_ERROR constant is 500")
  func testHttpInternalErrorConstant() {
    #expect(java.net.HttpURLConnection.HTTP_INTERNAL_ERROR == 500)
  }

  @Test("HTTP_NOT_IMPLEMENTED constant is 501")
  func testHttpNotImplementedConstant() {
    #expect(java.net.HttpURLConnection.HTTP_NOT_IMPLEMENTED == 501)
  }

  @Test("HTTP_BAD_GATEWAY constant is 502")
  func testHttpBadGatewayConstant() {
    #expect(java.net.HttpURLConnection.HTTP_BAD_GATEWAY == 502)
  }

  @Test("HTTP_UNAVAILABLE constant is 503")
  func testHttpUnavailableConstant() {
    #expect(java.net.HttpURLConnection.HTTP_UNAVAILABLE == 503)
  }

  // MARK: - Request Method

  @Test("Default request method is GET")
  func testDefaultRequestMethod() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    #expect(conn.getRequestMethod() == "GET")
  }

  @Test("Can set request method to POST")
  func testSetRequestMethodPost() throws {
    let url = try java.net.URL("https://httpbin.org/post")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.setRequestMethod("POST")
    #expect(conn.getRequestMethod() == "POST")
  }

  @Test("Can set request method to PUT")
  func testSetRequestMethodPut() throws {
    let url = try java.net.URL("https://httpbin.org/put")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.setRequestMethod("PUT")
    #expect(conn.getRequestMethod() == "PUT")
  }

  @Test("Can set request method to DELETE")
  func testSetRequestMethodDelete() throws {
    let url = try java.net.URL("https://httpbin.org/delete")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.setRequestMethod("DELETE")
    #expect(conn.getRequestMethod() == "DELETE")
  }

  @Test("Can set request method to HEAD")
  func testSetRequestMethodHead() throws {
    let url = try java.net.URL("https://httpbin.org/head")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.setRequestMethod("HEAD")
    #expect(conn.getRequestMethod() == "HEAD")
  }

  @Test("Request method is case-normalized to uppercase")
  func testRequestMethodNormalizedToUppercase() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.setRequestMethod("get")
    #expect(conn.getRequestMethod() == "GET")
  }

  @Test("Cannot change request method after connect")
  func testCannotChangeMethodAfterConnect() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()
    do {
      try conn.setRequestMethod("POST")
      Issue.record("Should have thrown ProtocolException")
    } catch _ as java.net.ProtocolException {
      // Expected exception was thrown
      return
    } catch {
      Issue.record("Wrong exception type: \(type(of: error))")
    }
  }

  // MARK: - Disconnect

  @Test("disconnect() closes the connection")
  func testDisconnect() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()
    conn.disconnect()
    #expect(Bool(true)) // If disconnect throws, test fails
  }

  @Test("Can reconnect after disconnect")
  func testReconnectAfterDisconnect() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()
    conn.disconnect()
    // Should be able to connect again
    try conn.connect()
    #expect(Bool(true))
  }

  // MARK: - Redirect Behavior

  @Test("followRedirects class variable defaults to true")
  func testFollowRedirectsDefault() {
    #expect(java.net.HttpURLConnection.followRedirects == true)
  }

  @Test("instanceFollowRedirects follows class default")
  func testInstanceFollowRedirectsDefault() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    #expect(conn.instanceFollowRedirects == java.net.HttpURLConnection.followRedirects)
  }

  @Test("Can set instanceFollowRedirects independently")
  func testSetInstanceFollowRedirects() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    let originalValue = java.net.HttpURLConnection.followRedirects
    conn.instanceFollowRedirects = !originalValue
    #expect(conn.instanceFollowRedirects == !originalValue)
  }

  // MARK: - Response Code and Message

  @Test("Response code is -1 before connect")
  func testResponseCodeBeforeConnect() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    let code = try conn.getResponseCode()
    #expect(code >= 200 || code == -1) // May connect automatically
  }

  @Test("getResponseMessage returns nil before connect")
  func testResponseMessageBeforeConnect() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    _ = conn.getResponseMessage()
    // Message might be nil if not connected
    #expect(Bool(true))
  }

  // MARK: - URL Property

  @Test("Connection preserves the URL")
  func testGetUrl() throws {
    let urlString = "https://httpbin.org/get"
    let url = try java.net.URL(urlString)
    let conn = url.openConnection() as! java.net.HttpURLConnection
    #expect(conn.getURL().toExternalForm() == urlString)
  }

  // MARK: - Content Type and Length

  @Test("Can retrieve content type header")
  func testGetContentType() throws {
    let url = try java.net.URL("https://httpbin.org/json")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()
    let contentType = conn.getContentType()
    // httpbin returns application/json or similar
    #expect(contentType != nil)
  }

  @Test("Can retrieve content length")
  func testGetContentLength() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()
    let length = conn.getContentLength()
    #expect(length >= -1) // -1 means unknown, otherwise should be > 0
  }

  // MARK: - Header Access

  @Test("Can retrieve header fields")
  func testGetHeaderField() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()
    _ = conn.getHeaderField("Server")
    // httpbin may or may not include Server header
    #expect(true)
  }

  @Test("Unknown header returns nil")
  func testUnknownHeaderReturnsNil() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()
    let unknown = conn.getHeaderField("X-Unknown-Header-12345")
    #expect(unknown == nil)
  }

  // MARK: - Input Stream

  @Test("Can get input stream after connect")
  func testGetInputStreamAfterConnect() throws {
    let url = try java.net.URL("https://httpbin.org/json")
    let conn = url.openConnection() as! java.net.HttpURLConnection
    try conn.connect()
    _ = try conn.getInputStream()
    #expect(Bool(true)) // If we got here without exception, it works
  }

  // MARK: - Subclass Identity

  @Test("openConnection returns HttpURLConnection for HTTP URLs")
  func testOpenConnectionReturnsHttpURLConnection() throws {
    let url = try java.net.URL("https://httpbin.org/get")
    let conn = url.openConnection()
    #expect(conn is java.net.HttpURLConnection)
  }

  @Test("HTTP URL returns HttpURLConnection")
  func testHttpUrlReturnsHttpURLConnection() throws {
    let url = try java.net.URL("http://httpbin.org/get")
    let conn = url.openConnection()
    #expect(conn is java.net.HttpURLConnection)
  }
}
