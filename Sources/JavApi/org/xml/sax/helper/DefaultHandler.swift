/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {
  
  /// A **do nothing** implementation or call it like java.awt.event an *Adapter*.
  /// - Since: Java 1.4
  /// - Since: SAX 2.0
  open class DefaultHandler : org.xml.sax.EntityResolver, org.xml.sax.DTDHandler, org.xml.sax.ErrorHandler, org.xml.sax.ContentHandler {
    // MARK: EntityResolver implementation
    
    /// Allways return nil
    open func resolveEntity(publicId: String?, systemId: String?) throws -> org.xml.sax.InputSource? {
      return nil
    }
    // MARK: DTDHandler implementation
    
    /// by default do nothing
    open func notationDecl(name: String, publicId: String?, systemId: String?) {}
    
    // by default do nothing
    open func unparsedEntityDecl(name: String, publicId: String?, systemId: String?, notationName: String?) {}
    
    // MARK: Error Handler implementation
    
    /// by default do nothing
    open func warning(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func error(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func fatalError(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {}
    
    // MARK: Content Handler implementation
    
    /// by default do nothing
    open func setDocumentLocator(_ locator: any org.xml.sax.Locator) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func startDocument() throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func endDocument() throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func startPrefixMapping(_ prefix: String, _ uri: String) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func endPrefixMapping(_ prefix: String) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func startElement(_ uri: String, _ localName: String, _ qName: String, _ attributes: [String : String]) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func endElement(_ uri: String, _ localName: String, _ qName: String) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func characters(_ ch: [Character], _ start: Int, length: Int) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func ignorableWhitespace(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func processingInstruction(_ target: String, _data: String) throws(org.xml.sax.SAXException) {}
    
    /// by default do nothing
    open func skippedEntity(_ name: String) throws(org.xml.sax.SAXException) {}
    
  }
}
