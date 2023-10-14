/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
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
  
}
