/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift protocol mirroring `java.util.SortedMap<K,V>`.
  ///
  /// A `Map` that maintains its keys in ascending order according to their
  /// natural ordering (`Comparable`). The `TreeMap` concrete implementation
  /// provides this contract.
  ///
  /// - Since: Java 1.2
  public protocol SortedMap<K, V>: java.util.Map where K: Comparable {

    // MARK: - Range views

    /// Returns a view of the portion of this map whose keys are strictly
    /// less than `toKey`.
    func headMap(_ toKey: K) -> any java.util.SortedMap<K, V>

    /// Returns a view of the portion of this map whose keys are greater
    /// than or equal to `fromKey`.
    func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V>

    /// Returns a view of the portion of this map whose keys range from
    /// `fromKey` (inclusive) to `toKey` (exclusive).
    func subMap(_ fromKey: K, _ toKey: K) -> any java.util.SortedMap<K, V>

    // MARK: - Endpoints

    /// Returns the first (lowest) key in this map.
    /// - Throws: `NoSuchElementException` if the map is empty.
    func firstKey() throws -> K

    /// Returns the last (highest) key in this map.
    /// - Throws: `NoSuchElementException` if the map is empty.
    func lastKey() throws -> K
  }
}
