/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Cloneable {
  /// Swift-idiomatic alias for `clone()`.
  ///
  /// The return type is `Cloneable` (the protocol) rather than `Self` because
  /// `clone()` is declared on the protocol with return type `Cloneable`.
  /// Narrowing to `Self` would require changing the `clone()` signature, which
  /// is tracked in the FIXME in `Cloneable.swift`.
  ///
  /// - Returns: Cloneable
  func copy() -> Cloneable {
    return try! self.clone()
  }
}
