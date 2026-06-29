/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

#if canImport(Foundation) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))
import Foundation

/// A concrete SAX 2.0 ``org.xml.sax.XMLReader`` backed by Foundation's `XMLParser`.
///
/// > Note: **This class is a JavApi4Swift extension — it has no equivalent in the
/// > original Java API.**
///
/// Available on Apple platforms only. Linux and WASM use ``JavApiXMLReaderFallback``
/// (same type name, different `#if` branch).
///
/// The parser is automatically registered as the default in
/// ``org.xml.sax.helper.XMLReaderFactory`` under
/// ``org.xml.sax.helper.XMLReaderFactory/defaultReaderName``.
///
/// ### Supported features
/// - `"http://xml.org/sax/features/namespaces"` — default `true`
/// - `"http://xml.org/sax/features/namespace-prefixes"` — default `false`
///
/// - Since: JavApi4Swift (not part of the Java API)
public final class JavApiXMLReader : org.xml.sax.XMLReader, @unchecked Sendable {

  // MARK: - Features

  private var featureNamespaces:        Bool = true
  private var featureNamespacePrefixes: Bool = false

  private static let knownFeatures: Set<String> = [
    "http://xml.org/sax/features/namespaces",
    "http://xml.org/sax/features/namespace-prefixes",
  ]

  // MARK: - Handlers

  private var contentHandler: (any org.xml.sax.ContentHandler)?
  private var dtdHandler:     (any org.xml.sax.DTDHandler)?
  private var entityResolver: (any org.xml.sax.EntityResolver)?
  private var errorHandler:   (any org.xml.sax.ErrorHandler)?

  public init() {}

  // MARK: - XMLReader: features

  public func getFeature(_ name: String) throws(org.xml.sax.SAXNotRecognizedException) -> Bool {
    switch name {
    case "http://xml.org/sax/features/namespaces":        return featureNamespaces
    case "http://xml.org/sax/features/namespace-prefixes": return featureNamespacePrefixes
    default: throw org.xml.sax.SAXNotRecognizedException("Unknown feature: \(name)")
    }
  }

  public func setFeature(_ name: String, _ value: Bool) throws(org.xml.sax.SAXNotRecognizedException) {
    switch name {
    case "http://xml.org/sax/features/namespaces":        featureNamespaces = value
    case "http://xml.org/sax/features/namespace-prefixes": featureNamespacePrefixes = value
    default: throw org.xml.sax.SAXNotRecognizedException("Unknown feature: \(name)")
    }
  }

  // MARK: - XMLReader: properties (none supported)

  public func getProperty(_ name: String) throws(org.xml.sax.SAXException) -> Any? {
    throw org.xml.sax.SAXNotRecognizedException("Unknown property: \(name)")
  }

  public func setProperty(_ name: String, _ value: Any?) throws(org.xml.sax.SAXException) {
    throw org.xml.sax.SAXNotRecognizedException("Unknown property: \(name)")
  }

  // MARK: - XMLReader: handlers

  public func setContentHandler(_ handler: (any org.xml.sax.ContentHandler)?) { contentHandler = handler }
  public func getContentHandler() -> (any org.xml.sax.ContentHandler)?         { contentHandler }

  public func setDTDHandler(_ handler: (any org.xml.sax.DTDHandler)?) { dtdHandler = handler }
  public func getDTDHandler() -> (any org.xml.sax.DTDHandler)?         { dtdHandler }

  public func setEntityResolver(_ resolver: (any org.xml.sax.EntityResolver)?) { entityResolver = resolver }
  public func getEntityResolver() -> (any org.xml.sax.EntityResolver)?          { entityResolver }

  public func setErrorHandler(_ handler: (any org.xml.sax.ErrorHandler)?) { errorHandler = handler }
  public func getErrorHandler() -> (any org.xml.sax.ErrorHandler)?         { errorHandler }

  // MARK: - XMLReader: parse

  public func parse(_ input: org.xml.sax.InputSource) throws {
    let delegate = _SAX2FoundationDelegate(
      contentHandler: contentHandler,
      dtdHandler:     dtdHandler,
      errorHandler:   errorHandler,
      namespaces:     featureNamespaces,
      namespacePrefixes: featureNamespacePrefixes
    )
    let xmlParser: XMLParser
    if let byteStream = input.getByteStream() {
      var bytes: [UInt8] = []
      var buf = [UInt8](repeating: 0, count: 4096)
      var n = (try? byteStream.read(&buf, 0, buf.count)) ?? -1
      while n > 0 {
        bytes.append(contentsOf: buf[0 ..< n])
        n = (try? byteStream.read(&buf, 0, buf.count)) ?? -1
      }
      xmlParser = XMLParser(data: Data(bytes))
    } else if let charReader = input.getCharacterStream() {
      var result = ""
      var cbuf = [Character](repeating: Character("\0"), count: 4096)
      var n = try charReader.read(&cbuf, 0, cbuf.count)
      while n > 0 {
        result += String(cbuf[0 ..< n])
        n = try charReader.read(&cbuf, 0, cbuf.count)
      }
      guard let data = result.data(using: .utf8) else {
        throw org.xml.sax.SAXException("Cannot encode character stream as UTF-8")
      }
      xmlParser = XMLParser(data: data)
    } else if let systemId = input.getSystemId(), let url = URL(string: systemId) {
      xmlParser = XMLParser(contentsOf: url) ?? XMLParser(data: Data())
    } else {
      throw org.xml.sax.SAXException("InputSource has no usable content")
    }
    xmlParser.delegate = delegate
    xmlParser.shouldProcessNamespaces      = featureNamespaces
    xmlParser.shouldReportNamespacePrefixes = featureNamespacePrefixes
    if !xmlParser.parse() {
      if let err = xmlParser.parserError {
        throw org.xml.sax.SAXException(err.localizedDescription)
      }
    }
    if let saxErr = delegate.thrownError { throw saxErr }
  }

  public func parse(_ systemId: String) throws {
    try parse(org.xml.sax.InputSource(systemId))
  }
}

// MARK: - Foundation XMLParserDelegate bridge (SAX 2.0)

private final class _SAX2FoundationDelegate : NSObject, XMLParserDelegate, @unchecked Sendable {

  private let contentHandler: (any org.xml.sax.ContentHandler)?
  private let dtdHandler:     (any org.xml.sax.DTDHandler)?
  private let errorHandler:   (any org.xml.sax.ErrorHandler)?
  private let namespaces:     Bool
  private let namespacePrefixes: Bool

  var thrownError: org.xml.sax.SAXException?

  init(contentHandler: (any org.xml.sax.ContentHandler)?,
       dtdHandler:     (any org.xml.sax.DTDHandler)?,
       errorHandler:   (any org.xml.sax.ErrorHandler)?,
       namespaces:     Bool,
       namespacePrefixes: Bool) {
    self.contentHandler    = contentHandler
    self.dtdHandler        = dtdHandler
    self.errorHandler      = errorHandler
    self.namespaces        = namespaces
    self.namespacePrefixes = namespacePrefixes
  }

  // MARK: Document lifecycle

  func parserDidStartDocument(_ parser: XMLParser) {
    guard thrownError == nil else { return }
    do { try contentHandler?.startDocument() }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    guard thrownError == nil else { return }
    do { try contentHandler?.endDocument() }
    catch { thrownError = error; parser.abortParsing() }
  }

  // MARK: Namespace mappings

  func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
    guard thrownError == nil else { return }
    do { try contentHandler?.startPrefixMapping(prefix, namespaceURI) }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
    guard thrownError == nil else { return }
    do { try contentHandler?.endPrefixMapping(prefix) }
    catch { thrownError = error; parser.abortParsing() }
  }

  // MARK: Elements

  func parser(_ parser: XMLParser,
              didStartElement elementName: String,
              namespaceURI: String?,
              qualifiedName qName: String?,
              attributes attributeDict: [String: String] = [:]) {
    guard thrownError == nil else { return }
    let atts = org.xml.sax.helper.AttributesImpl()
    for (key, value) in attributeDict {
      // When namespace processing is on, Foundation provides localName in elementName
      // and qName separately. For attributes we only have the raw key here.
      atts.addAttribute("", key, key, "CDATA", value)
    }
    let uri   = namespaceURI ?? ""
    let local = namespaces ? elementName : ""
    let q     = qName ?? elementName
    do { try contentHandler?.startElement(uri, local, q, atts) }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser,
              didEndElement elementName: String,
              namespaceURI: String?,
              qualifiedName qName: String?) {
    guard thrownError == nil else { return }
    let uri   = namespaceURI ?? ""
    let local = namespaces ? elementName : ""
    let q     = qName ?? elementName
    do { try contentHandler?.endElement(uri, local, q) }
    catch { thrownError = error; parser.abortParsing() }
  }

  // MARK: Characters

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    guard thrownError == nil else { return }
    let chars = Array(string)
    do { try contentHandler?.characters(chars, 0, length: chars.count) }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    guard thrownError == nil else { return }
    let chars = Array(whitespaceString)
    do { try contentHandler?.ignorableWhitespace(chars, 0, chars.count) }
    catch { thrownError = error; parser.abortParsing() }
  }

  // MARK: Processing instructions

  func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
    guard thrownError == nil else { return }
    do { try contentHandler?.processingInstruction(target, _data: data ?? "") }
    catch { thrownError = error; parser.abortParsing() }
  }

  // MARK: DTD

  func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String,
              publicID: String?, systemID: String?) {
    dtdHandler?.notationDecl(name: name, publicId: publicID, systemId: systemID)
  }

  func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String,
              publicID: String?, systemID: String?, notationName: String?) {
    dtdHandler?.unparsedEntityDecl(name: name, publicId: publicID,
                                   systemId: systemID, notationName: notationName)
  }

  // MARK: Errors

  private func makeLocator(_ parser: XMLParser) -> org.xml.sax.LocatorImpl {
    let loc = org.xml.sax.LocatorImpl()
    loc.setSystemId(parser.systemID)
    loc.setPublicId(parser.publicID)
    loc.setLineNumber(parser.lineNumber)
    loc.setColumnNumber(parser.columnNumber)
    return loc
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    let saxErr = org.xml.sax.SAXParseException(parseError.localizedDescription, makeLocator(parser))
    do { try errorHandler?.fatalError(saxErr) } catch { thrownError = error }
    if thrownError == nil { thrownError = saxErr }
    parser.abortParsing()
  }

  func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
    let saxErr = org.xml.sax.SAXParseException(validationError.localizedDescription, makeLocator(parser))
    do { try errorHandler?.error(saxErr) }
    catch { thrownError = error; parser.abortParsing() }
  }
}

#endif // canImport(Foundation) && Apple platforms
