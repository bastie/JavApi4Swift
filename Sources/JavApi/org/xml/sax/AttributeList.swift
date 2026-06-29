/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {

  /// Interface for an element's attribute specifications in SAX 1.0.
  ///
  /// Passed to ``DocumentHandler/startElement(_:_:)`` during parsing.
  /// Replaced by ``Attributes`` in SAX 2.0.
  ///
  /// - Since: SAX 1.0
  @available(*, deprecated, renamed: "Attributes", message: "Deprecated since SAX 2.0. Use Attributes instead.")
  public protocol AttributeList {

    /// Return the number of attributes in this list.
    func getLength() -> Int

    /// Return the name of an attribute in this list (by position).
    /// - Parameter i: 0-based index; returns `nil` if out of range
    func getName(_ i: Int) -> String?

    /// Return the type of an attribute in this list (by position).
    ///
    /// Common values: `"CDATA"`, `"ID"`, `"IDREF"`, `"IDREFS"`,
    /// `"NMTOKEN"`, `"NMTOKENS"`, `"ENTITY"`, `"ENTITIES"`, `"NOTATION"`.
    /// - Parameter i: 0-based index; returns `nil` if out of range
    func getType(_ i: Int) -> String?

    /// Return the type of an attribute in this list (by name).
    /// - Parameter name: attribute name; returns `nil` if not found
    func getType(_ name: String) -> String?

    /// Return the value of an attribute in this list (by position).
    /// - Parameter i: 0-based index; returns `nil` if out of range
    func getValue(_ i: Int) -> String?

    /// Return the value of an attribute in this list (by name).
    /// - Parameter name: attribute name; returns `nil` if not found
    func getValue(_ name: String) -> String?
  }
}
