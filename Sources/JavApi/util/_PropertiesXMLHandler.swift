/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - Foundation XMLParser delegate for loadFromXML

/// SAX-style delegate that collects `<entry key="…">…</entry>` pairs from a
/// Java-format properties XML document. Foundation's `XMLParser` handles all
/// entity decoding and encoding detection automatically.
internal final class _PropertiesXMLHandler: NSObject, XMLParserDelegate, @unchecked Sendable {
  
  /// Collected key-value pairs after a successful parse.
  var entries: [String: String] = [:]
  
  private var currentKey: String?
  private var currentValue: String = ""
  private var insideEntry: Bool = false
  
  func parser(
    _ parser: Foundation.XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName _: String?,
    attributes: [String: String] = [:]
  ) {
    if elementName == "entry", let key = attributes["key"] {
      currentKey = key
      currentValue = ""
      insideEntry = true
    }
  }
  
  func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
    if insideEntry { currentValue += string }
  }
  
  func parser(
    _ parser: Foundation.XMLParser,
    didEndElement elementName: String,
    namespaceURI _: String?,
    qualifiedName _: String?
  ) {
    if elementName == "entry", let key = currentKey {
      entries[key] = currentValue
      currentKey = nil
      currentValue = ""
      insideEntry = false
    }
  }
}
