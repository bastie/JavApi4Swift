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
