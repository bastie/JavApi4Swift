/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// ``Runnable`` type in Java
/// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
public protocol Runnable {
  
  /// Function called by `Thread` to run separately from main thread.
  func run ()
  
  associatedtype Runnable: java.lang.Runnable
}
