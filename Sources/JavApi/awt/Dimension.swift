/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  open class Dimension: Equatable {
    
    public var width:  Int
    public var height: Int
    
    public init(_ width: Int, _ height: Int) {
      self.width = width; self.height = height
    }
    public convenience init() { self.init(0, 0) }
    
    open func getWidth()  -> Double { Double(width)  }
    open func getHeight() -> Double { Double(height) }
    
    open func setSize(_ width: Int, _ height: Int) {
      self.width = width; self.height = height
    }
    
    public static func == (lhs: Dimension, rhs: Dimension) -> Bool {
      lhs.width == rhs.width && lhs.height == rhs.height
    }
  }
}
