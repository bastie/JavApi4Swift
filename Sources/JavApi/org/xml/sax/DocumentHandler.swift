/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  @available(*, deprecated, renamed: "ContentHandler", message: "Deprecated since Java 5. Use ContentHandler instead")
  public protocol DocumentHandler {
    func startDocument() throws (SAXException)
    func endDocument() throws (SAXException)
    func startElement(_ name: String, _ attributes: [String: String]) throws (SAXException)
    func endElement(_ name: String) throws (SAXException)
    func characters(_ ch: [Character], _ start : Int, _ length: Int) throws (SAXException)
    func ignorableWhitespace(_ ch: [Character], _ start: Int, _ length: Int) throws (SAXException)
    func processingInstruction(_ target: String, _data: String) throws (SAXException)
    func setDocumentLocator(_ locator: Locator) throws (SAXException)
  }
}
