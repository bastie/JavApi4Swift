/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// An event delivered when a bound or constrained property changes.
  ///
  /// - Since: Java 1.1
  open class PropertyChangeEvent: java.util.EventObject, @unchecked Sendable {

    private let propertyName: String?
    private let oldValue: AnyObject?
    private let newValue: AnyObject?
    private var propagationId: AnyObject?

    /// - Parameters:
    ///   - source: The bean that fired the event.
    ///   - propertyName: The changed property name, or `nil` if unspecified.
    ///   - oldValue: The previous value.
    ///   - newValue: The new value.
    public init(_ source: AnyObject, _ propertyName: String?, _ oldValue: AnyObject?, _ newValue: AnyObject?) {
      self.propertyName  = propertyName
      self.oldValue      = oldValue
      self.newValue      = newValue
      self.propagationId = nil
      super.init(source)
    }

    /// - Returns: The name of the changed property, or `nil` if unspecified.
    public func getPropertyName() -> String? { propertyName }

    /// - Returns: The new value after the change.
    public func getNewValue() -> AnyObject? { newValue }

    /// - Returns: The old value before the change.
    public func getOldValue() -> AnyObject? { oldValue }

    /// Sets the propagation ID used to identify event chains.
    /// - Parameter propagationId: The propagation ID, or `nil` to clear it.
    public func setPropagationId(_ propagationId: AnyObject?) {
      self.propagationId = propagationId
    }

    /// - Returns: The propagation ID.
    public func getPropagationId() -> AnyObject? { propagationId }
  }
}
