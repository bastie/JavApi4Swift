/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_org_xml_sax_AttributeListImpl_Tests {

  // MARK: - empty list

  @Test("empty AttributeListImpl has length 0")
  func testEmptyLength() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    #expect(atts.getLength() == 0)
  }

  @Test("empty list returns nil for index access")
  func testEmptyIndexAccess() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    #expect(atts.getName(0) == nil)
    #expect(atts.getType(0) == nil)
    #expect(atts.getValue(0) == nil)
  }

  @Test("empty list returns nil for name access")
  func testEmptyNameAccess() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    #expect(atts.getType("missing") == nil)
    #expect(atts.getValue("missing") == nil)
  }

  // MARK: - addAttribute / getLength

  @Test("addAttribute increases length")
  func testAddLength() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("href", "CDATA", "https://example.com")
    #expect(atts.getLength() == 1)
    atts.addAttribute("id", "ID", "main")
    #expect(atts.getLength() == 2)
  }

  // MARK: - getName / getType / getValue by index

  @Test("getName returns correct name by index")
  func testGetNameByIndex() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("href", "CDATA", "https://example.com")
    atts.addAttribute("id", "ID", "main")
    #expect(atts.getName(0) == "href")
    #expect(atts.getName(1) == "id")
    #expect(atts.getName(2) == nil)
    #expect(atts.getName(-1) == nil)
  }

  @Test("getType returns correct type by index")
  func testGetTypeByIndex() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("href", "CDATA", "https://example.com")
    atts.addAttribute("id", "ID", "main")
    #expect(atts.getType(0) == "CDATA")
    #expect(atts.getType(1) == "ID")
    #expect(atts.getType(2) == nil)
  }

  @Test("getValue returns correct value by index")
  func testGetValueByIndex() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("href", "CDATA", "https://example.com")
    atts.addAttribute("id", "ID", "main")
    #expect(atts.getValue(0) == "https://example.com")
    #expect(atts.getValue(1) == "main")
    #expect(atts.getValue(2) == nil)
  }

  // MARK: - getType / getValue by name

  @Test("getType returns correct type by name")
  func testGetTypeByName() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("href", "CDATA", "https://example.com")
    atts.addAttribute("id", "ID", "main")
    #expect(atts.getType("href") == "CDATA")
    #expect(atts.getType("id") == "ID")
    #expect(atts.getType("missing") == nil)
  }

  @Test("getValue returns correct value by name")
  func testGetValueByName() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("href", "CDATA", "https://example.com")
    atts.addAttribute("id", "ID", "main")
    #expect(atts.getValue("href") == "https://example.com")
    #expect(atts.getValue("id") == "main")
    #expect(atts.getValue("missing") == nil)
  }

  // MARK: - removeAttribute

  @Test("removeAttribute removes first occurrence by name")
  func testRemoveAttribute() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("href", "CDATA", "https://example.com")
    atts.addAttribute("id", "ID", "main")
    atts.removeAttribute("href")
    #expect(atts.getLength() == 1)
    #expect(atts.getName(0) == "id")
    #expect(atts.getValue("href") == nil)
  }

  @Test("removeAttribute on missing name is a no-op")
  func testRemoveMissing() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("id", "ID", "main")
    atts.removeAttribute("nothere")
    #expect(atts.getLength() == 1)
  }

  // MARK: - clear

  @Test("clear removes all attributes")
  func testClear() {
    let atts = org.xml.sax.helper.AttributeListImpl()
    atts.addAttribute("a", "CDATA", "1")
    atts.addAttribute("b", "CDATA", "2")
    atts.clear()
    #expect(atts.getLength() == 0)
    #expect(atts.getName(0) == nil)
  }

  // MARK: - copy constructor

  @Test("copy constructor duplicates all attributes")
  func testCopyConstructor() {
    let original = org.xml.sax.helper.AttributeListImpl()
    original.addAttribute("href", "CDATA", "https://example.com")
    original.addAttribute("id", "ID", "main")

    let copy = org.xml.sax.helper.AttributeListImpl(original)
    #expect(copy.getLength() == 2)
    #expect(copy.getValue("href") == "https://example.com")
    #expect(copy.getValue("id") == "main")
  }

  @Test("copy is independent from original")
  func testCopyIndependent() {
    let original = org.xml.sax.helper.AttributeListImpl()
    original.addAttribute("href", "CDATA", "https://example.com")

    let copy = org.xml.sax.helper.AttributeListImpl(original)
    original.clear()

    #expect(copy.getLength() == 1)
    #expect(copy.getValue("href") == "https://example.com")
  }
}
