/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.Optional {
  /// - Returns: the underlying Swift `Optional<T>` value.
  public func swiftOptional() -> T? {
    return _value
  }
}
