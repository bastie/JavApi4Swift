/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.ext {

  /// SAX 2.0 extension handler for lexical events.
  ///
  /// Receives events for constructs that are not part of the document's
  /// logical content: comments, CDATA sections, DTD boundaries, and
  /// general entity boundaries.
  ///
  /// Register via `XMLReader.setProperty`:
  /// ```swift
  /// try reader.setProperty(
  ///   "http://xml.org/sax/properties/lexical-handler",
  ///   myLexicalHandler)
  /// ```
  ///
  /// - Since: Java 1.4
  /// - Since: SAX 2.0 ext
  public protocol LexicalHandler {

    /// Reports the start of DTD declarations.
    /// - Parameters:
    ///   - name: The document type name.
    ///   - publicId: The public identifier, or `nil` if none.
    ///   - systemId: The system identifier, or `nil` if none.
    func startDTD(_ name: String, _ publicId: String?, _ systemId: String?) throws(org.xml.sax.SAXException)

    /// Reports the end of DTD declarations.
    func endDTD() throws(org.xml.sax.SAXException)

    /// Reports the beginning of an entity.
    /// - Parameter name: The entity name. `[dtd]` for the DTD entity,
    ///   `[xml]` for the XML declaration pseudo-entity.
    func startEntity(_ name: String) throws(org.xml.sax.SAXException)

    /// Reports the end of an entity.
    func endEntity(_ name: String) throws(org.xml.sax.SAXException)

    /// Reports the start of a CDATA section.
    func startCDATA() throws(org.xml.sax.SAXException)

    /// Reports the end of a CDATA section.
    func endCDATA() throws(org.xml.sax.SAXException)

    /// Reports an XML comment anywhere in the document.
    func comment(_ ch: [Character], _ start: Int, _ length: Int) throws(org.xml.sax.SAXException)
  }
}
