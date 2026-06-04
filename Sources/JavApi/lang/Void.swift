/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.lang {

  /// Uninstantiable placeholder class for the Java `void` keyword.
  ///
  /// In Java, `Void` is used as a type argument where a return type of `void` is
  /// required generically, e.g. `Callable<Void>` or `Class<Void>`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public final class Void: @unchecked Sendable {
    /// `Void` cannot be instantiated.
    private init() {}
  }
}
