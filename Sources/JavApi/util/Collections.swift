/*
 * SPDX-FileCopyrightText: 2023 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation   // for NSLock

extension java.util {

  /// Swift port of `java.util.Collections` (Java 1.2).
  open class Collections {

    // MARK: - Inner: UnmodifiableList

    /// Wrapper that throws `UnsupportedOperationException` on any mutating call.
    public final class UnmodifiableList<E: Equatable>: java.util.ArrayList<E> {

      private let delegate: java.util.ArrayList<E>

      public init(_ delegate: java.util.ArrayList<E>) {
        self.delegate = delegate
        super.init()
      }

      // Read-through
      public override func size() -> Int { delegate.size() }
      public override func isEmpty() -> Bool { delegate.isEmpty() }
      public override func get(_ location: Int) throws -> E? { try delegate.get(location) }
      public override func contains(_ element: E?) -> Bool { delegate.contains(element) }
      public override func indexOf(element: Any?) -> Int { delegate.indexOf(element: element) }
      public override func lastIndexOf(_ element: Any?) -> Int { delegate.lastIndexOf(element) }
      public override func toArray() -> [E?] { delegate.toArray() }
      public override func iterator() -> any java.util.Iterator<E> { delegate.iterator() }
      public override func listIterator() -> any java.util.ListIterator<E> { delegate.listIterator() }
      public override func listIterator(_ location: Int) -> any java.util.ListIterator<E> { delegate.listIterator(location) }
      public override func subList(_ start: Int, _ end: Int) -> any java.util.List { delegate.subList(start, end) }

      // Mutation — blocked
      public override func add(_ element: E?) throws -> Bool {
        throw UnsupportedOperationException("unmodifiable list")
      }
      public override func add(_ location: Int, _ element: E?) throws {
        throw UnsupportedOperationException("unmodifiable list")
      }
      public override func set(_ location: Int, _ element: E?) throws -> E? {
        throw UnsupportedOperationException("unmodifiable list")
      }
      public override func remove(_ location: Int) throws -> E? {
        throw UnsupportedOperationException("unmodifiable list")
      }
      @discardableResult
      public override func remove(_ element: E?) -> Bool {
        // cannot throw from non-throwing override, use fatalError to surface misuse
        fatalError("UnsupportedOperationException: unmodifiable list")
      }
      public override func clear() {
        fatalError("UnsupportedOperationException: unmodifiable list")
      }
    }

    // MARK: - Inner: SynchronizedList

    /// Wrapper that serialises every access with an `NSLock`.
    /// In Swift 6 strict-concurrency contexts callers must ensure the wrapped
    /// list itself is not accessed concurrently from outside this wrapper.
    public final class SynchronizedList<E: Equatable>: java.util.ArrayList<E> {

      private let delegate: java.util.ArrayList<E>
      private let lock = NSLock()

      public init(_ delegate: java.util.ArrayList<E>) {
        self.delegate = delegate
        super.init()
      }

      private func withLock<R>(_ body: () throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return try body()
      }

      public override func size() -> Int { withLock { delegate.size() } }
      public override func isEmpty() -> Bool { withLock { delegate.isEmpty() } }
      public override func get(_ location: Int) throws -> E? { try withLock { try delegate.get(location) } }
      public override func contains(_ element: E?) -> Bool { withLock { delegate.contains(element) } }
      public override func indexOf(element: Any?) -> Int { withLock { delegate.indexOf(element: element) } }
      public override func lastIndexOf(_ element: Any?) -> Int { withLock { delegate.lastIndexOf(element) } }
      public override func toArray() -> [E?] { withLock { delegate.toArray() } }
      public override func iterator() -> any java.util.Iterator<E> { withLock { delegate.iterator() } }

      public override func add(_ element: E?) throws -> Bool {
        try withLock { try delegate.add(element) }
      }
      public override func add(_ location: Int, _ element: E?) throws {
        try withLock { try delegate.add(location, element) }
      }
      public override func set(_ location: Int, _ element: E?) throws -> E? {
        try withLock { try delegate.set(location, element) }
      }
      public override func remove(_ location: Int) throws -> E? {
        try withLock { try delegate.remove(location) }
      }
      @discardableResult
      public override func remove(_ element: E?) -> Bool {
        withLock { delegate.remove(element) }
      }
      public override func clear() {
        withLock { delegate.clear() }
      }
    }

    // MARK: - Empty / Singleton factories

    /// Returns an empty, immutable Swift `Set`.
    public static func emptySet<E>() -> Swift.Set<E> {
      return Swift.Set<E>()
    }

    /// Returns an empty `ArrayList`.
    public static func emptyList<E: Equatable>() -> java.util.ArrayList<E> {
      return java.util.ArrayList<E>()
    }

    /// Returns an empty `HashMap`.
    public static func emptyMap<K: Hashable, V>() -> java.util.HashMap<K, V> {
      return java.util.HashMap<K, V>()
    }

    /// Returns an `ArrayList` containing only `element`.
    public static func singletonList<E: Equatable>(_ element: E) -> java.util.ArrayList<E> {
      let list = java.util.ArrayList<E>()
      _ = try? list.add(element)
      return list
    }

    /// Returns an `ArrayList` containing `count` copies of `element`.
    public static func nCopies<E: Equatable>(_ count: Int, _ element: E) -> java.util.ArrayList<E> {
      let list = java.util.ArrayList<E>(initialCapacity: count)
      for _ in 0..<count { _ = try? list.add(element) }
      return list
    }

    // MARK: - Unmodifiable / Synchronized wrappers

    /// Returns a wrapper that throws `UnsupportedOperationException` on mutation.
    public static func unmodifiableList<E: Equatable>(_ list: java.util.ArrayList<E>) -> java.util.ArrayList<E> {
      return UnmodifiableList(list)
    }

    /// Returns a wrapper that serialises all access with an `NSLock`.
    public static func synchronizedList<E: Equatable>(_ list: java.util.ArrayList<E>) -> java.util.ArrayList<E> {
      return SynchronizedList(list)
    }

    // MARK: - Sorting

    /// Sorts `list` in ascending natural order.
    public static func sort<E: Equatable & Comparable>(_ list: java.util.ArrayList<E>) {
      let sorted = list.toArray().compactMap { $0 }.sorted()
      list.clear()
      for element in sorted { _ = try? list.add(element) }
    }

    /// Sorts `list` using the supplied comparator closure.
    public static func sort<E: Equatable>(_ list: java.util.ArrayList<E>, _ comparator: (E, E) -> Int) {
      let sorted = list.toArray().compactMap { $0 }.sorted { comparator($0, $1) < 0 }
      list.clear()
      for element in sorted { _ = try? list.add(element) }
    }

    // MARK: - Order manipulation

    /// Reverses the order of elements in `list` in place.
    public static func reverse<E: Equatable>(_ list: java.util.ArrayList<E>) {
      let arr = list.toArray()
      list.clear()
      for element in arr.reversed() { _ = try? list.add(element ?? nil) }
    }

    /// Randomly permutes `list` using Fisher-Yates with the supplied `Random`.
    ///
    /// This matches the Java signature `Collections.shuffle(List<?>, Random)`.
    public static func shuffle<E: Equatable>(_ list: java.util.ArrayList<E>, _ rng: java.util.Random) {
      var arr = list.toArray()
      for i in stride(from: arr.count - 1, through: 1, by: -1) {
        let j = (try? rng.nextInt(i + 1)) ?? 0
        arr.swapAt(i, j)
      }
      list.clear()
      for element in arr { _ = try? list.add(element ?? nil) }
    }

    /// Randomly permutes `list` using Fisher-Yates with a default `java.util.Random`.
    ///
    /// Convenience overload matching Java's `Collections.shuffle(List<?>)`.
    public static func shuffle<E: Equatable>(_ list: java.util.ArrayList<E>) {
      shuffle(list, java.util.Random())
    }

    // MARK: - Search

    /// Binary search on a **sorted** list (natural ascending order).
    ///
    /// Returns a non-negative index if found, or `-(insertion point) - 1` if not found.
    public static func binarySearch<E: Equatable & Comparable>(_ list: java.util.ArrayList<E>, _ key: E) -> Int {
      var low = 0
      var high = list.size() - 1
      while low <= high {
        let mid = (low + high) >>> 1
        guard let midVal = try? list.get(mid) else { return -(low + 1) }
        if midVal < key       { low  = mid + 1 }
        else if midVal > key  { high = mid - 1 }
        else                  { return mid }
      }
      return -(low + 1)
    }

    /// Binary search using a supplied comparator on a sorted list.
    public static func binarySearch<E: Equatable>(_ list: java.util.ArrayList<E>, _ key: E, _ comparator: (E, E) -> Int) -> Int {
      var low = 0
      var high = list.size() - 1
      while low <= high {
        let mid = (low + high) >>> 1
        guard let midVal = try? list.get(mid) else { return -(low + 1) }
        let cmp = comparator(midVal, key)
        if cmp < 0       { low  = mid + 1 }
        else if cmp > 0  { high = mid - 1 }
        else             { return mid }
      }
      return -(low + 1)
    }

    // MARK: - Min / Max

    /// Returns the minimum element by natural order, or `nil` if the list is empty.
    public static func min<E: Equatable & Comparable>(_ list: java.util.ArrayList<E>) -> E? {
      return list.toArray().compactMap { $0 }.min()
    }

    /// Returns the maximum element by natural order, or `nil` if the list is empty.
    public static func max<E: Equatable & Comparable>(_ list: java.util.ArrayList<E>) -> E? {
      return list.toArray().compactMap { $0 }.max()
    }

    /// Returns the minimum element using the supplied comparator.
    public static func min<E: Equatable>(_ list: java.util.ArrayList<E>, _ comparator: (E, E) -> Int) -> E? {
      return list.toArray().compactMap { $0 }.min { comparator($0, $1) < 0 }
    }

    /// Returns the maximum element using the supplied comparator.
    public static func max<E: Equatable>(_ list: java.util.ArrayList<E>, _ comparator: (E, E) -> Int) -> E? {
      return list.toArray().compactMap { $0 }.max { comparator($0, $1) < 0 }
    }

    // MARK: - Frequency / Disjoint

    /// Returns the number of elements in `list` equal to `element`.
    public static func frequency<E: Equatable>(_ list: java.util.ArrayList<E>, _ element: E) -> Int {
      return list.toArray().compactMap { $0 }.filter { $0 == element }.count
    }

    /// Returns `true` if `a` and `b` have no elements in common.
    public static func disjoint<E: Equatable>(_ a: java.util.ArrayList<E>, _ b: java.util.ArrayList<E>) -> Bool {
      let setB = b.toArray().compactMap { $0 }
      return a.toArray().compactMap { $0 }.allSatisfy { !setB.contains($0) }
    }

    // MARK: - Fill / Copy

    /// Replaces every element in `list` with `element`.
    public static func fill<E: Equatable>(_ list: java.util.ArrayList<E>, _ element: E) {
      let count = list.size()
      list.clear()
      for _ in 0..<count { _ = try? list.add(element) }
    }

    /// Copies all elements from `src` into `dest` (dest must be at least as large as src).
    public static func copy<E: Equatable>(_ dest: java.util.ArrayList<E>, _ src: java.util.ArrayList<E>) {
      for (i, elem) in src.toArray().enumerated() {
        _ = try? dest.set(i, elem ?? nil)
      }
    }

    // MARK: - addAll (varargs convenience)

    /// Adds all supplied elements to `collection`. Returns `true` if the collection changed.
    @discardableResult
    public static func addAll<E: Equatable>(_ collection: java.util.ArrayList<E>, _ elements: E...) -> Bool {
      var changed = false
      for e in elements {
        if (try? collection.add(e)) == true { changed = true }
      }
      return changed
    }
  }
}
