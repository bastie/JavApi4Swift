/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {

  /// - Since: Java 1.4
  /// - Since: SAX 1.0
  @available(*, deprecated, renamed: "XMLReaderFactory", message: "Since Java 1.5 use XMLReaderFactory")
  open class ParserFactory {

    /// Key used to look up (and replace) the built-in default parser.
    ///
    /// The default parser is ``JavApiSax1Parser`` — a Foundation-backed implementation
    /// on Apple platforms, and a pure-Swift fallback on Linux and other platforms (e.g. WASM).
    /// Replace the entry to swap in your own implementation:
    /// ```swift
    /// await MainActor.run {
    ///   org.xml.sax.helper.ParserFactory.registeredParsers[
    ///     org.xml.sax.helper.ParserFactory.defaultParserName] = MyParser()
    /// }
    /// ```
    public static let defaultParserName = "JavApiSax1Parser"

    @MainActor
    public static var registeredParsers: [String: any org.xml.sax.Parser] = ParserFactory._defaultParsers()

    /// Returns the default parser registered under ``defaultParserName``,
    /// or any parser registered under `name`.
    ///
    /// - Note: In Swift add your ``org.xml.sax.Parser`` implementation to
    ///   `registeredParsers` before calling this method.
    @MainActor
    public static func makeParser(_ name: String = defaultParserName) throws -> any org.xml.sax.Parser {
      if let parser = registeredParsers[name] {
        return parser
      }
      throw org.xml.sax.SAXNotSupportedException("Parser \(name) not found")
    }

    // MARK: - Internal bootstrap

    /// Builds the initial registry.  Called once during static initialisation.
    private static func _defaultParsers() -> [String: any org.xml.sax.Parser] {
      var dict: [String: any org.xml.sax.Parser] = [:]
      dict[defaultParserName] = JavApiSax1Parser()
      return dict
    }
  }
}
