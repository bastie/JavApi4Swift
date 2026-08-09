/*
 * SPDX-FileCopyrightText: 2023 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift protocol mirroring `java.util.Map<K,V>`.
  ///
  /// A map cannot contain duplicate keys; each key maps to at most one value.
  ///
  /// - Note: Concrete implementations such as `HashMap` and `TreeMap` inherit
  ///   from `AbstractMap`.
  ///
  /// > Note: **Why `V: Equatable`?**
  /// > In Java every object implicitly provides `equals(Object)` inherited from
  /// > `java.lang.Object`, so `Map<K,V>` places no explicit constraint on `V`.
  /// > Swift has no such universal base class; value equality must be stated
  /// > explicitly via the `Equatable` protocol.  Without this constraint the
  /// > compiler cannot synthesise `containsValue(_:)`, `values()` returning a
  /// > typed `Collection`, `entrySet()` returning a typed `Set`, or `equals(_:)`
  /// > on the map itself.  Adding `V: Equatable` is therefore the Swift-idiomatic
  /// > equivalent of Java's implicit `Object.equals` contract.
  ///
  /// - Since: Java 1.2
  public protocol Map<K, V> {
    associatedtype K: Hashable
    associatedtype V: Equatable

    // MARK: Query

    /// Returns the number of key-value mappings.
    func size() -> Int

    /// Returns `true` if this map contains no key-value mappings.
    func isEmpty() -> Bool

    /// Returns `true` if this map contains a mapping for `key`.
    func containsKey(_ key: K) -> Bool

    /// Returns `true` if this map maps one or more keys to `value`.
    func containsValue(_ value: V) -> Bool

    /// Returns the value to which `key` is mapped, or `nil`.
    func get(_ key: K) -> V?

    // MARK: Mutation

    /// Associates `value` with `key`. Returns the previous value, or `nil`.
    @discardableResult
    func put(_ key: K, _ value: V) -> V?

    /// Removes the mapping for `key`. Returns the previous value, or `nil`.
    @discardableResult
    func remove(_ key: K) -> V?

    /// Copies all mappings from `map` into this map.
    func putAll(_ map: any java.util.Map<K, V>)

    /// Removes all mappings.
    func clear()

    // MARK: Views

    /// Returns a `Set` view of the keys.
    func keySet() -> any java.util.Set<K>

    /// Returns a collection view of the values (may contain duplicates).
    func values() -> any java.util.Collection<V>

    /// Returns a `Set` view of all key-value mappings.
    ///
    /// In Java the return type is `Set<Map.Entry<K,V>>`.  Here it is
    /// `any java.util.Set<Entry<K,V>>` — `Entry` is `Hashable` because
    /// `K: Hashable` and `V: Equatable` (both constraints on this protocol).
    ///
    /// - Since: Java 1.2
    func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>>

    // MARK: Java 8 — conditional-mutation (protocol requirements for dynamic dispatch)

    /// Returns the value for `key`, or `defaultValue` if the key is absent.
    /// - Since: Java 8
    func getOrDefault(_ key: K, _ defaultValue: V) -> V

    /// Associates `key` with `value` only if `key` is not already present.
    /// Returns the existing value, or `nil` after inserting.
    /// - Since: Java 8
    @discardableResult
    func putIfAbsent(_ key: K, _ value: V) -> V?

    /// Replaces the value for `key` if present. Returns the previous value,
    /// or `nil` if the key was absent.
    /// - Since: Java 8
    @discardableResult
    func replace(_ key: K, _ value: V) -> V?

    /// Replaces the value for `key` only when it currently equals `oldValue`.
    /// Returns `true` on success.
    /// - Since: Java 8
    @discardableResult
    func replace(_ key: K, _ oldValue: V, _ newValue: V) -> Bool

    /// Removes the mapping for `key` only when it currently maps to `value`.
    /// Returns `true` if the mapping was removed.
    /// - Since: Java 8
    @discardableResult
    func remove(_ key: K, _ value: V) -> Bool
  }
}

// MARK: - Default implementations

extension java.util.Map {
  public func isEmpty() -> Bool { size() == 0 }

  // MARK: Java 8 default methods

  /// Returns the value for `key`, or `defaultValue` if the key is absent.
  ///
  /// Matches `java.util.Map.getOrDefault(Object, V)` (Java 8).
  public func getOrDefault(_ key: K, _ defaultValue: V) -> V {
    get(key) ?? defaultValue
  }

  /// If `key` is not already present (or maps to `nil`), associates it with
  /// `value` and returns `nil`; otherwise returns the existing value.
  ///
  /// Matches `java.util.Map.putIfAbsent(K, V)` (Java 8).
  @discardableResult
  public func putIfAbsent(_ key: K, _ value: V) -> V? {
    if let existing = get(key) { return existing }
    _ = put(key, value)
    return nil
  }

  /// If `key` is present, replaces its value with `value` and returns the
  /// old value; otherwise returns `nil` without modifying the map.
  ///
  /// Matches `java.util.Map.replace(K, V)` (Java 8).
  @discardableResult
  public func replace(_ key: K, _ value: V) -> V? {
    guard containsKey(key) else { return nil }
    return put(key, value)
  }

  /// If `key` currently maps to `oldValue`, replaces it with `newValue` and
  /// returns `true`; otherwise returns `false`.
  ///
  /// Matches `java.util.Map.replace(K, V, V)` (Java 8).
  @discardableResult
  public func replace(_ key: K, _ oldValue: V, _ newValue: V) -> Bool {
    guard get(key) == oldValue else { return false }
    _ = put(key, newValue)
    return true
  }

  /// If `key` currently maps to `value`, removes the mapping and returns
  /// `true`; otherwise returns `false`.
  ///
  /// Matches `java.util.Map.remove(Object, Object)` (Java 8).
  @discardableResult
  public func remove(_ key: K, _ value: V) -> Bool {
    guard get(key) == value else { return false }
    _ = remove(key)
    return true
  }
}
