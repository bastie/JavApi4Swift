/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java {
  /// The namespace of java.rmi types
  ///
  /// > Note: The RMI networking stack (`Registry`, `Naming`, `UnicastRemoteObject`, etc.)
  /// > is intentionally not implemented. See NotImplemented.md for the rationale.
  /// > This package provides only the formal types (marker interface and exceptions)
  /// > needed to compile ported Java code that references `java.rmi`.
  public enum rmi {}
}
