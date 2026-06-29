/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {

  /// Mutable implementation of the SAX 2.0 ``org.xml.sax.Attributes`` protocol.
  ///
  /// Use this class in ``org.xml.sax.ContentHandler`` implementations to build
  /// or copy attribute lists, and in concrete ``org.xml.sax.XMLReader`` implementations
  /// to pass attributes to `startElement`.
  ///
  /// - Since: Java 1.4
  /// - Since: SAX 2.0
  public final class AttributesImpl : org.xml.sax.Attributes {

    private struct Entry {
      var uri:       String
      var localName: String
      var qName:     String
      var type:      String
      var value:     String
    }

    private var entries: [Entry] = []

    // MARK: - Init

    /// Creates an empty attribute list.
    public init() {}

    /// Creates a copy of `other`.
    public init(_ other: any org.xml.sax.Attributes) {
      for i in 0 ..< other.getLength() {
        entries.append(Entry(
          uri:       other.getURI(i)       ?? "",
          localName: other.getLocalName(i) ?? "",
          qName:     other.getQName(i)     ?? "",
          type:      other.getType(i)      ?? "CDATA",
          value:     other.getValue(i)     ?? ""
        ))
      }
    }

    // MARK: - Mutation

    /// Appends a new attribute.
    public func addAttribute(_ uri: String, _ localName: String, _ qName: String,
                              _ type: String, _ value: String) {
      entries.append(Entry(uri: uri, localName: localName, qName: qName,
                           type: type, value: value))
    }

    /// Replaces the attribute at `index`.
    public func setAttribute(_ index: Int, _ uri: String, _ localName: String,
                               _ qName: String, _ type: String, _ value: String) {
      guard index >= 0 && index < entries.count else { return }
      entries[index] = Entry(uri: uri, localName: localName, qName: qName,
                              type: type, value: value)
    }

    /// Removes the attribute at `index`.
    public func removeAttribute(_ index: Int) {
      guard index >= 0 && index < entries.count else { return }
      entries.remove(at: index)
    }

    /// Sets the URI of the attribute at `index`.
    public func setURI(_ index: Int, _ uri: String) {
      guard index >= 0 && index < entries.count else { return }
      entries[index].uri = uri
    }

    /// Sets the local name of the attribute at `index`.
    public func setLocalName(_ index: Int, _ localName: String) {
      guard index >= 0 && index < entries.count else { return }
      entries[index].localName = localName
    }

    /// Sets the qualified name of the attribute at `index`.
    public func setQName(_ index: Int, _ qName: String) {
      guard index >= 0 && index < entries.count else { return }
      entries[index].qName = qName
    }

    /// Sets the type of the attribute at `index`.
    public func setType(_ index: Int, _ type: String) {
      guard index >= 0 && index < entries.count else { return }
      entries[index].type = type
    }

    /// Sets the value of the attribute at `index`.
    public func setValue(_ index: Int, _ value: String) {
      guard index >= 0 && index < entries.count else { return }
      entries[index].value = value
    }

    /// Removes all attributes.
    public func clear() {
      entries.removeAll()
    }

    // MARK: - org.xml.sax.Attributes

    public func getLength() -> Int { entries.count }

    public func getURI(_ index: Int) -> String? {
      guard index >= 0 && index < entries.count else { return nil }
      return entries[index].uri
    }

    public func getLocalName(_ index: Int) -> String? {
      guard index >= 0 && index < entries.count else { return nil }
      return entries[index].localName
    }

    public func getQName(_ index: Int) -> String? {
      guard index >= 0 && index < entries.count else { return nil }
      return entries[index].qName
    }

    public func getType(_ index: Int) -> String? {
      guard index >= 0 && index < entries.count else { return nil }
      return entries[index].type
    }

    public func getValue(_ index: Int) -> String? {
      guard index >= 0 && index < entries.count else { return nil }
      return entries[index].value
    }

    public func getIndex(_ uri: String, _ localName: String) -> Int {
      entries.firstIndex(where: { $0.uri == uri && $0.localName == localName }) ?? -1
    }

    public func getType(_ uri: String, _ localName: String) -> String? {
      let i = getIndex(uri, localName)
      return i >= 0 ? entries[i].type : nil
    }

    public func getValue(_ uri: String, _ localName: String) -> String? {
      let i = getIndex(uri, localName)
      return i >= 0 ? entries[i].value : nil
    }

    public func getIndex(_ qName: String) -> Int {
      entries.firstIndex(where: { $0.qName == qName }) ?? -1
    }

    public func getType(_ qName: String) -> String? {
      let i = getIndex(qName)
      return i >= 0 ? entries[i].type : nil
    }

    public func getValue(_ qName: String) -> String? {
      let i = getIndex(qName)
      return i >= 0 ? entries[i].value : nil
    }
  }
}
