/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Interface for objects that can edit a bean property value.
  ///
  /// `getCustomEditor()` is **not** included because it returns
  /// `java.awt.Component` and requires an AWT peer; use the AWT layer directly
  /// if a visual editor is needed.
  ///
  /// - Since: Java 1.1
  public protocol PropertyEditor: AnyObject {

    // MARK: - Value access

    func setValue(_ value: AnyObject?)
    func getValue() -> AnyObject?

    // MARK: - Text representation

    /// Returns `true` if this editor knows how to render the value as a string.
    func supportsCustomEditor() -> Bool

    func getAsText() -> String?
    func setAsText(_ text: String) throws

    /// Returns an array of known values, or `nil` if not enumerable.
    func getTags() -> [String]?

    // MARK: - Painting

    /// Returns `true` if `paintValue` can render the value graphically.
    func isPaintable() -> Bool

    // MARK: - Code generation

    /// Returns a Java initialiser expression for the current value (for IDE
    /// code generation). May return `nil` if not supported.
    func getJavaInitializationString() -> String?

    // MARK: - Listeners

    func addPropertyChangeListener(_ listener: PropertyChangeListener)
    func removePropertyChangeListener(_ listener: PropertyChangeListener)
  }
}
