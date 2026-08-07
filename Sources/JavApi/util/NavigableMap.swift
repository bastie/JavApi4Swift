/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift protocol mirroring `java.util.NavigableMap<K,V>`.
  ///
  /// A `SortedMap` extended with navigation methods returning the closest matching
  /// entry or key for given search targets.  Methods `lowerEntry`, `floorEntry`,
  /// `ceilingEntry`, and `higherEntry` return an `Entry<K,V>?` — `nil` where Java
  /// would return `null`.  The polling methods remove and return the endpoint entry,
  /// or return `nil` if the map is empty.
  ///
  /// The inclusive range-view overloads (`subMap/headMap/tailMap` with boolean
  /// parameters) are the Java-6 additions that complement the Java-1.2 exclusive
  /// variants inherited from `SortedMap`.
  ///
  /// - Since: Java 6
  public protocol NavigableMap<K, V>: java.util.SortedMap {

    // MARK: - Closest-match navigation — entries

    /// Returns the entry with the greatest key strictly less than `key`, or `nil`.
    func lowerEntry(_ key: K) -> java.util.MapEntry<K, V>?

    /// Returns the entry with the greatest key less than or equal to `key`, or `nil`.
    func floorEntry(_ key: K) -> java.util.MapEntry<K, V>?

    /// Returns the entry with the least key greater than or equal to `key`, or `nil`.
    func ceilingEntry(_ key: K) -> java.util.MapEntry<K, V>?

    /// Returns the entry with the least key strictly greater than `key`, or `nil`.
    func higherEntry(_ key: K) -> java.util.MapEntry<K, V>?

    // MARK: - Closest-match navigation — keys only

    /// Returns the greatest key strictly less than `key`, or `nil`.
    func lowerKey(_ key: K) -> K?

    /// Returns the greatest key less than or equal to `key`, or `nil`.
    func floorKey(_ key: K) -> K?

    /// Returns the least key greater than or equal to `key`, or `nil`.
    func ceilingKey(_ key: K) -> K?

    /// Returns the least key strictly greater than `key`, or `nil`.
    func higherKey(_ key: K) -> K?

    // MARK: - Endpoint entries

    /// Returns the entry with the lowest key, or `nil` if the map is empty.
    func firstEntry() -> java.util.MapEntry<K, V>?

    /// Returns the entry with the highest key, or `nil` if the map is empty.
    func lastEntry() -> java.util.MapEntry<K, V>?

    // MARK: - Polling (removes and returns endpoint entry)

    /// Removes and returns the entry with the lowest key, or `nil`.
    func pollFirstEntry() -> java.util.MapEntry<K, V>?

    /// Removes and returns the entry with the highest key, or `nil`.
    func pollLastEntry() -> java.util.MapEntry<K, V>?

    // MARK: - Descending views

    /// Returns a reverse-order view of the mappings in this map.
    func descendingMap() -> any java.util.NavigableMap<K, V>

    /// Returns a `NavigableSet` view of the keys in descending order.
    func descendingKeySet() -> any java.util.NavigableSet<K>

    /// Returns a `NavigableSet` view of the keys in ascending order.
    func navigableKeySet() -> any java.util.NavigableSet<K>

    // MARK: - Range views (inclusive overloads, Java 6)

    /// Returns a view of the portion of this map whose keys range from
    /// `fromKey` to `toKey`.
    func subMap(_ fromKey: K, _ fromInclusive: Bool,
                _ toKey: K,   _ toInclusive: Bool) -> any java.util.NavigableMap<K, V>

    /// Returns a view of the portion of this map whose keys are less than
    /// (or equal to, if `inclusive`) `toKey`.
    func headMap(_ toKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V>

    /// Returns a view of the portion of this map whose keys are greater than
    /// (or equal to, if `inclusive`) `fromKey`.
    func tailMap(_ fromKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V>
  }
}

// MARK: - Default implementations (key-only from entry methods)

extension java.util.NavigableMap {

  public func lowerKey(_ key: K) -> K? { lowerEntry(key)?.key }
  public func floorKey(_ key: K) -> K? { floorEntry(key)?.key }
  public func ceilingKey(_ key: K) -> K? { ceilingEntry(key)?.key }
  public func higherKey(_ key: K) -> K? { higherEntry(key)?.key }
}
