/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Java's `java.util.Queue` — a collection designed for holding elements prior to processing.
  ///
  /// `Queue` extends `Collection` and adds head-access operations that do not
  /// throw (`peek`, `poll`) alongside throwing counterparts (`element`, `remove`).
  ///
  /// ### associatedtype note
  /// Uses the same `E` associatedtype name as `Collection` to avoid a Swift
  /// generic-parameter mismatch when a class conforms to both `List` and `Queue`.
  public protocol Queue<E> : Collection {
    // E is inherited from Collection — no separate associatedtype needed.

    /// Inserts `elem` into the queue; throws if capacity constraints prevent it.
    func add(_ elem: E) throws -> Bool

    /// Retrieves, but does not remove, the head; throws if queue is empty.
    func element() throws -> E

    /// Inserts `elem`; returns `false` instead of throwing on failure.
    func offer(_ elem: E) -> Bool

    /// Retrieves, but does not remove, the head; returns `nil` if empty.
    func peek() -> E?

    /// Retrieves and removes the head; returns `nil` if empty.
    func poll() -> E?

    /// Retrieves and removes the head; throws if queue is empty.
    func remove() throws -> E
  }

}

