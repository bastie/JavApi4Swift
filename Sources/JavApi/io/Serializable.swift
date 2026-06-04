/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  /// Marker protocol mirroring `java.io.Serializable`.
  public protocol Serializable {}

  /// Backward-compatible alias (Swift-friendly name).
  public typealias Serialization = Serializable
}
