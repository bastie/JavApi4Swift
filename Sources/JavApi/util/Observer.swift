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
    
    ///
    /// This method is called if the specified {@code Observable} object's
    /// {@code notifyObservers} method is called (because the {@code Observable}
    /// object has been updated.
    ///
    /// - Parameter observable the {@link Observable} object.
    /// - Parameter data the data passed to {@link Observable#notifyObservers(Object)}.
    ///
    func update(_ observable : Observable, _ data : Any?)
    
    /// Swift requirement: You need to implement this by ```return self```
    func observerInstance() -> AnyObject
  }
}
