/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

#if !canImport(Foundation) || !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))

/// A minimal SAX 1.0 ``org.xml.sax.Parser`` implemented in pure Swift.
///
/// > Note: **This class is a JavApi4Swift extension — it has no equivalent in the
/// > original Java API.**
///
/// This implementation is used on platforms where Foundation's `XMLParser` is not
/// available (e.g. WASM). It handles well-formed XML documents with:
/// - Elements with attributes (both single- and double-quoted values)
/// - Text content (character data)
/// - Processing instructions
/// - XML and DOCTYPE declarations (silently skipped)
/// - Comments (silently skipped)
/// - CDATA sections (content forwarded as characters)
///
/// It does **not** validate DTDs, resolve external entities, or support namespaces.
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
    let xml: String
    if let byteStream = source.getByteStream() {
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
    } else if let charReader = source.getCharacterStream() {
      var result = ""
      var cbuf = [Character](repeating: Character("\0"), count: 4096)
      var n = try charReader.read(&cbuf, 0, cbuf.count)
      while n > 0 {
        result += String(cbuf[0 ..< n])
        n = try charReader.read(&cbuf, 0, cbuf.count)
      }
      xml = result
    } else if let systemId = source.getSystemId() {
      throw org.xml.sax.SAXException("systemId resolution not available on this platform: \(systemId)")
    } else {
      throw org.xml.sax.SAXException("InputSource has no usable content")
    }
    let engine = _PureSAX1Engine(xml: xml,
                                  documentHandler: documentHandler,
                                  errorHandler: errorHandler,
                                  dtdHandler: dtdHandler)
    try engine.parse()
  }

  public func parse(_ systemId: String) throws {
    try parse(org.xml.sax.InputSource(systemId))
  }
}

// MARK: - Pure-Swift SAX engine

private final class _PureSAX1Engine {

  private let src: [Unicode.Scalar]
  private var pos: Int = 0
  private var line: Int = 1
  private var col: Int  = 1

  private let documentHandler: (any org.xml.sax.DocumentHandler)?
  private let errorHandler:    (any org.xml.sax.ErrorHandler)?
  private let dtdHandler:      (any org.xml.sax.DTDHandler)?

  init(xml: String,
       documentHandler: (any org.xml.sax.DocumentHandler)?,
       errorHandler:    (any org.xml.sax.ErrorHandler)?,
       dtdHandler:      (any org.xml.sax.DTDHandler)?) {
    self.src             = Array(xml.unicodeScalars)
    self.documentHandler = documentHandler
    self.errorHandler    = errorHandler
    self.dtdHandler      = dtdHandler
  }

  // MARK: - Entry

  func parse() throws {
    try documentHandler?.startDocument()
    while pos < src.count {
      if current == "<" {
        try parseMarkup()
      } else {
        try parseCharData()
      }
    }
    try documentHandler?.endDocument()
  }

  // MARK: - Markup dispatcher

  private func parseMarkup() throws {
    advance() // consume '<'
    guard pos < src.count else { throw saxError("Unexpected end after '<'") }

    if current == "/" {
      // end tag
      advance()
      let name = try parseName()
      skipSpace()
      try expect(">")
      try documentHandler?.endElement(name)

    } else if current == "!" {
      advance()
      if startsWith("--") {
        // comment
        advance(2)
        try skipUntil("-->")
      } else if startsWith("[CDATA[") {
        // CDATA section
        advance(7)
        let text = try readUntil("]]>")
        let chars = Array(text)
        if !chars.isEmpty {
          try documentHandler?.characters(chars, 0, chars.count)
        }
      } else {
        // DOCTYPE or other declaration — skip to '>'
        try skipUntil(">")
      }
    } else if current == "?" {
      // processing instruction or XML declaration
      advance()
      let target = try parseName()
      skipSpace()
      let data = try readUntil("?>").trimmingCharacters(in: .whitespaces)
      if target.lowercased() != "xml" {
        try documentHandler?.processingInstruction(target, _data: data)
      }
    } else {
      // start tag
      let name = try parseName()
      skipSpace()
      let atts = org.xml.sax.helper.AttributeListImpl()
      while pos < src.count && current != ">" && current != "/" {
        let attrName = try parseName()
        skipSpace()
        try expect("=")
        skipSpace()
        let attrValue = try parseAttrValue()
        atts.addAttribute(attrName, "CDATA", attrValue)
        skipSpace()
      }
      let selfClosing = current == "/"
      if selfClosing { advance() }
      try expect(">")
      try documentHandler?.startElement(name, atts)
      if selfClosing {
        try documentHandler?.endElement(name)
      }
    }
  }

  // MARK: - Character data

  private func parseCharData() throws {
    var chars: [Character] = []
    while pos < src.count && current != "<" {
      let ch = current
      advance()
      if ch == "&" {
        let unescaped = try parseEntityRef()
        chars.append(contentsOf: unescaped)
      } else {
        chars.append(Character(ch))
      }
    }
    if !chars.isEmpty {
      // Determine whether this is all whitespace (ignorable)
      let allWhite = chars.allSatisfy { $0.isWhitespace }
      if allWhite {
        try documentHandler?.ignorableWhitespace(chars, 0, chars.count)
      } else {
        try documentHandler?.characters(chars, 0, chars.count)
      }
    }
  }

  // MARK: - Name parsing

  private func parseName() throws -> String {
    guard pos < src.count, isNameStart(current) else {
      throw saxError("Expected XML name at line \(line), col \(col)")
    }
    var name = ""
    while pos < src.count && isNameChar(current) {
      name.unicodeScalars.append(current)
      advance()
    }
    return name
  }

  // MARK: - Attribute value

  private func parseAttrValue() throws -> String {
    guard pos < src.count, current == "\"" || current == "'" else {
      throw saxError("Expected quote around attribute value at line \(line), col \(col)")
    }
    let quote = current
    advance()
    var value = ""
    while pos < src.count && current != quote {
      if current == "&" {
        advance()
        let unescaped = try parseEntityRef()
        value += String(unescaped)
      } else {
        value.unicodeScalars.append(current)
        advance()
      }
    }
    try expect(String(Character(quote)))
    return value
  }

  // MARK: - Entity references

  private func parseEntityRef() throws -> [Character] {
    var name = ""
    while pos < src.count && current != ";" {
      name.unicodeScalars.append(current)
      advance()
    }
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
        if let val = UInt32(hex, radix: 16), let scalar = Unicode.Scalar(val) {
          return [Character(scalar)]
        }
      } else if name.hasPrefix("#") {
        let dec = String(name.dropFirst())
        if let val = UInt32(dec), let scalar = Unicode.Scalar(val) {
          return [Character(scalar)]
        }
      }
      // Unknown entity — pass through literally
      return Array("&\(name);")
    }
  }

  // MARK: - Helpers

  private var current: Unicode.Scalar { src[pos] }

  private func advance(_ n: Int = 1) {
    for _ in 0 ..< n {
      guard pos < src.count else { return }
      if src[pos] == "\n" { line += 1; col = 1 } else { col += 1 }
      pos += 1
    }
  }

  private func skipSpace() {
    while pos < src.count && (current == " " || current == "\t" || current == "\n" || current == "\r") {
      advance()
    }
  }

  private func startsWith(_ s: String) -> Bool {
    let scalars = Array(s.unicodeScalars)
    guard pos + scalars.count <= src.count else { return false }
    return zip(src[pos ..< pos + scalars.count], scalars).allSatisfy { $0 == $1 }
  }

  /// Reads (and discards) everything up to and including `terminator`.
  private func skipUntil(_ terminator: String) throws {
    let t = Array(terminator.unicodeScalars)
    while pos < src.count {
      if startsWith(terminator) { advance(t.count); return }
      advance()
    }
    throw saxError("Unterminated construct, expected '\(terminator)'")
  }

  /// Reads everything up to (but not including) `terminator`, then consumes the terminator.
  private func readUntil(_ terminator: String) throws -> String {
    let t = Array(terminator.unicodeScalars)
    var result = ""
    while pos < src.count {
      if startsWith(terminator) { advance(t.count); return result }
      result.unicodeScalars.append(current)
      advance()
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

// MARK: - String.CharacterView.allSatisfy shim
// (already available in Swift stdlib — no shim needed)

#endif // !canImport(Foundation) || non-Apple platforms
