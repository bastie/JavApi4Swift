/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

public struct System {
  // FIXME: create a generic function
  /*
   src − This is the source array.
   srcPos − This is the starting position in the source array.
   dest − This is the destination array.
   destPos − This is the starting position in the destination data.
   length − This is the number of array elements to be copied.
   */
  public static func arraycopy (_ src : [UInt8]?, _ srcPos : Int, _ dest : inout [UInt8]? , _ destPos : Int, _ length : Int) {
    if let src {
      if var dest {
        for offset in 0..<length {
          dest [destPos+offset] = src [srcPos+offset]
        }
      }
    }
  }
  public static func arraycopy (_ src : [UInt8], _ srcPos : Int, _ dest : inout [UInt8] , _ destPos : Int, _ length : Int) {
    for offset in 0..<length {
      dest [destPos+offset] = src [srcPos+offset]
    }
  }
  public static func arraycopy (_ src : [UInt16], _ srcPos : Int, _ dest : inout [UInt16] , _ destPos : Int, _ length : Int) {
    for offset in 0..<length {
      dest [destPos+offset] = src [srcPos+offset]
    }
  }
  public static func arraycopy (_ src : [Int16], _ srcPos : Int, _ dest : inout [Int16] , _ destPos : Int, _ length : Int) {
    for offset in 0..<length {
      dest [destPos+offset] = src [srcPos+offset]
    }
  }
  
  
  public static func arraycopy (_ src : [Int], _ srcPos : Int, _ dest : inout [Int] , _ destPos : Int, _ length : Int) {
    for offset in 0..<length {
      dest [destPos+offset] = src [srcPos+offset]
    }
  }
  
  public static func arraycopy (_ src : [UInt16], _ srcPos : Int, _ dest : inout [UInt16]? , _ destPos : Int, _ length : Int) {
    System.arraycopy(src, srcPos, &dest!, destPos, length)
  }
  
  public static func arraycopy (_ src : [Int16], _ srcPos : Int, _ dest : inout [UInt8]? , _ destPos : Int, _ length : Int) {
    System.arraycopy(src, srcPos, &dest!, destPos, length)
  }
  
  public static func arraycopy (_ src : [Int16], _ srcPos : Int, _ dest : inout [UInt8] , _ destPos : Int, _ length : Int) {
    for offset in 0..<length {
      dest [destPos+offset] = UInt8(src [srcPos+offset])
    }
  }
  
  /// Return the value from environment variable
  /// - Returns value of environment variable or nil
  static public func getenv (_ name : String) -> String? {
    return ProcessInfo.processInfo.environment[name]
  }
  
  /// Exits the application
  public static func exit (_ status : Int) -> Never {
    Foundation.exit(Int32(status))
  }
  
  /// Printstream to write on standard output.
  public static var out : SystemOut {
    get {
      return SystemOut ()
    }
  }
  
  /// Internal PrintStream to write on standard OutputStream
  public class SystemOut : java.io.PrintStream {
    init () {
      super.init(java.io.OutputStream.nullOutputStream())
    }
    
    public override func write(_ b: Int) {
      Swift.print (b, terminator: "")
    }
    public override func write(_ b: UInt8) {
      Swift.print (b, terminator: "")
    }
    
    public override func write(_ value: [byte]) {
      Swift.print (String(decoding: Data(value), as: UTF8.self))
    }
    
    public override func println(_ s: String) {
      Swift.print(s)
    }
    public override func print(_ s: String) {
      Swift.print(s, terminator: "")
    }
  }
}
