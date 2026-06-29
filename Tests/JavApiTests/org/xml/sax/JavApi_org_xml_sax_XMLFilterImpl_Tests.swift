/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

#if canImport(Foundation) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))

struct JavApi_org_xml_sax_XMLFilterImpl_Tests {

  // MARK: - Helpers

  /// Records all SAX 2.0 content events.
  private class RecordingHandler : org.xml.sax.helper.DefaultHandler {
    var startDocumentCalled = false
    var endDocumentCalled   = false
    var startElements: [String] = []   // qNames
    var endElements:   [String] = []
    var characters:    String   = ""
    var prefixMappings: [(prefix: String, uri: String)] = []

    override func startDocument() throws(org.xml.sax.SAXException) { startDocumentCalled = true }
    override func endDocument()   throws(org.xml.sax.SAXException) { endDocumentCalled   = true }
    override func startPrefixMapping(_ prefix: String, _ uri: String) throws(org.xml.sax.SAXException) {
      prefixMappings.append((prefix, uri))
    }
    override func startElement(_ uri: String, _ localName: String, _ qName: String,
                                _ attributes: any org.xml.sax.Attributes) throws(org.xml.sax.SAXException) {
      startElements.append(qName)
    }
    override func endElement(_ uri: String, _ localName: String, _ qName: String) throws(org.xml.sax.SAXException) {
      endElements.append(qName)
    }
    override func characters(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {
      characters += String(ch[start ..< start + length])
    }
  }

  /// A filter that uppercases all element qNames.
  private class UpperCaseElementFilter : org.xml.sax.helper.XMLFilterImpl {
    override func startElement(_ uri: String, _ localName: String, _ qName: String,
                                _ attributes: any org.xml.sax.Attributes) throws(org.xml.sax.SAXException) {
      try super.startElement(uri, localName.uppercased(), qName.uppercased(), attributes)
    }
    override func endElement(_ uri: String, _ localName: String, _ qName: String) throws(org.xml.sax.SAXException) {
      try super.endElement(uri, localName.uppercased(), qName.uppercased())
    }
  }

  /// A filter that prepends ">" to every character chunk.
  private class PrefixCharactersFilter : org.xml.sax.helper.XMLFilterImpl {
    override func characters(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {
      let prefix: [Character] = Array("> ")
      let body = Array(ch[start ..< start + length])
      try super.characters(prefix + body, 0, prefix.count + body.count)
    }
  }

  private func makeReader() -> JavApiXMLReader { JavApiXMLReader() }

  // MARK: - Pass-through

  @Test("XMLFilterImpl without overrides passes all events through")
  func testPassThrough() throws {
    let recorder = RecordingHandler()
    let filter   = org.xml.sax.helper.XMLFilterImpl(parent: makeReader())
    filter.setContentHandler(recorder)

    try filter.parse(org.xml.sax.InputSource(java.io.StringReader("<root><child/></root>")))

    #expect(recorder.startDocumentCalled)
    #expect(recorder.endDocumentCalled)
    #expect(recorder.startElements == ["root", "child"])
    #expect(recorder.endElements   == ["child", "root"])
  }

  @Test("XMLFilterImpl passes character data through")
  func testPassThroughCharacters() throws {
    let recorder = RecordingHandler()
    let filter   = org.xml.sax.helper.XMLFilterImpl(parent: makeReader())
    filter.setContentHandler(recorder)

    try filter.parse(org.xml.sax.InputSource(java.io.StringReader("<note>Hello</note>")))
    #expect(recorder.characters == "Hello")
  }

  // MARK: - Selective override

  @Test("UpperCaseElementFilter transforms element names")
  func testUpperCaseFilter() throws {
    let recorder = RecordingHandler()
    let filter   = UpperCaseElementFilter(parent: makeReader())
    filter.setContentHandler(recorder)

    try filter.parse(org.xml.sax.InputSource(java.io.StringReader("<root><child/></root>")))

    #expect(recorder.startElements == ["ROOT", "CHILD"])
    #expect(recorder.endElements   == ["CHILD", "ROOT"])
  }

  @Test("PrefixCharactersFilter prepends to character data")
  func testPrefixCharactersFilter() throws {
    let recorder = RecordingHandler()
    let filter   = PrefixCharactersFilter(parent: makeReader())
    filter.setContentHandler(recorder)

    try filter.parse(org.xml.sax.InputSource(java.io.StringReader("<p>Hello</p>")))
    #expect(recorder.characters.hasPrefix("> "))
    #expect(recorder.characters.hasSuffix("Hello"))
  }

  // MARK: - Two-filter pipeline

  @Test("two filters can be chained in a pipeline")
  func testFilterPipeline() throws {
    let recorder  = RecordingHandler()
    let reader    = makeReader()
    let filter1   = UpperCaseElementFilter(parent: reader)
    let filter2   = PrefixCharactersFilter(parent: filter1)
    filter2.setContentHandler(recorder)

    try filter2.parse(org.xml.sax.InputSource(java.io.StringReader("<root>text</root>")))

    // filter1 uppercases element names, filter2 prefixes character data
    #expect(recorder.startElements == ["ROOT"])
    #expect(recorder.endElements   == ["ROOT"])
    #expect(recorder.characters.contains("text"))
    #expect(recorder.characters.hasPrefix("> "))
  }

  // MARK: - Error propagation

  @Test("XMLFilterImpl throws on invalid XML")
  func testErrorPropagation() {
    let filter = org.xml.sax.helper.XMLFilterImpl(parent: makeReader())
    #expect(throws: (any Error).self) {
      try filter.parse(org.xml.sax.InputSource(java.io.StringReader("<unclosed>")))
    }
  }

  @Test("XMLFilterImpl without parent throws SAXException")
  func testNoParentThrows() {
    let filter = org.xml.sax.helper.XMLFilterImpl()
    #expect(throws: (any Error).self) {
      try filter.parse(org.xml.sax.InputSource(java.io.StringReader("<root/>")))
    }
  }

  // MARK: - Handler wiring

  @Test("setContentHandler on filter is retrievable via getContentHandler")
  func testHandlerWiring() {
    let recorder = RecordingHandler()
    let filter   = org.xml.sax.helper.XMLFilterImpl(parent: makeReader())
    filter.setContentHandler(recorder)
    #expect(filter.getContentHandler() != nil)
  }

  @Test("setParent / getParent round-trip")
  func testParentRoundTrip() {
    let reader = makeReader()
    let filter = org.xml.sax.helper.XMLFilterImpl()
    filter.setParent(reader)
    #expect(filter.getParent() != nil)
  }
}

#endif // canImport(Foundation) && Apple platforms
