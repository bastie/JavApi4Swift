/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// An abstract base class for resource bundles — locale-sensitive collections
  /// of named resources (strings and objects).
  ///
  /// Mirrors `java.util.ResourceBundle` from Java 1.1.
  ///
  /// ## Subclassing
  /// Concrete subclasses must implement ``handleGetObject(_:)`` and
  /// ``getKeys()``.  The two standard concrete subclasses are
  /// ``ListResourceBundle`` and ``PropertyResourceBundle``.
  ///
  /// ## Bundle lookup chain
  /// ``getBundle(_:locale:)`` searches for bundles in the following order
  /// (most-specific first), stopping at the first match:
  ///
  /// 1. `baseName_language_country`
  /// 2. `baseName_language`
  /// 3. `baseName` (root bundle)
  ///
  /// The parent chain is then set so that missing keys fall through to less
  /// specific bundles automatically.
  ///
  /// - Since: Java 1.1
  open class ResourceBundle {

    // MARK: - State

    /// The parent bundle consulted when a key is not found in this bundle.
    public var parent: ResourceBundle?

    // MARK: - Abstract interface

    /// Returns the object for `key` defined **in this bundle only**,
    /// without consulting ``parent``.  Return `nil` if the key is absent.
    ///
    /// - Parameter key: The resource key.
    /// - Returns: The resource object, or `nil`.
    open func handleGetObject(_ key: String) -> Any? {
      return nil
    }

    /// Returns an `Enumeration` over the keys defined **in this bundle**
    /// (not including keys inherited from ``parent``).
    open func getKeys() -> any java.util.Enumeration<String> {
      return HashtableEnumeration<String>([])
    }

    // MARK: - Public API

    /// Returns the named object for `key`, searching the parent chain.
    ///
    /// - Parameter key: The resource key.
    /// - Returns: The resource object.
    /// - Throws: ``MissingResourceException`` if the key is not found.
    /// - Since: Java 1.1
    public func getObject(_ key: String) throws -> Any {
      if let value = handleGetObject(key) { return value }
      if let p = parent { return try p.getObject(key) }
      throw MissingResourceException("Can't find resource for key '\(key)'", String(describing: type(of: self)), key)
    }

    /// Returns the `String` resource for `key`.
    ///
    /// - Parameter key: The resource key.
    /// - Returns: The string value.
    /// - Throws: ``MissingResourceException`` if the key is not found or the
    ///   value is not a `String`.
    /// - Since: Java 1.1
    public func getString(_ key: String) throws -> String {
      let obj = try getObject(key)
      guard let str = obj as? String else {
        throw MissingResourceException("Resource for key '\(key)' is not a String", String(describing: type(of: self)), key)
      }
      return str
    }

    /// Returns the `[String]` resource for `key`.
    ///
    /// - Parameter key: The resource key.
    /// - Returns: The string-array value.
    /// - Throws: ``MissingResourceException`` if the key is not found or the
    ///   value is not a `[String]`.
    /// - Since: Java 1.1
    public func getStringArray(_ key: String) throws -> [String] {
      let obj = try getObject(key)
      guard let arr = obj as? [String] else {
        throw MissingResourceException("Resource for key '\(key)' is not a String[]", String(describing: type(of: self)), key)
      }
      return arr
    }

    /// Returns `true` if `key` exists in this bundle or any parent.
    ///
    /// - Parameter key: The resource key.
    /// - Since: Java 6
    public func containsKey(_ key: String) -> Bool {
      if handleGetObject(key) != nil { return true }
      return parent?.containsKey(key) ?? false
    }

    /// Returns a `Set` of all keys visible through the parent chain.
    ///
    /// - Since: Java 6
    public func keySet() -> Set<String> {
      var keys = Set<String>()
      var bundle: ResourceBundle? = self
      while let b = bundle {
        var e = b.getKeys()
        while e.hasMoreElements() {
          if let k = try? e.nextElement() { keys.insert(k) }
        }
        bundle = b.parent
      }
      return keys
    }

    // MARK: - Factory methods

    /// Returns the root bundle for `baseName` using the default locale.
    ///
    /// - Parameter baseName: The base name of the resource bundle family.
    /// - Returns: A `ResourceBundle` for the default locale.
    /// - Throws: ``MissingResourceException`` if no bundle can be found.
    /// - Since: Java 1.1
    public static func getBundle(_ baseName: String) throws -> ResourceBundle {
      return try getBundle(baseName, locale: java.util.Locale.getDefault())
    }

    /// Returns the bundle for `baseName` and `locale`.
    ///
    /// Searches (most specific first):
    /// 1. `baseName_language_country`
    /// 2. `baseName_language`
    /// 3. `baseName`
    ///
    /// Each level is wired as the ``parent`` of the more-specific level so
    /// that missing keys fall through automatically.
    ///
    /// - Parameters:
    ///   - baseName: The base name of the resource bundle family.
    ///   - locale: The desired locale.
    /// - Returns: A `ResourceBundle` for `locale`.
    /// - Throws: ``MissingResourceException`` if no bundle can be found.
    /// - Since: Java 1.1
    public static func getBundle(_ baseName: String, locale: java.util.Locale) throws -> ResourceBundle {
      let lang    = locale.getLanguage()
      let country = locale.getCountry()

      var candidates: [String] = []
      if !lang.isEmpty && !country.isEmpty {
        candidates.append("\(baseName)_\(lang)_\(country)")
      }
      if !lang.isEmpty {
        candidates.append("\(baseName)_\(lang)")
      }
      candidates.append(baseName)

      // Build parent chain from least- to most-specific.
      // root ends up being the most specific loaded bundle.
      var root: ResourceBundle? = nil
      for name in candidates.reversed() {
        if let b = loadBundle(name) {
          b.parent = root
          root = b
        }
      }

      guard let result = root else {
        throw MissingResourceException(
          "Can't find bundle for base name '\(baseName)', locale \(lang)",
          baseName, "")
      }
      return result
    }

    // MARK: - Private helpers

    /// Attempts to load a `.properties` file from the main bundle.  Returns `nil` if not found.
    private static func loadBundle(_ name: String) -> ResourceBundle? {
      if let url = Foundation.Bundle.main.url(forResource: name, withExtension: "properties"),
         let data = try? Data(contentsOf: url),
         let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) {
        let bundle = PropertyResourceBundle()
        bundle.loadFromText(text)
        return bundle
      }
      return nil
    }
  }
}
