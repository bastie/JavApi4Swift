/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Hash-table backed implementation of `java.util.Set`.
  ///
  /// Backed internally by a `HashMap<E, AnyObject>` — the same design Java uses
  /// internally. A shared singleton object (`_PRESENT`) acts as the dummy value
  /// stored for every key. Only the key set is meaningful.
  ///
  /// Iteration order is undefined (matches Java semantics). Permits `nil`
  /// elements (matching Java's `HashSet`).
  ///
  /// - Since: Java 1.2
  open class HashSet<E: Hashable>: AbstractCollection<E> {

    // MARK: - Backing store

    /// Shared dummy value stored for every key — mirrors Java's `PRESENT` field.
    private static var _PRESENT: AnyObject { _SentinelObject.shared }

    internal var _map: HashMap<E, AnyObject>

    // MARK: - Init

    /// Creates an empty set with default initial capacity (16).
    public override init() {
      _map = HashMap<E, AnyObject>()
    }

    /// Creates an empty set with the given capacity hint.
    public init(initialCapacity: Int) {
      _map = HashMap<E, AnyObject>(initialCapacity: initialCapacity)
    }

    /// Creates a set containing all elements of `collection`.
    public init(collection: any java.util.Collection<E?>) {
      _map = HashMap<E, AnyObject>(initialCapacity: Swift.max(16, collection.size() * 2))
      super.init()
      let it = collection.iterator()
      while it.hasNext() {
        if let e = try? it.next() {
          _map.put(e, HashSet._PRESENT)
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
      _HashSetIterator(keys: Array(_map.keySet()))
    }

    // MARK: - Mutation

    /// Adds `element` to this set if not already present.
    ///
    /// - Returns: `true` if the set was modified (element was absent).
    @discardableResult
    open override func add(_ element: E?) throws -> Bool {
      guard let element else { return false }
      let previous = _map.put(element, HashSet._PRESENT)
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
      for key in _map.keySet() {
        copy._map.put(key, HashSet._PRESENT)
      }
      return copy
    }
  }
}

// MARK: - Private helpers

/// Singleton object used as the dummy map value (mirrors Java's `PRESENT`).
fileprivate final class _SentinelObject: @unchecked Sendable {
  static let shared = _SentinelObject()
  private init() {}
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
