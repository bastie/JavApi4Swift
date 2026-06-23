/*
 * SPDX-FileCopyrightText: 2023 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift protocol mirroring `java.util.Map<K,V>`.
  ///
  /// A map cannot contain duplicate keys; each key maps to at most one value.
  ///
  /// - Note: Swift's built-in `Dictionary` type satisfies this protocol
  ///   through `Dictionary+Java.swift`. Concrete implementations such as
  ///   `HashMap` and `TreeMap` inherit from `AbstractMap`.
  ///
  /// - Since: Java 1.2
  public protocol Map<K, V> {
    associatedtype K: Hashable
    associatedtype V

    // MARK: Query

    /// Returns the number of key-value mappings.
    func size() -> Int

    /// Returns `true` if this map contains no key-value mappings.
    func isEmpty() -> Bool

    /// Returns `true` if this map contains a mapping for `key`.
    func containsKey(_ key: K) -> Bool

    /// Returns `true` if this map maps one or more keys to `value`.
    /// Default implementation returns `false` for non-`Equatable` value types.
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
    func keySet() -> Swift.Set<K>

    /// Returns a collection of the values (may contain duplicates).
    func values() -> [V]
  }
}

// MARK: - Default implementations

extension java.util.Map {
  public func isEmpty() -> Bool { size() == 0 }
}
