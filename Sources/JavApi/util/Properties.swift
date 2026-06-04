/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// A persistent set of string properties (key-value pairs).
  ///
  /// Mirrors `java.util.Properties` from Java 1.0. `Properties` extends
  /// `java.util.Hashtable` with `String` keys and `String` values and adds
  /// support for loading and storing `.properties` files.
  ///
  /// A secondary `Properties` table (`defaults`) can be supplied at
  /// construction time; ``getProperty(_:)`` falls back to it when a key is
  /// not found in the primary table.
  ///
  /// ```swift
  /// let props = java.util.Properties()
  /// props.setProperty("host", "localhost")
  /// props.setProperty("port", "8080")
  /// print(props.getProperty("host") ?? "")   // localhost
  /// print(props.getProperty("timeout", "30")) // 30  (default)
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  public class Properties : Hashtable<String, String> {

    // MARK: - Defaults

    /// A property list that provides default values when a key is not found
    /// in this table.
    public let defaults: Properties?

    // MARK: - Initialisers

    /// Creates an empty property list with no defaults.
    /// - Since: JavaApi (Java 1.0)
    public override init() {
      self.defaults = nil
      super.init()
    }

    /// Creates an empty property list with the given defaults table.
    ///
    /// - Parameter defaults: Fallback property list consulted by
    ///   ``getProperty(_:)`` when a key is absent.
    /// - Since: JavaApi (Java 1.0)
    public init(_ defaults: Properties) {
      self.defaults = defaults
      super.init()
    }

    // MARK: - Core API

    /// Returns the property value for `key`, or `nil` if not found in this
    /// table or in the defaults chain.
    ///
    /// - Parameter key: The property key.
    /// - Returns: The property value, or `nil`.
    /// - Since: JavaApi (Java 1.0)
    public func getProperty(_ key: String) -> String? {
      if let value = get(key) { return value }
      return defaults?.getProperty(key)
    }

    /// Returns the property value for `key`, or `defaultValue` if not found.
    ///
    /// - Parameters:
    ///   - key: The property key.
    ///   - defaultValue: Value returned when `key` is absent.
    /// - Returns: The property value, or `defaultValue`.
    /// - Since: JavaApi (Java 1.0)
    public func getProperty(_ key: String, _ defaultValue: String) -> String {
      return getProperty(key) ?? defaultValue
    }

    /// Sets the property `key` to `value` and returns the previous value.
    ///
    /// - Parameters:
    ///   - key: The property key.
    ///   - value: The new value.
    /// - Returns: The previous value, or `nil`.
    /// - Since: JavaApi (Java 1.0)
    @discardableResult
    public func setProperty(_ key: String, _ value: String) -> String? {
      return put(key, value)
    }

    /// Returns an `Enumeration` over all property names, including those from
    /// the defaults chain.
    /// - Since: JavaApi (Java 1.0)
    public func propertyNames() -> any java.util.Enumeration<String> {
      var allKeys = Set(storage.keys)
      if let defaults {
        var defEnum = defaults.propertyNames()
        while defEnum.hasMoreElements() {
          if let k = try? defEnum.nextElement() { allKeys.insert(k) }
        }
      }
      return HashtableEnumeration(Array(allKeys))
    }

    // MARK: - load / store

    /// Loads properties from a `.properties`-format `InputStream`.
    ///
    /// Lines starting with `#` or `!` are comments and are ignored.
    /// Key-value pairs are separated by `=` or `:` (with optional surrounding
    /// whitespace). Lines may be continued with a trailing `\`.
    ///
    /// - Parameter inStream: The input stream to read from.
    /// - Throws: `java.io.IOException` on read errors.
    /// - Since: JavaApi (Java 1.0)
    public func load(_ inStream: java.io.InputStream) throws {
      var bytes: [UInt8] = []
      var b = try inStream.read()
      while b != -1 {
        bytes.append(UInt8(b))
        b = try inStream.read()
      }
      let text = String(bytes: bytes, encoding: .utf8)
              ?? String(bytes: bytes, encoding: .isoLatin1)
              ?? ""
      parseProperties(text)
    }

    /// Saves properties to an `OutputStream` in `.properties` format.
    ///
    /// - Parameters:
    ///   - out: The output stream to write to.
    ///   - comments: Optional header comment written as the first line.
    /// - Throws: `java.io.IOException` on write errors.
    /// - Since: JavaApi (Java 1.0)
    public func store(_ out: java.io.OutputStream, _ comments: String?) throws {
      var lines = ""
      if let comments {
        lines += "# \(comments)\n"
      }
      lines += "# \(Foundation.Date())\n"
      withLock {
        for (key, value) in storage {
          let escapedKey   = escape(key,   escapeSpace: true)
          let escapedValue = escape(value, escapeSpace: false)
          lines += "\(escapedKey)=\(escapedValue)\n"
        }
      }
      let data = [UInt8](lines.utf8)
      try out.write(data)
    }

    /// Saves properties to an `OutputStream` in `.properties` format.
    ///
    /// - Parameters:
    ///   - out: The output stream to write to.
    ///   - comments: Optional header comment written as the first line.
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "as of Java 1.2, use store(OutputStream, String?) instead")
    public func save(_ out: java.io.OutputStream, _ comments: String?) {
      try? store(out, comments)
    }

    /// Prints all properties to `out` prefixed with an optional comment.
    ///
    /// - Parameters:
    ///   - out: The `PrintStream` to write to.
    /// - Since: JavaApi (Java 1.0)
    public func list(_ out: java.io.PrintStream) {
      out.println("-- listing properties --")
      withLock {
        for (key, value) in storage {
          out.println("\(key)=\(value)")
        }
      }
      if let defaults {
        defaults.list(out)
      }
    }

    // MARK: - Private helpers

    /// Parses a `.properties`-format string and populates the storage.
    private func parseProperties(_ text: String) {
      let lines = text.components(separatedBy: .newlines)
      var i = 0
      while i < lines.count {
        var line = lines[i].trimmingCharacters(in: .whitespaces)
        i += 1
        // skip blank lines and comments
        if line.isEmpty || line.hasPrefix("#") || line.hasPrefix("!") { continue }
        // handle line continuation
        while line.hasSuffix("\\") {
          line = String(line.dropLast())
          if i < lines.count {
            line += lines[i].trimmingCharacters(in: .whitespaces)
            i += 1
          }
        }
        // split on first '=' or ':'
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
          _ = put(key, value)
        }
      }
    }

    /// Escapes special characters for `.properties` output.
    private func escape(_ s: String, escapeSpace: Bool) -> String {
      var result = ""
      for ch in s {
        switch ch {
        case "\\" : result += "\\\\"
        case "\n" : result += "\\n"
        case "\r" : result += "\\r"
        case "\t" : result += "\\t"
        case "=", ":", "#", "!" : result += "\\\(ch)"
        case " "  : result += escapeSpace ? "\\ " : " "
        default   : result.append(ch)
        }
      }
      return result
    }
  }
}
