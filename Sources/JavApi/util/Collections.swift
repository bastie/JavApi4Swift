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

    // MARK: - Inner: UnmodifiableLinkedHashSet

    /// Wrapper around `LinkedHashSet` that throws `UnsupportedOperationException`
    /// on any mutating call (Java 21 `Collections.unmodifiableSequencedSet`).
    public final class UnmodifiableLinkedHashSet<E: Hashable>: java.util.LinkedHashSet<E> {

      private let delegate: java.util.LinkedHashSet<E>

      public init(_ delegate: java.util.LinkedHashSet<E>) {
        self.delegate = delegate
        super.init()
      }

      // Read-through
      public override func size() -> Int { delegate.size() }
      public override func isEmpty() -> Bool { delegate.isEmpty() }
      public override func contains(_ element: E?) -> Bool { delegate.contains(element) }
      public override func iterator() -> any java.util.Iterator<E> { delegate.iterator() }
      public override func toArray() -> [E?] { delegate.toArray() }
      public override func getFirst() throws -> E { try delegate.getFirst() }
      public override func getLast() throws -> E { try delegate.getLast() }
      public override func reversed() -> any java.util.SequencedCollection<E> { delegate.reversed() }
      public override func reversedSet() -> any java.util.SequencedSet<E> { delegate.reversedSet() }

      // Mutation — blocked
      public override func add(_ element: E?) throws -> Bool {
        throw UnsupportedOperationException("unmodifiable sequenced set")
      }
      @discardableResult
      public override func remove(_ element: E?) -> Bool {
        fatalError("UnsupportedOperationException: unmodifiable sequenced set")
      }
      public override func clear() {
        fatalError("UnsupportedOperationException: unmodifiable sequenced set")
      }
      public override func addFirst(_ e: E) throws {
        throw UnsupportedOperationException("unmodifiable sequenced set")
      }
      public override func addLast(_ e: E) throws {
        throw UnsupportedOperationException("unmodifiable sequenced set")
      }
      public override func removeFirst() throws -> E {
        throw UnsupportedOperationException("unmodifiable sequenced set")
      }
      public override func removeLast() throws -> E {
        throw UnsupportedOperationException("unmodifiable sequenced set")
      }
    }

    // MARK: - Inner: SynchronizedLinkedHashSet

    /// Wrapper around `LinkedHashSet` that serialises every access with an
    /// `NSLock` (Java 21 `Collections.synchronizedSequencedSet`).
    public final class SynchronizedLinkedHashSet<E: Hashable>: java.util.LinkedHashSet<E> {

      private let delegate: java.util.LinkedHashSet<E>
      private let lock = NSLock()

      public init(_ delegate: java.util.LinkedHashSet<E>) {
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
      public override func contains(_ element: E?) -> Bool { withLock { delegate.contains(element) } }
      public override func iterator() -> any java.util.Iterator<E> { withLock { delegate.iterator() } }
      public override func toArray() -> [E?] { withLock { delegate.toArray() } }
      public override func getFirst() throws -> E { try withLock { try delegate.getFirst() } }
      public override func getLast() throws -> E { try withLock { try delegate.getLast() } }
      public override func add(_ element: E?) throws -> Bool { try withLock { try delegate.add(element) } }
      @discardableResult
      public override func remove(_ element: E?) -> Bool { withLock { delegate.remove(element) } }
      public override func clear() { withLock { delegate.clear() } }
      public override func addFirst(_ e: E) throws { try withLock { try delegate.addFirst(e) } }
      public override func addLast(_ e: E) throws { try withLock { try delegate.addLast(e) } }
      public override func removeFirst() throws -> E { try withLock { try delegate.removeFirst() } }
      public override func removeLast() throws -> E { try withLock { try delegate.removeLast() } }
    }

    // MARK: - Inner: UnmodifiableLinkedHashMap

    /// Wrapper around `LinkedHashMap` that throws `UnsupportedOperationException`
    /// on any mutating call (Java 21 `Collections.unmodifiableSequencedMap`).
    public final class UnmodifiableLinkedHashMap<K: Hashable, V: Equatable>: java.util.LinkedHashMap<K, V> {

      private let delegate: java.util.LinkedHashMap<K, V>

      public override init(_ delegate: java.util.LinkedHashMap<K, V>) {
        self.delegate = delegate
        super.init()
      }

      // Satisfies `required init()` inherited from LinkedHashMap; not for direct use.
      public required init() {
        self.delegate = java.util.LinkedHashMap<K, V>()
        super.init()
      }

      // Read-through
      public override func size() -> Int { delegate.size() }
      public override func isEmpty() -> Bool { delegate.isEmpty() }
      public override func containsKey(_ key: K) -> Bool { delegate.containsKey(key) }
      public override func containsValue(_ value: V) -> Bool { delegate.containsValue(value) }
      public override func get(_ key: K) -> V? { delegate.get(key) }
      public override func keySet() -> any java.util.Set<K> { delegate.keySet() }
      public override func values() -> any java.util.Collection<V> { delegate.values() }
      public override func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> { delegate.entrySet() }
      public override func firstEntry() -> java.util.MapEntry<K, V>? { delegate.firstEntry() }
      public override func lastEntry() -> java.util.MapEntry<K, V>? { delegate.lastEntry() }
      public override func sequencedKeySet() -> any java.util.SequencedSet<K> { delegate.sequencedKeySet() }
      public override func sequencedValues() -> any java.util.SequencedCollection<V> { delegate.sequencedValues() }
      public override func sequencedEntrySet() -> any java.util.SequencedSet<java.util.MapEntry<K, V>> { delegate.sequencedEntrySet() }
      public override func reversedMap() -> any java.util.SequencedMap<K, V> { delegate.reversedMap() }

      // Mutation — blocked (non-throwing overrides use fatalError; throwing ones throw)
      @discardableResult
      public override func put(_ key: K, _ newValue: V) -> V? {
        fatalError("UnsupportedOperationException: unmodifiable sequenced map")
      }
      @discardableResult
      public override func remove(_ key: K) -> V? {
        fatalError("UnsupportedOperationException: unmodifiable sequenced map")
      }
      public override func clear() {
        fatalError("UnsupportedOperationException: unmodifiable sequenced map")
      }
      public override func putAll(_ map: any java.util.Map<K, V>) {
        fatalError("UnsupportedOperationException: unmodifiable sequenced map")
      }
      public override func pollFirstEntry() -> java.util.MapEntry<K, V>? {
        fatalError("UnsupportedOperationException: unmodifiable sequenced map")
      }
      public override func pollLastEntry() -> java.util.MapEntry<K, V>? {
        fatalError("UnsupportedOperationException: unmodifiable sequenced map")
      }
      @discardableResult
      public override func putFirst(_ key: K, _ value: V) throws -> V? {
        throw UnsupportedOperationException("unmodifiable sequenced map")
      }
      @discardableResult
      public override func putLast(_ key: K, _ value: V) throws -> V? {
        throw UnsupportedOperationException("unmodifiable sequenced map")
      }
    }

    // MARK: - Inner: SynchronizedLinkedHashMap

    /// Wrapper around `LinkedHashMap` that serialises every access with an
    /// `NSLock` (Java 21 `Collections.synchronizedSequencedMap`).
    public final class SynchronizedLinkedHashMap<K: Hashable, V: Equatable>: java.util.LinkedHashMap<K, V> {

      private let delegate: java.util.LinkedHashMap<K, V>
      private let lock = NSLock()

      public override init(_ delegate: java.util.LinkedHashMap<K, V>) {
        self.delegate = delegate
        super.init()
      }

      // Satisfies `required init()` inherited from LinkedHashMap; not for direct use.
      public required init() {
        self.delegate = java.util.LinkedHashMap<K, V>()
        super.init()
      }

      private func withLock<R>(_ body: () throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return try body()
      }

      public override func size() -> Int { withLock { delegate.size() } }
      public override func isEmpty() -> Bool { withLock { delegate.isEmpty() } }
      public override func containsKey(_ key: K) -> Bool { withLock { delegate.containsKey(key) } }
      public override func containsValue(_ value: V) -> Bool { withLock { delegate.containsValue(value) } }
      public override func get(_ key: K) -> V? { withLock { delegate.get(key) } }
      public override func keySet() -> any java.util.Set<K> { withLock { delegate.keySet() } }
      public override func values() -> any java.util.Collection<V> { withLock { delegate.values() } }
      public override func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> { withLock { delegate.entrySet() } }
      public override func firstEntry() -> java.util.MapEntry<K, V>? { withLock { delegate.firstEntry() } }
      public override func lastEntry() -> java.util.MapEntry<K, V>? { withLock { delegate.lastEntry() } }
      @discardableResult
      public override func put(_ key: K, _ newValue: V) -> V? { withLock { delegate.put(key, newValue) } }
      @discardableResult
      public override func remove(_ key: K) -> V? { withLock { delegate.remove(key) } }
      public override func clear() { withLock { delegate.clear() } }
      public override func putAll(_ map: any java.util.Map<K, V>) { withLock { delegate.putAll(map) } }
      public override func pollFirstEntry() -> java.util.MapEntry<K, V>? { withLock { delegate.pollFirstEntry() } }
      public override func pollLastEntry() -> java.util.MapEntry<K, V>? { withLock { delegate.pollLastEntry() } }
      @discardableResult
      public override func putFirst(_ key: K, _ value: V) throws -> V? { try withLock { try delegate.putFirst(key, value) } }
      @discardableResult
      public override func putLast(_ key: K, _ value: V) throws -> V? { try withLock { try delegate.putLast(key, value) } }
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

    // MARK: - Empty constants (Java 1.2)

    /// An immutable empty list (matches Java's `Collections.EMPTY_LIST`).
    ///
    /// Prefer the type-safe `emptyList()` method in generic code.
    /// Uses `AnyHashable` as element type since Java's version used raw types.
    public nonisolated(unsafe) static let EMPTY_LIST: java.util.ArrayList<AnyHashable> =
      java.util.ArrayList<AnyHashable>()

    /// An immutable empty set (matches Java's `Collections.EMPTY_SET`).
    ///
    /// Prefer the type-safe `emptySet()` method in generic code.
    public nonisolated(unsafe) static let EMPTY_SET: java.util.HashSet<AnyHashable> =
      java.util.HashSet<AnyHashable>()

    /// An immutable empty map (matches Java's `Collections.EMPTY_MAP`).
    ///
    /// Prefer the type-safe `emptyMap()` method in generic code.
    public nonisolated(unsafe) static let EMPTY_MAP: java.util.HashMap<AnyHashable, AnyHashable> =
      java.util.HashMap<AnyHashable, AnyHashable>()

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

    /// Returns an unmodifiable view of a `SequencedCollection` (Java 21).
    ///
    /// Delegates to `unmodifiableList` since `ArrayList` is the standard
    /// `SequencedCollection` implementation in this library.
    public static func unmodifiableSequencedCollection<E: Equatable>(
      _ c: java.util.ArrayList<E>
    ) -> java.util.ArrayList<E> {
      return UnmodifiableList(c)
    }

    /// Returns an unmodifiable view of a `SequencedSet` (Java 21).
    public static func unmodifiableSequencedSet<E: Hashable>(
      _ s: java.util.LinkedHashSet<E>
    ) -> java.util.LinkedHashSet<E> {
      return UnmodifiableLinkedHashSet(s)
    }

    /// Returns an unmodifiable view of a `SequencedMap` (Java 21).
    public static func unmodifiableSequencedMap<K: Hashable, V: Equatable>(
      _ m: java.util.LinkedHashMap<K, V>
    ) -> java.util.LinkedHashMap<K, V> {
      return UnmodifiableLinkedHashMap(m)
    }

    /// Returns a synchronised (thread-safe) view of a `SequencedCollection` (Java 21).
    ///
    /// Delegates to `synchronizedList` since `ArrayList` is the standard
    /// `SequencedCollection` implementation in this library.
    public static func synchronizedSequencedCollection<E: Equatable>(
      _ c: java.util.ArrayList<E>
    ) -> java.util.ArrayList<E> {
      return SynchronizedList(c)
    }

    /// Returns a synchronised (thread-safe) view of a `SequencedSet` (Java 21).
    public static func synchronizedSequencedSet<E: Hashable>(
      _ s: java.util.LinkedHashSet<E>
    ) -> java.util.LinkedHashSet<E> {
      return SynchronizedLinkedHashSet(s)
    }

    /// Returns a synchronised (thread-safe) view of a `SequencedMap` (Java 21).
    public static func synchronizedSequencedMap<K: Hashable, V: Equatable>(
      _ m: java.util.LinkedHashMap<K, V>
    ) -> java.util.LinkedHashMap<K, V> {
      return SynchronizedLinkedHashMap(m)
    }

    // MARK: - Ordering factories (Java 1.2)

    /// Returns a comparator that imposes the reverse of the natural ordering
    /// on a collection of `Comparable` objects.
    ///
    /// Matches `java.util.Collections.reverseOrder()` (Java 1.2).
    public static func reverseOrder<T: Comparable & Equatable>() -> any java.util.Comparator<T> {
      _ReverseNaturalComparator<T>()
    }

    /// Returns a comparator that imposes the reverse ordering of `cmp`.
    ///
    /// Matches `java.util.Collections.reverseOrder(Comparator<T>)` (Java 1.2).
    public static func reverseOrder<T>(_ cmp: any java.util.Comparator<T>) -> any java.util.Comparator<T> {
      cmp.reversed()
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

    // MARK: - Java 1.4 additions

    /// Swaps the elements at positions `i` and `j` in `list`.
    ///
    /// Matches `java.util.Collections.swap(List<?>, int, int)` (Java 1.4).
    /// - Throws: `IndexOutOfBoundsException` if either index is out of range.
    public static func swap<E: Equatable>(_ list: java.util.ArrayList<E>, _ i: Int, _ j: Int) throws {
      let tmp = try list.get(i)
      _ = try list.set(i, list.get(j))
      _ = try list.set(j, tmp)
    }

    /// Rotates the elements in `list` by `distance`.
    ///
    /// After the call, element at index `k` will be the element formerly at
    /// `(k - distance) mod size`. Positive `distance` rotates towards higher
    /// indices (last elements move to the front); negative rotates the other way.
    ///
    /// Matches `java.util.Collections.rotate(List<?>, int)` (Java 1.4).
    public static func rotate<E: Equatable>(_ list: java.util.ArrayList<E>, _ distance: Int) {
      let n = list.size()
      guard n > 1 else { return }
      var arr = list.toArray()
      // Normalize distance to [0, n) so we always rotate "right" by d positions
      let d = ((distance % n) + n) % n
      guard d != 0 else { return }
      // Take last d elements and prepend them
      let tail = Array(arr[(n - d)...])
      let head = Array(arr[..<(n - d)])
      arr = tail + head
      list.clear()
      for e in arr { _ = try? list.add(e) }
    }

    /// Replaces all occurrences of `oldVal` with `newVal` in `list`.
    ///
    /// Returns `true` if the list was modified.
    /// Matches `java.util.Collections.replaceAll(List<T>, T, T)` (Java 1.4).
    @discardableResult
    public static func replaceAll<E: Equatable>(
      _ list: java.util.ArrayList<E>, _ oldVal: E?, _ newVal: E?
    ) -> Bool {
      var changed = false
      for i in 0..<list.size() {
        if (try? list.get(i)) == oldVal {
          _ = try? list.set(i, newVal)
          changed = true
        }
      }
      return changed
    }

    /// Returns the starting index of the first occurrence of `target` as a
    /// contiguous subsequence of `source`, or `-1` if not found.
    ///
    /// Returns `0` if `target` is empty (consistent with Java behaviour).
    /// Matches `java.util.Collections.indexOfSubList(List<?>, List<?>)` (Java 1.4).
    public static func indexOfSubList<E: Equatable>(
      _ source: java.util.ArrayList<E>, _ target: java.util.ArrayList<E>
    ) -> Int {
      let s = source.toArray()
      let t = target.toArray()
      guard !t.isEmpty else { return 0 }
      guard s.count >= t.count else { return -1 }
      for i in 0...(s.count - t.count) {
        if s[i..<(i + t.count)].elementsEqual(t, by: { $0 == $1 }) { return i }
      }
      return -1
    }

    /// Returns the starting index of the last occurrence of `target` as a
    /// contiguous subsequence of `source`, or `-1` if not found.
    ///
    /// Returns `source.size()` if `target` is empty (consistent with Java behaviour).
    /// Matches `java.util.Collections.lastIndexOfSubList(List<?>, List<?>)` (Java 1.4).
    public static func lastIndexOfSubList<E: Equatable>(
      _ source: java.util.ArrayList<E>, _ target: java.util.ArrayList<E>
    ) -> Int {
      let s = source.toArray()
      let t = target.toArray()
      guard !t.isEmpty else { return s.count }
      guard s.count >= t.count else { return -1 }
      for i in stride(from: s.count - t.count, through: 0, by: -1) {
        if s[i..<(i + t.count)].elementsEqual(t, by: { $0 == $1 }) { return i }
      }
      return -1
    }
  }
}

// MARK: - Private helpers for Collections.reverseOrder()

/// Reverse-natural-order comparator used by `Collections.reverseOrder()`.
///
/// Mirrors the behaviour of `Comparator.reverseOrder()` (Java 8) but is
/// accessible as a concrete type from within `Collections`.
private final class _ReverseNaturalComparator<T: Comparable>:
  java.util.Comparator, SortComparator, @unchecked Sendable
{
  var order: SortOrder = .forward

  func compare(_ lhs: T, _ rhs: T) -> Int {
    lhs < rhs ? 1 : lhs > rhs ? -1 : 0
  }

  func compare(_ lhs: T?, _ rhs: T?) -> Int {
    switch (lhs, rhs) {
    case (nil, nil): return 0
    case (nil, _):   return 1   // nil sorts last in reverse order
    case (_, nil):   return -1
    default:         return compare(lhs!, rhs!)
    }
  }

  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    let r: Int = compare(lhs, rhs)
    return r < 0 ? .orderedAscending : r > 0 ? .orderedDescending : .orderedSame
  }

  // Two reverse-natural-order comparators for the same T are logically equal.
  static func == (lhs: _ReverseNaturalComparator<T>, rhs: _ReverseNaturalComparator<T>) -> Bool { true }
  func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(T.self)) }
}
