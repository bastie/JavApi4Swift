/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A mutable, dictionary-backed implementation of `AttributeSet`.
  ///
  /// `SimpleAttributeSet` is the everyday choice when you need to build up a
  /// set of character or paragraph attributes to pass to
  /// `StyledDocument.setCharacterAttributes` or `JTextPane.setCharacterAttributes`.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let attrs = javax.swing.text.SimpleAttributeSet()
  /// javax.swing.text.StyleConstants.setBold(attrs, true)
  /// javax.swing.text.StyleConstants.setFontSize(attrs, 18)
  /// textPane.setCharacterAttributes(attrs, replace: false)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class SimpleAttributeSet: javax.swing.text.AttributeSet {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var _attrs: [AnyHashable: Any] = [:]
    private var _resolveParent: javax.swing.text.AttributeSet?

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates an empty attribute set.
    public init() {}

    /// Creates an attribute set that is a copy of `source`.
    public init(copying source: javax.swing.text.AttributeSet) {
      for key in source.getAttributeNames() {
        if let value = source.getAttribute(key) {
          _attrs[key] = value
        }
      }
      _resolveParent = source.getResolveParent()
    }

    // -------------------------------------------------------------------------
    // MARK: AttributeSet
    // -------------------------------------------------------------------------

    open func getAttributeCount() -> Int { _attrs.count }

    open func isDefined(_ name: AnyHashable) -> Bool { _attrs[name] != nil }

    open func containsAttributes(_ attrs: javax.swing.text.AttributeSet) -> Bool {
      for key in attrs.getAttributeNames() {
        guard let v1 = attrs.getAttribute(key),
              let v2 = _attrs[key] else { return false }
        // Compare via string representation (Any is not Equatable)
        guard String(describing: v1) == String(describing: v2) else { return false }
      }
      return true
    }

    open func getAttribute(_ name: AnyHashable) -> Any? {
      if let v = _attrs[name] { return v }
      return _resolveParent?.getAttribute(name)
    }

    open func getAttributeNames() -> [AnyHashable] { Array(_attrs.keys) }

    open func getResolveParent() -> javax.swing.text.AttributeSet? { _resolveParent }

    // -------------------------------------------------------------------------
    // MARK: Mutation
    // -------------------------------------------------------------------------

    /// Adds a single attribute.
    open func addAttribute(_ name: AnyHashable, _ value: Any) {
      _attrs[name] = value
    }

    /// Adds all attributes from `attrs`.
    open func addAttributes(_ attrs: javax.swing.text.AttributeSet) {
      for key in attrs.getAttributeNames() {
        if let v = attrs.getAttribute(key) { _attrs[key] = v }
      }
    }

    /// Removes the attribute with the given name.
    open func removeAttribute(_ name: AnyHashable) {
      _attrs.removeValue(forKey: name)
    }

    /// Sets the resolving parent.
    open func setResolveParent(_ parent: javax.swing.text.AttributeSet?) {
      _resolveParent = parent
    }

    // -------------------------------------------------------------------------
    // MARK: Convenience
    // -------------------------------------------------------------------------

    /// Returns `true` if this set contains no attributes.
    public var isEmpty: Bool { _attrs.isEmpty }
  }
}
