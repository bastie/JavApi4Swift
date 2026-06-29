/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {

  /// Interface for reading an XML document using callbacks (SAX 2.0).
  ///
  /// `XMLReader` is the SAX 2.0 replacement for the deprecated ``Parser`` protocol.
  /// It adds namespace support, feature/property configuration, and a cleaner
  /// handler registration API.
  ///
  /// ### Standard features
  /// - `"http://xml.org/sax/features/namespaces"` — enable namespace processing (default: `true`)
  /// - `"http://xml.org/sax/features/namespace-prefixes"` — report xmlns attributes (default: `false`)
  /// - `"http://xml.org/sax/features/validation"` — request DTD validation (default: `false`)
  ///
  /// - Since: Java 1.4
  /// - Since: SAX 2.0
  public protocol XMLReader {

    // MARK: - Features

    /// Returns the value of the named feature.
    /// - Throws: ``SAXNotRecognizedException`` if the feature is unknown.
    /// - Throws: ``SAXNotSupportedException`` if the feature is known but not readable in this state.
    func getFeature(_ name: String) throws -> Bool

    /// Sets the value of the named feature.
    /// - Throws: ``SAXNotRecognizedException`` if the feature is unknown.
    /// - Throws: ``SAXNotSupportedException`` if the feature cannot be set in this state.
    func setFeature(_ name: String, _ value: Bool) throws

    // MARK: - Properties

    /// Returns the value of the named property.
    /// - Throws: ``SAXNotRecognizedException`` if the property is unknown.
    /// - Throws: ``SAXNotSupportedException`` if the property is known but not readable in this state.
    func getProperty(_ name: String) throws -> Any?

    /// Sets the value of the named property.
    /// - Throws: ``SAXNotRecognizedException`` if the property is unknown.
    /// - Throws: ``SAXNotSupportedException`` if the property cannot be set in this state.
    func setProperty(_ name: String, _ value: Any?) throws

    // MARK: - Handlers

    func setEntityResolver(_ resolver: (any EntityResolver)?)
    func getEntityResolver() -> (any EntityResolver)?

    func setDTDHandler(_ handler: (any DTDHandler)?)
    func getDTDHandler() -> (any DTDHandler)?

    func setContentHandler(_ handler: (any ContentHandler)?)
    func getContentHandler() -> (any ContentHandler)?

    func setErrorHandler(_ handler: (any ErrorHandler)?)
    func getErrorHandler() -> (any ErrorHandler)?

    // MARK: - Parse

    /// Parses an XML document from an ``InputSource``.
    func parse(_ input: InputSource) throws

    /// Parses an XML document from a system identifier (URI).
    func parse(_ systemId: String) throws
  }
}
