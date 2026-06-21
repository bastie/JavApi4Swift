/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.rmi {
  /// Marker protocol corresponding to Java's `java.rmi.Remote`.
  ///
  /// In Java, `Remote` is an empty marker interface that signals a class's
  /// methods may be invoked from a non-local JVM. Since the RMI networking
  /// stack is not implemented in JavApi⁴Swift, this protocol serves purely
  /// as a formal marker so that ported Java types compiling with
  /// `implements Remote` translate without errors.
  public typealias Remote = JavApi.Remote
}

public protocol Remote {}
