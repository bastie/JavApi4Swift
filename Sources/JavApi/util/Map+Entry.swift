/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - java.util.MapEntry<K,V>

extension java.util {

  /// A key-value pair contained in a `Map`.
  ///
  /// Mirrors `java.util.Map.Entry<K,V>` (Java 1.2).
  ///
  /// ### Java vs. Swift naming
  ///
  /// In Java, `Map.Entry` is a *nested interface* inside `Map`.  Swift protocols
  /// cannot contain nested protocol or type declarations whose generic parameters
  /// are independent of the outer protocol's associated types without triggering
  /// a "type cannot conform to itself" error.  Therefore `Entry` is declared as a
  /// standalone concrete type `java.util.MapEntry<K,V>` and aliased back into
  /// the `Map` protocol as `Entry` via a `typealias`.  From call sites the access
  /// path `HashMap<String,Int>.Entry` or `java.util.Map<String,Int>.Entry` still
  /// matches the Java `Map.Entry<K,V>` concept.
  ///
  /// ### Why `V: Equatable`?
  ///
  /// In Java every class inherits `equals(Object)` from `java.lang.Object`,
  /// so `Map.Entry` imposes no explicit constraint on `V`.  Swift has no such
  /// universal base class; equality must be declared via `Equatable`.  Because
  /// the enclosing `Map<K,V>` already requires `V: Equatable`, `MapEntry`
  /// inherits that constraint and synthesises `Equatable` conformance automatically.
  ///
  /// - Since: Java 1.2
  public struct MapEntry<K: Hashable, V: Equatable>: Equatable, Hashable {

    // MARK: - Storage

    /// The key of this entry.
    public let key: K

    /// The value of this entry.
    public private(set) var value: V

    /// Creates a new entry with the given key and value.
    public init(_ key: K, _ value: V) {
      self.key = key
      self.value = value
    }

    // MARK: - Java API

    /// Returns the key corresponding to this entry.
    ///
    /// - Since: Java 1.2
    public func getKey() -> K { key }

    /// Returns the value corresponding to this entry.
    ///
    /// - Since: Java 1.2
    public func getValue() -> V { value }

    /// Replaces the value corresponding to this entry with `newValue`.
    /// Returns the old value.
    ///
    /// - Since: Java 1.2
    @discardableResult
    public mutating func setValue(_ newValue: V) -> V {
      let old = value
      value = newValue
      return old
    }

    // MARK: - Hashable

    /// Hash derived from the key only.
    ///
    /// Java's `Map.Entry.hashCode()` XORs key and value hashes, but in Swift
    /// `V` is constrained only to `Equatable` (not `Hashable`) — see the
    /// `V: Equatable` design note above.  Using the key alone is safe: the
    /// `Hashable` contract requires `a == b → a.hashValue == b.hashValue`, and
    /// two equal entries always share the same key, so equal entries always hash
    /// identically.  Collisions for entries with equal keys but different values
    /// are harmless (a Map cannot hold duplicate keys, so this case never arises
    /// inside a well-formed `entrySet()`).
    public func hash(into hasher: inout Hasher) {
      hasher.combine(key)
    }

    // MARK: - Equatable

    /// Two entries are equal when both key and value are equal.
    ///
    /// Mirrors Java's `Map.Entry.equals(Object o)`.
    public static func == (lhs: MapEntry<K, V>, rhs: MapEntry<K, V>) -> Bool {
      lhs.key == rhs.key && lhs.value == rhs.value
    }
  }
}

// MARK: - Map.Entry comparators (Java 8)

extension java.util.MapEntry where K: Comparable {

  /// Returns a comparator that compares `Map.Entry` objects by key in natural order.
  ///
  /// Mirrors `java.util.Map.Entry.comparingByKey()` (Java 8).
  ///
  /// - Since: Java 8
  public static func comparingByKey() -> any java.util.Comparator<java.util.MapEntry<K, V>> {
    _EntryByKeyComparator<K, V>()
  }
}

extension java.util.MapEntry where V: Comparable {

  /// Returns a comparator that compares `Map.Entry` objects by value in natural order.
  ///
  /// Mirrors `java.util.Map.Entry.comparingByValue()` (Java 8).
  ///
  /// - Since: Java 8
  public static func comparingByValue() -> any java.util.Comparator<java.util.MapEntry<K, V>> {
    _EntryByValueComparator<K, V>()
  }
}

// MARK: - Private concrete comparator implementations

/// Compares `MapEntry` pairs by key in natural (ascending) order.
private final class _EntryByKeyComparator<K: Hashable & Comparable, V: Equatable>:
    java.util.Comparator, SortComparator, @unchecked Sendable {

  typealias T = java.util.MapEntry<K, V>
  var order: SortOrder = .forward

  func compare(_ lhs: T, _ rhs: T) -> Int {
    lhs.key < rhs.key ? -1 : lhs.key > rhs.key ? 1 : 0
  }
  func compare(_ lhs: T?, _ rhs: T?) -> Int {
    switch (lhs, rhs) {
    case (nil, nil): return 0
    case (nil, _):   return -1
    case (_, nil):   return  1
    default:         return compare(lhs!, rhs!)
    }
  }
  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    let r: Int = compare(lhs, rhs)
    return r < 0 ? .orderedAscending : r > 0 ? .orderedDescending : .orderedSame
  }
  static func == (lhs: _EntryByKeyComparator, rhs: _EntryByKeyComparator) -> Bool { lhs === rhs }
  func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
}

/// Compares `MapEntry` pairs by value in natural (ascending) order.
private final class _EntryByValueComparator<K: Hashable, V: Equatable & Comparable>:
    java.util.Comparator, SortComparator, @unchecked Sendable {

  typealias T = java.util.MapEntry<K, V>
  var order: SortOrder = .forward

  func compare(_ lhs: T, _ rhs: T) -> Int {
    lhs.value < rhs.value ? -1 : lhs.value > rhs.value ? 1 : 0
  }
  func compare(_ lhs: T?, _ rhs: T?) -> Int {
    switch (lhs, rhs) {
    case (nil, nil): return 0
    case (nil, _):   return -1
    case (_, nil):   return  1
    default:         return compare(lhs!, rhs!)
    }
  }
  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    let r: Int = compare(lhs, rhs)
    return r < 0 ? .orderedAscending : r > 0 ? .orderedDescending : .orderedSame
  }
  static func == (lhs: _EntryByValueComparator, rhs: _EntryByValueComparator) -> Bool { lhs === rhs }
  func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
}

// MARK: - typealias Entry in Map protocol

extension java.util.Map {
  /// Type alias that exposes `java.util.MapEntry<K,V>` as `Entry` on every
  /// concrete `Map` conformance — mirroring Java's `Map.Entry<K,V>` access path.
  public typealias Entry = java.util.MapEntry<K, V>
}
