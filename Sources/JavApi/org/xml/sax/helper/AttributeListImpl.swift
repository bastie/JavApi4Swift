/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {

  /// Concrete, mutable implementation of ``org.xml.sax.AttributeList`` for SAX 1.0.
  ///
  /// Parser authors may use this class to provide an ``org.xml.sax.AttributeList``
  /// to the application. When re-using the object between elements, call
  /// ``clear()`` first, then build the list with ``addAttribute(_:_:_:)``.
  ///
  /// - Since: SAX 1.0
  @available(*, deprecated, renamed: "org.xml.sax.helper.AttributesImpl", message: "Deprecated since SAX 2.0. Use AttributesImpl instead.")
  public final class AttributeListImpl : org.xml.sax.AttributeList, @unchecked Sendable {

    private struct Entry {
      let name: String
      let type: String
      let value: String
    }

    private var entries: [Entry] = []

    /// Create an empty attribute list.
    public init() {}

    /// Create a copy of an existing attribute list.
    public init(_ atts: any org.xml.sax.AttributeList) {
      for i in 0 ..< atts.getLength() {
        if let name = atts.getName(i),
           let type = atts.getType(i),
           let value = atts.getValue(i) {
          entries.append(Entry(name: name, type: type, value: value))
        }
      }
    }

    // MARK: - Mutation

    /// Remove all attributes.
    public func clear() {
      entries.removeAll()
    }

    /// Add an attribute to the end of the list.
    /// - Parameters:
    ///   - name: attribute name (non-qualified)
    ///   - type: attribute type (`"CDATA"`, `"ID"`, …)
    ///   - value: attribute value
    public func addAttribute(_ name: String, _ type: String, _ value: String) {
      entries.append(Entry(name: name, type: type, value: value))
    }

    /// Remove the attribute with the given name (first occurrence).
    public func removeAttribute(_ name: String) {
      if let idx = entries.firstIndex(where: { $0.name == name }) {
        entries.remove(at: idx)
      }
    }

    // MARK: - AttributeList

    public func getLength() -> Int {
      return entries.count
    }

    public func getName(_ i: Int) -> String? {
      guard i >= 0 && i < entries.count else { return nil }
      return entries[i].name
    }

    public func getType(_ i: Int) -> String? {
      guard i >= 0 && i < entries.count else { return nil }
      return entries[i].type
    }

    public func getType(_ name: String) -> String? {
      return entries.first(where: { $0.name == name })?.type
    }

    public func getValue(_ i: Int) -> String? {
      guard i >= 0 && i < entries.count else { return nil }
      return entries[i].value
    }

    public func getValue(_ name: String) -> String? {
      return entries.first(where: { $0.name == name })?.value
    }
  }
}
