/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// ``Cloneable`` type
/// - Since: JavaApi &lt; 0.16.1 (Java 1.0)
public protocol Cloneable {
  
  /// Clone the instance
  func clone () throws -> Cloneable // FIXME: Cloneable working not with Object instead with self type
  
  associatedtype Cloneable: java.lang.Cloneable
}
