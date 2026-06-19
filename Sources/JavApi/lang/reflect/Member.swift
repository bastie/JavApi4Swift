/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.lang {
  public enum reflect {}
}

extension java.lang.reflect {

  /// Port of `java.lang.reflect.Member`.
  ///
  /// Member is an interface that reflects identifying information about a single
  /// member (a field, a method, or a constructor) or an initializer.
  ///
  /// - Since: Java 1.1
  public protocol Member: Sendable {

    /// Returns the `Class` object representing the class or interface that
    /// declares the member or constructor represented by this Member.
    func getDeclaringClass() -> java.lang.Class

    /// Returns the simple name of the underlying member or constructor
    /// represented by this Member.
    func getName() -> String

    /// Returns the Java language modifiers for the member or constructor
    /// represented by this Member, as an integer.
    func getModifiers() -> Int

    /// Returns `true` if this member was introduced by the compiler;
    /// returns `false` otherwise.
    func isSynthetic() -> Bool
  }
}
