/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

extension java.awt.geom {
  
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

  ///
  /// - author Denis M. Kishenko
  /// - Since: JavaApi &gt; 0.19.1 (Java 1.2)
  public class Point2D : java.lang.Cloneable, Equatable {
    public typealias Cloneable = Point2D
    
    
    /// - author Denis M. Kishenko
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.2)
    public class Float : Point2D {
      
      public var x : Swift.Float = 0
      public var y : Swift.Float = 0
      
      public override init() {
      }
      
      public init(_ x : Swift.Float, _ y : Swift.Float) {
        self.x = x
        self.y = y
      }
      
      open override func getX() -> Swift.Double {
        return Swift.Double(x)
      }
      
      open override func getY() -> Swift.Double {
        return Swift.Double(y)
      }
      
      open func setLocation(_ x : Swift.Float, _ y : Swift.Float) {
        self.x = x;
        self.y = y;
      }
      
      open override func setLocation(_ x : Swift.Double, _ y : Swift.Double) {
        self.x = Swift.Float(x)
        self.y = Swift.Float(y)
      }
      
      open func toString() -> String {
        return "java.awt.Point2D.Float [x=\(x),y=\(y)]";
      }

      public override func clone() throws -> Point2D.Float {
        return java.awt.geom.Point2D.Float(self.x,self.y)
      }
      
    }
    
    /// - author Denis M. Kishenko
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.2)
    public class Double : Point2D {
      
      public var x : Swift.Double = 0
      public var y : Swift.Double = 0
      
      public override init() {
      }
      
      public init(_ x : Swift.Double, _ y : Swift.Double) {
        self.x = x;
        self.y = y;
      }
      
      open override func getX() -> Swift.Double {
        return x;
      }
      
      open override func getY() -> Swift.Double {
        return y;
      }
      
      open override func setLocation(_ x : Swift.Double, _ y : Swift.Double) {
        self.x = x;
        self.y = y;
      }
      
      open func toString() -> String {
        return "\(String(describing: type(of: self))) [x=\(x),y=\(y)]";
      }

      public override func clone() throws -> Point2D.Double {
        return java.awt.geom.Point2D.Double(self.getX(),self.getY())
      }

    }
    
    // MARK: Point2D Implementation
    
    /// Abstract class
    public init() {}
    
    open func getX() -> Swift.Double {
      fatalError("abstract method not implemented")
    }
    
    open func getY() -> Swift.Double {
      fatalError("abstract method not implemented")
    }
    
    open func setLocation(_ x : Swift.Double, _ y : Swift.Double) {
      fatalError("abstract method not implemented")
    }
    
    open func setLocation(_ p : Point2D) {
      setLocation(p.getX(), p.getY());
    }
    
    public static func distanceSq(_ x1 : Swift.Double, _ y1 : Swift.Double, _ x2_ : Swift.Double, _ y2_ : Swift.Double) -> Swift.Double {
      var x2 : Swift.Double = x2_
      var y2 : Swift.Double = y2_
      x2 -= x1
      y2 -= y1
      return x2 * x2 + y2 * y2;
    }
    
    open func distanceSq(_ px : Swift.Double, _ py : Swift.Double) -> Swift.Double {
      return Point2D.distanceSq(getX(), getY(), px, py);
    }
    
    open func distanceSq(_ p : Point2D) -> Swift.Double {
      return Point2D.distanceSq(getX(), getY(), p.getX(), p.getY());
    }
    
    public static func distance(_ x1 : Swift.Double, _ y1 : Swift.Double , _ x2 : Swift.Double, _ y2 : Swift.Double) -> Swift.Double {
      return Math.sqrt(distanceSq(x1, y1, x2, y2));
    }
    
    open func distance(_ px : Swift.Double, _ py : Swift.Double) -> Swift.Double {
      return Math.sqrt(distanceSq(px, py));
    }
    
    public func distance(_ p : Point2D) -> Swift.Double{
      return Math.sqrt(distanceSq(p));
    }
    
    /*
     public Object clone() {
     try {
     return super.clone();
     } catch (CloneNotSupportedException e) {
     throw new InternalError();
     }
     }
     */
    public func clone() throws -> java.awt.geom.Point2D {
      let clone = java.awt.geom.Point2D()
      clone.setLocation(self.getX(), self.getY())
      return clone
    }
    
    /// Tests the equality of given object against self.
    /// - Parameter obj the object to check
    /// - Returns `true` if given object is equal (or same)
    /// - Note: see == operator in Swift instead equals function in Java
    public func equals(_ obj : AnyObject) -> Bool {
      return self == obj
    }

    /// Implements the Java like equals method.
    public static func ==(lhs: java.awt.geom.Point2D, rhs: AnyObject) -> Bool {
      if lhs === rhs { return true }
      guard rhs is Point2D else {
        return false
      }
      let p = rhs as! Point2D
      return lhs.getX() == p.getX() && lhs.getY() == p.getY();
    }
    /// Implements the Equatable protocol
    public static func ==(lhs: java.awt.geom.Point2D, rhs: Point2D) -> Bool {
      if lhs === rhs { return true }
      return lhs.getX() == rhs.getX() && lhs.getY() == rhs.getY();
    }
  }
  
}
