/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Hash-table backed implementation of `java.util.Set`.
  ///
  /// Backed internally by a `HashMap<E, _SentinelObject>` — the same design Java
  /// uses internally (a dummy value is stored for every key; only the key set is
  /// meaningful).
  ///
  /// Iteration order is undefined (matches Java semantics).
  ///
  /// - Since: Java 1.2
  open class HashSet<E: Hashable>: AbstractSet<E> {

    // MARK: - Backing store

    internal var _map: HashMap<E, _SentinelObject>

    // MARK: - Init

    /// Creates an empty set with default initial capacity (16).
    public override init() {
      _map = HashMap<E, _SentinelObject>()
    }

    /// Creates an empty set with the given capacity hint.
    public init(initialCapacity: Int) {
      _map = HashMap<E, _SentinelObject>(initialCapacity: initialCapacity)
    }

    /// Creates a set containing all elements of `collection`.
    public init(collection: any java.util.Collection<E?>) {
      _map = HashMap<E, _SentinelObject>(initialCapacity: Swift.max(16, collection.size() * 2))
      super.init()
      let it = collection.iterator()
      while it.hasNext() {
        if let e = try? it.next() {
          _ = _map.put(e, .shared)
        }
      }
    }

    // MARK: - AbstractCollection — required overrides

    open override func size() -> Int {
      _map.size()
    }

    open override func isEmpty() -> Bool {
      _map.isEmpty()
    }

    open override func iterator() -> any java.util.Iterator<E> {
      // Access backing store directly to avoid infinite recursion:
      // entrySet() returns HashSet<MapEntry<E,_SentinelObject>>, whose iterator()
      // would call entrySet() again → infinite recursion.
      return _HashSetIterator(keys: Array(_map._store.keys))
    }

    // MARK: - Mutation

    /// Adds `element` to this set if not already present.
    ///
    /// - Returns: `true` if the set was modified (element was absent).
    @discardableResult
    open override func add(_ element: E?) throws -> Bool {
      guard let element else { return false }
      let previous = _map.put(element, .shared)
      return previous == nil
    }

    /// Removes `element` from this set.
    ///
    /// - Returns: `true` if the set contained the element.
    @discardableResult
    open override func remove(_ element: E?) -> Bool {
      guard let element else { return false }
      return _map.remove(element) != nil
    }

    /// Removes all elements from this set.
    public override func clear() {
      _map.clear()
    }

    // MARK: - Query

    open override func contains(_ element: E?) -> Bool {
      guard let element else { return false }
      return _map.containsKey(element)
    }

    // MARK: - Cloning

    /// Returns a shallow copy of this `HashSet`.
    open func clone() -> HashSet<E> {
      let copy = HashSet<E>(initialCapacity: _map.size() * 2)
      // Use backing store directly — see iterator() for why entrySet() must be avoided.
      for key in _map._store.keys {
        _ = copy._map.put(key, .shared)
      }
      return copy
    }

    // MARK: - Java 9 factory: Set.of(…)

    /// Returns an unmodifiable set containing the given elements.
    ///
    /// Null-hostile: `E` is non-optional so `nil` is a compile-time error.
    /// Throws `java.lang.IllegalArgumentException` if duplicate elements are provided.
    ///
    /// Mirrors `java.util.Set.of(E...)` (Java 9).
    ///
    /// - Parameter elements: The elements to include (must be distinct).
    /// - Returns: An unmodifiable `Set` containing `elements`.
    /// - Throws: `IllegalArgumentException` if any two elements are equal.
    /// - Since: Java 9
    public static func of(_ elements: E...) throws(java.lang.IllegalArgumentException) -> any java.util.Set<E> {
      let set = HashSet<E>(initialCapacity: Swift.max(16, elements.count * 2))
      for e in elements {
        let wasNew = (try? set.add(e)) ?? false
        if !wasNew {
          throw java.lang.IllegalArgumentException("duplicate element: \(e)")
        }
      }
      return java.util.Collections.unmodifiableSet(set)
    }

    // MARK: - Java 10 factory: Set.copyOf(…)

    /// Returns an unmodifiable set containing the elements of `collection`.
    ///
    /// Null elements cause a `NullPointerException` (null-hostile).
    /// Duplicate elements are silently de-duplicated (set semantics).
    ///
    /// Mirrors `java.util.Set.copyOf(Collection)` (Java 10).
    ///
    /// - Parameter collection: The collection whose elements to copy.
    /// - Returns: An unmodifiable `Set` containing the same distinct elements.
    /// - Since: Java 10
    public static func copyOf(_ collection: any java.util.Collection<E>) -> any java.util.Set<E> {
      let set = HashSet<E>(initialCapacity: Swift.max(16, collection.size() * 2))
      let it = collection.iterator()
      while it.hasNext() {
        if let element = try? it.next() {
          _ = try? set.add(element)
        }
      }
      return java.util.Collections.unmodifiableSet(set)
    }
  }
}

// MARK: - Private helpers

/// Singleton sentinel used as the dummy map value (mirrors Java's `PRESENT`).
///
/// Conforms to `Equatable` via reference identity — since there is only one
/// instance, all comparisons are trivially equal.
final class _SentinelObject: Equatable, @unchecked Sendable {
  static let shared = _SentinelObject()
  private init() {}
  static func == (lhs: _SentinelObject, rhs: _SentinelObject) -> Bool { true }
}

/// Snapshot iterator over a `HashSet`'s key array.
///
/// Conforms to both `java.util.Iterator` (throwing `next()`) and
/// `IteratorProtocol` (non-throwing `next() -> E?`) for Swift `for-in` support.
private final class _HashSetIterator<E: Hashable>: java.util.Iterator, IteratorProtocol {
  public typealias Element = E

  private let keys: [E]
  private var index: Int = 0

  init(keys: [E]) {
    self.keys = keys
  }

  public func hasNext() -> Bool {
    index < keys.count
  }

  public func next() throws(java.util.NoSuchElementException) -> E {
    guard index < keys.count else {
      throw java.util.NoSuchElementException()
    }
    defer { index += 1 }
    return keys[index]
  }

  /// `IteratorProtocol` — non-throwing, returns `nil` when exhausted.
  public func next() -> E? {
    guard index < keys.count else { return nil }
    defer { index += 1 }
    return keys[index]
  }

  public func remove() throws(java.lang.IllegalStateException) {
    throw java.lang.IllegalStateException("remove() not supported on snapshot iterator")
  }

  public func makeIterator() -> _HashSetIterator<E> { self }
}
