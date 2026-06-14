/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// A `ResourceBundle` backed by a `.properties` file.
  ///
  /// Keys and values are plain strings loaded from the standard Java
  /// `.properties` format (UTF-8 or ISO-8859-1, `#`/`!` comments, `=`/`:`
  /// separators, `\` line continuation).
  ///
  /// You normally obtain instances through ``ResourceBundle/getBundle(_:locale:)``
  /// rather than constructing them directly.
  ///
  /// - Since: Java 1.1
  public class PropertyResourceBundle : ResourceBundle {

    private var storage: [String: String] = [:]

    /// Creates an empty `PropertyResourceBundle`.
    public override init() {
      super.init()
    }

    /// Creates a `PropertyResourceBundle` by loading from `stream`.
    ///
    /// - Parameter stream: An `InputStream` whose content is a `.properties` file.
    /// - Throws: `java.io.IOException` on read errors.
    public init(_ stream: java.io.InputStream) throws {
      super.init()
      var bytes: [UInt8] = []
      var b = try stream.read()
      while b != -1 {
        bytes.append(UInt8(b))
        b = try stream.read()
      }
      let text = String(bytes: bytes, encoding: .utf8) ?? String(bytes: bytes, encoding: .isoLatin1) ?? ""
      loadFromText(text)
    }

    override public func handleGetObject(_ key: String) -> Any? {
      return storage[key]
    }

    override public func getKeys() -> any java.util.Enumeration<String> {
      return HashtableEnumeration(Array(storage.keys))
    }

    /// Parses a `.properties`-format string into the internal storage.
    internal func loadFromText(_ text: String) {
      let lines = text.components(separatedBy: .newlines)
      var i = 0
      while i < lines.count {
        var line = lines[i].trimmingCharacters(in: .whitespaces)
        i += 1
        if line.isEmpty || line.hasPrefix("#") || line.hasPrefix("!") { continue }
        // line continuation
        while line.hasSuffix("\\") && i < lines.count {
          line = String(line.dropLast())
          line += lines[i].trimmingCharacters(in: .whitespaces)
          i += 1
        }
        var key = ""
        var value = ""
        if let eqRange = line.range(of: "=") {
          key   = String(line[line.startIndex..<eqRange.lowerBound]).trimmingCharacters(in: .whitespaces)
          value = String(line[eqRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else if let colRange = line.range(of: ":") {
          key   = String(line[line.startIndex..<colRange.lowerBound]).trimmingCharacters(in: .whitespaces)
          value = String(line[colRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else {
          key = line
        }
        if !key.isEmpty {
          storage[key] = value
        }
      }
    }
  }
}
