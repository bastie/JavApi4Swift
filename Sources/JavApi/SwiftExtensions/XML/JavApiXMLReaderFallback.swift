/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

#if !canImport(Foundation) || !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))

/// A minimal SAX 2.0 ``org.xml.sax.XMLReader`` implemented in pure Swift.
///
/// > Note: **This class is a JavApi4Swift extension — it has no equivalent in the
/// > original Java API.**
///
/// Used on platforms where Foundation's `XMLParser` is unavailable (Linux, WASM).
/// Internally reuses the same pure-Swift XML engine as ``JavApiSax1Parser``.
///
/// - Since: JavApi4Swift (not part of the Java API)
public final class JavApiXMLReader : org.xml.sax.XMLReader, @unchecked Sendable {

  // MARK: - Features

  private var featureNamespaces:        Bool = true
  private var featureNamespacePrefixes: Bool = false

  // MARK: - Handlers

  private var contentHandler: (any org.xml.sax.ContentHandler)?
  private var dtdHandler:     (any org.xml.sax.DTDHandler)?
  private var entityResolver: (any org.xml.sax.EntityResolver)?
  private var errorHandler:   (any org.xml.sax.ErrorHandler)?

  public init() {}

  // MARK: - XMLReader: features

  public func getFeature(_ name: String) throws -> Bool {
    switch name {
    case "http://xml.org/sax/features/namespaces":         return featureNamespaces
    case "http://xml.org/sax/features/namespace-prefixes": return featureNamespacePrefixes
    default: throw org.xml.sax.SAXNotRecognizedException("Unknown feature: \(name)")
    }
  }

  public func setFeature(_ name: String, _ value: Bool) throws {
    switch name {
    case "http://xml.org/sax/features/namespaces":         featureNamespaces = value
    case "http://xml.org/sax/features/namespace-prefixes": featureNamespacePrefixes = value
    default: throw org.xml.sax.SAXNotRecognizedException("Unknown feature: \(name)")
    }
  }

  public func getProperty(_ name: String) throws -> Any? {
    throw org.xml.sax.SAXNotRecognizedException("Unknown property: \(name)")
  }

  public func setProperty(_ name: String, _ value: Any?) throws {
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
    let xml: String
    if let byteStream = input.getByteStream() {
      var bytes: [UInt8] = []
      var buf = [UInt8](repeating: 0, count: 4096)
      var n = (try? byteStream.read(&buf, 0, buf.count)) ?? -1
      while n > 0 {
        bytes.append(contentsOf: buf[0 ..< n])
        n = (try? byteStream.read(&buf, 0, buf.count)) ?? -1
      }
      guard let s = String(bytes: bytes, encoding: .utf8) else {
        throw org.xml.sax.SAXException("Byte stream is not valid UTF-8")
      }
      xml = s
    } else if let charReader = input.getCharacterStream() {
      var result = ""
      var cbuf = [Character](repeating: Character("\0"), count: 4096)
      var n = try charReader.read(&cbuf, 0, cbuf.count)
      while n > 0 {
        result += String(cbuf[0 ..< n])
        n = try charReader.read(&cbuf, 0, cbuf.count)
      }
      xml = result
    } else if let systemId = input.getSystemId() {
      throw org.xml.sax.SAXException("systemId resolution not available on this platform: \(systemId)")
    } else {
      throw org.xml.sax.SAXException("InputSource has no usable content")
    }
    let engine = _PureSAX2Engine(
      xml:            xml,
      contentHandler: contentHandler,
      dtdHandler:     dtdHandler,
      errorHandler:   errorHandler,
      namespaces:     featureNamespaces
    )
    try engine.parse()
  }

  public func parse(_ systemId: String) throws {
    try parse(org.xml.sax.InputSource(systemId))
  }
}

// MARK: - Pure-Swift SAX 2.0 engine

private final class _PureSAX2Engine {

  private let src: [Unicode.Scalar]
  private var pos:  Int = 0
  private var line: Int = 1
  private var col:  Int = 1

  private let contentHandler: (any org.xml.sax.ContentHandler)?
  private let dtdHandler:     (any org.xml.sax.DTDHandler)?
  private let errorHandler:   (any org.xml.sax.ErrorHandler)?
  private let namespaces:     Bool

  init(xml: String,
       contentHandler: (any org.xml.sax.ContentHandler)?,
       dtdHandler:     (any org.xml.sax.DTDHandler)?,
       errorHandler:   (any org.xml.sax.ErrorHandler)?,
       namespaces:     Bool) {
    self.src            = Array(xml.unicodeScalars)
    self.contentHandler = contentHandler
    self.dtdHandler     = dtdHandler
    self.errorHandler   = errorHandler
    self.namespaces     = namespaces
  }

  // MARK: Entry

  func parse() throws {
    try contentHandler?.startDocument()
    while pos < src.count {
      if current == "<" { try parseMarkup() }
      else              { try parseCharData() }
    }
    try contentHandler?.endDocument()
  }

  // MARK: Markup dispatcher

  private func parseMarkup() throws {
    advance() // '<'
    guard pos < src.count else { throw saxError("Unexpected end after '<'") }

    if current == "/" {
      advance()
      let qName = try parseName()
      skipSpace()
      try expect(">")
      let (uri, local) = splitQName(qName)
      try contentHandler?.endElement(uri, local, qName)

    } else if current == "!" {
      advance()
      if startsWith("--") {
        advance(2); try skipUntil("-->")
      } else if startsWith("[CDATA[") {
        advance(7)
        let text = try readUntil("]]>")
        let chars = Array(text)
        if !chars.isEmpty { try contentHandler?.characters(chars, 0, chars.count) }
      } else {
        try skipUntil(">")
      }
    } else if current == "?" {
      advance()
      let target = try parseName()
      skipSpace()
      let data = try readUntil("?>").trimmingCharacters(in: .whitespaces)
      if target.lowercased() != "xml" {
        try contentHandler?.processingInstruction(target, _data: data)
      }
    } else {
      let qName = try parseName()
      skipSpace()
      let atts = org.xml.sax.helper.AttributesImpl()
      while pos < src.count && current != ">" && current != "/" {
        let attrQName = try parseName()
        skipSpace(); try expect("="); skipSpace()
        let attrValue = try parseAttrValue()
        let (attrUri, attrLocal) = splitQName(attrQName)
        atts.addAttribute(attrUri, attrLocal, attrQName, "CDATA", attrValue)
        skipSpace()
      }
      let selfClosing = current == "/"
      if selfClosing { advance() }
      try expect(">")
      let (uri, local) = splitQName(qName)
      try contentHandler?.startElement(uri, local, qName, atts)
      if selfClosing { try contentHandler?.endElement(uri, local, qName) }
    }
  }

  // MARK: Character data

  private func parseCharData() throws {
    var chars: [Character] = []
    while pos < src.count && current != "<" {
      let ch = current; advance()
      if ch == "&" { chars.append(contentsOf: try parseEntityRef()) }
      else         { chars.append(Character(ch)) }
    }
    if !chars.isEmpty {
      if chars.allSatisfy({ $0.isWhitespace }) {
        try contentHandler?.ignorableWhitespace(chars, 0, chars.count)
      } else {
        try contentHandler?.characters(chars, 0, chars.count)
      }
    }
  }

  // MARK: Namespace splitting

  private func splitQName(_ qName: String) -> (uri: String, localName: String) {
    guard namespaces else { return ("", "") }
    if let colon = qName.firstIndex(of: ":") {
      let local = String(qName[qName.index(after: colon)...])
      return ("", local) // URI resolution would require xmlns tracking; return empty for now
    }
    return ("", qName)
  }

  // MARK: Helpers (identical to SAX 1.0 engine)

  private func parseName() throws -> String {
    guard pos < src.count, isNameStart(current) else {
      throw saxError("Expected XML name at line \(line), col \(col)")
    }
    var name = ""
    while pos < src.count && isNameChar(current) {
      name.unicodeScalars.append(current); advance()
    }
    return name
  }

  private func parseAttrValue() throws -> String {
    guard pos < src.count, current == "\"" || current == "'" else {
      throw saxError("Expected quote at line \(line), col \(col)")
    }
    let quote = current; advance()
    var value = ""
    while pos < src.count && current != quote {
      if current == "&" { advance(); value += String(try parseEntityRef()) }
      else              { value.unicodeScalars.append(current); advance() }
    }
    try expect(String(Character(quote)))
    return value
  }

  private func parseEntityRef() throws -> [Character] {
    var name = ""
    while pos < src.count && current != ";" { name.unicodeScalars.append(current); advance() }
    try expect(";")
    switch name {
    case "amp":  return ["&"]
    case "lt":   return ["<"]
    case "gt":   return [">"]
    case "apos": return ["'"]
    case "quot": return ["\""]
    default:
      if name.hasPrefix("#x") || name.hasPrefix("#X") {
        let hex = String(name.dropFirst(2))
        if let v = UInt32(hex, radix: 16), let s = Unicode.Scalar(v) { return [Character(s)] }
      } else if name.hasPrefix("#") {
        let dec = String(name.dropFirst())
        if let v = UInt32(dec), let s = Unicode.Scalar(v) { return [Character(s)] }
      }
      return Array("&\(name);")
    }
  }

  private var current: Unicode.Scalar { src[pos] }

  private func advance(_ n: Int = 1) {
    for _ in 0 ..< n {
      guard pos < src.count else { return }
      if src[pos] == "\n" { line += 1; col = 1 } else { col += 1 }
      pos += 1
    }
  }

  private func skipSpace() {
    while pos < src.count && (current == " " || current == "\t" || current == "\n" || current == "\r") { advance() }
  }

  private func startsWith(_ s: String) -> Bool {
    let scalars = Array(s.unicodeScalars)
    guard pos + scalars.count <= src.count else { return false }
    return zip(src[pos ..< pos + scalars.count], scalars).allSatisfy { $0 == $1 }
  }

  private func skipUntil(_ terminator: String) throws {
    let t = Array(terminator.unicodeScalars)
    while pos < src.count {
      if startsWith(terminator) { advance(t.count); return }
      advance()
    }
    throw saxError("Unterminated construct, expected '\(terminator)'")
  }

  private func readUntil(_ terminator: String) throws -> String {
    let t = Array(terminator.unicodeScalars)
    var result = ""
    while pos < src.count {
      if startsWith(terminator) { advance(t.count); return result }
      result.unicodeScalars.append(current); advance()
    }
    throw saxError("Unterminated construct, expected '\(terminator)'")
  }

  private func expect(_ s: String) throws {
    for ch in s.unicodeScalars {
      guard pos < src.count, current == ch else {
        throw saxError("Expected '\(s)' at line \(line), col \(col)")
      }
      advance()
    }
  }

  private func isNameStart(_ s: Unicode.Scalar) -> Bool {
    (s >= "a" && s <= "z") || (s >= "A" && s <= "Z") || s == "_" || s == ":" || s.value > 127
  }
  private func isNameChar(_ s: Unicode.Scalar) -> Bool {
    isNameStart(s) || (s >= "0" && s <= "9") || s == "-" || s == "."
  }

  private func saxError(_ msg: String) -> org.xml.sax.SAXException {
    org.xml.sax.SAXException(msg)
  }
}

#endif // !canImport(Foundation) || non-Apple platforms
