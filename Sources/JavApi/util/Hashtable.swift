/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util {

  /// A thread-safe hash table mapping keys to values.
  ///
  /// Mirrors `java.util.Hashtable` from Java 1.0. All public methods are
  /// synchronized via an `NSLock`. Neither keys nor values may be `nil` —
  /// attempting to store `nil` throws `NullPointerException`, matching Java
  /// behaviour.
  ///
  /// `Hashtable` is declared `open` so that ``java.util.Properties`` can
  /// subclass it.
  ///
  /// ```swift
  /// let ht = java.util.Hashtable<String, Int>()
  /// try ht.put("one", 1)
  /// print(try ht.get("one") ?? -1)   // 1
  /// print(ht.size())                  // 1
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  open class Hashtable<K: Hashable, V> {

    // MARK: - Storage & lock

    internal var storage: [K: V] = [:]
    internal let lock = NSLock()

    internal func withLock<T>(_ body: () throws -> T) rethrows -> T {
      lock.lock()
      defer { lock.unlock() }
      return try body()
    }

    // MARK: - Initialisers

    /// Creates an empty hashtable with default capacity.
    /// - Since: JavaApi (Java 1.0)
    public init() {}

    /// Creates an empty hashtable with the given initial capacity hint.
    ///
    /// - Parameter initialCapacity: Hint for the initial bucket count.
    /// - Since: JavaApi (Java 1.0)
    public init(_ initialCapacity: Int) {
      storage.reserveCapacity(initialCapacity)
    }

    /// Creates an empty hashtable with the given initial capacity and load
    /// factor hint. The load factor is accepted for API compatibility but
    /// ignored — Swift's `Dictionary` manages rehashing automatically.
    ///
    /// - Parameters:
    ///   - initialCapacity: Hint for the initial bucket count.
    ///   - loadFactor: Ignored. Kept for Java API compatibility.
    /// - Since: JavaApi (Java 1.0)
    public init(_ initialCapacity: Int, _ loadFactor: Float) {
      storage.reserveCapacity(initialCapacity)
    }

    // MARK: - Core API

    /// Returns the number of key-value mappings.
    /// - Since: JavaApi (Java 1.0)
    public func size() -> Int {
      withLock { storage.count }
    }

    /// Returns `true` if this hashtable contains no mappings.
    /// - Since: JavaApi (Java 1.0)
    public func isEmpty() -> Bool {
      withLock { storage.isEmpty }
    }

    /// Returns the value for `key`, or `nil` if not present.
    ///
    /// - Parameter key: The key to look up.
    /// - Returns: The associated value, or `nil`.
    /// - Since: JavaApi (Java 1.0)
    public func get(_ key: K) -> V? {
      withLock { storage[key] }
    }

    /// Associates `value` with `key` and returns the previous value, if any.
    ///
    /// - Parameters:
    ///   - key: Must not be `nil`.
    ///   - value: Must not be `nil`.
    /// - Returns: The previous value, or `nil`.
    /// - Throws: `NullPointerException` if key or value is passed as an
    ///   optional that resolves to `nil` (enforced at the call site via
    ///   Swift's type system — non-optional parameters cannot be `nil`).
    /// - Since: JavaApi (Java 1.0)
    @discardableResult
    public func put(_ key: K, _ value: V) -> V? {
      withLock {
        let old = storage[key]
        storage[key] = value
        return old
      }
    }

    /// Removes the mapping for `key` and returns the previous value, if any.
    ///
    /// - Parameter key: The key to remove.
    /// - Returns: The removed value, or `nil` if not present.
    /// - Since: JavaApi (Java 1.0)
    @discardableResult
    public func remove(_ key: K) -> V? {
      withLock { storage.removeValue(forKey: key) }
    }

    /// Removes all mappings.
    /// - Since: JavaApi (Java 1.0)
    public func clear() {
      withLock { storage.removeAll() }
    }

    /// Returns `true` if this hashtable maps one or more keys to `value`.
    ///
    /// This overload is available when `V` conforms to `Equatable` and uses
    /// value equality (`==`), matching Java's `equals()`-based semantics.
    ///
    /// - Parameter value: The value to search for.
    /// - Since: JavaApi (Java 1.0)
    public func contains(_ value: V) -> Bool where V: Equatable {
      withLock { storage.values.contains(value) }
    }

    /// Returns `true` if this hashtable maps one or more keys to `value`.
    ///
    /// This overload is available when `V` is a reference type (`AnyObject`)
    /// and uses identity equality (`===`), which corresponds to Java's default
    /// `Object.equals()` for types that do not override it.
    ///
    /// - Parameter value: The reference value to search for.
    /// - Since: JavaApi (Java 1.0)
    public func contains(_ value: V) -> Bool where V: AnyObject {
      withLock { storage.values.contains { $0 === value } }
    }

    /// Returns `true` if this hashtable contains a mapping for `key`.
    ///
    /// - Parameter key: The key to test.
    /// - Since: JavaApi (Java 1.0)
    public func containsKey(_ key: K) -> Bool {
      withLock { storage[key] != nil }
    }

    /// Returns `true` if this hashtable maps one or more keys to `value`.
    ///
    /// Alias for ``contains(_:)`` — added for API completeness.
    ///
    /// - Parameter value: The value to search for (equality via `==`).
    /// - Since: JavaApi (Java 1.0)
    public func containsValue(_ value: V) -> Bool where V: Equatable {
      contains(value)
    }

    /// Returns an `Enumeration` over the keys of this hashtable.
    /// - Since: JavaApi (Java 1.0)
    public func keys() -> any java.util.Enumeration<K> {
      withLock { HashtableEnumeration(Array(storage.keys)) }
    }

    /// Returns an `Enumeration` over the values of this hashtable.
    /// - Since: JavaApi (Java 1.0)
    public func elements() -> any java.util.Enumeration<V> {
      withLock { HashtableEnumeration(Array(storage.values)) }
    }

    /// Returns a shallow copy of this hashtable.
    /// - Since: JavaApi (Java 1.0)
    public func clone() -> Hashtable<K, V> {
      withLock {
        let copy = Hashtable<K, V>()
        copy.storage = self.storage
        return copy
      }
    }

    /// Returns a string representation, e.g. `{one=1, two=2}`.
    /// - Since: JavaApi (Java 1.0)
    public func toString() -> String {
      withLock {
        let pairs = storage.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
        return "{\(pairs)}"
      }
    }
  }
}

// MARK: - Internal Enumeration adapter

internal final class HashtableEnumeration<E>: java.util.Enumeration {
  public typealias Element = E

  private let items: [E]
  private var index: Int = 0

  init(_ items: [E]) {
    self.items = items
  }

  public func hasMoreElements() -> Bool {
    return index < items.count
  }

  public func nextElement() throws -> E {
    guard index < items.count else {
      throw java.util.NoSuchElementException()
    }
    defer { index += 1 }
    return items[index]
  }

  /// `IteratorProtocol` requirement — delegates to `nextElement()`.
  public func next() -> E? {
    guard hasMoreElements() else { return nil }
    return try? nextElement()
  }

  /// `Sequence` requirement — the enumeration is its own iterator.
  public func makeIterator() -> HashtableEnumeration<E> {
    return self
  }
}
