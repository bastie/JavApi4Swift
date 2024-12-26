/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like 32-bit long Integer type
public class Integer {
  /// https://stackoverflow.com/questions/56222323/what-is-the-equivelent-to-javas-integer-reversebytes-in-swift?rq=3 :
  
  /// Reverse the bytes of Int32 in result of Java int is 32-bits long
  ///
  /// <strong>The method is Java-like only for 32-bit implemented. </strong> Use `Int.byteSwapped` for Swift and of course 64-bit Int types.
  ///
  /// A Java int is always 32 bits, so Integer.reverseBytes turns 0x00801600 into 0x00168000.
  ///
  /// A Swift Int is 32 bits on 32-bit platforms and 64 bits on 64-bit platforms (which is most current platforms). So on a 32-bit platform, i.byteSwapped turns 0x00801600 into 0x00168000, but on a 64-bit platform, i.byteSwapped turns 0x0000000000801600 into 0x0016800000000000.
  ///
  /// - Parameters value to reverse
  /// - Returns reverse byte of given Int (as Int32)
  ///
  public static func reverseBytes (_ value : Int) -> Int {
    return Int (Int32(value).byteSwapped)
  }

  /// The maximum value of `Int` type
  ///
  /// ## Sample for port Java to Swift without [JavApi⁴Swift](https://github.com/bastie/JavApi4Swift)
  ///
  /// Java code
  /// ```Java
  /// int maximum = Integer.MAX_VALUE;
  /// ```
  /// Swift code
  /// ```Swift
  /// var maximum = Int32.max
  /// ```
  ///
  /// ⚔️
  ///
  /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
  public static let MAX_VALUE : Int = Int(Int32.max)

  /// The minimum value of `Int` type
  ///
  /// ## Sample for port Java to Swift without [JavApi⁴Swift](https://github.com/bastie/JavApi4Swift)
  ///
  /// Java code
  /// ```Java
  /// int minimum = Integer.MIX_VALUE;
  /// ```
  /// Swift code
  /// ```Swift
  /// var minimum = Int32.min
  /// ```
  ///
  /// ⚔️
  ///
  /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
  public static let MIN_VALUE : Int = Int(Int32.min)
  
  
  public static func parseInt (_ string : String) throws -> Int {
    if let value = Int(string) {
      return value
    }
    throw java.lang.Throwable.NumberFormatException("\(string) is not a number")
  }
  
  public static func valueOf (_ string : String, _ radix : Int) throws -> Int {
    return try parseInt(string)
  }
}
