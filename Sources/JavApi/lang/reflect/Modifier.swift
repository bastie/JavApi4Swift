/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.lang.reflect {

  /// Port of `java.lang.reflect.Modifier`.
  ///
  /// The `Modifier` class provides `static` methods and constants to decode
  /// class and member access modifiers.
  ///
  /// Note: Swift does not expose access modifiers at runtime via reflection.
  /// The constants are provided for API compatibility; `getModifiers()` on
  /// `Field` returns a best-effort value based on available information.
  ///
  /// - Since: Java 1.1
  public struct Modifier: Sendable {

    // MARK: - Modifier constants (match Java bit-field values)

    public static var PUBLIC: Int    { 0x0001 }
    public static var PRIVATE: Int   { 0x0002 }
    public static var PROTECTED: Int { 0x0004 }
    public static var STATIC: Int    { 0x0008 }
    public static var FINAL: Int     { 0x0010 }
    public static var SYNCHRONIZED: Int { 0x0020 }
    public static var VOLATILE: Int  { 0x0040 }
    public static var TRANSIENT: Int { 0x0080 }
    public static var NATIVE: Int    { 0x0100 }
    public static var INTERFACE: Int { 0x0200 }
    public static var ABSTRACT: Int  { 0x0400 }
    public static var STRICT: Int    { 0x0800 }

    // MARK: - Query methods

    /// Returns `true` if the integer argument includes the `public` modifier.
    public static func isPublic(_ mod: Int) -> Bool       { (mod & PUBLIC) != 0 }

    /// Returns `true` if the integer argument includes the `private` modifier.
    public static func isPrivate(_ mod: Int) -> Bool      { (mod & PRIVATE) != 0 }

    /// Returns `true` if the integer argument includes the `protected` modifier.
    public static func isProtected(_ mod: Int) -> Bool    { (mod & PROTECTED) != 0 }

    /// Returns `true` if the integer argument includes the `static` modifier.
    public static func isStatic(_ mod: Int) -> Bool       { (mod & STATIC) != 0 }

    /// Returns `true` if the integer argument includes the `final` modifier.
    public static func isFinal(_ mod: Int) -> Bool        { (mod & FINAL) != 0 }

    /// Returns `true` if the integer argument includes the `synchronized` modifier.
    public static func isSynchronized(_ mod: Int) -> Bool { (mod & SYNCHRONIZED) != 0 }

    /// Returns `true` if the integer argument includes the `volatile` modifier.
    public static func isVolatile(_ mod: Int) -> Bool     { (mod & VOLATILE) != 0 }

    /// Returns `true` if the integer argument includes the `transient` modifier.
    public static func isTransient(_ mod: Int) -> Bool    { (mod & TRANSIENT) != 0 }

    /// Returns `true` if the integer argument includes the `native` modifier.
    public static func isNative(_ mod: Int) -> Bool       { (mod & NATIVE) != 0 }

    /// Returns `true` if the integer argument includes the `interface` modifier.
    public static func isInterface(_ mod: Int) -> Bool    { (mod & INTERFACE) != 0 }

    /// Returns `true` if the integer argument includes the `abstract` modifier.
    public static func isAbstract(_ mod: Int) -> Bool     { (mod & ABSTRACT) != 0 }

    /// Returns `true` if the integer argument includes the `strictfp` modifier.
    public static func isStrict(_ mod: Int) -> Bool       { (mod & STRICT) != 0 }

    /// Returns a string describing the access modifier flags in the specified
    /// modifier, for example `"public static final"`.
    public static func toString(_ mod: Int) -> String {
      var parts: [String] = []
      if isPublic(mod)       { parts.append("public") }
      if isProtected(mod)    { parts.append("protected") }
      if isPrivate(mod)      { parts.append("private") }
      if isAbstract(mod)     { parts.append("abstract") }
      if isStatic(mod)       { parts.append("static") }
      if isFinal(mod)        { parts.append("final") }
      if isTransient(mod)    { parts.append("transient") }
      if isVolatile(mod)     { parts.append("volatile") }
      if isSynchronized(mod) { parts.append("synchronized") }
      if isNative(mod)       { parts.append("native") }
      if isStrict(mod)       { parts.append("strictfp") }
      if isInterface(mod)    { parts.append("interface") }
      return parts.joined(separator: " ")
    }
  }
}
