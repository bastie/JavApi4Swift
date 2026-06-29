/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {

  /// Extension of ``DefaultHandler`` that also implements the SAX 2.0 extension
  /// handler interfaces ``org.xml.sax.ext.LexicalHandler`` and
  /// ``org.xml.sax.ext.DeclHandler`` with no-op defaults.
  ///
  /// Subclass this instead of ``DefaultHandler`` when you want to intercept
  /// lexical events (comments, CDATA sections, entity boundaries, DTD boundaries)
  /// or DTD declaration events without implementing every method yourself.
  ///
  /// ### Registration
  /// ```swift
  /// let handler = MyHandler()
  /// reader.setContentHandler(handler)
  /// try reader.setProperty("http://xml.org/sax/properties/lexical-handler", handler)
  /// try reader.setProperty("http://xml.org/sax/properties/declaration-handler", handler)
  /// ```
  ///
  /// - Since: Java 1.5
  /// - Since: SAX 2.0 ext
  open class DefaultHandler2 : DefaultHandler,
                                org.xml.sax.ext.LexicalHandler,
                                org.xml.sax.ext.DeclHandler {

    public override init() {}

    // MARK: - LexicalHandler (no-op defaults)

    /// By default does nothing.
    open func startDTD(_ name: String, _ publicId: String?,
                        _ systemId: String?) throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func endDTD() throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func startEntity(_ name: String) throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func endEntity(_ name: String) throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func startCDATA() throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func endCDATA() throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func comment(_ ch: [Character], _ start: Int,
                       _ length: Int) throws(org.xml.sax.SAXException) {}

    // MARK: - DeclHandler (no-op defaults)

    /// By default does nothing.
    open func elementDecl(_ name: String,
                           _ model: String) throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func attributeDecl(_ eName: String, _ aName: String, _ type: String,
                             _ mode: String?,
                             _ value: String?) throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func internalEntityDecl(_ name: String,
                                  _ value: String) throws(org.xml.sax.SAXException) {}

    /// By default does nothing.
    open func externalEntityDecl(_ name: String, _ publicId: String?,
                                  _ systemId: String) throws(org.xml.sax.SAXException) {}
  }
}
