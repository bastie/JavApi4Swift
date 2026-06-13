/*
 * SPDX-FileCopyrightText: 2024-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// ``Runnable`` type 
/// - Since: Java 1.0
public protocol Runnable {
  
  /// Function called by `Thread` to run separately from main thread.
  func run ()
  
  associatedtype Runnable: java.lang.Runnable
}
