/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.lang {

  /// Stub for `java.lang.ClassLoader` (Java 1.0).
  ///
  /// Swift has no built-in class-loader concept. A future implementation could
  /// use `dlopen`/`dlsym` (POSIX) or `NSBundle` to dynamically load external
  /// libraries and resolve types at runtime — but this is not yet implemented.
  ///
  /// - TODO: Implement dynamic library loading via `dlopen`/`dlsym` on POSIX platforms
  ///   and `NSBundle` on Apple platforms to support runtime class resolution.
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open class ClassLoader {

    /// Creates a new `ClassLoader`.
    ///
    /// - TODO: Implement dynamic library loading via `dlopen`/`dlsym` (POSIX) or
    ///   `NSBundle` (Apple). Currently triggers `fatalError`.
    /// - Since: Java 1.0
    public init() {
      fatalError("TODO: ClassLoader() — dynamic library loading via dlopen/NSBundle not yet implemented")
    }
  }
}
