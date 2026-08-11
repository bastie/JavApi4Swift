/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A specialized `Map` implementation for use with enum-like keys.
  ///
  /// Keys must conform to `CaseIterable & Hashable`; this covers both Swift enums
  /// and any other type that enumerates its cases and provides hash-based equality.
  /// Storage is backed by an ordinal-indexed `[V?]` array for O(1) get/put/remove.
  ///
  /// Differences from `java.util.EnumMap`:
  /// - The key constraint is `CaseIterable & Hashable` rather than `java.lang.Enum`,
  ///   giving broader compatibility with plain Swift enums.
  /// - `keySet()` returns an `[K]` array rather than a Java `Set` view.
  /// - Iteration order follows `K.allCases` (declaration order), matching Java semantics.
  public final class EnumMap<K, V>
    where K: CaseIterable & Hashable, K.AllCases.Element == K {

    // MARK: - Storage

    private let _allCases: [K]
    private var _storage: [V?]

    // MARK: - Init

    /// Creates an empty `EnumMap`.
    public init() {
      _allCases = Array(K.allCases)
      _storage  = Array(repeating: nil, count: _allCases.count)
    }

    /// Creates a copy of an existing `EnumMap`.
    public convenience init(_ other: EnumMap<K, V>) {
      self.init()
      _storage = other._storage
    }

    // MARK: - Private helpers

    @inline(__always)
    private func _ordinal(of key: K) -> Int? {
      _allCases.firstIndex(of: key)
    }

    // MARK: - Core Map operations

    /// Associates `value` with `key`.  Returns the previous value, or `nil`.
    @discardableResult
    public func put(_ key: K, _ value: V) -> V? {
      guard let i = _ordinal(of: key) else { return nil }
      let old = _storage[i]
      _storage[i] = value
      return old
    }

    /// Returns the value mapped to `key`, or `nil` if absent.
    public func get(_ key: K) -> V? {
      guard let i = _ordinal(of: key) else { return nil }
      return _storage[i]
    }

    /// Removes the mapping for `key`.  Returns the previous value, or `nil`.
    @discardableResult
    public func remove(_ key: K) -> V? {
      guard let i = _ordinal(of: key) else { return nil }
      let old = _storage[i]
      _storage[i] = nil
      return old
    }

    /// Returns `true` if a mapping exists for `key`.
    public func containsKey(_ key: K) -> Bool {
      guard let i = _ordinal(of: key) else { return false }
      return _storage[i] != nil
    }

    /// Returns the number of key-value mappings.
    public func size() -> Int {
      _storage.reduce(0) { $0 + ($1 != nil ? 1 : 0) }
    }

    /// Returns `true` if the map contains no mappings.
    public func isEmpty() -> Bool {
      _storage.allSatisfy { $0 == nil }
    }

    /// Removes all mappings.
    public func clear() {
      for i in _storage.indices { _storage[i] = nil }
    }

    // MARK: - Bulk / view operations

    /// Returns all keys that currently have a mapping, in declaration order.
    public func keySet() -> [K] {
      _allCases.enumerated().compactMap { _storage[$0.offset] != nil ? $0.element : nil }
    }

    /// Returns all values in declaration-order of their keys.
    public func values() -> [V] {
      _storage.compactMap { $0 }
    }

    /// Returns all key-value pairs as tuples, in declaration order.
    public func entrySet() -> [(key: K, value: V)] {
      _allCases.enumerated().compactMap { pair -> (key: K, value: V)? in
        guard let v = _storage[pair.offset] else { return nil }
        return (key: pair.element, value: v)
      }
    }

    /// Applies `action` to each key-value pair.
    public func forEach(_ action: (K, V) -> Void) {
      for (k, v) in entrySet() { action(k, v) }
    }

    /// Returns `true` if any key maps to a value equal to `value`.
    public func containsValue(_ value: V) -> Bool where V: Equatable {
      _storage.contains { $0 == value }
    }

    // MARK: - putAll / replaceAll

    /// Copies all mappings from `other` into this map.
    public func putAll(_ other: EnumMap<K, V>) {
      for i in _storage.indices {
        if let v = other._storage[i] { _storage[i] = v }
      }
    }

    /// Replaces each value with the result of `transform(key, oldValue)`.
    public func replaceAll(_ transform: (K, V) -> V) {
      for i in _allCases.indices {
        if let v = _storage[i] { _storage[i] = transform(_allCases[i], v) }
      }
    }

    // MARK: - clone / equals / hashCode

    /// Returns a copy of this map.
    public func clone() -> EnumMap<K, V> { EnumMap(self) }

    public func equals(_ other: EnumMap<K, V>) -> Bool where V: Equatable {
      _storage.elementsEqual(other._storage) { $0 == $1 }
    }

    public func hashCode() -> Int where V: Hashable {
      var hasher = Hasher()
      for v in _storage { hasher.combine(v) }
      return hasher.finalize()
    }

    // MARK: - Subscript

    public subscript(_ key: K) -> V? {
      get { get(key) }
      set {
        if let v = newValue { put(key, v) }
        else { remove(key) }
      }
    }
  }
}
