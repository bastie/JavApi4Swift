/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: Java 1.4
  /// - Since: SAX 1.0
  public protocol ContentHandler {
    /// - Since: Java 1.4
    func setDocumentLocator(_ locator: Locator) throws (SAXException)
    /// - Since: Java 1.4
    func startDocument() throws (SAXException)
    /// Default implementation do nothing
    /// - Since: Java 14
    func declaration( _ version: String?, _ encoding: String?, _ standalone: String?) throws (SAXException)
    /// - Since: Java 1.4
    func endDocument() throws (SAXException)
    /// - Since: Java 1.4
    func startPrefixMapping(_ prefix: String, _ uri: String) throws (SAXException)
    /// - Since: Java 1.4
    func endPrefixMapping(_ prefix: String) throws (SAXException)
    /// - Since: Java 1.4
    func startElement(_ uri: String, _ localName: String, _ qName: String, _ attributes: [String: String]) throws (SAXException)
    /// - Since: Java 1.4
    func endElement(_ uri: String, _ localName: String, _ qName: String) throws (SAXException)
    /// - Since: Java 1.4
    func characters(_ ch: [Character], _ start : Int, length: Int) throws (SAXException)
    /// - Since: Java 1.4
    func ignorableWhitespace(_ ch: [Character], _ start: Int, _ length: Int) throws (SAXException)
    /// - Since: Java 1.4
    func processingInstruction(_ target: String, _data: String) throws (SAXException)
    /// - Since: Java 1.4
    func skippedEntity(_ name: String) throws (SAXException)
  }
  
}
// MARK: Default implementation doc declaration
extension org.xml.sax.ContentHandler {
  
  public func declaration( _ version: String?, _ encoding: String?, _ standalone: String?) throws (org.xml.sax.SAXException) {
    // time to do ... - brew coffee and eat pizza
  }
}
