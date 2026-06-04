/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Stub for `java.lang.Compiler` (Java 1.0).
///
/// In Java, `Compiler` provided hooks to control the JIT compiler. All methods
/// were no-ops on most JVMs and the class was deprecated in Java 9, removed in
/// Java 17. This Swift implementation follows the same pattern: all methods are
/// no-ops and the class cannot be instantiated.
///
/// - Since: JavaApi > 0.19.1 (Java 1.0)
public final class Compiler {

  /// `Compiler` cannot be instantiated.
  private init() {}

  /// Compiles the given class. Always returns `false` in this implementation.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func compileClass(_ clazz: AnyClass) -> Bool {
    return false
  }

  /// Compiles all classes whose name matches the given string. Always returns `false`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func compileClasses(_ string: String) -> Bool {
    return false
  }

  /// Examines the argument and performs whatever command the compiler
  /// directs. No-op in this implementation, returns `nil`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func command(_ any: Any?) -> Any? {
    return nil
  }

  /// Causes the compiler to resume operation. No-op in this implementation.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func enable() {}

  /// Causes the compiler to cease operation. No-op in this implementation.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func disable() {}
}
