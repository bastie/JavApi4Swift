/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {

  /// Base implementation of ``org.xml.sax.XMLFilter`` that passes all events
  /// through to a parent ``org.xml.sax.XMLReader`` unchanged.
  ///
  /// Subclass this and override only the methods whose events you want to
  /// intercept or transform. All unoverridden methods forward directly to
  /// the parent reader or to the registered handlers.
  ///
  /// - Since: Java 1.4
  /// - Since: SAX 2.0
  open class XMLFilterImpl : org.xml.sax.XMLFilter,
                              org.xml.sax.ContentHandler,
                              org.xml.sax.DTDHandler,
                              org.xml.sax.EntityResolver,
                              org.xml.sax.ErrorHandler {

    private var parent:          (any org.xml.sax.XMLReader)?
    private var contentHandler:  (any org.xml.sax.ContentHandler)?
    private var dtdHandler:      (any org.xml.sax.DTDHandler)?
    private var entityResolver:  (any org.xml.sax.EntityResolver)?
    private var errorHandler:    (any org.xml.sax.ErrorHandler)?

    public init() {}

    public init(parent: any org.xml.sax.XMLReader) {
      self.parent = parent
    }

    // MARK: - XMLFilter

    open func setParent(_ parent: (any org.xml.sax.XMLReader)?) { self.parent = parent }
    open func getParent() -> (any org.xml.sax.XMLReader)?       { parent }

    // MARK: - XMLReader: features & properties

    open func getFeature(_ name: String) throws(org.xml.sax.SAXNotRecognizedException) -> Bool {
      guard let p = parent else {
        throw org.xml.sax.SAXNotRecognizedException("No parent reader set")
      }
      return try p.getFeature(name)
    }

    open func setFeature(_ name: String, _ value: Bool) throws(org.xml.sax.SAXNotRecognizedException) {
      guard let p = parent else {
        throw org.xml.sax.SAXNotRecognizedException("No parent reader set")
      }
      try p.setFeature(name, value)
    }

    open func getProperty(_ name: String) throws(org.xml.sax.SAXException) -> Any? {
      guard let p = parent else {
        throw org.xml.sax.SAXNotRecognizedException("No parent reader set")
      }
      return try p.getProperty(name)
    }

    open func setProperty(_ name: String, _ value: Any?) throws(org.xml.sax.SAXException) {
      guard let p = parent else {
        throw org.xml.sax.SAXNotRecognizedException("No parent reader set")
      }
      try p.setProperty(name, value)
    }

    // MARK: - XMLReader: handlers

    open func setEntityResolver(_ resolver: (any org.xml.sax.EntityResolver)?) {
      self.entityResolver = resolver
      parent?.setEntityResolver(resolver)
    }
    open func getEntityResolver() -> (any org.xml.sax.EntityResolver)? { entityResolver }

    open func setDTDHandler(_ handler: (any org.xml.sax.DTDHandler)?) {
      self.dtdHandler = handler
      parent?.setDTDHandler(handler)
    }
    open func getDTDHandler() -> (any org.xml.sax.DTDHandler)? { dtdHandler }

    open func setContentHandler(_ handler: (any org.xml.sax.ContentHandler)?) {
      self.contentHandler = handler
      parent?.setContentHandler(self) // filter sits between parent and app handler
    }
    open func getContentHandler() -> (any org.xml.sax.ContentHandler)? { contentHandler }

    open func setErrorHandler(_ handler: (any org.xml.sax.ErrorHandler)?) {
      self.errorHandler = handler
      parent?.setErrorHandler(handler)
    }
    open func getErrorHandler() -> (any org.xml.sax.ErrorHandler)? { errorHandler }

    // MARK: - XMLReader: parse

    open func parse(_ input: org.xml.sax.InputSource) throws {
      guard let p = parent else {
        throw org.xml.sax.SAXException("No parent reader set")
      }
      setupParent()
      try p.parse(input)
    }

    open func parse(_ systemId: String) throws {
      try parse(org.xml.sax.InputSource(systemId))
    }

    /// Wires this filter as the parent's content handler so events flow through.
    private func setupParent() {
      parent?.setContentHandler(self)
      if let er = entityResolver { parent?.setEntityResolver(er) }
      if let dh = dtdHandler     { parent?.setDTDHandler(dh) }
      if let eh = errorHandler   { parent?.setErrorHandler(eh) }
    }

    // MARK: - ContentHandler (forward to app handler)

    open func setDocumentLocator(_ locator: any org.xml.sax.Locator) throws(org.xml.sax.SAXException) {
      try contentHandler?.setDocumentLocator(locator)
    }
    open func startDocument() throws(org.xml.sax.SAXException) {
      try contentHandler?.startDocument()
    }
    open func endDocument() throws(org.xml.sax.SAXException) {
      try contentHandler?.endDocument()
    }
    open func startPrefixMapping(_ prefix: String, _ uri: String) throws(org.xml.sax.SAXException) {
      try contentHandler?.startPrefixMapping(prefix, uri)
    }
    open func endPrefixMapping(_ prefix: String) throws(org.xml.sax.SAXException) {
      try contentHandler?.endPrefixMapping(prefix)
    }
    open func startElement(_ uri: String, _ localName: String, _ qName: String,
                            _ attributes: any org.xml.sax.Attributes) throws(org.xml.sax.SAXException) {
      try contentHandler?.startElement(uri, localName, qName, attributes)
    }
    open func endElement(_ uri: String, _ localName: String, _ qName: String) throws(org.xml.sax.SAXException) {
      try contentHandler?.endElement(uri, localName, qName)
    }
    open func characters(_ ch: [Character], _ start: Int, length: Int) throws(org.xml.sax.SAXException) {
      try contentHandler?.characters(ch, start, length: length)
    }
    open func ignorableWhitespace(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException) {
      try contentHandler?.ignorableWhitespace(ch, start, length)
    }
    open func processingInstruction(_ target: String, _data: String) throws(org.xml.sax.SAXException) {
      try contentHandler?.processingInstruction(target, _data: _data)
    }
    open func skippedEntity(_ name: String) throws(org.xml.sax.SAXException) {
      try contentHandler?.skippedEntity(name)
    }

    // MARK: - DTDHandler (forward)

    open func notationDecl(name: String, publicId: String?, systemId: String?) {
      dtdHandler?.notationDecl(name: name, publicId: publicId, systemId: systemId)
    }
    open func unparsedEntityDecl(name: String, publicId: String?, systemId: String?, notationName: String?) {
      dtdHandler?.unparsedEntityDecl(name: name, publicId: publicId,
                                      systemId: systemId, notationName: notationName)
    }

    // MARK: - EntityResolver (forward)

    open func resolveEntity(publicId: String?, systemId: String?) throws -> org.xml.sax.InputSource? {
      try entityResolver?.resolveEntity(publicId: publicId, systemId: systemId)
    }

    // MARK: - ErrorHandler (forward)

    open func warning(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {
      try errorHandler?.warning(exception)
    }
    open func error(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {
      try errorHandler?.error(exception)
    }
    open func fatalError(_ exception: org.xml.sax.SAXParseException) throws(org.xml.sax.SAXException) {
      try errorHandler?.fatalError(exception)
    }
  }
}
