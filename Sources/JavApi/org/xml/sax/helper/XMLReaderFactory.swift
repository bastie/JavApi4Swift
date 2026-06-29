/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {

  /// Factory for creating SAX 2.0 ``org.xml.sax.XMLReader`` instances.
  ///
  /// The SAX 2.0 replacement for the deprecated ``ParserFactory``.
  ///
  /// By default ``JavApiXMLReader`` is registered under ``defaultReaderName``.
  /// Swap it out by replacing the entry in ``registeredReaders``:
  /// ```swift
  /// await MainActor.run {
  ///   org.xml.sax.helper.XMLReaderFactory.registeredReaders[
  ///     org.xml.sax.helper.XMLReaderFactory.defaultReaderName] = MyXMLReader()
  /// }
  /// ```
  ///
  /// - Since: Java 1.4
  /// - Since: SAX 2.0
  open class XMLReaderFactory {

    /// Key under which the built-in ``JavApiXMLReader`` is registered.
    public static let defaultReaderName = "JavApiXMLReader"

    @MainActor
    public static var registeredReaders: [String: any org.xml.sax.XMLReader] = XMLReaderFactory._defaultReaders()

    /// Returns the reader registered under `name`, defaulting to ``defaultReaderName``.
    /// - Throws: ``org.xml.sax.SAXException`` if no reader is found for `name`.
    @MainActor
    public static func createXMLReader(_ name: String = defaultReaderName) throws -> any org.xml.sax.XMLReader {
      if let reader = registeredReaders[name] { return reader }
      throw org.xml.sax.SAXNotSupportedException("XMLReader \(name) not found")
    }

    // MARK: - Internal bootstrap

    private static func _defaultReaders() -> [String: any org.xml.sax.XMLReader] {
      var dict: [String: any org.xml.sax.XMLReader] = [:]
      dict[defaultReaderName] = JavApiXMLReader()
      return dict
    }
  }
}
