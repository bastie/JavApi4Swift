/*
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

import Foundation

extension java.util {
  
  ///
  /// Observable is used to notify a group of Observer objects when a change
  /// occurs. On creation, the set of observers is empty. After a change occurred,
  /// the application can call the {@link #notifyObservers()} method. This will
  /// cause the invocation of the {@code update()} method of all registered
  /// Observers. The order of invocation is not specified. This implementation will
  /// call the Observers in the order they registered. Subclasses are completely
  /// free in what order they call the update methods.
  ///
  /// @see Observer
  /// - see ``java.util.Observer``
  ///
  open class Observable {
    
    private let lock : NSLock = NSLock()
    
    internal var observers : [any Observer] = []
    
    internal var changed = false;
    
    ///
    /// Constructs a new `Observable` object.
    ///
    public init() {
    }
    
    ///
    /// Adds the specified observer to the list of observers. If it is already
    /// registered, it is not added a second time.
    ///
    /// - Parameter observer the Observer to add.
    ///
    public func addObserver(_ observer : any Observer) {
      defer {
        self.lock.unlock()
      }
      self.lock.lock()
      if (!observers.contains(where: {observer.hashCode() == $0.hashCode() })) {
        observers.append(observer)
      }
    }
    
    ///
    /// Clears the changed flag for this `Observable`. After calling
    /// `clearChanged()`, `hasChanged()` will return `false`.
    ///
    public func clearChanged() {
      changed = false
    }
    
    ///
    /// Returns the number of observers registered to this {@code Observable}.
    ///
    /// - Returns the number of observers.
    ///
    public func countObservers() -> Int{
      return observers.count
    }
    
    ///
    /// Removes the specified observer from the list of observers. Passing null
    /// won't do anything.
    ///
    /// - Parameter observer the observer to remove.
    ///
    public func deleteObserver(_ observer : any Observer) {
      defer {
        self.lock.unlock()
      }
      self.lock.lock()
      observers.removeAll(where: { $0.hashCode() == observer.hashCode() })
    }
    
    ///
    /// Removes all observers from the list of observers.
    ///
    public func deleteObservers() {
      defer {
        self.lock.unlock()
      }
      self.lock.lock()
      //observers.clear();
      self.observers = []
    }
    
    ///
    /// Returns the changed flag for this `Observable`.
    ///
    /// - Returns `true` when the changed flag for this `Observable` is
    ///         set, `false` otherwise.
    ///
    public func hasChanged() -> Bool {
      return changed;
    }
    
    /**
    /// If `hasChanged()` returns `true`, calls the `update()`
    /// method for every observer in the list of observers using null as the
    /// argument. Afterwards, calls `clearChanged()`.
    ///
    /// Equivalent to calling `notifyObservers(nil)`.
     */
    public func notifyObservers() {
      notifyObservers(nil);
    }
    
    ///
    /// If `hasChanged()` returns `true`, calls the `update()`
    /// method for every Observer in the list of observers using the specified
    /// argument. Afterwards calls `clearChanged()`.
    ///
    /// - Parameters:
    /// - Parameter data the argument passed to `update()`.
    ///
    public func notifyObservers(_ data : Any?) {
      var arrays : [any Observer]?
      defer {
        self.lock.unlock()
      }
      self.lock.lock()
      if (hasChanged()) {
        clearChanged()
        arrays = Array (observers)
      }
      self.lock.unlock()
      if let arrays {
        for observer in arrays {
          observer.update(self, data)
        }
      }
    }
    
    ///
    /// Sets the changed flag for this `Observable`. After calling
    /// `setChanged()`, `hasChanged()` will return `true`.
    ///
    public func setChanged() {
      changed = true;
    }
  }
}
