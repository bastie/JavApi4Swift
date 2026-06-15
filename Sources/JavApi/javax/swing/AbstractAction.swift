/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Base class for `Action` implementations.
  ///
  /// Subclasses only need to implement `actionPerformed(_:)`.  All property
  /// storage, enabled state, and listener management are handled here.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// class SaveAction: javax.swing.AbstractAction {
  ///   init() { super.init("Save…") }
  ///   override func actionPerformed(_ e: java.awt.event.ActionEvent) {
  ///     print("save!")
  ///   }
  /// }
  /// ```
  ///
  @MainActor
  open class AbstractAction: javax.swing.Action {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var properties: [String: AnyObject] = [:]
    private var _enabled:   Bool = true
    private var propertyListeners: [java.beans.PropertyChangeListener] = []

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}

    /// Creates an action with a display name.
    public init(_ name: String) {
      properties[javax.swing.AbstractAction.NAME] = name as AnyObject
    }

    /// Creates an action with a display name and small icon.
    public init(_ name: String, _ icon: javax.swing.Icon) {
      properties[javax.swing.AbstractAction.NAME]       = name as AnyObject
      properties[javax.swing.AbstractAction.SMALL_ICON] = icon
    }

    // -------------------------------------------------------------------------
    // MARK: Action – property accessors
    // -------------------------------------------------------------------------

    open func getValue(_ key: String) -> AnyObject? {
      properties[key]
    }

    open func putValue(_ key: String, _ value: AnyObject?) {
      let old = properties[key]
      if let value {
        properties[key] = value
      } else {
        properties.removeValue(forKey: key)
      }
      firePropertyChange(key, oldValue: old, newValue: value)
    }

    // -------------------------------------------------------------------------
    // MARK: Action – enabled
    // -------------------------------------------------------------------------

    open func isEnabled() -> Bool { _enabled }

    open func setEnabled(_ b: Bool) {
      guard b != _enabled else { return }
      let old = _enabled
      _enabled = b
      firePropertyChange("enabled", oldValue: old as AnyObject, newValue: b as AnyObject)
    }

    // -------------------------------------------------------------------------
    // MARK: Action – property change listeners
    // -------------------------------------------------------------------------

    open func addPropertyChangeListener(_ listener: java.beans.PropertyChangeListener) {
      propertyListeners.append(listener)
    }

    open func removePropertyChangeListener(_ listener: java.beans.PropertyChangeListener) {
      propertyListeners.removeAll { $0 === listener }
    }

    private func firePropertyChange(_ key: String, oldValue: AnyObject?, newValue: AnyObject?) {
      guard !propertyListeners.isEmpty else { return }
      let event = java.beans.PropertyChangeEvent(self, key, oldValue, newValue)
      for listener in propertyListeners {
        listener.propertyChange(event)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: ActionListener – subclasses must override
    // -------------------------------------------------------------------------

    open func actionPerformed(_ e: java.awt.event.ActionEvent) {
      // Subclasses override this.
    }

    // -------------------------------------------------------------------------
    // MARK: Convenience accessors (mirror Java's Action property keys)
    // -------------------------------------------------------------------------

    /// The display name (`Action.NAME`).
    public func getName() -> String {
      (properties[javax.swing.AbstractAction.NAME] as? String) ?? ""
    }

    /// The small icon (`Action.SMALL_ICON`).
    public func getSmallIcon() -> javax.swing.Icon? {
      properties[javax.swing.AbstractAction.SMALL_ICON] as? javax.swing.Icon
    }

    /// The tooltip text (`Action.SHORT_DESCRIPTION`).
    public func getShortDescription() -> String {
      (properties[javax.swing.AbstractAction.SHORT_DESCRIPTION] as? String) ?? ""
    }
  }
}
