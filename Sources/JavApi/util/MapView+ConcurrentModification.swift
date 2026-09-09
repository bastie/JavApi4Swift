/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Fail-fast support for Map views (keySet/entrySet/values)
//
// `HashMap`/`LinkedHashMap`'s `keySet()`/`entrySet()`/`values()` each return
// a freshly built, disconnected *snapshot* copy (a plain `HashSet`/`ArrayList`)
// rather than a view genuinely backed by the source map's storage — a
// pre-existing design choice in this port (documented at each call site to
// avoid an infinite-recursion trap between `entrySet()` and `HashSet.iterator()`).
//
// That means a snapshot's own `modCount` never changes after creation, so a
// plain `HashSet<K>`/`ArrayList<V>` copy alone cannot detect a structural
// modification of the *original* map the way `java.util.HashMap`'s live
// `keySet()`/`entrySet()`/`values()` views do. The three internal wrapper
// types below close that gap without a full live-view rewrite: they behave
// exactly like the plain snapshot copies (same storage, same Set/Collection
// semantics, inherited unchanged), but override `iterator()` to check the
// *originating* map's `modCount` instead of their own — so
// `for k in map.keySet() { map.remove(...) }` still throws
// `ConcurrentModificationException`, matching Java's fail-fast guarantee for
// these views.

/// Snapshot iterator that checks an externally supplied "current modCount"
/// closure (rather than an owner object's own stored property), so it can be
/// shared by every map-view wrapper regardless of the originating map's
/// concrete type (`HashMap`, `LinkedHashMap`, …).
internal final class _MapViewIterator<E>: java.util.Iterator, IteratorProtocol {
  public typealias Element = E

  private let elements: [E]
  private var index: Int = 0
  private let expectedModCount: Int
  private let currentModCount: () -> Int

  internal init(elements: [E], expectedModCount: Int, currentModCount: @escaping () -> Int) {
    self.elements = elements
    self.expectedModCount = expectedModCount
    self.currentModCount = currentModCount
  }

  public func hasNext() -> Bool { index < elements.count }

  /// Also throws `ConcurrentModificationException` (fail-fast) if the
  /// *originating* map was structurally modified since this view was
  /// created — see the file-level doc for why this snapshot iterator still
  /// performs that check.
  public func next() throws(java.lang.RuntimeException) -> E {
    guard expectedModCount == currentModCount() else { throw java.util.ConcurrentModificationException() }
    guard index < elements.count else { throw java.util.NoSuchElementException() }
    defer { index += 1 }
    return elements[index]
  }

  public func next() -> E? {
    guard index < elements.count else { return nil }
    defer { index += 1 }
    return elements[index]
  }

  public func remove() throws(java.lang.RuntimeException) {
    guard expectedModCount == currentModCount() else { throw java.util.ConcurrentModificationException() }
    throw java.lang.IllegalStateException("remove() not supported on this map-view snapshot iterator")
  }

  public func makeIterator() -> _MapViewIterator<E> { self }
}

extension java.util {

  /// `keySet()` wrapper — a `HashSet<K>` snapshot copy whose `iterator()`
  /// checks the originating map's `modCount`. See file-level doc.
  internal final class _MapKeySetView<K: Hashable>: HashSet<K> {
    // Keeps the caller-supplied ORDER (insertion order for LinkedHashMap,
    // sorted order for TreeMap) alongside the inherited HashSet storage.
    // Deriving the iterator's elements from the inherited `_map` (a plain
    // HashMap, i.e. an unordered Swift Dictionary underneath) would silently
    // drop that ordering guarantee, so this snapshot array is kept and used
    // directly instead.
    private let orderedKeys: [K]
    private let expectedModCount: Int
    private let currentModCount: () -> Int

    internal init(keys: [K], expectedModCount: Int, currentModCount: @escaping () -> Int) {
      self.orderedKeys = keys
      self.expectedModCount = expectedModCount
      self.currentModCount = currentModCount
      super.init(initialCapacity: Swift.max(16, keys.count * 2))
      for k in keys { _ = try? self.add(k) }
    }

    public override func iterator() -> any java.util.Iterator<K> {
      _MapViewIterator(elements: orderedKeys, expectedModCount: expectedModCount, currentModCount: currentModCount)
    }
  }

  /// `entrySet()` wrapper — a `HashSet<MapEntry<K,V>>` snapshot copy whose
  /// `iterator()` checks the originating map's `modCount`. See file-level doc.
  internal final class _MapEntrySetView<K: Hashable, V: Equatable>: HashSet<java.util.MapEntry<K, V>> {
    // See _MapKeySetView — keeps the caller-supplied ORDER separately from
    // the inherited (unordered) HashSet backing storage.
    private let orderedEntries: [java.util.MapEntry<K, V>]
    private let expectedModCount: Int
    private let currentModCount: () -> Int

    internal init(entries: [java.util.MapEntry<K, V>], expectedModCount: Int, currentModCount: @escaping () -> Int) {
      self.orderedEntries = entries
      self.expectedModCount = expectedModCount
      self.currentModCount = currentModCount
      super.init(initialCapacity: Swift.max(16, entries.count * 2))
      for e in entries { _ = try? self.add(e) }
    }

    public override func iterator() -> any java.util.Iterator<java.util.MapEntry<K, V>> {
      _MapViewIterator(elements: orderedEntries, expectedModCount: expectedModCount, currentModCount: currentModCount)
    }
  }

  /// `values()` wrapper — an `ArrayList<V>` snapshot copy whose `iterator()`
  /// checks the originating map's `modCount`. See file-level doc.
  internal final class _MapValuesView<V: Equatable>: ArrayList<V> {
    private let expectedModCount: Int
    private let currentModCount: () -> Int

    internal init(values: [V], expectedModCount: Int, currentModCount: @escaping () -> Int) {
      self.expectedModCount = expectedModCount
      self.currentModCount = currentModCount
      super.init(initialCapacity: Swift.max(10, values.count))
      for v in values { _ = try? self.add(v) }
    }

    public override func iterator() -> any java.util.Iterator<V> {
      _MapViewIterator(elements: self.elements.compactMap { $0 }, expectedModCount: expectedModCount, currentModCount: currentModCount)
    }
  }
}
