/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

public struct System {

  // MARK: - arraycopy
  //
  // Java signature: System.arraycopy(src, srcPos, dest, destPos, length)
  //
  // Swift arrays are value types: assigning an array to a new variable produces
  // an independent copy (copy-on-write). The `inout` parameter keyword is the
  // correct way to write back into the caller's array — no loops needed.
  //
  // Overlapping copies (src === dest with offset) are not supported: Swift's
  // exclusive-access rules forbid passing the same variable as both a read and
  // an inout argument. This matches Java's undefined-behaviour note for
  // overlapping System.arraycopy on the same array object when src == dest in
  // practice uses memmove, but callers in this codebase never overlap.
  //
  // Bounds violations throw ArrayIndexOutOfBoundsException, matching Java.

  /// Validates indices before a copy and throws `ArrayIndexOutOfBoundsException`
  /// with a descriptive message if any bound is invalid.
  private static func checkBounds(
    srcCount: Int, srcPos: Int,
    destCount: Int, destPos: Int,
    length: Int
  ) throws {
    guard length >= 0 else {
      throw ArrayIndexOutOfBoundsException("arraycopy: length \(length) is negative")
    }
    guard srcPos >= 0 else {
      throw ArrayIndexOutOfBoundsException("arraycopy: srcPos \(srcPos) is negative")
    }
    guard destPos >= 0 else {
      throw ArrayIndexOutOfBoundsException("arraycopy: destPos \(destPos) is negative")
    }
    guard srcPos + length <= srcCount else {
      throw ArrayIndexOutOfBoundsException(
        "arraycopy: src range [\(srcPos)..<\(srcPos+length)] out of bounds for length \(srcCount)")
    }
    guard destPos + length <= destCount else {
      throw ArrayIndexOutOfBoundsException(
        "arraycopy: dest range [\(destPos)..<\(destPos+length)] out of bounds for length \(destCount)")
    }
  }

  /// Generic same-type copy — covers `[UInt8]`, `[Int]`, `[Int16]`, `[UInt16]`,
  /// `[Character]` and any future element type in one implementation.
  ///
  /// Uses `replaceSubrange` which maps to a single optimised buffer operation
  /// (equivalent to `memmove` for trivial types) instead of an element-by-element loop.
  ///
  /// - Throws: `ArrayIndexOutOfBoundsException` on invalid indices or length.
  public static func arraycopy<T>(
    _ src: [T], _ srcPos: Int,
    _ dest: inout [T], _ destPos: Int,
    _ length: Int
  ) throws {
    try checkBounds(
      srcCount: src.count, srcPos: srcPos,
      destCount: dest.count, destPos: destPos,
      length: length)
    dest.replaceSubrange(
      destPos ..< destPos + length,
      with: src[srcPos ..< srcPos + length])
  }

  /// Optional-dest convenience overload: unwraps `dest` and delegates to the
  /// generic `inout [T]` overload. Throws `NullPointerException` when `dest` is nil.
  ///
  /// - Throws: `NullPointerException` if `dest` is nil;
  ///           `ArrayIndexOutOfBoundsException` on invalid indices.
  public static func arraycopy<T>(
    _ src: [T], _ srcPos: Int,
    _ dest: inout [T]?, _ destPos: Int,
    _ length: Int
  ) throws {
    guard dest != nil else {
      throw NullPointerException("arraycopy: dest is null")
    }
    try arraycopy(src, srcPos, &dest!, destPos, length)
  }

  // MARK: - Type-converting overloads
  //
  // These exist because Java arrays are covariant and allow copies between
  // compatible numeric types (e.g. short[] → byte[]). Swift generics cannot
  // express this, so explicit overloads are needed.

  /// Copies `[Int16]` into `[UInt8]` via truncating cast — mirrors Java
  /// `System.arraycopy(short[], …, byte[], …)`.
  ///
  /// - Throws: `ArrayIndexOutOfBoundsException` on invalid indices.
  public static func arraycopy(
    _ src: [Int16], _ srcPos: Int,
    _ dest: inout [UInt8], _ destPos: Int,
    _ length: Int
  ) throws {
    try checkBounds(
      srcCount: src.count, srcPos: srcPos,
      destCount: dest.count, destPos: destPos,
      length: length)
    dest.replaceSubrange(
      destPos ..< destPos + length,
      with: src[srcPos ..< srcPos + length].map { UInt8(truncatingIfNeeded: $0) })
  }

  /// Optional-dest variant of the `[Int16] → [UInt8]` converting overload.
  public static func arraycopy(
    _ src: [Int16], _ srcPos: Int,
    _ dest: inout [UInt8]?, _ destPos: Int,
    _ length: Int
  ) throws {
    guard dest != nil else {
      throw NullPointerException("arraycopy: dest is null")
    }
    try arraycopy(src, srcPos, &dest!, destPos, length)
  }

  /// Copies `[UInt8]` into `[Int]` — mirrors Java widening `byte[] → int[]`.
  ///
  /// - Throws: `ArrayIndexOutOfBoundsException` on invalid indices.
  public static func arraycopy(
    _ src: [UInt8], _ srcPos: Int,
    _ dest: inout [Int], _ destPos: Int,
    _ length: Int
  ) throws {
    try checkBounds(
      srcCount: src.count, srcPos: srcPos,
      destCount: dest.count, destPos: destPos,
      length: length)
    dest.replaceSubrange(
      destPos ..< destPos + length,
      with: src[srcPos ..< srcPos + length].map { Int($0) })
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
