/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_org_xml_sax_AttributesImpl_Tests {

  // MARK: - empty list

  @Test("empty AttributesImpl has length 0")
  func testEmptyLength() {
    let atts = org.xml.sax.helper.AttributesImpl()
    #expect(atts.getLength() == 0)
  }

  @Test("empty list returns nil for index access")
  func testEmptyIndexAccess() {
    let atts = org.xml.sax.helper.AttributesImpl()
    #expect(atts.getURI(0)       == nil)
    #expect(atts.getLocalName(0) == nil)
    #expect(atts.getQName(0)     == nil)
    #expect(atts.getType(0)      == nil)
    #expect(atts.getValue(0)     == nil)
  }

  @Test("empty list returns -1 for index lookup")
  func testEmptyLookup() {
    let atts = org.xml.sax.helper.AttributesImpl()
    #expect(atts.getIndex("", "href") == -1)
    #expect(atts.getIndex("href")     == -1)
  }

  // MARK: - addAttribute / getLength

  @Test("addAttribute increases length")
  func testAddLength() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "href", "href", "CDATA", "https://example.com")
    #expect(atts.getLength() == 1)
    atts.addAttribute("", "id", "id", "ID", "main")
    #expect(atts.getLength() == 2)
  }

  // MARK: - Access by index

  @Test("getURI / getLocalName / getQName by index")
  func testIndexAccess() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("http://example.com/ns", "href", "ex:href", "CDATA", "https://example.com")
    #expect(atts.getURI(0)       == "http://example.com/ns")
    #expect(atts.getLocalName(0) == "href")
    #expect(atts.getQName(0)     == "ex:href")
    #expect(atts.getType(0)      == "CDATA")
    #expect(atts.getValue(0)     == "https://example.com")
    #expect(atts.getURI(1)       == nil)
  }

  // MARK: - Lookup by namespace

  @Test("getIndex by URI + localName")
  func testGetIndexByNamespace() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("http://ns.example", "id", "ex:id", "ID", "42")
    #expect(atts.getIndex("http://ns.example", "id") == 0)
    #expect(atts.getIndex("http://ns.example", "href") == -1)
    #expect(atts.getIndex("http://other", "id") == -1)
  }

  @Test("getValue by URI + localName")
  func testGetValueByNamespace() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("http://ns.example", "lang", "xml:lang", "CDATA", "en")
    #expect(atts.getValue("http://ns.example", "lang") == "en")
    #expect(atts.getValue("http://ns.example", "missing") == nil)
  }

  // MARK: - Lookup by qName

  @Test("getIndex by qName")
  func testGetIndexByQName() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "href", "href", "CDATA", "https://example.com")
    atts.addAttribute("", "rel", "rel", "CDATA", "stylesheet")
    #expect(atts.getIndex("href") == 0)
    #expect(atts.getIndex("rel")  == 1)
    #expect(atts.getIndex("missing") == -1)
  }

  @Test("getType and getValue by qName")
  func testGetTypeValueByQName() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "id", "id", "ID", "main")
    #expect(atts.getType("id")    == "ID")
    #expect(atts.getValue("id")   == "main")
    #expect(atts.getType("nope")  == nil)
    #expect(atts.getValue("nope") == nil)
  }

  // MARK: - Mutation

  @Test("setAttribute replaces attribute at index")
  func testSetAttribute() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "href", "href", "CDATA", "old")
    atts.setAttribute(0, "", "href", "href", "CDATA", "new")
    #expect(atts.getValue("href") == "new")
    atts.setAttribute(99, "", "x", "x", "CDATA", "y") // out of bounds — no crash
  }

  @Test("removeAttribute removes by index")
  func testRemoveAttribute() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "a", "a", "CDATA", "1")
    atts.addAttribute("", "b", "b", "CDATA", "2")
    atts.removeAttribute(0)
    #expect(atts.getLength() == 1)
    #expect(atts.getQName(0) == "b")
    atts.removeAttribute(99) // out of bounds — no crash
  }

  @Test("setURI / setLocalName / setQName / setType / setValue")
  func testFieldSetters() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "x", "x", "CDATA", "old")
    atts.setURI(0, "http://ns")
    atts.setLocalName(0, "y")
    atts.setQName(0, "ns:y")
    atts.setType(0, "ID")
    atts.setValue(0, "new")
    #expect(atts.getURI(0)       == "http://ns")
    #expect(atts.getLocalName(0) == "y")
    #expect(atts.getQName(0)     == "ns:y")
    #expect(atts.getType(0)      == "ID")
    #expect(atts.getValue(0)     == "new")
  }

  @Test("clear removes all attributes")
  func testClear() {
    let atts = org.xml.sax.helper.AttributesImpl()
    atts.addAttribute("", "a", "a", "CDATA", "1")
    atts.addAttribute("", "b", "b", "CDATA", "2")
    atts.clear()
    #expect(atts.getLength() == 0)
  }

  // MARK: - Copy constructor

  @Test("copy constructor duplicates all attributes")
  func testCopyConstructor() {
    let original = org.xml.sax.helper.AttributesImpl()
    original.addAttribute("http://ns", "id", "ns:id", "ID", "42")
    original.addAttribute("", "href", "href", "CDATA", "https://example.com")

    let copy = org.xml.sax.helper.AttributesImpl(original)
    #expect(copy.getLength() == 2)
    #expect(copy.getValue("ns:id") == "42")
    #expect(copy.getValue("href")  == "https://example.com")
  }

  @Test("copy is independent from original")
  func testCopyIndependent() {
    let original = org.xml.sax.helper.AttributesImpl()
    original.addAttribute("", "x", "x", "CDATA", "1")

    let copy = org.xml.sax.helper.AttributesImpl(original)
    original.clear()

    #expect(copy.getLength()    == 1)
    #expect(copy.getValue("x") == "1")
  }
}
