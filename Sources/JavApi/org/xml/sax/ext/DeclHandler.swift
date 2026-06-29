/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.ext {

  /// SAX 2.0 extension handler for DTD declaration events.
  ///
  /// Receives events for element type, attribute list, internal entity,
  /// and external entity declarations found in the DTD.
  ///
  /// Register via `XMLReader.setProperty`:
  /// ```swift
  /// try reader.setProperty(
  ///   "http://xml.org/sax/properties/declaration-handler",
  ///   myDeclHandler)
  /// ```
  ///
  /// - Since: Java 1.4
  /// - Since: SAX 2.0 ext
  public protocol DeclHandler {

    /// Reports an element type declaration.
    /// - Parameters:
    ///   - name: The element type name.
    ///   - model: The content model as a normalised string, e.g. `"(a|b)*"` or `"EMPTY"`.
    func elementDecl(_ name: String, _ model: String) throws(org.xml.sax.SAXException)

    /// Reports an attribute type declaration.
    /// - Parameters:
    ///   - eName: The element type name.
    ///   - aName: The attribute name.
    ///   - type: The attribute type as a string, e.g. `"CDATA"`, `"ID"`, `"(a|b)"`.
    ///   - mode: The attribute default mode: `"#IMPLIED"`, `"#REQUIRED"`, `"#FIXED"`, or `nil`.
    ///   - value: The default value, or `nil` if none.
    func attributeDecl(_ eName: String, _ aName: String, _ type: String,
                        _ mode: String?, _ value: String?) throws(org.xml.sax.SAXException)

    /// Reports an internal entity declaration.
    /// - Parameters:
    ///   - name: The entity name.
    ///   - value: The replacement text.
    func internalEntityDecl(_ name: String, _ value: String) throws(org.xml.sax.SAXException)

    /// Reports a parsed external entity declaration.
    /// - Parameters:
    ///   - name: The entity name.
    ///   - publicId: The public identifier, or `nil` if none.
    ///   - systemId: The system identifier.
    func externalEntityDecl(_ name: String, _ publicId: String?,
                             _ systemId: String) throws(org.xml.sax.SAXException)
  }
}
