/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax.helper {
  
  /// - Since: Java 1.4
  /// - Since: SAX 1.0
  @available(*, deprecated, renamed: "XMLReaderFactory", message: "Since Java 1.5 use XMLReaderFactory")
  open class ParserFactory {
    
    @MainActor
    public static var registeredParsers : [String:org.xml.sax.Parser] = [:]
    
    /// use system property `org.xml.sax.parser`
    /// - Note: In Swift add your `org.xml.sax.Parser` implementation to `registeredParsers` property before use this function.
    @MainActor public static func makeParser(_ name : String) throws -> org.xml.sax.Parser {
      if registeredParsers[name] != nil {
        return registeredParsers[name]!
      }
      throw org.xml.sax.SAXNotSupportedException("Parser \(name) not found")
    }
  }
}
