/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Abstract base implementation of `java.util.Map`.
  ///
  /// Subclasses must implement `entrySet()` to return a `Set` view of key-value
  /// pairs, and `put(_:_:)` to support mutation. All other methods are derived
  /// from these two.  This mirrors the contract of Java's `AbstractMap`.
  ///
  /// Concrete subclasses (e.g. `HashMap`, `TreeMap`) override individual methods
  /// for better performance where the backing store allows it.
  ///
  /// - Since: Java 1.2
  open class AbstractMap<K: Hashable, V>: java.util.Map {

    public init() {}

    // MARK: - Abstract — subclasses MUST override

    /// Returns a `Set` view of all key-value pairs.
    ///
    /// This is the single abstract method of `AbstractMap`; every other default
    /// implementation is derived from it.
    open func entrySet() -> [(key: K, value: V)] {
      fatalError("entrySet() must be implemented by \(type(of: self))")
    }

    // MARK: - java.util.Map — Query (all derived from entrySet)

    open func size() -> Int {
      entrySet().count
    }

    open func isEmpty() -> Bool {
      entrySet().isEmpty
    }

    open func containsKey(_ key: K) -> Bool {
      entrySet().contains { $0.key == key }
    }

    /// Default fallback for non-`Equatable` value types — always returns `false`.
    /// Concrete subclasses whose `V` conforms to `Equatable` should override this.
    open func containsValue(_ value: V) -> Bool {
      false
    }

    open func get(_ key: K) -> V? {
      entrySet().first { $0.key == key }?.value
    }

    // MARK: - java.util.Map — Mutation (throw by default; override to enable)

    @discardableResult
    open func put(_ key: K, _ value: V) -> V? {
      fatalError("put(_:_:) must be implemented by \(type(of: self))")
    }

    @discardableResult
    open func remove(_ key: K) -> V? {
      fatalError("remove(_:) must be implemented by \(type(of: self))")
    }

    open func putAll(_ map: any java.util.Map<K, V>) {
      for key in map.keySet() {
        if let v = map.get(key) {
          _ = put(key, v)
        }
      }
    }

    open func clear() {
      for entry in entrySet() {
        _ = remove(entry.key)
      }
    }

    // MARK: - java.util.Map — Views

    open func keySet() -> Swift.Set<K> {
      Swift.Set(entrySet().map { $0.key })
    }

    open func values() -> [V] {
      entrySet().map { $0.value }
    }

    // MARK: - equals / hashCode / toString

    /// Two maps are equal when they contain the same key→value mappings.
    open func equals(_ other: any java.util.Map<K, V>) -> Bool where V: Equatable {
      guard other.size() == size() else { return false }
      for entry in entrySet() {
        guard let v = other.get(entry.key), v == entry.value else { return false }
      }
      return true
    }

    open func toString() -> String {
      let entries = entrySet().map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
      return "{\(entries)}"
    }
  }
}
