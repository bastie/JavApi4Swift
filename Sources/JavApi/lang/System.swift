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
  public static func arraycopy (_ src : [UInt8], _ srcPos : Int, _ dest : inout [Int] , _ destPos : Int, _ length : Int) {
    for offset in 0..<length {
      dest [destPos+offset] = Int(src [srcPos+offset])
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
  public static func arraycopy (_ src : [Character], _ srcPos : Int, _ dest : inout [Character] , _ destPos : Int, _ length : Int) {
    for offset in 0..<length {
      dest [destPos+offset] = src [srcPos+offset]
    }
  }
  
  /// Return the current time in milliseconds
  ///
  /// - Returns: milliseconds as Int64
  public static func currentTimeMillis () -> Int64 {
    return Int64(Date().timeIntervalSince1970.advanced(by: 0)*1_000)
  }
  /// Exits the application
  /// - Parameters:
  /// - Parameter status return value e.g. for scripting with your application
  ///
  /// - Returns Never
  public static func exit (_ status : Int) -> Never {
    Foundation.exit(Int32(status))
  }
  
  /// Returns a hashCode
  /// - Note: unsafe
  public static func identityHashCode (_ x : AnyObject?) -> Int {
    if let x {
      return ObjectIdentifier(x).hashValue
    }
    else {
      return 0
    }
  }
  
  /// Returns the value of the specified environment variable.
  ///
  /// - Parameter name: The name of the environment variable.
  /// - Returns: The value of the variable, or `nil` if not set.
  /// - Since: Java 1.5
  public static func getenv (_ name : String) -> String? {
    return ProcessInfo.processInfo.environment[name]
  }

  /// Returns an unmodifiable snapshot of all environment variables.
  ///
  /// - Returns: A dictionary mapping environment variable names to their values.
  /// - Since: Java 1.5
  public static func getenv() -> [String:String] {
    return ProcessInfo.processInfo.environment
  }

  // MARK: - Security
  //
  // Storage and accessors are marked deprecated themselves so that the compiler
  // does not emit secondary warnings when the deprecated public API accesses them.

  @available(*, deprecated)
  nonisolated(unsafe) private static var _securityManager: SecurityManager? = nil

  @available(*, deprecated)
  private static func _getSecurityManager() -> SecurityManager? { _securityManager }

  @available(*, deprecated)
  private static func _setSecurityManager(_ sm: SecurityManager?) { _securityManager = sm }

  /// Sets the system security manager.
  ///
  /// Behaviour depends on `java.expected.version` system property:
  /// - Java < 17: sets the manager; throws `SecurityException` if already set.
  /// - Java ≥ 17 (default): always throws `UnsupportedOperationException`
  ///   (deprecated Java 17, effectively removed Java 18).
  ///
  /// - Throws: `UnsupportedOperationException` for Java ≥ 17, `SecurityException` if already set on Java < 17.
  /// - Since: Java 1.0
  @available(*, deprecated, message: "setSecurityManager is deprecated since Java 17 and throws UnsupportedOperationException unless java.expected.version < 17 is set")
  public static func setSecurityManager (_ newSecurityManager: SecurityManager?) throws {
    let expectedVersion = (try? System.getProperty("java.expected.version")).flatMap { $0.flatMap(Int.init) } ?? Int.max
    guard expectedVersion < 17 else {
      throw UnsupportedOperationException("setSecurityManager is not supported since Java 17")
    }
    if _getSecurityManager() != nil {
      throw SecurityException("security manager already set")
    }
    _setSecurityManager(newSecurityManager)
  }

  /// Returns the currently installed security manager, or `nil` if none.
  ///
  /// Behaviour depends on `java.expected.version` system property:
  /// - Java < 17: returns the installed manager.
  /// - Java ≥ 17 (default): always returns `nil`
  ///   (deprecated Java 17, effectively removed Java 18).
  ///
  /// - Since: Java 1.0
  @available(*, deprecated, message: "getSecurityManager is deprecated since Java 17 and always returns nil unless java.expected.version < 17 is set")
  public static func getSecurityManager() -> SecurityManager? {
    let expectedVersion = (try? System.getProperty("java.expected.version")).flatMap { $0.flatMap(Int.init) } ?? Int.max
    guard expectedVersion < 17 else {
      return nil
    }
    return _getSecurityManager()
  }

}
