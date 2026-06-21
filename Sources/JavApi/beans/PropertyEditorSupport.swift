/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// A convenience base class for `PropertyEditor` implementors.
  ///
  /// Provides default (no-op or nil-returning) implementations of every
  /// `PropertyEditor` method and handles `PropertyChangeListener` registration
  /// via an internal `PropertyChangeSupport` instance.
  ///
  /// - Since: Java 1.1
  open class PropertyEditorSupport: PropertyEditor, @unchecked Sendable {

    private var _value: AnyObject? = nil
    // _source stores the explicit source bean; nil means use self.
    // support is lazy so that self is fully initialised before it is accessed.
    private var _source: AnyObject? = nil
    private lazy var support: PropertyChangeSupport = PropertyChangeSupport(_source ?? self)

    // MARK: - Constructors

    public init() {
      // support is lazily initialised with self as source bean
    }

    public init(_ source: AnyObject) {
      self._source = source
    }

    // MARK: - PropertyEditor — value

    open func getValue() -> AnyObject? { _value }

    open func setValue(_ value: AnyObject?) {
      let old = _value
      _value = value
      support.firePropertyChange(PropertyChangeEvent(support, nil, old, value))
    }

    // MARK: - PropertyEditor — text

    open func getAsText() -> String? { _value.map { "\($0)" } }

    open func setAsText(_ text: String) throws {
      setValue(text as AnyObject)
    }

    open func getTags() -> [String]? { nil }

    // MARK: - PropertyEditor — painting / custom editor

    open func isPaintable() -> Bool { false }
    open func supportsCustomEditor() -> Bool { false }

    // MARK: - PropertyEditor — code generation

    open func getJavaInitializationString() -> String? { nil }

    // MARK: - Listeners

    open func addPropertyChangeListener(_ listener: PropertyChangeListener) {
      support.addPropertyChangeListener(listener)
    }

    open func removePropertyChangeListener(_ listener: PropertyChangeListener) {
      support.removePropertyChangeListener(listener)
    }

    // MARK: - Helper

    /// Fires a property-change event to all registered listeners.
    open func firePropertyChange() {
      support.firePropertyChange(PropertyChangeEvent(support, nil, nil, _value))
    }
  }
}
