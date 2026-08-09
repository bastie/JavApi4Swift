/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import XCTest
@testable import JavApi

// MARK: - java.util.Properties Tests

final class JavApi_util_Properties_Tests: XCTestCase {

  // MARK: - getProperty / setProperty

  func testSetAndGetProperty() {
    let props = java.util.Properties()
    props.setProperty("host", "localhost")
    XCTAssertEqual(props.getProperty("host"), "localhost")
  }

  func testGetPropertyMissing() {
    let props = java.util.Properties()
    XCTAssertNil(props.getProperty("missing"))
  }

  func testGetPropertyWithDefault() {
    let props = java.util.Properties()
    XCTAssertEqual(props.getProperty("timeout", "30"), "30")
    props.setProperty("timeout", "60")
    XCTAssertEqual(props.getProperty("timeout", "30"), "60")
  }

  func testSetPropertyReturnsOldValue() {
    let props = java.util.Properties()
    XCTAssertNil(props.setProperty("key", "v1"))
    XCTAssertEqual(props.setProperty("key", "v2"), "v1")
  }

  // MARK: - defaults chain

  func testDefaultsChainGetProperty() {
    let base = java.util.Properties()
    base.setProperty("color", "blue")
    let child = java.util.Properties(base)
    XCTAssertEqual(child.getProperty("color"), "blue")
    // child overrides
    child.setProperty("color", "red")
    XCTAssertEqual(child.getProperty("color"), "red")
    XCTAssertEqual(base.getProperty("color"), "blue")
  }

  // MARK: - propertyNames

  func testPropertyNamesIncludesDefaults() {
    let base = java.util.Properties()
    base.setProperty("a", "1")
    let child = java.util.Properties(base)
    child.setProperty("b", "2")
    var names = Swift.Set<String>()
    var en = child.propertyNames()
    while en.hasMoreElements() {
      if let n = try? en.nextElement() { names.insert(n) }
    }
    XCTAssertTrue(names.contains("a"))
    XCTAssertTrue(names.contains("b"))
  }

  // MARK: - stringPropertyNames

  func testStringPropertyNamesEmpty() {
    let props = java.util.Properties()
    XCTAssertTrue(props.stringPropertyNames().isEmpty)
  }

  func testStringPropertyNamesIncludesDefaults() {
    let base = java.util.Properties()
    base.setProperty("x", "1")
    let child = java.util.Properties(base)
    child.setProperty("y", "2")
    let names = child.stringPropertyNames()
    XCTAssertTrue(names.contains("x"))
    XCTAssertTrue(names.contains("y"))
    XCTAssertEqual(names.count, 2)
  }

  func testStringPropertyNamesDeduplicatesOverriddenKeys() {
    let base = java.util.Properties()
    base.setProperty("host", "base-host")
    let child = java.util.Properties(base)
    child.setProperty("host", "child-host")
    // "host" appears in both but should be in the set only once
    XCTAssertEqual(child.stringPropertyNames().count, 1)
  }

  // MARK: - load / store (.properties format)

  func testLoadFromPropertiesFormat() throws {
    let text = """
      # comment
      host=localhost
      port=8080
      """
    let bytes = [UInt8](text.utf8)
    let stream = java.io.ByteArrayInputStream(bytes)
    let props = java.util.Properties()
    try props.load(stream)
    XCTAssertEqual(props.getProperty("host"), "localhost")
    XCTAssertEqual(props.getProperty("port"), "8080")
  }

  func testStoreRoundTrip() throws {
    let props = java.util.Properties()
    props.setProperty("k1", "v1")
    props.setProperty("k2", "v2")

    let out = java.io.ByteArrayOutputStream()
    try props.store(out, "test comment")
    let stored = out.toString()

    XCTAssertTrue(stored.contains("k1=v1"))
    XCTAssertTrue(stored.contains("k2=v2"))
    XCTAssertTrue(stored.contains("# test comment"))
  }

  // MARK: - list(PrintStream)

  func testListPrintStream() {
    let props = java.util.Properties()
    props.setProperty("alpha", "1")
    let out = java.io.ByteArrayOutputStream()
    let ps = java.io.PrintStream(out)
    props.list(ps)
    let output = out.toString()
    XCTAssertTrue(output.contains("-- listing properties --"))
    XCTAssertTrue(output.contains("alpha=1"))
  }

  // MARK: - list(PrintWriter)

  func testListPrintWriter() {
    let props = java.util.Properties()
    props.setProperty("beta", "2")
    let out = java.io.ByteArrayOutputStream()
    let pw = java.io.PrintWriter(out)
    props.list(pw)
    let output = out.toString()
    XCTAssertTrue(output.contains("-- listing properties --"))
    XCTAssertTrue(output.contains("beta=2"))
  }

  func testListPrintWriterIncludesDefaults() {
    let base = java.util.Properties()
    base.setProperty("from-base", "yes")
    let child = java.util.Properties(base)
    child.setProperty("from-child", "yes")

    let out = java.io.ByteArrayOutputStream()
    let pw = java.io.PrintWriter(out)
    child.list(pw)
    let output = out.toString()
    XCTAssertTrue(output.contains("from-child=yes"))
    XCTAssertTrue(output.contains("from-base=yes"))
  }

  // MARK: - XML: storeToXML / loadFromXML

  func testStoreToXMLContainsEntries() throws {
    let props = java.util.Properties()
    props.setProperty("city", "Berlin")
    props.setProperty("lang", "de")

    let out = java.io.ByteArrayOutputStream()
    try props.storeToXML(out, nil)
    let xml = out.toString()

    XCTAssertTrue(xml.contains("<?xml version=\"1.0\""))
    XCTAssertTrue(xml.contains("<entry key=\"city\">Berlin</entry>"))
    XCTAssertTrue(xml.contains("<entry key=\"lang\">de</entry>"))
  }

  func testStoreToXMLWithComment() throws {
    let props = java.util.Properties()
    props.setProperty("n", "1")

    let out = java.io.ByteArrayOutputStream()
    try props.storeToXML(out, "my comment")
    let xml = out.toString()

    XCTAssertTrue(xml.contains("<comment>my comment</comment>"))
  }

  func testLoadFromXMLRoundTrip() throws {
    let props = java.util.Properties()
    props.setProperty("key1", "value1")
    props.setProperty("key2", "value2")

    // Store to XML
    let out = java.io.ByteArrayOutputStream()
    try props.storeToXML(out, "round-trip test")

    // Load from XML
    let loaded = java.util.Properties()
    let bytes = out.toByteArray()
    let inStream = java.io.ByteArrayInputStream(bytes)
    try loaded.loadFromXML(inStream)

    XCTAssertEqual(loaded.getProperty("key1"), "value1")
    XCTAssertEqual(loaded.getProperty("key2"), "value2")
  }

  func testLoadFromXMLSpecialCharacters() throws {
    let xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
      <properties>
      <entry key="greeting">Hello &amp; World</entry>
      <entry key="tag">&lt;br&gt;</entry>
      </properties>
      """
    let bytes = [UInt8](xml.utf8)
    let inStream = java.io.ByteArrayInputStream(bytes)
    let props = java.util.Properties()
    try props.loadFromXML(inStream)

    XCTAssertEqual(props.getProperty("greeting"), "Hello & World")
    XCTAssertEqual(props.getProperty("tag"), "<br>")
  }

  func testStoreToXMLEscapesSpecialChars() throws {
    let props = java.util.Properties()
    props.setProperty("html", "<b>bold</b>")
    props.setProperty("amp", "a & b")

    let out = java.io.ByteArrayOutputStream()
    try props.storeToXML(out, nil)
    let xml = out.toString()

    XCTAssertTrue(xml.contains("&lt;b&gt;bold&lt;/b&gt;"))
    XCTAssertTrue(xml.contains("a &amp; b"))
  }

  func testStoreToXMLWithEncoding() throws {
    let props = java.util.Properties()
    props.setProperty("enc", "test")

    let out = java.io.ByteArrayOutputStream()
    try props.storeToXML(out, nil, "ISO-8859-1")
    let xml = out.toString()

    XCTAssertTrue(xml.contains("encoding=\"ISO-8859-1\""))
  }

  // MARK: - deprecated save

  func testSaveDeprecated() {
    let props = java.util.Properties()
    props.setProperty("dep", "val")
    let out = java.io.ByteArrayOutputStream()
    props.save(out, "deprecated comment")
    let output = out.toString()
    XCTAssertTrue(output.contains("dep=val"))
  }
}
