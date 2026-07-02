/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

#if canImport(Foundation) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))

// MARK: - Recording handler for test assertions

/// A HandlerBase subclass that records all SAX 1.0 events.
///
/// `HandlerBase` is deprecated in production code (SAX 2.0: use `DefaultHandler`).
/// The deprecation warning is intentionally suppressed here — the test exists
/// specifically to verify that the deprecated API still works correctly.
@available(*, deprecated)
private class RecordingHandler : org.xml.sax.helper.HandlerBase {

  struct ElementEvent: Equatable {
    let name: String
    let attributeNames: [String]
    let attributeValues: [String]
  }

  var startDocumentCalled = false
  var endDocumentCalled = false
  var startElements: [ElementEvent] = []
  var endElements: [String] = []
  var characters: String = ""
  var processingInstructions: [(target: String, data: String)] = []
  var locator: (any org.xml.sax.Locator)?

  override func startDocument() throws(org.xml.sax.SAXException) {
    startDocumentCalled = true
  }

  override func endDocument() throws(org.xml.sax.SAXException) {
    endDocumentCalled = true
  }

  override func setDocumentLocator(_ locator: any org.xml.sax.Locator) throws(org.xml.sax.SAXException) {
    self.locator = locator
  }

  override func startElement(_ name: String, _ attributes: any org.xml.sax.AttributeList) throws(org.xml.sax.SAXException) {
    var names: [String] = []
    var values: [String] = []
    for i in 0 ..< attributes.getLength() {
      names.append(attributes.getName(i) ?? "")
      values.append(attributes.getValue(i) ?? "")
    }
    startElements.append(ElementEvent(name: name, attributeNames: names, attributeValues: values))
  }

  override func endElement(_ name: String) throws(org.xml.sax.SAXException) {
    endElements.append(name)
  }

  override func characters(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {
    characters += String(ch[start ..< start + length])
  }

  override func processingInstruction(_ target: String, _data: String) throws(org.xml.sax.SAXException) {
    processingInstructions.append((target: target, data: _data))
  }
}

// MARK: - Factory (isolates deprecation warning to one place)

/// Returns a fresh `RecordingHandler`.
///
/// Marked deprecated so the compiler suppresses the `HandlerBase`-deprecation
/// warning inside, without propagating it to the `@Test` methods themselves.
@available(*, deprecated)
private func makeRecordingHandler() -> RecordingHandler { RecordingHandler() }

// MARK: - Tests

struct JavApi_org_xml_sax_XMLSAXParser_Tests {

  // MARK: - Basic lifecycle

  @Test("parse minimal XML calls startDocument and endDocument")
  func testStartEndDocument() throws {
    let xml = "<root/>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    let source = org.xml.sax.InputSource(java.io.StringReader(xml))
    try parser.parse(source)

    #expect(handler.startDocumentCalled)
    #expect(handler.endDocumentCalled)
  }

  // MARK: - Elements

  @Test("parse single element fires startElement and endElement")
  func testSingleElement() throws {
    let xml = "<root/>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))

    #expect(handler.startElements.count == 1)
    #expect(handler.startElements[0].name == "root")
    #expect(handler.endElements == ["root"])
  }

  @Test("parse nested elements fires events in correct order")
  func testNestedElements() throws {
    let xml = "<root><child/></root>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))

    #expect(handler.startElements.map(\.name) == ["root", "child"])
    #expect(handler.endElements == ["child", "root"])
  }

  // MARK: - Attributes

  @Test("parse element with attributes delivers attributes via AttributeList")
  func testAttributes() throws {
    let xml = "<link href=\"https://example.com\" rel=\"stylesheet\"/>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))

    #expect(handler.startElements.count == 1)
    let evt = handler.startElements[0]
    #expect(evt.name == "link")
    // attributes may arrive in any order — check by name lookup
    let hrefIdx = evt.attributeNames.firstIndex(of: "href")
    let relIdx  = evt.attributeNames.firstIndex(of: "rel")
    #expect(hrefIdx != nil)
    #expect(relIdx  != nil)
    if let i = hrefIdx { #expect(evt.attributeValues[i] == "https://example.com") }
    if let i = relIdx  { #expect(evt.attributeValues[i] == "stylesheet") }
  }

  @Test("element without attributes delivers empty AttributeList")
  func testNoAttributes() throws {
    let xml = "<empty/>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))

    #expect(handler.startElements[0].attributeNames.isEmpty)
  }

  // MARK: - Characters

  @Test("text content is delivered via characters callback")
  func testCharacters() throws {
    let xml = "<note>Hello World</note>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))

    #expect(handler.characters == "Hello World")
  }

  @Test("mixed content delivers characters between elements")
  func testMixedContent() throws {
    let xml = "<p>Hello <b>World</b>!</p>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))

    #expect(handler.characters.contains("Hello"))
    #expect(handler.characters.contains("World"))
    #expect(handler.characters.contains("!"))
  }

  // MARK: - Processing instructions

  @Test("processing instruction is delivered to handler")
  func testProcessingInstruction() throws {
    let xml = "<?xml-stylesheet type=\"text/css\" href=\"style.css\"?><root/>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))

    #expect(handler.processingInstructions.contains(where: { $0.target == "xml-stylesheet" }))
  }

  // MARK: - parse(String systemId)

  @Test("parse via systemId String overload works")
  func testParseSystemId() throws {
    let xml = "<ok/>"
    let handler = makeRecordingHandler()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(handler)

    try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))
    #expect(handler.startElements[0].name == "ok")
  }

  // MARK: - Error handling

  @Test("invalid XML causes parse to throw")
  func testInvalidXML() {
    let xml = "<unclosed>"
    let parser = JavApiSax1Parser()

    #expect(throws: (any Error).self) {
      try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))
    }
  }

  @Test("ErrorHandler receives fatalError on invalid XML")
  func testErrorHandlerFatalError() {
    class ErrorRecorder : org.xml.sax.helper.HandlerBase {
      var fatalMessages: [String] = []
      override func fatalError(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {
        fatalMessages.append(exception.getMessage() ?? "")
        throw exception
      }
    }
    let xml = "<bad"
    let recorder = ErrorRecorder()
    let parser = JavApiSax1Parser()
    parser.setDocumentHandler(recorder)
    parser.setErrorHandler(recorder)

    #expect(throws: (any Error).self) {
      try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))
    }
    #expect(!recorder.fatalMessages.isEmpty)
  }

  // MARK: - ParserFactory registration

  @Test("JavApiSax1Parser is registered as default parser in ParserFactory")
  @MainActor func testParserFactoryDefaultRegistration() throws {
    let retrieved = try org.xml.sax.helper.ParserFactory.makeParser()
    #expect(retrieved is JavApiSax1Parser)
  }

  @Test("ParserFactory default parser can be replaced with custom implementation")
  @MainActor func testParserFactoryReplacement() throws {
    class CustomParser : org.xml.sax.helper.HandlerBase, org.xml.sax.Parser {
      func parse(_ source: org.xml.sax.InputSource) throws {}
      func parse(_ source: String) throws {}
      func setErrorHandler(_ errorHandler: any org.xml.sax.ErrorHandler) {}
      func setDocumentHandler(_ documentHandler: any org.xml.sax.DocumentHandler) {}
      func setDTDHandler(_ dtdHandler: any org.xml.sax.DTDHandler) {}
      func setEntityResolver(_ entityResolver: any org.xml.sax.EntityResolver) {}
      func setLocale(_ locale: java.util.Locale) {}
    }
    let key = org.xml.sax.helper.ParserFactory.defaultParserName
    let original = org.xml.sax.helper.ParserFactory.registeredParsers[key]
    defer {
      // restore original so other tests are unaffected
      org.xml.sax.helper.ParserFactory.registeredParsers[key] = original
    }
    org.xml.sax.helper.ParserFactory.registeredParsers[key] = CustomParser()
    let retrieved = try org.xml.sax.helper.ParserFactory.makeParser()
    #expect(retrieved is CustomParser)
  }
}

// MARK: - Large document integration test

struct JavApi_org_xml_sax_XMLSAXParser_LargeDocument_Tests {

  // XML document used across all tests in this suite
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
        <tags>
          <tag>swift</tag>
          <tag>programming</tag>
          <tag>apple</tag>
        </tags>
        <description>Official guide to the Swift language.</description>
      </book>
      <book id="b002" genre="technical" inStock="false">
        <title>Java in a Nutshell</title>
        <author role="primary">Ben Evans</author>
        <year>2019</year>
        <price currency="EUR">49.99</price>
        <tags>
          <tag>java</tag>
          <tag>programming</tag>
        </tags>
        <description>Comprehensive Java reference.</description>
      </book>
      <book id="b003" genre="technical" inStock="true">
        <title>Clean Code</title>
        <author role="primary">Robert C. Martin</author>
        <year>2008</year>
        <price currency="USD">35.99</price>
        <tags>
          <tag>craftsmanship</tag>
          <tag>refactoring</tag>
        </tags>
        <description>A handbook of agile software craftsmanship.</description>
      </book>
    </catalog>
    """

  // MARK: - Handler that builds a structured model from SAX events

  private class CatalogHandler : org.xml.sax.helper.HandlerBase {

    struct Book {
      var id: String = ""
      var genre: String = ""
      var inStock: Bool = false
      var title: String = ""
      var authors: [(role: String, name: String)] = []
      var year: String = ""
      var price: String = ""
      var currency: String = ""
      var tags: [String] = []
      var description: String = ""
    }

    var catalogVersion: String = ""
    var catalogLang: String = ""
    var metadataCreated: String = ""
    var metadataOwner: String = ""
    var books: [Book] = []
    var processingInstructions: [(target: String, data: String)] = []

    private var currentBook: Book?
    private var currentText: String = ""
    private var currentAuthorRole: String = ""
    private var elementStack: [String] = []

    override func processingInstruction(_ target: String, _data: String) throws(org.xml.sax.SAXException) {
      processingInstructions.append((target: target, data: _data))
    }

    override func startElement(_ name: String, _ atts: any org.xml.sax.AttributeList) throws(org.xml.sax.SAXException) {
      elementStack.append(name)
      currentText = ""
      switch name {
      case "catalog":
        catalogVersion = atts.getValue("version") ?? ""
        catalogLang    = atts.getValue("lang") ?? ""
      case "book":
        var book = Book()
        book.id      = atts.getValue("id") ?? ""
        book.genre   = atts.getValue("genre") ?? ""
        book.inStock = atts.getValue("inStock") == "true"
        currentBook  = book
      case "author":
        currentAuthorRole = atts.getValue("role") ?? ""
      case "price":
        currentBook?.currency = atts.getValue("currency") ?? ""
      default:
        break
      }
    }

    override func endElement(_ name: String) throws(org.xml.sax.SAXException) {
      _ = elementStack.popLast()
      let parent = elementStack.last ?? ""
      let text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

      switch name {
      case "book":
        if let book = currentBook { books.append(book) }
        currentBook = nil
      case "title":
        currentBook?.title = text
      case "author":
        currentBook?.authors.append((role: currentAuthorRole, name: text))
        currentAuthorRole = ""
      case "year":
        currentBook?.year = text
      case "price":
        currentBook?.price = text
      case "tag":
        currentBook?.tags.append(text)
      case "description":
        currentBook?.description = text
      case "created" where parent == "metadata":
        metadataCreated = text
      case "owner" where parent == "metadata":
        metadataOwner = text
      default:
        break
      }
      currentText = ""
    }

    override func characters(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {
      currentText += String(ch[start ..< start + length])
    }
  }

  // MARK: - Helper

  private func parsedCatalog() throws -> CatalogHandler {
    let handler = CatalogHandler()
    let parser  = JavApiSax1Parser()
    parser.setDocumentHandler(handler)
    let source = org.xml.sax.InputSource(java.io.StringReader(Self.catalogXML))
    try parser.parse(source)
    return handler
  }

  // MARK: - Root element attributes

  @Test("catalog root element attributes are parsed correctly")
  func testRootAttributes() throws {
    let h = try parsedCatalog()
    #expect(h.catalogVersion == "2.0")
    #expect(h.catalogLang   == "en")
  }

  // MARK: - Processing instruction

  @Test("processing instruction before root is delivered")
  func testProcessingInstruction() throws {
    let h = try parsedCatalog()
    #expect(h.processingInstructions.contains(where: { $0.target == "display-hint" }))
    let pi = h.processingInstructions.first(where: { $0.target == "display-hint" })
    #expect(pi?.data.contains("columns") == true)
  }

  // MARK: - Metadata sub-elements

  @Test("metadata sub-elements are parsed correctly")
  func testMetadata() throws {
    let h = try parsedCatalog()
    #expect(h.metadataCreated == "2026-06-29")
    #expect(h.metadataOwner  == "JavApi4Swift")
  }

  // MARK: - Book count

  @Test("three books are parsed from catalog")
  func testBookCount() throws {
    let h = try parsedCatalog()
    #expect(h.books.count == 3)
  }

  // MARK: - First book: attributes

  @Test("first book id and genre attributes are correct")
  func testFirstBookAttributes() throws {
    let h = try parsedCatalog()
    let b = h.books[0]
    #expect(b.id    == "b001")
    #expect(b.genre == "fiction")
    #expect(b.inStock == true)
  }

  // MARK: - First book: simple text elements

  @Test("first book title and year are correct")
  func testFirstBookTextElements() throws {
    let h = try parsedCatalog()
    let b = h.books[0]
    #expect(b.title == "The Swift Programming Language")
    #expect(b.year  == "2014")
  }

  // MARK: - First book: element with attribute (price + currency)

  @Test("first book price text and currency attribute are correct")
  func testFirstBookPrice() throws {
    let h = try parsedCatalog()
    let b = h.books[0]
    #expect(b.price    == "0.00")
    #expect(b.currency == "USD")
  }

  // MARK: - First book: multiple same-name child elements (authors)

  @Test("first book has two authors with correct roles")
  func testFirstBookMultipleAuthors() throws {
    let h = try parsedCatalog()
    let b = h.books[0]
    #expect(b.authors.count == 2)
    #expect(b.authors[0].role == "primary")
    #expect(b.authors[0].name == "Apple Inc.")
    #expect(b.authors[1].role == "contributor")
    #expect(b.authors[1].name == "Swift Community")
  }

  // MARK: - First book: nested list of tags

  @Test("first book tags sub-elements are all parsed")
  func testFirstBookTags() throws {
    let h = try parsedCatalog()
    let b = h.books[0]
    #expect(b.tags.count == 3)
    #expect(b.tags.contains("swift"))
    #expect(b.tags.contains("programming"))
    #expect(b.tags.contains("apple"))
  }

  // MARK: - First book: longer description text

  @Test("first book description text is correct")
  func testFirstBookDescription() throws {
    let h = try parsedCatalog()
    #expect(h.books[0].description == "Official guide to the Swift language.")
  }

  // MARK: - Second book: inStock false, EUR currency

  @Test("second book inStock false and EUR currency")
  func testSecondBook() throws {
    let h = try parsedCatalog()
    let b = h.books[1]
    #expect(b.id       == "b002")
    #expect(b.inStock  == false)
    #expect(b.currency == "EUR")
    #expect(b.price    == "49.99")
    #expect(b.authors.count == 1)
    #expect(b.authors[0].name == "Ben Evans")
  }

  // MARK: - Third book

  @Test("third book title and tags are correct")
  func testThirdBook() throws {
    let h = try parsedCatalog()
    let b = h.books[2]
    #expect(b.id    == "b003")
    #expect(b.title == "Clean Code")
    #expect(b.tags  == ["craftsmanship", "refactoring"])
  }

  // MARK: - Cross-book checks

  @Test("tag 'programming' appears in two books")
  func testCrossBookTags() throws {
    let h = try parsedCatalog()
    let count = h.books.filter { $0.tags.contains("programming") }.count
    #expect(count == 2)
  }

  @Test("all book ids are unique")
  func testUniqueIds() throws {
    let h = try parsedCatalog()
    let ids = h.books.map(\.id)
    #expect(Set(ids).count == ids.count)
  }
}

#endif // canImport(Foundation) && Apple platforms
