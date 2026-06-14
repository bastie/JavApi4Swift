/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Utility class for managing ``VetoableChangeListener``s and firing constrained property events.
  ///
  /// Beans that support constrained properties delegate to this class.
  ///
  /// - Since: Java 1.1
  open class VetoableChangeSupport: @unchecked Sendable {

    private let sourceBean: AnyObject
    // listeners keyed by property name; nil key = global listeners
    private var listenerMap: [String?: [any java.beans.VetoableChangeListener]] = [:]

    /// - Parameter sourceBean: The bean that owns this support object.
    public init(_ sourceBean: AnyObject) {
      self.sourceBean = sourceBean
    }

    // MARK: - Registration

    /// Adds a global vetoable listener notified of all constrained property changes.
    /// - Parameter listener: The listener to add.
    public func addVetoableChangeListener(_ listener: any java.beans.VetoableChangeListener) {
      listenerMap[nil, default: []].append(listener)
    }

    /// Removes a global vetoable listener.
    /// - Parameter listener: The listener to remove.
    public func removeVetoableChangeListener(_ listener: any java.beans.VetoableChangeListener) {
      listenerMap[nil]?.removeAll { $0 === listener }
    }

    /// Adds a vetoable listener for a specific named property.
    /// - Parameters:
    ///   - propertyName: The property to observe.
    ///   - listener: The listener to add.
    public func addVetoableChangeListener(_ propertyName: String,
                                          _ listener: any java.beans.VetoableChangeListener) {
      listenerMap[propertyName, default: []].append(listener)
    }

    /// Removes a vetoable listener for a specific named property.
    /// - Parameters:
    ///   - propertyName: The observed property.
    ///   - listener: The listener to remove.
    public func removeVetoableChangeListener(_ propertyName: String,
                                              _ listener: any java.beans.VetoableChangeListener) {
      listenerMap[propertyName]?.removeAll { $0 === listener }
    }

    // MARK: - Querying

    /// - Returns: All registered vetoable listeners (global and per-property).
    public func getVetoableChangeListeners() -> [any java.beans.VetoableChangeListener] {
      return listenerMap.values.flatMap { $0 }
    }

    /// - Parameter propertyName: The property name to query.
    /// - Returns: All vetoable listeners registered for `propertyName`.
    public func getVetoableChangeListeners(_ propertyName: String) -> [any java.beans.VetoableChangeListener] {
      return listenerMap[propertyName] ?? []
    }

    /// - Parameter propertyName: The property name to check.
    /// - Returns: `true` if there is at least one vetoable listener (global or for `propertyName`).
    public func hasListeners(_ propertyName: String) -> Bool {
      let globalListeners = listenerMap[nil] ?? []
      let namedListeners  = listenerMap[propertyName] ?? []
      return !globalListeners.isEmpty || !namedListeners.isEmpty
    }

    // MARK: - Firing

    /// Fires a constrained property change event.
    ///
    /// On veto, already-notified listeners receive a rollback event (old ↔ new swapped)
    /// before the exception is re-thrown.
    /// - Parameter evt: The pending change event.
    /// - Throws: ``PropertyVetoException`` if a listener rejects the change.
    public func fireVetoableChange(_ evt: java.beans.PropertyChangeEvent) throws {
      let name = evt.getPropertyName()
      var targets: [any java.beans.VetoableChangeListener] = []
      targets += listenerMap[nil] ?? []
      if let name {
        targets += listenerMap[name] ?? []
      }

      var notified: [any java.beans.VetoableChangeListener] = []
      for listener in targets {
        do {
          try listener.vetoableChange(evt)
          notified.append(listener)
        } catch let veto as java.beans.PropertyVetoException {
          // Roll back: inform already-notified listeners with old ↔ new swapped
          let rollback = java.beans.PropertyChangeEvent(
            sourceBean,
            evt.getPropertyName(),
            evt.getNewValue(),
            evt.getOldValue())
          for prior in notified.reversed() {
            try? prior.vetoableChange(rollback)
          }
          throw veto
        }
      }
    }

    /// - Parameters:
    ///   - propertyName: The property about to change.
    ///   - oldValue: The current value.
    ///   - newValue: The proposed new value.
    /// - Throws: ``PropertyVetoException`` if a listener rejects the change.
    public func fireVetoableChange(_ propertyName: String,
                                   _ oldValue: AnyObject?,
                                   _ newValue: AnyObject?) throws {
      guard hasListeners(propertyName) else { return }
      try fireVetoableChange(
        java.beans.PropertyChangeEvent(sourceBean, propertyName, oldValue, newValue))
    }

    /// Convenience overload for `Int` values. No event is fired if `oldValue == newValue`.
    /// - Parameters:
    ///   - propertyName: The property about to change.
    ///   - oldValue: The current value.
    ///   - newValue: The proposed new value.
    /// - Throws: ``PropertyVetoException`` if a listener rejects the change.
    public func fireVetoableChange(_ propertyName: String,
                                   _ oldValue: Int,
                                   _ newValue: Int) throws {
      guard oldValue != newValue else { return }
      try fireVetoableChange(
        java.beans.PropertyChangeEvent(sourceBean, propertyName,
                                       Integer(oldValue),
                                       Integer(newValue)))
    }

    /// Convenience overload for `Bool` values. No event is fired if `oldValue == newValue`.
    /// - Parameters:
    ///   - propertyName: The property about to change.
    ///   - oldValue: The current value.
    ///   - newValue: The proposed new value.
    /// - Throws: ``PropertyVetoException`` if a listener rejects the change.
    public func fireVetoableChange(_ propertyName: String,
                                   _ oldValue: Bool,
                                   _ newValue: Bool) throws {
      guard oldValue != newValue else { return }
      try fireVetoableChange(
        java.beans.PropertyChangeEvent(sourceBean, propertyName,
                                       Integer(oldValue ? 1 : 0),
                                       Integer(newValue ? 1 : 0)))
    }
  }
}
