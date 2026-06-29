/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {

  /// Interface for a list of XML attributes in SAX 2.0.
  ///
  /// Replaces the deprecated SAX 1.0 ``AttributeList`` protocol.
  /// An instance is supplied to ``ContentHandler/startElement(_:_:_:_:)``
  /// and is only valid for the duration of that callback.
  ///
  /// Attribute types returned by `getType` are one of the strings
  /// `"CDATA"`, `"ID"`, `"IDREF"`, `"IDREFS"`, `"NMTOKEN"`, `"NMTOKENS"`,
  /// `"ENTITY"`, `"ENTITIES"`, or `"NOTATION"`.
  ///
  /// - Since: Java 1.4
  /// - Since: SAX 2.0
  public protocol Attributes {

    // MARK: - Count

    /// Returns the number of attributes in the list.
    func getLength() -> Int

    // MARK: - Access by index

    /// Returns the namespace URI of the attribute at `index`, or `nil` if none.
    func getURI(_ index: Int) -> String?

    /// Returns the local name (without prefix) of the attribute at `index`, or `nil`.
    func getLocalName(_ index: Int) -> String?

    /// Returns the qualified name (with prefix) of the attribute at `index`, or `nil`.
    func getQName(_ index: Int) -> String?

    /// Returns the type of the attribute at `index`, or `nil`.
    func getType(_ index: Int) -> String?

    /// Returns the value of the attribute at `index`, or `nil`.
    func getValue(_ index: Int) -> String?

    // MARK: - Lookup by namespace

    /// Returns the index of the attribute with the given namespace URI and local name, or -1.
    func getIndex(_ uri: String, _ localName: String) -> Int

    /// Returns the type of the attribute with the given namespace URI and local name, or `nil`.
    func getType(_ uri: String, _ localName: String) -> String?

    /// Returns the value of the attribute with the given namespace URI and local name, or `nil`.
    func getValue(_ uri: String, _ localName: String) -> String?

    // MARK: - Lookup by qualified name

    /// Returns the index of the attribute with the given qualified name, or -1.
    func getIndex(_ qName: String) -> Int

    /// Returns the type of the attribute with the given qualified name, or `nil`.
    func getType(_ qName: String) -> String?

    /// Returns the value of the attribute with the given qualified name, or `nil`.
    func getValue(_ qName: String) -> String?
  }
}
