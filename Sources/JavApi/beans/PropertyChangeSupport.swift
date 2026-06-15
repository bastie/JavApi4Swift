/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Utility class for managing ``PropertyChangeListener``s and firing ``PropertyChangeEvent``s.
  ///
  /// Beans that support bound properties delegate to this class.
  ///
  /// - Since: Java 1.1
  open class PropertyChangeSupport: @unchecked Sendable {

    private let sourceBean: AnyObject
    // listeners keyed by property name; nil key = global listeners
    private var listenerMap: [String?: [any java.beans.PropertyChangeListener]] = [:]

    /// - Parameter sourceBean: The bean that owns this support object.
    public init(_ sourceBean: AnyObject) {
      self.sourceBean = sourceBean
    }

    // MARK: - Registration

    /// Adds a global listener notified of all property changes.
    /// - Parameter listener: The listener to add.
    public func addPropertyChangeListener(_ listener: any java.beans.PropertyChangeListener) {
      listenerMap[nil, default: []].append(listener)
    }

    /// Removes a global listener.
    /// - Parameter listener: The listener to remove.
    public func removePropertyChangeListener(_ listener: any java.beans.PropertyChangeListener) {
      listenerMap[nil]?.removeAll { $0 === listener }
    }

    /// Adds a listener for a specific named property.
    /// - Parameters:
    ///   - propertyName: The property to observe.
    ///   - listener: The listener to add.
    public func addPropertyChangeListener(_ propertyName: String, _ listener: any java.beans.PropertyChangeListener) {
      listenerMap[propertyName, default: []].append(listener)
    }

    /// Removes a listener for a specific named property.
    /// - Parameters:
    ///   - propertyName: The observed property.
    ///   - listener: The listener to remove.
    public func removePropertyChangeListener(_ propertyName: String, _ listener: any java.beans.PropertyChangeListener) {
      listenerMap[propertyName]?.removeAll { $0 === listener }
    }

    // MARK: - Querying

    /// - Returns: All listeners (global and per-property), without duplicates.
    public func getPropertyChangeListeners() -> [any java.beans.PropertyChangeListener] {
      return listenerMap.values.flatMap { $0 }
    }

    /// - Parameter propertyName: The property name to query.
    /// - Returns: All listeners registered for `propertyName`.
    public func getPropertyChangeListeners(_ propertyName: String) -> [any java.beans.PropertyChangeListener] {
      return listenerMap[propertyName] ?? []
    }

    /// - Parameter propertyName: The property name to check.
    /// - Returns: `true` if there is at least one listener (global or for `propertyName`).
    public func hasListeners(_ propertyName: String) -> Bool {
      let globalListeners = listenerMap[nil] ?? []
      let namedListeners  = listenerMap[propertyName] ?? []
      return !globalListeners.isEmpty || !namedListeners.isEmpty
    }

    // MARK: - Firing

    /// Fires a ``PropertyChangeEvent`` to all registered listeners.
    /// - Parameter evt: The event to fire.
    public func firePropertyChange(_ evt: java.beans.PropertyChangeEvent) {
      let name = evt.getPropertyName()
      var targets: [any java.beans.PropertyChangeListener] = []
      targets += listenerMap[nil] ?? []
      if let name {
        targets += listenerMap[name] ?? []
      }
      for listener in targets {
        listener.propertyChange(evt)
      }
    }

    /// - Parameters:
    ///   - propertyName: The changed property.
    ///   - oldValue: The previous value.
    ///   - newValue: The new value.
    public func firePropertyChange(_ propertyName: String,
                                   _ oldValue: AnyObject?,
                                   _ newValue: AnyObject?) {
      guard hasListeners(propertyName) else { return }
      firePropertyChange(java.beans.PropertyChangeEvent(sourceBean, propertyName, oldValue, newValue))
    }

    /// Convenience overload for `Int` values. No event is fired if `oldValue == newValue`.
    /// - Parameters:
    ///   - propertyName: The changed property.
    ///   - oldValue: The previous value.
    ///   - newValue: The new value.
    public func firePropertyChange(_ propertyName: String,
                                   _ oldValue: Int,
                                   _ newValue: Int) {
      guard oldValue != newValue else { return }
      firePropertyChange(java.beans.PropertyChangeEvent(sourceBean, propertyName, Integer(oldValue), Integer(newValue)))
    }

    /// Convenience overload for `Bool` values. No event is fired if `oldValue == newValue`.
    /// - Parameters:
    ///   - propertyName: The changed property.
    ///   - oldValue: The previous value.
    ///   - newValue: The new value.
    public func firePropertyChange(_ propertyName: String,
                                   _ oldValue: Bool,
                                   _ newValue: Bool) {
      guard oldValue != newValue else { return }
      firePropertyChange(
        java.beans.PropertyChangeEvent(sourceBean, propertyName,
                                       Integer(oldValue ? 1 : 0),
                                       Integer(newValue ? 1 : 0)))
    }
  }
}
