/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

#if canImport(Foundation) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))
import Foundation

/// A concrete SAX 1.0 ``org.xml.sax.Parser`` backed by Foundation's `XMLParser`.
///
/// > Note: **This class is a JavApi4Swift extension — it has no equivalent in the
/// > original Java API.** Java never shipped a concrete parser in `org.xml.sax`;
/// > applications were expected to instantiate vendor parsers via ``org.xml.sax.helper.ParserFactory``.
/// > JavApi4Swift provides this built-in implementation so callers work out of the box
/// > without a third-party parser dependency.
///
/// This class is deliberately placed outside the `org.xml.sax` package hierarchy
/// because it is a Swift-native extension, not a Java API port.
///
/// On platforms without Foundation (e.g. WASM) ``JavApiSax1ParserFallback`` is used instead.
///
/// ### Usage
/// ```swift
/// let parser = JavApiSax1Parser()
/// parser.setDocumentHandler(myHandler)
/// parser.setErrorHandler(myErrorHandler)
/// try parser.parse(org.xml.sax.InputSource(java.io.StringReader(xml)))
/// ```
///
/// The parser is automatically registered as the default in
/// ``org.xml.sax.helper.ParserFactory`` under ``org.xml.sax.helper.ParserFactory/defaultParserName``.
///
/// - Since: JavApi4Swift (not part of the Java API)
public final class JavApiSax1Parser : org.xml.sax.Parser, @unchecked Sendable {

  private var documentHandler: (any org.xml.sax.DocumentHandler)?
  private var errorHandler:    (any org.xml.sax.ErrorHandler)?
  private var dtdHandler:      (any org.xml.sax.DTDHandler)?
  private var entityResolver:  (any org.xml.sax.EntityResolver)?
  private var locale: java.util.Locale = java.util.Locale.getDefault()

  public init() {}

  // MARK: - org.xml.sax.Parser

  public func setDocumentHandler(_ documentHandler: any org.xml.sax.DocumentHandler) {
    self.documentHandler = documentHandler
  }
  public func setErrorHandler(_ errorHandler: any org.xml.sax.ErrorHandler) {
    self.errorHandler = errorHandler
  }
  public func setDTDHandler(_ dtdHandler: any org.xml.sax.DTDHandler) {
    self.dtdHandler = dtdHandler
  }
  public func setEntityResolver(_ entityResolver: any org.xml.sax.EntityResolver) {
    self.entityResolver = entityResolver
  }
  public func setLocale(_ locale: java.util.Locale) {
    self.locale = locale
  }

  public func parse(_ source: org.xml.sax.InputSource) throws {
    let delegate = _SAX1FoundationDelegate(
      documentHandler: documentHandler,
      errorHandler:    errorHandler,
      dtdHandler:      dtdHandler
    )
    let xmlParser: XMLParser
    if let byteStream = source.getByteStream() {
      var bytes: [UInt8] = []
      var buf = [UInt8](repeating: 0, count: 4096)
      var n = (try? byteStream.read(&buf, 0, buf.count)) ?? -1
      while n > 0 {
        bytes.append(contentsOf: buf[0 ..< n])
        n = (try? byteStream.read(&buf, 0, buf.count)) ?? -1
      }
      xmlParser = XMLParser(data: Data(bytes))
    } else if let charReader = source.getCharacterStream() {
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
    } else if let systemId = source.getSystemId(), let url = URL(string: systemId) {
      xmlParser = XMLParser(contentsOf: url) ?? XMLParser(data: Data())
    } else {
      throw org.xml.sax.SAXException("InputSource has no usable content (no byteStream, charStream, or systemId)")
    }
    xmlParser.delegate = delegate
    xmlParser.shouldProcessNamespaces = false
    xmlParser.shouldReportNamespacePrefixes = false
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

// MARK: - Foundation XMLParserDelegate bridge

private final class _SAX1FoundationDelegate : NSObject, XMLParserDelegate, @unchecked Sendable {

  private let documentHandler: (any org.xml.sax.DocumentHandler)?
  private let errorHandler:    (any org.xml.sax.ErrorHandler)?
  private let dtdHandler:      (any org.xml.sax.DTDHandler)?
  var thrownError: org.xml.sax.SAXException?

  init(
    documentHandler: (any org.xml.sax.DocumentHandler)?,
    errorHandler:    (any org.xml.sax.ErrorHandler)?,
    dtdHandler:      (any org.xml.sax.DTDHandler)?
  ) {
    self.documentHandler = documentHandler
    self.errorHandler    = errorHandler
    self.dtdHandler      = dtdHandler
  }

  func parserDidStartDocument(_ parser: XMLParser) {
    guard thrownError == nil else { return }
    do { try documentHandler?.startDocument() }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    guard thrownError == nil else { return }
    do { try documentHandler?.endDocument() }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String,
              namespaceURI: String?, qualifiedName: String?,
              attributes attributeDict: [String: String] = [:]) {
    guard thrownError == nil else { return }
    let atts = org.xml.sax.helper.AttributeListImpl()
    for (name, value) in attributeDict { atts.addAttribute(name, "CDATA", value) }
    do { try documentHandler?.startElement(elementName, atts) }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String,
              namespaceURI: String?, qualifiedName: String?) {
    guard thrownError == nil else { return }
    do { try documentHandler?.endElement(elementName) }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    guard thrownError == nil else { return }
    let chars = Array(string)
    do { try documentHandler?.characters(chars, 0, chars.count) }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    guard thrownError == nil else { return }
    let chars = Array(whitespaceString)
    do { try documentHandler?.ignorableWhitespace(chars, 0, chars.count) }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
    guard thrownError == nil else { return }
    do { try documentHandler?.processingInstruction(target, _data: data ?? "") }
    catch { thrownError = error; parser.abortParsing() }
  }

  func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String,
              publicID: String?, systemID: String?) {
    dtdHandler?.notationDecl(name: name, publicId: publicID, systemId: systemID)
  }

  func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String,
              publicID: String?, systemID: String?, notationName: String?) {
    dtdHandler?.unparsedEntityDecl(name: name, publicId: publicID,
                                   systemId: systemID, notationName: notationName)
  }

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
