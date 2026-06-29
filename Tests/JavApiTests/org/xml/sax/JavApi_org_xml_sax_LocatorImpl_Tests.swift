/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_org_xml_sax_LocatorImpl_Tests {

  // MARK: - Default values

  @Test("default init sets all values to UNKNOWN_LINE_OR_COLUMN / nil")
  func testDefaultInit() {
    let loc = org.xml.sax.LocatorImpl()
    #expect(loc.getLineNumber()   == org.xml.sax.LocatorImpl.UNKNOWN_LINE_OR_COLUMN)
    #expect(loc.getColumnNumber() == org.xml.sax.LocatorImpl.UNKNOWN_LINE_OR_COLUMN)
    #expect(loc.getPublicId()  == nil)
    #expect(loc.getSystemId()  == nil)
  }

  // MARK: - Copy constructor

  @Test("copy constructor transfers all fields")
  func testCopyConstructor() {
    let src = org.xml.sax.LocatorImpl()
    src.setLineNumber(42)
    src.setColumnNumber(7)
    src.setPublicId("-//W3C//DTD HTML 4.01//EN")
    src.setSystemId("http://example.com/doc.xml")

    let copy = org.xml.sax.LocatorImpl(src)
    #expect(copy.getLineNumber()   == 42)
    #expect(copy.getColumnNumber() == 7)
    #expect(copy.getPublicId()     == "-//W3C//DTD HTML 4.01//EN")
    #expect(copy.getSystemId()     == "http://example.com/doc.xml")
  }

  // MARK: - setLineNumber

  @Test("setLineNumber stores valid values")
  func testSetLineNumberValid() {
    let loc = org.xml.sax.LocatorImpl()
    loc.setLineNumber(1)
    #expect(loc.getLineNumber() == 1)
    loc.setLineNumber(999)
    #expect(loc.getLineNumber() == 999)
  }

  @Test("setLineNumber with 0 stores UNKNOWN")
  func testSetLineNumberZero() {
    let loc = org.xml.sax.LocatorImpl()
    loc.setLineNumber(10)   // set a known value first
    loc.setLineNumber(0)
    #expect(loc.getLineNumber() == org.xml.sax.LocatorImpl.UNKNOWN_LINE_OR_COLUMN)
  }

  @Test("setLineNumber with negative value stores UNKNOWN")
  func testSetLineNumberNegative() {
    let loc = org.xml.sax.LocatorImpl()
    loc.setLineNumber(5)
    loc.setLineNumber(-1)
    #expect(loc.getLineNumber() == org.xml.sax.LocatorImpl.UNKNOWN_LINE_OR_COLUMN)
  }

  @Test("setLineNumber with 0 does not overwrite with 0 after UNKNOWN assignment")
  func testSetLineNumberZeroDoesNotBleedThrough() {
    // Regression: before the bug fix, the value was set to UNKNOWN and then
    // immediately overwritten with the original (invalid) value.
    let loc = org.xml.sax.LocatorImpl()
    loc.setLineNumber(0)
    #expect(loc.getLineNumber() == org.xml.sax.LocatorImpl.UNKNOWN_LINE_OR_COLUMN)
    #expect(loc.getLineNumber() != 0)
  }

  // MARK: - setColumnNumber

  @Test("setColumnNumber stores valid values")
  func testSetColumnNumberValid() {
    let loc = org.xml.sax.LocatorImpl()
    loc.setColumnNumber(1)
    #expect(loc.getColumnNumber() == 1)
    loc.setColumnNumber(80)
    #expect(loc.getColumnNumber() == 80)
  }

  @Test("setColumnNumber with 0 stores UNKNOWN")
  func testSetColumnNumberZero() {
    let loc = org.xml.sax.LocatorImpl()
    loc.setColumnNumber(10)
    loc.setColumnNumber(0)
    #expect(loc.getColumnNumber() == org.xml.sax.LocatorImpl.UNKNOWN_LINE_OR_COLUMN)
  }

  @Test("setColumnNumber with negative value stores UNKNOWN")
  func testSetColumnNumberNegative() {
    let loc = org.xml.sax.LocatorImpl()
    loc.setColumnNumber(5)
    loc.setColumnNumber(-3)
    #expect(loc.getColumnNumber() == org.xml.sax.LocatorImpl.UNKNOWN_LINE_OR_COLUMN)
  }

  @Test("setColumnNumber checks columnNumber, not lineNumber")
  func testSetColumnNumberChecksOwnField() {
    // Regression: before the bug fix, setColumnNumber checked lineNumber instead
    // of columnNumber, so a valid column could be silently reset to UNKNOWN
    // when the line number happened to be 0 or negative.
    let loc = org.xml.sax.LocatorImpl()
    loc.setLineNumber(0)   // line is UNKNOWN — must NOT affect column
    loc.setColumnNumber(5)
    #expect(loc.getColumnNumber() == 5)
  }

  // MARK: - publicId / systemId round-trip

  @Test("setPublicId / getPublicId round-trip")
  func testPublicId() {
    let loc = org.xml.sax.LocatorImpl()
    loc.setPublicId("pub")
    #expect(loc.getPublicId() == "pub")
    loc.setPublicId(nil)
    #expect(loc.getPublicId() == nil)
  }

  @Test("setSystemId / getSystemId round-trip")
  func testSystemId() {
    let loc = org.xml.sax.LocatorImpl()
    loc.setSystemId("file:///doc.xml")
    #expect(loc.getSystemId() == "file:///doc.xml")
    loc.setSystemId(nil)
    #expect(loc.getSystemId() == nil)
  }

  // MARK: - UNKNOWN constant

  @Test("UNKNOWN_LINE_OR_COLUMN constant is -1")
  func testUnknownConstant() {
    #expect(org.xml.sax.LocatorImpl.UNKNOWN_LINE_OR_COLUMN == -1)
  }
}
