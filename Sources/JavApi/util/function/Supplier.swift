/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.function {
  public protocol Supplier<T> {
    associatedtype T
    func get() -> T
  }
}
