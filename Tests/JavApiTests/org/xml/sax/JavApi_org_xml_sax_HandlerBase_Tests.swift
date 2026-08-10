/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_org_xml_sax_HandlerBase_Tests {

  // MARK: - EntityResolver

  @Test("resolveEntity always returns nil")
  @available(*, deprecated)
  func testResolveEntity() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    let result = try handler.resolveEntity(publicId: "-//W3C//DTD HTML 4.01//EN", systemId: "http://www.w3.org/TR/html4/strict.dtd")
    #expect(result == nil)
  }

  @Test("resolveEntity with nil IDs returns nil")
  @available(*, deprecated)
  func testResolveEntityNilIds() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    let result = try handler.resolveEntity(publicId: nil, systemId: nil)
    #expect(result == nil)
  }

  // MARK: - DTDHandler (no-ops, must not throw)

  @Test("notationDecl does not throw")
  @available(*, deprecated)
  func testNotationDecl() {
    let handler = org.xml.sax.helper.HandlerBase()
    handler.notationDecl(name: "myNotation", publicId: nil, systemId: "notation.dtd")
  }

  @Test("unparsedEntityDecl does not throw")
  @available(*, deprecated)
  func testUnparsedEntityDecl() {
    let handler = org.xml.sax.helper.HandlerBase()
    handler.unparsedEntityDecl(name: "logo", publicId: nil, systemId: "logo.gif", notationName: "gif")
  }

  // MARK: - DocumentHandler (no-ops, must not throw)

  @Test("startDocument does not throw")
  @available(*, deprecated)
  func testStartDocument() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    try handler.startDocument()
  }

  @Test("endDocument does not throw")
  @available(*, deprecated)
  func testEndDocument() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    try handler.endDocument()
  }

  @Test("startElement does not throw")
  @available(*, deprecated)
  func testStartElement() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("id", "ID", "main")
    try handler.startElement("div", atts)
  }

  @Test("endElement does not throw")
  @available(*, deprecated)
  func testEndElement() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    try handler.endElement("div")
  }

  @Test("characters does not throw")
  @available(*, deprecated)
  func testCharacters() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    let chars = Array("Hello")
    try handler.characters(chars, 0, chars.count)
  }

  @Test("ignorableWhitespace does not throw")
  @available(*, deprecated)
  func testIgnorableWhitespace() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    let chars = Array("   ")
    try handler.ignorableWhitespace(chars, 0, chars.count)
  }

  @Test("processingInstruction does not throw")
  @available(*, deprecated)
  func testProcessingInstruction() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    try handler.processingInstruction("xml-stylesheet", _data: "type=\"text/css\" href=\"style.css\"")
  }

  @Test("setDocumentLocator does not throw")
  @available(*, deprecated)
  func testSetDocumentLocator() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    let locator = org.xml.sax.LocatorImpl()
    try handler.setDocumentLocator(locator)
  }

  // MARK: - ErrorHandler

  @Test("warning does not throw")
  @available(*, deprecated)
  func testWarning() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    let locator = org.xml.sax.LocatorImpl()
    let exc = org.xml.sax.SAXParseException("minor issue", locator)
    try handler.warning(exc)
  }

  @Test("error does not throw")
  @available(*, deprecated)
  func testError() throws {
    let handler = org.xml.sax.helper.HandlerBase()
    let locator = org.xml.sax.LocatorImpl()
    let exc = org.xml.sax.SAXParseException("recoverable error", locator)
    try handler.error(exc)
  }

  @Test("fatalError re-throws the exception")
  @available(*, deprecated)
  func testFatalError() {
    let handler = org.xml.sax.helper.HandlerBase()
    let locator = org.xml.sax.LocatorImpl()
    let exc = org.xml.sax.SAXParseException("fatal", locator)
    #expect(throws: (any Error).self) {
      try handler.fatalError(exc)
    }
  }

  // MARK: - Subclass override

  @Test("subclass can override startElement")
  @available(*, deprecated)
  func testSubclassOverride() throws {
    class RecordingHandler : org.xml.sax.helper.HandlerBase {
      var recordedElements: [String] = []
      override func startElement(_ name: String, _ attributes: any org.xml.sax.AttributeList) throws(org.xml.sax.SAXException) {
        recordedElements.append(name)
      }
    }
    let handler = RecordingHandler()
    let atts = org.xml.sax.helper.AttributeListImpl()
    try handler.startElement("root", atts)
    try handler.startElement("child", atts)
    #expect(handler.recordedElements == ["root", "child"])
  }
}
