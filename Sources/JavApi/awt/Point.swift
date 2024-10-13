/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

extension java.awt {
  
  
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
  
  /// Represent a point with x and y coordinates as integer values.
  ///
  /// - authors Denis M. Kishenko
  /// - authors Sebastian Ritter (port to Swift and documentation)
  /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
  public class Point : java.awt.geom.Point2D /*implements Serializable*/ {
    
    private let serialVersionUID : Int64 = -5276940640259749850
    
    public var x : Int = 0
    public var y : Int = 0
    
    public override init() {
      super.init()
      setLocation(0, 0);
    }
    
    public init(_ x : Int, _ y : Int) {
      super.init()
      setLocation(x, y)
    }
    
    public init(_ p : Point) {
      super.init()
      setLocation(p.x, p.y)
    }
    
    open override func equals(_ obj : AnyObject) -> Bool{
      if (obj === self) {
        return true;
      }
      if (obj is Point) {
        let p = obj as! Point
        return x == p.x && y == p.y;
      }
      return false;
    }
    
    /// The text representation of instance with wrapped x and y coordinates.
    ///
    /// - returns a text representation of Point instance
    open func toString() -> String {
      return "\(String(describing: type(of: self))) [x=\(x),y=\(y)]"
    }
    
    /// Return the x coordinate as Double value
    /// - Returns x coordinate
    open override func getX() -> Swift.Double {
      return Swift.Double (x)
    }
    /// Return the y coordinate as Double value
    /// - Returns y coordnate
    open override func getY() -> Swift.Double {
      return Swift.Double (y)
    }
    /// Return a **copy** of point
    /// - returns copy of point
    open func getLocation() -> Point{
      return Point(x, y);
    }
    /// Set the x and y coordinates to same value as given point
    /// - parameters p source point for new coordnates
    open func setLocation(_ p : Point) {
      setLocation(p.x, p.y);
    }
    /// Set the x an y coordinates from integer values
    /// - parameter x the new x coordinate
    /// - parameter y the new y coordnate
    open func setLocation(_ x : Int, _ y : Int) {
      self.x = x;
      self.y = y;
    }
    /// Set the x an y coordinates from double values as integer value
    /// - parameter x the new x coordinate
    /// - parameter y the new y coordnate
    open override func setLocation(_ x_ : Swift.Double, _ y_ : Swift.Double) {
      var x = x_
      var y = y_
      x = x < Swift.Double(Integer.MIN_VALUE) ? Swift.Double(Integer.MIN_VALUE) : x > Swift.Double(Integer.MAX_VALUE) ? Swift.Double(Integer.MAX_VALUE) : x;
      y = y < Swift.Double(Integer.MIN_VALUE) ? Swift.Double(Integer.MIN_VALUE) : y > Swift.Double(Integer.MAX_VALUE) ? Swift.Double(Integer.MAX_VALUE) : y;
      setLocation(Int(Math.round(x)), Int(Math.round(y)))
    }
    /// Convience function to set the x an y coordinates from integer values
    ///
    /// This function do the same as `setLocation` function.
    ///
    /// - parameter x the new x coordinate
    /// - parameter y the new y coordnate
    open func move(_ x : Int, _ y : Int) {
      setLocation(x, y);
    }
    /// Add the given delta integere values to the x and y coordinates
    ///
    /// - parameter dx delta to the x value of self
    /// - parameter dy delta to the y value of self
    open func translate(_ dx : Int, _ dy : Int) {
      x += dx;
      y += dy;
    }
  }
}
