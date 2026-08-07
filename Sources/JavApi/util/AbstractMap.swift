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
  open class AbstractMap<K: Hashable, V: Equatable>: java.util.Map {

    public init() {}

    // MARK: - Abstract — subclasses MUST override

    /// Returns a `Set` view of all key-value pairs.
    ///
    /// This is the single abstract method of `AbstractMap`; every other default
    /// implementation is derived from it.  Subclasses must override this.
    ///
    /// - Since: Java 1.2
    open func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> {
      fatalError("entrySet() must be implemented by \(type(of: self))")
    }

    // MARK: - java.util.Map — Query (all derived from entrySet)

    open func size() -> Int {
      entrySet().size()
    }

    open func isEmpty() -> Bool {
      entrySet().isEmpty()
    }

    open func containsKey(_ key: K) -> Bool {
      let it = entrySet().iterator()
      while it.hasNext() {
        if let e = try? it.next(), e.key == key { return true }
      }
      return false
    }

    open func containsValue(_ value: V) -> Bool {
      let it = entrySet().iterator()
      while it.hasNext() {
        if let e = try? it.next(), e.value == value { return true }
      }
      return false
    }

    open func get(_ key: K) -> V? {
      let it = entrySet().iterator()
      while it.hasNext() {
        if let e = try? it.next(), e.key == key { return e.value }
      }
      return nil
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
      let it = map.keySet().iterator()
      while it.hasNext() {
        if let key = try? it.next(), let v = map.get(key) {
          _ = put(key, v)
        }
      }
    }

    open func clear() {
      let it = entrySet().iterator()
      var keys: [K] = []
      while it.hasNext() {
        if let e = try? it.next() { keys.append(e.key) }
      }
      for k in keys { _ = remove(k) }
    }

    // MARK: - java.util.Map — Views

    open func keySet() -> any java.util.Set<K> {
      let set = HashSet<K>(initialCapacity: Swift.max(16, size() * 2))
      let it = entrySet().iterator()
      while it.hasNext() {
        if let e = try? it.next() { _ = try? set.add(e.key) }
      }
      return set
    }

    open func values() -> any java.util.Collection<V> {
      let list = java.util.ArrayList<V>()
      let it = entrySet().iterator()
      while it.hasNext() {
        if let e = try? it.next() { _ = try? list.add(e.value) }
      }
      return list
    }

    // MARK: - equals / hashCode / toString

    /// Two maps are equal when they contain the same key→value mappings.
    open func equals(_ other: any java.util.Map<K, V>) -> Bool {
      guard other.size() == size() else { return false }
      let it = entrySet().iterator()
      while it.hasNext() {
        guard let e = try? it.next(),
              let v = other.get(e.key),
              v == e.value else { return false }
      }
      return true
    }

    open func toString() -> String {
      var parts: [String] = []
      let it = entrySet().iterator()
      while it.hasNext() {
        if let e = try? it.next() { parts.append("\(e.key)=\(e.value)") }
      }
      return "{\(parts.joined(separator: ", "))}"
    }
  }
}
