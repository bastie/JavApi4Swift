/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// `Cloneable` type in Java
public protocol Cloneable {
  
  /// Clone the instance
  func clone () throws -> Cloneable // FIXME: Cloneable working not with Object instead with self type
  
  associatedtype Cloneable: java.lang.Cloneable
}
