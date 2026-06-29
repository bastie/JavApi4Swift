/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_org_xml_sax_DefaultHandler2_Tests {

  // MARK: - Inherited DefaultHandler no-ops still work

  @Test("startDocument does not throw")
  func testStartDocument() throws {
    try org.xml.sax.helper.DefaultHandler2().startDocument()
  }

  @Test("endDocument does not throw")
  func testEndDocument() throws {
    try org.xml.sax.helper.DefaultHandler2().endDocument()
  }

  @Test("startElement does not throw")
  func testStartElement() throws {
    let atts = org.xml.sax.helper.AttributesImpl()
    try org.xml.sax.helper.DefaultHandler2().startElement("", "root", "root", atts)
  }

  @Test("fatalError does not throw by default (inherited from DefaultHandler)")
  func testFatalErrorNoThrow() throws {
    let exc = org.xml.sax.SAXParseException("fatal", org.xml.sax.LocatorImpl())
    try org.xml.sax.helper.DefaultHandler2().fatalError(exc)
  }

  // MARK: - LexicalHandler no-ops

  @Test("startDTD does not throw")
  func testStartDTD() throws {
    try org.xml.sax.helper.DefaultHandler2().startDTD("root", nil, "root.dtd")
  }

  @Test("endDTD does not throw")
  func testEndDTD() throws {
    try org.xml.sax.helper.DefaultHandler2().endDTD()
  }

  @Test("startEntity does not throw")
  func testStartEntity() throws {
    try org.xml.sax.helper.DefaultHandler2().startEntity("amp")
  }

  @Test("endEntity does not throw")
  func testEndEntity() throws {
    try org.xml.sax.helper.DefaultHandler2().endEntity("amp")
  }

  @Test("startCDATA does not throw")
  func testStartCDATA() throws {
    try org.xml.sax.helper.DefaultHandler2().startCDATA()
  }

  @Test("endCDATA does not throw")
  func testEndCDATA() throws {
    try org.xml.sax.helper.DefaultHandler2().endCDATA()
  }

  @Test("comment does not throw")
  func testComment() throws {
    let chars = Array(" a comment ")
    try org.xml.sax.helper.DefaultHandler2().comment(chars, 0, chars.count)
  }

  // MARK: - DeclHandler no-ops

  @Test("elementDecl does not throw")
  func testElementDecl() throws {
    try org.xml.sax.helper.DefaultHandler2().elementDecl("note", "(title,body)")
  }

  @Test("attributeDecl does not throw")
  func testAttributeDecl() throws {
    try org.xml.sax.helper.DefaultHandler2()
      .attributeDecl("note", "id", "ID", "#REQUIRED", nil)
  }

  @Test("internalEntityDecl does not throw")
  func testInternalEntityDecl() throws {
    try org.xml.sax.helper.DefaultHandler2().internalEntityDecl("copy", "©")
  }

  @Test("externalEntityDecl does not throw")
  func testExternalEntityDecl() throws {
    try org.xml.sax.helper.DefaultHandler2()
      .externalEntityDecl("chapter", nil, "chapter.xml")
  }

  // MARK: - Subclass overrides

  @Test("subclass can override comment to collect comments")
  func testSubclassComment() throws {
    class CommentCollector : org.xml.sax.helper.DefaultHandler2 {
      var comments: [String] = []
      override func comment(_ ch: [Character], _ start: Int,
                             _ length: Int) throws(org.xml.sax.SAXException) {
        comments.append(String(ch[start ..< start + length]))
      }
    }
    let c = CommentCollector()
    let text = Array(" hello ")
    try c.comment(text, 0, text.count)
    #expect(c.comments == [" hello "])
  }

  @Test("subclass can override startCDATA and endCDATA")
  func testSubclassCDATA() throws {
    class CDATATracker : org.xml.sax.helper.DefaultHandler2 {
      var inCDATA = false
      override func startCDATA() throws(org.xml.sax.SAXException) { inCDATA = true  }
      override func endCDATA()   throws(org.xml.sax.SAXException) { inCDATA = false }
    }
    let tracker = CDATATracker()
    try tracker.startCDATA()
    #expect(tracker.inCDATA == true)
    try tracker.endCDATA()
    #expect(tracker.inCDATA == false)
  }

  @Test("subclass can override elementDecl and attributeDecl")
  func testSubclassDeclHandler() throws {
    class DeclRecorder : org.xml.sax.helper.DefaultHandler2 {
      var elements:   [String] = []
      var attributes: [(elem: String, attr: String)] = []
      override func elementDecl(_ name: String, _ model: String) throws(org.xml.sax.SAXException) {
        elements.append(name)
      }
      override func attributeDecl(_ eName: String, _ aName: String, _ type: String,
                                   _ mode: String?, _ value: String?) throws(org.xml.sax.SAXException) {
        attributes.append((elem: eName, attr: aName))
      }
    }
    let r = DeclRecorder()
    try r.elementDecl("note", "EMPTY")
    try r.attributeDecl("note", "id", "ID", "#REQUIRED", nil)
    try r.attributeDecl("note", "lang", "CDATA", "#IMPLIED", nil)
    #expect(r.elements == ["note"])
    #expect(r.attributes.count == 2)
    #expect(r.attributes[0].attr == "id")
    #expect(r.attributes[1].attr == "lang")
  }

  @Test("DefaultHandler2 conforms to LexicalHandler and DeclHandler")
  func testProtocolConformance() {
    let h = org.xml.sax.helper.DefaultHandler2()
    #expect(h is any org.xml.sax.ext.LexicalHandler)
    #expect(h is any org.xml.sax.ext.DeclHandler)
  }

  @Test("subclass can override startDTD to record DTD name")
  func testSubclassDTD() throws {
    class DTDTracker : org.xml.sax.helper.DefaultHandler2 {
      var dtdName: String?
      override func startDTD(_ name: String, _ publicId: String?,
                              _ systemId: String?) throws(org.xml.sax.SAXException) {
        dtdName = name
      }
    }
    let t = DTDTracker()
    try t.startDTD("html", "-//W3C//DTD HTML 4.01//EN", "http://www.w3.org/TR/html4/strict.dtd")
    #expect(t.dtdName == "html")
  }
}
