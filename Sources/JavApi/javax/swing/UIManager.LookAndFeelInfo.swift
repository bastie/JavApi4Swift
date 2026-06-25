/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.UIManager {
  
  @MainActor
  open class LookAndFeelInfo : @MainActor CustomStringConvertible {
    public var description: String {
      return toString()
    }
    
    internal let lafInstance : javax.swing.LookAndFeel
    
    private let name : String
    private let className : String
    
    /// - Note: In different to Java LookAndFeels are registered static not dynamic
    public init (_ lookAndFeel : javax.swing.LookAndFeel, _ name : String? = nil, _ className : String? = nil ) {
      if let name = name {
        self.name = name
      }
      else {
        self.name = lookAndFeel.getName()
      }
      if let className = className {
        self.className = className
      }
      else {
        self.className = "\(type(of: lookAndFeel))"
      }
      self.lafInstance = lookAndFeel
    }
    
    public func getName() -> String {
      return name
    }
    public func getClassName() -> String {
      return className
    }
    
    open func toString() -> String {
      return "\(name) (\(className))"
    }
  }
}
