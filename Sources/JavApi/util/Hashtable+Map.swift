/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Hashtable<K,V>: java.util.Map conformance (where V: Equatable)

/// Hashtable conforms to java.util.Map when its value type is Equatable.
///
/// The Map protocol already requires `V: Equatable` (see Map.swift) because
/// Swift has no universal `Object.equals` like Java.  Hashtable's own
/// `containsValue`, `equals`, and `hashCode` implementations also need `==`,
/// so the constraint is natural here.
extension java.util.Hashtable: java.util.Map where V: Equatable {

  // MARK: Map — Views

  /// Returns a `Set` view of the keys contained in this hashtable.
  ///
  /// - Since: Java 1.2
  public func keySet() -> any java.util.Set<K> {
    let set = java.util.HashSet<K>()
    withLock { for key in storage.keys { _ = try? set.add(key) } }
    return set
  }

  /// Returns a `Collection` view of the values contained in this hashtable.
  ///
  /// May contain duplicate values; the order is unspecified, as in Java.
  ///
  /// - Since: Java 1.2
  public func values() -> any java.util.Collection<V> {
    let list = java.util.ArrayList<V>()
    withLock { for value in storage.values { _ = try? list.add(value) } }
    return list
  }

  /// Returns a `Set` view of the key-value mappings in this hashtable.
  ///
  /// - Since: Java 1.2
  public func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> {
    let set = java.util.HashSet<java.util.MapEntry<K, V>>()
    withLock {
      for (key, value) in storage {
        _ = try? set.add(java.util.MapEntry(key, value))
      }
    }
    return set
  }

  // MARK: Map — Bulk mutation

  /// Copies all of the mappings from `map` into this hashtable.
  ///
  /// Existing mappings are overwritten by mappings in `map`.
  ///
  /// - Since: Java 1.2
  public func putAll(_ map: any java.util.Map<K, V>) {
    let entries = map.entrySet().iterator()
    while entries.hasNext() {
      if let e = try? entries.next() {
        _ = put(e.key, e.value)
      }
    }
  }

  // MARK: Equality and hashing

  /// Returns `true` if the given object is a map equal to this hashtable.
  ///
  /// Two maps are equal when they contain exactly the same key-value mappings,
  /// as defined by `java.util.AbstractMap.equals`.
  ///
  /// - Since: Java 1.0
  public func equals(_ other: any java.util.Map<K, V>) -> Bool {
    guard other.size() == size() else { return false }
    let it = other.entrySet().iterator()
    while it.hasNext() {
      guard let entry = try? it.next() else { return false }
      guard let v = get(entry.key), v == entry.value else { return false }
    }
    return true
  }

  /// Returns a hash code for this hashtable.
  ///
  /// The hash code is the sum of the hash codes of each entry in the map,
  /// as specified by `java.util.AbstractMap.hashCode`.
  ///
  /// - Since: Java 1.0
  public func hashCode() -> Int {
    withLock {
      var h = 0
      for (key, value) in storage {
        var entryHasher = Hasher()
        entryHasher.combine(key)
        if let hashableValue = value as? AnyHashable {
          entryHasher.combine(hashableValue)
        }
        h &+= entryHasher.finalize()
      }
      return h
    }
  }
}
