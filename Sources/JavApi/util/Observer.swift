/*
 * SPDX-License-Identifier: Apache-2.0
 */

extension java.util {
  
  
  ///
  /// {@code Observer} is the interface to be implemented by objects that
  /// receive notification of updates on an {@code Observable} object.
  ///
  /// - see Observable
  ///
  public protocol Observer : Equatable, Hashable {

    /// This method is called if the specified ``Observable`` object's
    /// ``Observable/notifyObservers()`` method is called because the
    /// `Observable` object has been updated.
    ///
    /// - Parameters:
    ///   - observable: The `Observable` object that changed.
    ///   - data: Optional data passed to ``Observable/notifyObservers(_:)``.
    func update(_ observable: Observable, _ data: Any?)

    /// Returns a hash code for this observer.
    ///
    /// Used by ``Observable`` to identify and deduplicate observers.
    /// A default implementation is provided in ``Observer+Swiftify`` for
    /// class types via `ObjectIdentifier`.
    func hashCode() -> Int
  }
}
