/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A map from UI-class keys to `ComponentUI` factory closures.
  ///
  /// `UIDefaults` extends `java.util.Hashtable<AnyHashable, Any>`, matching
  /// Java's `UIDefaults extends Hashtable<Object, Object>`.  Any object-typed
  /// key (typically a `String`) and any object-typed value (typically a
  /// `UIFactory` closure, but also `Color`, `Font`, `Border`, …) can be
  /// stored, just as in the Java original.
  ///
  /// Keys follow the Java convention of stripping the `J` prefix and appending
  /// `"UI"`: `JButton` → `"ButtonUI"`, `JLabel` → `"LabelUI"`, etc.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let defaults = UIDefaults()
  /// defaults["ButtonUI"] = { javax.swing.plaf.basic.BasicButtonUI() }
  /// defaults["LabelUI"]  = { javax.swing.plaf.basic.BasicLabelUI()  }
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  public class UIDefaults: java.util.Hashtable<AnyHashable, Any> {

    /// Factory closure type — returns a fresh `ComponentUI` instance.
    public typealias UIFactory = () -> javax.swing.plaf.ComponentUI

    public override init() { super.init() }

    // -------------------------------------------------------------------------
    // MARK: Convenience API for UIFactory values
    // -------------------------------------------------------------------------

    /// Registers a `UIFactory` for the given string key.
    ///
    /// Returns the previously registered factory for that key, if any.
    @discardableResult
    public func put(_ key: String, _ factory: @escaping UIFactory) -> UIFactory? {
      return put(key as AnyHashable, factory as Any) as? UIFactory
    }

    /// Subscript shorthand for `UIFactory` get/set by `String` key.
    public subscript(key: String) -> UIFactory? {
      get { get(key as AnyHashable) as? UIFactory }
      set {
        if let f = newValue {
          _ = put(key as AnyHashable, f as Any)
        } else {
          _ = remove(key as AnyHashable)
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: UI lookup
    // -------------------------------------------------------------------------

    /// Returns a new `ComponentUI` instance for `key`, or `nil` if not found.
    public func getUI(for key: String) -> javax.swing.plaf.ComponentUI? {
      return (get(key as AnyHashable) as? UIFactory)?()
    }
  }
}
