/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A map from UI-class keys to `ComponentUI` factory closures.
  ///
  /// `UIDefaults` is the look-up table that `UIManager.getUI(_:)` consults to
  /// find the correct `ComponentUI` subclass for a given `JComponent`.
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
  public class UIDefaults { // FIXME: Java type is a non final extension of java.util.Hashtable

    /// Factory closure type — returns a fresh `ComponentUI` instance.
    public typealias UIFactory = () -> javax.swing.plaf.ComponentUI

    private var table: [String: UIFactory] = [:]

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Registration
    // -------------------------------------------------------------------------

    /// Registers a factory for the given key.
    public func put(_ key: String, _ factory: @escaping UIFactory) {
      table[key] = factory
    }

    /// Subscript shorthand for `put` / `get`.
    public subscript(key: String) -> UIFactory? {
      get { table[key] }
      set { table[key] = newValue }
    }

    // -------------------------------------------------------------------------
    // MARK: Lookup
    // -------------------------------------------------------------------------

    /// Returns a new `ComponentUI` instance for `key`, or `nil` if not found.
    public func getUI(for key: String) -> javax.swing.plaf.ComponentUI? {
      return table[key]?()
    }
  }
}
