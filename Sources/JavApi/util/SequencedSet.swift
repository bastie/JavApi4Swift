/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A `Set` that is also a `SequencedCollection` — it has a well-defined
  /// encounter order and contains no duplicate elements. 
  ///
  /// The `reversed()` method is narrowed to return
  /// `any java.util.SequencedSet<E>` instead of the broader
  /// `any java.util.SequencedCollection<E>`.
  ///
  /// - Since: Java 21
  public protocol SequencedSet<E>: java.util.SequencedCollection, java.util.Set {

    /// Returns a reverse-order view of this set as a `SequencedSet`.
    ///
    /// Overrides `SequencedCollection.reversed()` to narrow the return type.
    func reversedSet() -> any java.util.SequencedSet<E>
  }
}
