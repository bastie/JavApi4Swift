/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_org_xml_sax_DefaultHandler_Tests {

  // MARK: - EntityResolver

  @Test("resolveEntity always returns nil")
  func testResolveEntity() throws {
    let h = org.xml.sax.helper.DefaultHandler()
    let result = try h.resolveEntity(publicId: "-//W3C//DTD HTML 4.01//EN",
                                     systemId: "http://www.w3.org/TR/html4/strict.dtd")
    #expect(result == nil)
  }

  @Test("resolveEntity with nil IDs returns nil")
  func testResolveEntityNilIds() throws {
    let h = org.xml.sax.helper.DefaultHandler()
    #expect(try h.resolveEntity(publicId: nil, systemId: nil) == nil)
  }

  // MARK: - DTDHandler (no-ops)

  @Test("notationDecl does not throw")
  func testNotationDecl() {
    org.xml.sax.helper.DefaultHandler().notationDecl(name: "n", publicId: nil, systemId: "n.dtd")
  }

  @Test("unparsedEntityDecl does not throw")
  func testUnparsedEntityDecl() {
    org.xml.sax.helper.DefaultHandler()
      .unparsedEntityDecl(name: "logo", publicId: nil, systemId: "logo.gif", notationName: "gif")
  }

  // MARK: - ErrorHandler (no-ops)

  @Test("warning does not throw")
  func testWarning() throws {
    let exc = org.xml.sax.SAXParseException("w", org.xml.sax.LocatorImpl())
    try org.xml.sax.helper.DefaultHandler().warning(exc)
  }

  @Test("error does not throw")
  func testError() throws {
    let exc = org.xml.sax.SAXParseException("e", org.xml.sax.LocatorImpl())
    try org.xml.sax.helper.DefaultHandler().error(exc)
  }

  @Test("fatalError does not throw in DefaultHandler (unlike HandlerBase)")
  func testFatalError() throws {
    let exc = org.xml.sax.SAXParseException("f", org.xml.sax.LocatorImpl())
    try org.xml.sax.helper.DefaultHandler().fatalError(exc)
  }

  // MARK: - ContentHandler (no-ops)

  @Test("startDocument does not throw")
  func testStartDocument() throws {
    try org.xml.sax.helper.DefaultHandler().startDocument()
  }

  @Test("endDocument does not throw")
  func testEndDocument() throws {
    try org.xml.sax.helper.DefaultHandler().endDocument()
  }

  @Test("startPrefixMapping does not throw")
  func testStartPrefixMapping() throws {
    try org.xml.sax.helper.DefaultHandler().startPrefixMapping("ns", "http://example.com")
  }

  @Test("endPrefixMapping does not throw")
  func testEndPrefixMapping() throws {
    try org.xml.sax.helper.DefaultHandler().endPrefixMapping("ns")
  }

  @Test("startElement does not throw")
  func testStartElement() throws {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "id", "id", "ID", "main")
    try org.xml.sax.helper.DefaultHandler().startElement("", "div", "div", atts)
  }

  @Test("endElement does not throw")
  func testEndElement() throws {
    try org.xml.sax.helper.DefaultHandler().endElement("", "div", "div")
  }

  @Test("characters does not throw")
  func testCharacters() throws {
    let chars = Array("Hello")
    try org.xml.sax.helper.DefaultHandler().characters(chars, 0, length: chars.count)
  }

  @Test("ignorableWhitespace does not throw")
  func testIgnorableWhitespace() throws {
    let chars = Array("   ")
    try org.xml.sax.helper.DefaultHandler().ignorableWhitespace(chars, 0, chars.count)
  }

  @Test("processingInstruction does not throw")
  func testProcessingInstruction() throws {
    try org.xml.sax.helper.DefaultHandler()
      .processingInstruction("xml-stylesheet", _data: "type=\"text/css\"")
  }

  @Test("skippedEntity does not throw")
  func testSkippedEntity() throws {
    try org.xml.sax.helper.DefaultHandler().skippedEntity("amp")
  }

  @Test("setDocumentLocator does not throw")
  func testSetDocumentLocator() throws {
    try org.xml.sax.helper.DefaultHandler().setDocumentLocator(org.xml.sax.LocatorImpl())
  }

  // MARK: - Subclass override

  @Test("subclass can override startElement and receive Attributes")
  func testSubclassStartElement() throws {
    class Recorder : org.xml.sax.helper.DefaultHandler {
      var seen: [(qName: String, value: String)] = []
      override func startElement(_ uri: String, _ localName: String, _ qName: String,
                                  _ attributes: any org.xml.sax.Attributes) throws(org.xml.sax.SAXException) {
        let v = attributes.getValue(qName) ?? attributes.getValue(0) ?? ""
        seen.append((qName: qName, value: v))
      }
    }
    let r = Recorder()
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "root", "root", "CDATA", "x")
    try r.startElement("", "root", "root", atts)
    #expect(r.seen.count == 1)
    #expect(r.seen[0].qName == "root")
  }

  @Test("subclass can override fatalError to re-throw")
  func testSubclassFatalError() {
    class StrictHandler : org.xml.sax.helper.DefaultHandler {
      override func fatalError(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {
        throw exception
      }
    }
    let exc = org.xml.sax.SAXParseException("fatal", org.xml.sax.LocatorImpl())
    #expect(throws: (any Error).self) {
      try StrictHandler().fatalError(exc)
    }
  }
}
