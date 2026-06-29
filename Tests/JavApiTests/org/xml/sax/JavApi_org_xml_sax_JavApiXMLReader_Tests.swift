/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

#if canImport(Foundation) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))

// MARK: - Recording handler

private class RecordingHandler : org.xml.sax.helper.DefaultHandler {

  struct ElementEvent: Equatable {
    let uri:        String
    let localName:  String
    let qName:      String
    let attrQNames: [String]
    let attrValues: [String]
  }

  var startDocumentCalled = false
  var endDocumentCalled   = false
  var startElements: [ElementEvent] = []
  var endElements:   [(uri: String, localName: String, qName: String)] = []
  var characters: String = ""
  var processingInstructions: [(target: String, data: String)] = []
  var prefixMappings: [(prefix: String, uri: String)] = []

  override func startDocument() throws(org.xml.sax.SAXException) { startDocumentCalled = true }
  override func endDocument()   throws(org.xml.sax.SAXException) { endDocumentCalled   = true }

  override func startPrefixMapping(_ prefix: String, _ uri: String) throws(org.xml.sax.SAXException) {
    prefixMappings.append((prefix: prefix, uri: uri))
  }

  override func startElement(_ uri: String, _ localName: String, _ qName: String,
                              _ attributes: any org.xml.sax.Attributes) throws(org.xml.sax.SAXException) {
    var names:  [String] = []
    var values: [String] = []
    for i in 0 ..< attributes.getLength() {
      names.append(attributes.getQName(i) ?? "")
      values.append(attributes.getValue(i) ?? "")
    }
    startElements.append(ElementEvent(uri: uri, localName: localName, qName: qName,
                                       attrQNames: names, attrValues: values))
  }

  override func endElement(_ uri: String, _ localName: String, _ qName: String) throws(org.xml.sax.SAXException) {
    endElements.append((uri: uri, localName: localName, qName: qName))
  }

  override func characters(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {
    characters += String(ch[start ..< start + length])
  }

  override func processingInstruction(_ target: String, _data: String) throws(org.xml.sax.SAXException) {
    processingInstructions.append((target: target, data: _data))
  }
}

// MARK: - Basic tests

struct JavApi_org_xml_sax_JavApiXMLReader_Tests {

  private func makeParser() -> JavApiXMLReader { JavApiXMLReader() }

  @Test("parse minimal XML calls startDocument and endDocument")
  func testStartEndDocument() throws {
    let handler = RecordingHandler()
    let reader  = makeParser()
    reader.setContentHandler(handler)
    try reader.parse(org.xml.sax.InputSource(java.io.StringReader("<root/>")))
    #expect(handler.startDocumentCalled)
    #expect(handler.endDocumentCalled)
  }

  @Test("single self-closing element fires start and end")
  func testSingleElement() throws {
    let handler = RecordingHandler()
    let reader  = makeParser()
    reader.setContentHandler(handler)
    try reader.parse(org.xml.sax.InputSource(java.io.StringReader("<root/>")))
    #expect(handler.startElements.count == 1)
    #expect(handler.startElements[0].qName == "root")
    #expect(handler.endElements.count == 1)
    #expect(handler.endElements[0].qName == "root")
  }

  @Test("nested elements fire in correct order")
  func testNestedElements() throws {
    let handler = RecordingHandler()
    let reader  = makeParser()
    reader.setContentHandler(handler)
    try reader.parse(org.xml.sax.InputSource(java.io.StringReader("<root><child/></root>")))
    #expect(handler.startElements.map(\.qName) == ["root", "child"])
    #expect(handler.endElements.map(\.qName)   == ["child", "root"])
  }

  @Test("attributes are delivered via Attributes protocol")
  func testAttributes() throws {
    let handler = RecordingHandler()
    let reader  = makeParser()
    reader.setContentHandler(handler)
    try reader.parse(org.xml.sax.InputSource(java.io.StringReader(
      "<link href=\"https://example.com\" rel=\"stylesheet\"/>")))
    let evt = handler.startElements[0]
    let hrefIdx = evt.attrQNames.firstIndex(of: "href")
    let relIdx  = evt.attrQNames.firstIndex(of: "rel")
    #expect(hrefIdx != nil); #expect(relIdx != nil)
    if let i = hrefIdx { #expect(evt.attrValues[i] == "https://example.com") }
    if let i = relIdx  { #expect(evt.attrValues[i] == "stylesheet") }
  }

  @Test("text content is delivered via characters callback")
  func testCharacters() throws {
    let handler = RecordingHandler()
    let reader  = makeParser()
    reader.setContentHandler(handler)
    try reader.parse(org.xml.sax.InputSource(java.io.StringReader("<note>Hello World</note>")))
    #expect(handler.characters == "Hello World")
  }

  @Test("mixed content delivers all character segments")
  func testMixedContent() throws {
    let handler = RecordingHandler()
    let reader  = makeParser()
    reader.setContentHandler(handler)
    try reader.parse(org.xml.sax.InputSource(java.io.StringReader("<p>Hello <b>World</b>!</p>")))
    #expect(handler.characters.contains("Hello"))
    #expect(handler.characters.contains("World"))
    #expect(handler.characters.contains("!"))
  }

  @Test("processing instruction is delivered")
  func testProcessingInstruction() throws {
    let handler = RecordingHandler()
    let reader  = makeParser()
    reader.setContentHandler(handler)
    try reader.parse(org.xml.sax.InputSource(java.io.StringReader(
      "<?xml-stylesheet type=\"text/css\" href=\"s.css\"?><root/>")))
    #expect(handler.processingInstructions.contains(where: { $0.target == "xml-stylesheet" }))
  }

  @Test("invalid XML causes parse to throw")
  func testInvalidXML() {
    let reader = makeParser()
    #expect(throws: (any Error).self) {
      try reader.parse(org.xml.sax.InputSource(java.io.StringReader("<unclosed>")))
    }
  }

  // MARK: - Features

  @Test("getFeature returns default values")
  func testDefaultFeatures() throws {
    let reader = makeParser()
    #expect(try reader.getFeature("http://xml.org/sax/features/namespaces") == true)
    #expect(try reader.getFeature("http://xml.org/sax/features/namespace-prefixes") == false)
  }

  @Test("setFeature changes the feature value")
  func testSetFeature() throws {
    let reader = makeParser()
    try reader.setFeature("http://xml.org/sax/features/namespace-prefixes", true)
    #expect(try reader.getFeature("http://xml.org/sax/features/namespace-prefixes") == true)
  }

  @Test("unknown feature throws SAXNotRecognizedException")
  func testUnknownFeature() {
    let reader = makeParser()
    #expect(throws: (any Error).self) {
      _ = try reader.getFeature("http://xml.org/sax/features/unknown")
    }
  }

  // MARK: - XMLReaderFactory registration

  @Test("JavApiXMLReader is registered as default in XMLReaderFactory")
  @MainActor func testXMLReaderFactoryDefault() throws {
    let reader = try org.xml.sax.helper.XMLReaderFactory.createXMLReader()
    #expect(reader is JavApiXMLReader)
  }

  @Test("XMLReaderFactory default can be replaced")
  @MainActor func testXMLReaderFactoryReplacement() throws {
    class CustomReader : org.xml.sax.helper.DefaultHandler, org.xml.sax.XMLReader {
      func getFeature(_ name: String) throws -> Bool { false }
      func setFeature(_ name: String, _ value: Bool) throws {}
      func getProperty(_ name: String) throws -> Any? { nil }
      func setProperty(_ name: String, _ value: Any?) throws {}
      func setEntityResolver(_ r: (any org.xml.sax.EntityResolver)?) {}
      func getEntityResolver() -> (any org.xml.sax.EntityResolver)? { nil }
      func setDTDHandler(_ h: (any org.xml.sax.DTDHandler)?) {}
      func getDTDHandler() -> (any org.xml.sax.DTDHandler)? { nil }
      func setContentHandler(_ h: (any org.xml.sax.ContentHandler)?) {}
      func getContentHandler() -> (any org.xml.sax.ContentHandler)? { nil }
      func setErrorHandler(_ h: (any org.xml.sax.ErrorHandler)?) {}
      func getErrorHandler() -> (any org.xml.sax.ErrorHandler)? { nil }
      func parse(_ input: org.xml.sax.InputSource) throws {}
      func parse(_ systemId: String) throws {}
    }
    let key      = org.xml.sax.helper.XMLReaderFactory.defaultReaderName
    let original = org.xml.sax.helper.XMLReaderFactory.registeredReaders[key]
    defer { org.xml.sax.helper.XMLReaderFactory.registeredReaders[key] = original }
    org.xml.sax.helper.XMLReaderFactory.registeredReaders[key] = CustomReader()
    let retrieved = try org.xml.sax.helper.XMLReaderFactory.createXMLReader()
    #expect(retrieved is CustomReader)
  }
}

// MARK: - Large document integration test

struct JavApi_org_xml_sax_JavApiXMLReader_LargeDocument_Tests {

  static let catalogXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <?display-hint columns="3"?>
    <catalog version="2.0" lang="en">
      <metadata>
        <created>2026-06-29</created>
        <owner>JavApi4Swift</owner>
      </metadata>
      <book id="b001" genre="fiction" inStock="true">
        <title>The Swift Programming Language</title>
        <author role="primary">Apple Inc.</author>
        <author role="contributor">Swift Community</author>
        <year>2014</year>
        <price currency="USD">0.00</price>
        <tags><tag>swift</tag><tag>programming</tag><tag>apple</tag></tags>
        <description>Official guide to the Swift language.</description>
      </book>
      <book id="b002" genre="technical" inStock="false">
        <title>Java in a Nutshell</title>
        <author role="primary">Ben Evans</author>
        <year>2019</year>
        <price currency="EUR">49.99</price>
        <tags><tag>java</tag><tag>programming</tag></tags>
        <description>Comprehensive Java reference.</description>
      </book>
      <book id="b003" genre="technical" inStock="true">
        <title>Clean Code</title>
        <author role="primary">Robert C. Martin</author>
        <year>2008</year>
        <price currency="USD">35.99</price>
        <tags><tag>craftsmanship</tag><tag>refactoring</tag></tags>
        <description>A handbook of agile software craftsmanship.</description>
      </book>
    </catalog>
    """

  private class CatalogHandler : org.xml.sax.helper.DefaultHandler {
    struct Book {
      var id: String = ""; var genre: String = ""; var inStock: Bool = false
      var title: String = ""; var authors: [(role: String, name: String)] = []
      var year: String = ""; var price: String = ""; var currency: String = ""
      var tags: [String] = []; var description: String = ""
    }
    var catalogVersion = ""; var catalogLang = ""
    var metadataCreated = ""; var metadataOwner = ""
    var books: [Book] = []
    var processingInstructions: [(target: String, data: String)] = []

    private var currentBook: Book?
    private var currentText = ""
    private var currentAuthorRole = ""
    private var elementStack: [String] = []

    override func processingInstruction(_ target: String, _data: String) throws(org.xml.sax.SAXException) {
      processingInstructions.append((target: target, data: _data))
    }
    override func startElement(_ uri: String, _ localName: String, _ qName: String,
                                _ atts: any org.xml.sax.Attributes) throws(org.xml.sax.SAXException) {
      elementStack.append(qName); currentText = ""
      switch qName {
      case "catalog": catalogVersion = atts.getValue("version") ?? ""; catalogLang = atts.getValue("lang") ?? ""
      case "book":
        var b = Book()
        b.id = atts.getValue("id") ?? ""; b.genre = atts.getValue("genre") ?? ""
        b.inStock = atts.getValue("inStock") == "true"; currentBook = b
      case "author": currentAuthorRole = atts.getValue("role") ?? ""
      case "price":  currentBook?.currency = atts.getValue("currency") ?? ""
      default: break
      }
    }
    override func endElement(_ uri: String, _ localName: String, _ qName: String) throws(org.xml.sax.SAXException) {
      _ = elementStack.popLast()
      let parent = elementStack.last ?? ""
      let text   = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
      switch qName {
      case "book":   if let b = currentBook { books.append(b) }; currentBook = nil
      case "title":  currentBook?.title = text
      case "author": currentBook?.authors.append((role: currentAuthorRole, name: text)); currentAuthorRole = ""
      case "year":   currentBook?.year  = text
      case "price":  currentBook?.price = text
      case "tag":    currentBook?.tags.append(text)
      case "description": currentBook?.description = text
      case "created" where parent == "metadata": metadataCreated = text
      case "owner"   where parent == "metadata": metadataOwner   = text
      default: break
      }
      currentText = ""
    }
    override func characters(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {
      currentText += String(ch[start ..< start + length])
    }
  }

  private func parsedCatalog() throws -> CatalogHandler {
    let handler = CatalogHandler()
    let reader  = JavApiXMLReader()
    reader.setContentHandler(handler)
    try reader.parse(org.xml.sax.InputSource(java.io.StringReader(Self.catalogXML)))
    return handler
  }

  @Test("catalog root attributes are parsed")
  func testRootAttributes() throws {
    let h = try parsedCatalog()
    #expect(h.catalogVersion == "2.0")
    #expect(h.catalogLang   == "en")
  }

  @Test("processing instruction before root is delivered")
  func testProcessingInstruction() throws {
    let h = try parsedCatalog()
    #expect(h.processingInstructions.contains(where: { $0.target == "display-hint" }))
  }

  @Test("metadata sub-elements are parsed")
  func testMetadata() throws {
    let h = try parsedCatalog()
    #expect(h.metadataCreated == "2026-06-29")
    #expect(h.metadataOwner  == "JavApi4Swift")
  }

  @Test("three books are parsed")
  func testBookCount() throws {
    #expect(try parsedCatalog().books.count == 3)
  }

  @Test("first book attributes and children")
  func testFirstBook() throws {
    let b = try parsedCatalog().books[0]
    #expect(b.id      == "b001")
    #expect(b.genre   == "fiction")
    #expect(b.inStock == true)
    #expect(b.title   == "The Swift Programming Language")
    #expect(b.year    == "2014")
    #expect(b.price   == "0.00")
    #expect(b.currency == "USD")
    #expect(b.authors.count == 2)
    #expect(b.authors[0].name == "Apple Inc.")
    #expect(b.tags.contains("swift"))
    #expect(b.tags.contains("programming"))
  }

  @Test("second book inStock false, EUR currency")
  func testSecondBook() throws {
    let b = try parsedCatalog().books[1]
    #expect(b.inStock  == false)
    #expect(b.currency == "EUR")
    #expect(b.price    == "49.99")
  }

  @Test("third book title and tags")
  func testThirdBook() throws {
    let b = try parsedCatalog().books[2]
    #expect(b.title == "Clean Code")
    #expect(b.tags  == ["craftsmanship", "refactoring"])
  }

  @Test("tag 'programming' appears in two books")
  func testCrossBookTags() throws {
    let h = try parsedCatalog()
    #expect(h.books.filter({ $0.tags.contains("programming") }).count == 2)
  }

  @Test("all book ids are unique")
  func testUniqueIds() throws {
    let ids = try parsedCatalog().books.map(\.id)
    #expect(Set(ids).count == ids.count)
  }
}

#endif // canImport(Foundation) && Apple platforms
