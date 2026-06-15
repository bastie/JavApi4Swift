/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A `ResourceBundle` backed by a Swift array of `(String, Any)` pairs.
  ///
  /// Subclass this class and override ``getContents()`` to return an array
  /// of key–value pairs:
  ///
  /// ```swift
  /// class MyBundle: java.util.ListResourceBundle {
  ///   override func getContents() -> [(String, Any)] {
  ///     return [
  ///       ("greeting", "Hello"),
  ///       ("farewell", "Goodbye"),
  ///     ]
  ///   }
  /// }
  /// ```
  ///
  /// - Since: Java 1.1
  open class ListResourceBundle : ResourceBundle {

    private lazy var lookup: [String: Any] = {
      var dict = [String: Any]()
      for (key, value) in getContents() {
        dict[key] = value
      }
      return dict
    }()

    /// Returns the key–value pairs that define this bundle's resources.
    ///
    /// Override in subclasses; the base implementation returns an empty array.
    open func getContents() -> [(String, Any)] {
      return []
    }

    override open func handleGetObject(_ key: String) -> Any? {
      return lookup[key]
    }

    override open func getKeys() -> any java.util.Enumeration<String> {
      return HashtableEnumeration(Array(lookup.keys))
    }
  }
}
