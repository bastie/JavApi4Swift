/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Shorthand
private typealias C = java.util.Collections
private func list<E: Equatable>(_ elements: E...) -> java.util.ArrayList<E> {
  let l = java.util.ArrayList<E>()
  for e in elements { _ = try? l.add(e) }
  return l
}

struct JavApi_util_Collections_Tests {

  // MARK: - emptyList / emptySet / emptyMap

  @Test("emptyList returns size-0 list")
  func testEmptyList() {
    let l: java.util.ArrayList<Int> = C.emptyList()
    #expect(l.isEmpty())
    #expect(l.size() == 0)
  }

  @Test("emptySet returns empty Swift Set")
  func testEmptySet() {
    let s: Swift.Set<Int> = C.emptySet()
    #expect(s.isEmpty)
  }

  @Test("emptyMap returns empty HashMap")
  func testEmptyMap() {
    let m: java.util.HashMap<String, Int> = C.emptyMap()
    #expect(m.isEmpty())
  }

  // MARK: - singletonList

  @Test("singletonList contains exactly one element")
  func testSingletonList() throws {
    let l = C.singletonList(42)
    #expect(l.size() == 1)
    #expect(try l.get(0) == 42)
  }

  // MARK: - nCopies

  @Test("nCopies(0, _) returns empty list")
  func testNCopiesZero() {
    #expect(C.nCopies(0, "x").isEmpty())
  }

  @Test("nCopies(3, 'a') returns list with three 'a'")
  func testNCopies() throws {
    let l = C.nCopies(3, "a")
    #expect(l.size() == 3)
    #expect(try l.get(0) == "a")
    #expect(try l.get(2) == "a")
  }

  // MARK: - unmodifiableList

  @Test("unmodifiableList returns an UnmodifiableList instance")
  func testUnmodifiableListType() {
    let l = list(1, 2, 3)
    let wrapped = C.unmodifiableList(l)
    #expect(wrapped is java.util.Collections.UnmodifiableList<Int>)
  }

  @Test("unmodifiableList read-through: size and get work")
  func testUnmodifiableListRead() throws {
    let wrapped = C.unmodifiableList(list(10, 20, 30))
    #expect(wrapped.size() == 3)
    #expect(try wrapped.get(1) == 20)
  }

  @Test("unmodifiableList blocks add(_:)")
  func testUnmodifiableListBlocksAdd() {
    let wrapped = C.unmodifiableList(list(1, 2))
    #expect(throws: (any Error).self) { try wrapped.add(3) }
  }

  @Test("unmodifiableList blocks add(_:at:)")
  func testUnmodifiableListBlocksAddAtIndex() {
    let wrapped = C.unmodifiableList(list(1, 2))
    #expect(throws: (any Error).self) { try wrapped.add(0, 99) }
  }

  @Test("unmodifiableList blocks set(_:_:)")
  func testUnmodifiableListBlocksSet() {
    let wrapped = C.unmodifiableList(list(1, 2))
    #expect(throws: (any Error).self) { try wrapped.set(0, 99) }
  }

  @Test("unmodifiableList blocks remove(at:)")
  func testUnmodifiableListBlocksRemoveAt() {
    let wrapped = C.unmodifiableList(list(1, 2))
    #expect(throws: (any Error).self) { try wrapped.remove(0) }
  }

  // MARK: - synchronizedList

  @Test("synchronizedList returns a SynchronizedList instance")
  func testSynchronizedListType() {
    let wrapped = C.synchronizedList(list(1, 2, 3))
    #expect(wrapped is java.util.Collections.SynchronizedList<Int>)
  }

  @Test("synchronizedList read and write work correctly")
  func testSynchronizedListReadWrite() throws {
    let wrapped = C.synchronizedList(list(1, 2))
    _ = try wrapped.add(3)
    #expect(wrapped.size() == 3)
    #expect(try wrapped.get(2) == 3)
  }

  // MARK: - sort (natural order)

  @Test("sort orders integers ascending")
  func testSortInts() {
    let l = list(3, 1, 4, 1, 5, 9, 2, 6)
    C.sort(l)
    #expect(l.toArray().compactMap { $0 } == [1, 1, 2, 3, 4, 5, 6, 9])
  }

  @Test("sort on empty list does nothing")
  func testSortEmpty() {
    let l: java.util.ArrayList<Int> = C.emptyList()
    C.sort(l)
    #expect(l.isEmpty())
  }

  @Test("sort on single-element list is a no-op")
  func testSortSingleElement() throws {
    let l = list(7)
    C.sort(l)
    #expect(try l.get(0) == 7)
  }

  @Test("sort with comparator sorts strings by length descending")
  func testSortComparator() throws {
    let l = list("bb", "aaa", "c", "dddd")
    C.sort(l) { a, b in b.count - a.count }
    #expect(try l.get(0) == "dddd")
    #expect(try l.get(3) == "c")
  }

  // MARK: - reverse

  @Test("reverse flips element order")
  func testReverse() {
    let l = list(1, 2, 3, 4, 5)
    C.reverse(l)
    #expect(l.toArray().compactMap { $0 } == [5, 4, 3, 2, 1])
  }

  @Test("reverse on empty list does nothing")
  func testReverseEmpty() {
    let l: java.util.ArrayList<Int> = C.emptyList()
    C.reverse(l)
    #expect(l.isEmpty())
  }

  @Test("reverse on single-element list is a no-op")
  func testReverseSingle() throws {
    let l = list(42)
    C.reverse(l)
    #expect(try l.get(0) == 42)
  }

  // MARK: - shuffle (with java.util.Random)

  @Test("shuffle(list, rng) preserves all elements")
  func testShuffleWithRng() {
    let l = list(1, 2, 3, 4, 5)
    let rng = java.util.Random(42)
    C.shuffle(l, rng)
    #expect(l.size() == 5)
    for v in [1, 2, 3, 4, 5] { #expect(C.frequency(l, v) == 1) }
  }

  @Test("shuffle(list, rng) with seeded Random produces deterministic permutation")
  func testShuffleDeterministic() {
    let l1 = list(1, 2, 3, 4, 5)
    let l2 = list(1, 2, 3, 4, 5)
    C.shuffle(l1, java.util.Random(99))
    C.shuffle(l2, java.util.Random(99))
    #expect(l1.toArray().compactMap { $0 } == l2.toArray().compactMap { $0 })
  }

  @Test("shuffle() convenience overload preserves all elements")
  func testShuffleConvenience() {
    let l = list(10, 20, 30)
    C.shuffle(l)
    #expect(l.size() == 3)
    for v in [10, 20, 30] { #expect(C.frequency(l, v) == 1) }
  }

  // MARK: - binarySearch (natural order)

  @Test("binarySearch finds existing element")
  func testBinarySearchFound() {
    let l = list(1, 3, 5, 7, 9)
    #expect(C.binarySearch(l, 7) == 3)
  }

  @Test("binarySearch returns negative when not found")
  func testBinarySearchNotFound() {
    let l = list(1, 3, 5, 7, 9)
    let idx = C.binarySearch(l, 4)
    // insertion point 2 → -(2)-1 == -3
    #expect(idx == -3)
  }

  @Test("binarySearch on empty list returns -1")
  func testBinarySearchEmpty() {
    let l: java.util.ArrayList<Int> = C.emptyList()
    #expect(C.binarySearch(l, 0) == -1)
  }

  @Test("binarySearch with comparator finds element in descending list")
  func testBinarySearchComparator() {
    let l = list(9, 7, 5, 3, 1)
    #expect(C.binarySearch(l, 5) { a, b in b - a } == 2)
  }

  // MARK: - min / max

  @Test("min returns smallest element")
  func testMin() { #expect(C.min(list(3, 1, 4, 1, 5)) == 1) }

  @Test("max returns largest element")
  func testMax() { #expect(C.max(list(3, 1, 4, 1, 5)) == 5) }

  @Test("min on empty list returns nil")
  func testMinEmpty() { #expect(C.min(java.util.Collections.emptyList() as java.util.ArrayList<Int>) == nil) }

  @Test("max on empty list returns nil")
  func testMaxEmpty() { #expect(C.max(java.util.Collections.emptyList() as java.util.ArrayList<Int>) == nil) }

  @Test("min with comparator returns shortest string")
  func testMinComparator() {
    #expect(C.min(list("hello", "hi", "howdy")) { a, b in a.count - b.count } == "hi")
  }

  @Test("max with comparator returns longest string")
  func testMaxComparator() {
    #expect(C.max(list("hello", "hi", "howdy")) { a, b in a.count - b.count } == "hello")
  }

  // MARK: - frequency

  @Test("frequency counts occurrences correctly")
  func testFrequency() {
    let l = list(1, 2, 2, 3, 2)
    #expect(C.frequency(l, 2) == 3)
    #expect(C.frequency(l, 1) == 1)
    #expect(C.frequency(l, 9) == 0)
  }

  // MARK: - disjoint

  @Test("disjoint returns true for non-overlapping lists")
  func testDisjointTrue() {
    #expect(C.disjoint(list(1, 2, 3), list(4, 5, 6)))
  }

  @Test("disjoint returns false when lists share an element")
  func testDisjointFalse() {
    #expect(!C.disjoint(list(1, 2, 3), list(3, 4, 5)))
  }

  @Test("disjoint returns true when either list is empty")
  func testDisjointEmpty() {
    let empty: java.util.ArrayList<Int> = C.emptyList()
    #expect(C.disjoint(empty, list(1, 2)))
    #expect(C.disjoint(list(1, 2), empty))
  }

  // MARK: - fill

  @Test("fill replaces all elements")
  func testFill() throws {
    let l = list(1, 2, 3, 4)
    C.fill(l, 0)
    #expect(l.size() == 4)
    for i in 0..<4 { #expect(try l.get(i) == 0) }
  }

  @Test("fill on empty list does nothing")
  func testFillEmpty() {
    let l: java.util.ArrayList<Int> = C.emptyList()
    C.fill(l, 99)
    #expect(l.isEmpty())
  }

  // MARK: - copy

  @Test("copy transfers src elements into dest")
  func testCopy() throws {
    let src = list(10, 20, 30)
    let dest = list(0, 0, 0)
    C.copy(dest, src)
    #expect(try dest.get(0) == 10)
    #expect(try dest.get(1) == 20)
    #expect(try dest.get(2) == 30)
  }

  // MARK: - addAll (varargs)

  @Test("addAll appends variadic elements to collection")
  func testAddAll() throws {
    let l = java.util.ArrayList<Int>()
    let changed = C.addAll(l, 1, 2, 3)
    #expect(changed)
    #expect(l.size() == 3)
    #expect(try l.get(2) == 3)
  }
}
