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
  public protocol SortedMap<K, V>: java.util.SequencedMap where K: Comparable {

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

    /// Returns the comparator used to order the keys in this map,
    /// or `nil` if it uses the keys' natural ordering.
    ///
    /// - Since: Java 1.2
    func comparator() -> (any java.util.Comparator<K>)?
  }
}

extension java.util.SortedMap {

  public func comparator() -> (any java.util.Comparator<K>)? { nil }

  // MARK: - SequencedMap defaults for SortedMap

  /// Default: entry with the first (lowest) key, or `nil` if empty.
  public func firstEntry() -> java.util.MapEntry<K, V>? {
    guard let key = try? firstKey(), let value = get(key) else { return nil }
    return java.util.MapEntry(key, value)
  }

  /// Default: entry with the last (highest) key, or `nil` if empty.
  public func lastEntry() -> java.util.MapEntry<K, V>? {
    guard let key = try? lastKey(), let value = get(key) else { return nil }
    return java.util.MapEntry(key, value)
  }

  /// Default: removes and returns the first entry, or `nil` if empty.
  public func pollFirstEntry() -> java.util.MapEntry<K, V>? {
    guard let key = try? firstKey(), let value = get(key) else { return nil }
    _ = remove(key)
    return java.util.MapEntry(key, value)
  }

  /// Default: removes and returns the last entry, or `nil` if empty.
  public func pollLastEntry() -> java.util.MapEntry<K, V>? {
    guard let key = try? lastKey(), let value = get(key) else { return nil }
    _ = remove(key)
    return java.util.MapEntry(key, value)
  }

  /// Default: not supported — concrete types must override.
  ///
  /// `TreeMap` provides a descending-order view in Phase 3.
  public func reversedMap() -> any java.util.SequencedMap<K, V> {
    fatalError("reversedMap() not implemented for \(type(of: self))")
  }

  /// Default: not supported — concrete types must override.
  public func sequencedKeySet() -> any java.util.SequencedSet<K> {
    fatalError("sequencedKeySet() not implemented for \(type(of: self))")
  }

  /// Default: not supported — concrete types must override.
  public func sequencedValues() -> any java.util.SequencedCollection<V> {
    fatalError("sequencedValues() not implemented for \(type(of: self))")
  }

  /// Default: not supported — concrete types must override.
  public func sequencedEntrySet() -> any java.util.SequencedSet<java.util.MapEntry<K, V>> {
    fatalError("sequencedEntrySet() not implemented for \(type(of: self))")
  }
}
