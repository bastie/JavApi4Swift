/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A `Map` with a well-defined encounter order that supports operations at both
  /// ends of the key sequence.  Part of the sequenced
  /// collections hierarchy.
  ///
  /// Endpoint-entry methods (`firstEntry`, `lastEntry`, `pollFirstEntry`,
  /// `pollLastEntry`) return `Entry<K,V>?` — `nil` where Java returns `null`.
  ///
  /// `putFirst` / `putLast` are optional operations; the default implementations
  /// throw `UnsupportedOperationException`, matching Java's behaviour for
  /// unmodifiable or unsorted views.
  ///
  /// - Since: Java 21
  public protocol SequencedMap<K, V>: java.util.Map {

    // MARK: - Endpoint entries

    /// - Returns: the entry with the first key in the encounter order, or `nil`.
    func firstEntry() -> java.util.MapEntry<K, V>?

    /// - Returns:  the entry with the last key in the encounter order, or `nil`.
    func lastEntry() -> java.util.MapEntry<K, V>?

    // MARK: - Polling

    /// Removes and returns the entry with the first key, or `nil`.
    func pollFirstEntry() -> java.util.MapEntry<K, V>?

    /// Removes and returns the entry with the last key, or `nil`.
    func pollLastEntry() -> java.util.MapEntry<K, V>?

    // MARK: - Endpoint mutation (optional operations)

    /// Associates `value` with `key`, inserting the mapping at the front
    /// of the encounter order (optional operation).
    func putFirst(_ key: K, _ value: V) throws -> V?

    /// Associates `value` with `key`, appending the mapping at the end
    /// of the encounter order (optional operation).
    func putLast(_ key: K, _ value: V) throws -> V?

    // MARK: - Reversed view

    /// Returns a reverse-order view of this map.
    func reversedMap() -> any java.util.SequencedMap<K, V>

    // MARK: - Sequenced views

    /// Returns a `SequencedSet` view of the keys in encounter order.
    func sequencedKeySet() -> any java.util.SequencedSet<K>

    /// Returns a `SequencedCollection` view of the values in encounter order.
    func sequencedValues() -> any java.util.SequencedCollection<V>

    /// Returns a `SequencedSet` view of the entries in encounter order.
    func sequencedEntrySet() -> any java.util.SequencedSet<java.util.MapEntry<K, V>>
  }
}

// MARK: - Default implementations

extension java.util.SequencedMap {

  /// Default: throws `UnsupportedOperationException`.
  public func putFirst(_ key: K, _ value: V) throws -> V? {
    throw java.lang.UnsupportedOperationException("putFirst not supported")
  }

  /// Default: throws `UnsupportedOperationException`.
  public func putLast(_ key: K, _ value: V) throws -> V? {
    throw java.lang.UnsupportedOperationException("putLast not supported")
  }
}
