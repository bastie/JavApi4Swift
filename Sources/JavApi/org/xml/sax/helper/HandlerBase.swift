/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {

  /// Default (do-nothing) base class for SAX 1.0 event handlers.
  ///
  /// Implements ``org.xml.sax.EntityResolver``, ``org.xml.sax.DTDHandler``,
  /// ``org.xml.sax.DocumentHandler`` and ``org.xml.sax.ErrorHandler`` with
  /// empty default methods so application code only needs to override what it uses.
  ///
  /// SAX 2.0 equivalent is ``DefaultHandler`` in the same package.
  ///
  /// - Since: SAX 1.0
  @available(*, deprecated, renamed: "org.xml.sax.helper.DefaultHandler", message: "Deprecated since SAX 2.0. Use DefaultHandler instead.")
  open class HandlerBase :
    org.xml.sax.EntityResolver,
    org.xml.sax.DTDHandler,
    org.xml.sax.DocumentHandler,
    org.xml.sax.ErrorHandler
  {
    public init() {}

    // MARK: EntityResolver

    /// Always returns `nil` (use default system identifier).
    open func resolveEntity(publicId: String?, systemId: String?) throws -> org.xml.sax.InputSource? {
      return nil
    }

    // MARK: DTDHandler

    /// By default do nothing.
    open func notationDecl(name: String, publicId: String?, systemId: String?) {}

    /// By default do nothing.
    open func unparsedEntityDecl(name: String, publicId: String?, systemId: String?, notationName: String?) {}

    // MARK: DocumentHandler

    /// By default do nothing.
    open func setDocumentLocator(_ locator: any org.xml.sax.Locator) throws(org.xml.sax.SAXException) {}

    /// By default do nothing.
    open func startDocument() throws(org.xml.sax.SAXException) {}

    /// By default do nothing.
    open func endDocument() throws(org.xml.sax.SAXException) {}

    /// By default do nothing.
    open func startElement(_ name: String, _ attributes: any org.xml.sax.AttributeList) throws(org.xml.sax.SAXException) {}

    /// By default do nothing.
    open func endElement(_ name: String) throws(org.xml.sax.SAXException) {}

    /// By default do nothing.
    open func characters(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {}

    /// By default do nothing.
    open func ignorableWhitespace(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {}

    /// By default do nothing.
    open func processingInstruction(_ target: String, _data: String) throws(org.xml.sax.SAXException) {}

    // MARK: ErrorHandler

    /// By default do nothing.
    open func warning(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {}

    /// By default do nothing.
    open func error(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {}

    /// By default re-throws the exception as a fatal error.
    open func fatalError(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {
      throw exception
    }
  }
}
