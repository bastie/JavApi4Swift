/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Shorthand
private func list<E: Equatable>(_ elements: E...) -> java.util.ArrayList<E> {
  let l = java.util.ArrayList<E>()
  for e in elements { _ = try? l.add(e) }
  return l
}

struct JavApi_util_Collections_Tests {

  // MARK: - emptyList / emptySet / emptyMap

  @Test("emptyList returns size-0 list")
  func testEmptyList() {
    let l: java.util.ArrayList<Int> = java.util.Collections.emptyList()
    #expect(l.isEmpty())
    #expect(l.size() == 0)
  }

  @Test("emptySet returns empty Swift Set")
  func testEmptySet() {
    let s: Swift.Set<Int> = java.util.Collections.emptySet()
    #expect(s.isEmpty)
  }

  @Test("emptyMap returns empty HashMap")
  func testEmptyMap() {
    let m: java.util.HashMap<String, Int> = java.util.Collections.emptyMap()
    #expect(m.isEmpty())
  }

  // MARK: - singletonList

  @Test("singletonList contains exactly one element")
  func testSingletonList() throws {
    let l = java.util.Collections.singletonList(42)
    #expect(l.size() == 1)
    #expect(try l.get(0) == 42)
  }

  // MARK: - nCopies

  @Test("nCopies(0, _) returns empty list")
  func testNCopiesZero() {
    #expect(java.util.Collections.nCopies(0, "x").isEmpty())
  }

  @Test("nCopies(3, 'a') returns list with three 'a'")
  func testNCopies() throws {
    let l = java.util.Collections.nCopies(3, "a")
    #expect(l.size() == 3)
    #expect(try l.get(0) == "a")
    #expect(try l.get(2) == "a")
  }

  // MARK: - unmodifiableList

  @Test("unmodifiableList returns an UnmodifiableList instance")
  func testUnmodifiableListType() {
    let l = list(1, 2, 3)
    let wrapped = java.util.Collections.unmodifiableList(l)
    #expect(wrapped is java.util.Collections.UnmodifiableList<Int>)
  }

  @Test("unmodifiableList read-through: size and get work")
  func testUnmodifiableListRead() throws {
    let wrapped = java.util.Collections.unmodifiableList(list(10, 20, 30))
    #expect(wrapped.size() == 3)
    #expect(try wrapped.get(1) == 20)
  }

  @Test("unmodifiableList blocks add(_:)")
  func testUnmodifiableListBlocksAdd() {
    let wrapped = java.util.Collections.unmodifiableList(list(1, 2))
    #expect(throws: (any Error).self) { try wrapped.add(3) }
  }

  @Test("unmodifiableList blocks add(_:at:)")
  func testUnmodifiableListBlocksAddAtIndex() {
    let wrapped = java.util.Collections.unmodifiableList(list(1, 2))
    #expect(throws: (any Error).self) { try wrapped.add(0, 99) }
  }

  @Test("unmodifiableList blocks set(_:_:)")
  func testUnmodifiableListBlocksSet() {
    let wrapped = java.util.Collections.unmodifiableList(list(1, 2))
    #expect(throws: (any Error).self) { try wrapped.set(0, 99) }
  }

  @Test("unmodifiableList blocks remove(at:)")
  func testUnmodifiableListBlocksRemoveAt() {
    let wrapped = java.util.Collections.unmodifiableList(list(1, 2))
    #expect(throws: (any Error).self) { try wrapped.remove(0) }
  }

  // MARK: - synchronizedList

  @Test("synchronizedList returns a SynchronizedList instance")
  func testSynchronizedListType() {
    let wrapped = java.util.Collections.synchronizedList(list(1, 2, 3))
    #expect(wrapped is java.util.Collections.SynchronizedList<Int>)
  }

  @Test("synchronizedList read and write work correctly")
  func testSynchronizedListReadWrite() throws {
    let wrapped = java.util.Collections.synchronizedList(list(1, 2))
    _ = try wrapped.add(3)
    #expect(wrapped.size() == 3)
    #expect(try wrapped.get(2) == 3)
  }

  // MARK: - sort (natural order)

  @Test("sort orders integers ascending")
  func testSortInts() {
    let l = list(3, 1, 4, 1, 5, 9, 2, 6)
    java.util.Collections.sort(l)
    #expect(l.toArray().compactMap { $0 } == [1, 1, 2, 3, 4, 5, 6, 9])
  }

  @Test("sort on empty list does nothing")
  func testSortEmpty() {
    let l: java.util.ArrayList<Int> = java.util.Collections.emptyList()
    java.util.Collections.sort(l)
    #expect(l.isEmpty())
  }

  @Test("sort on single-element list is a no-op")
  func testSortSingleElement() throws {
    let l = list(7)
    java.util.Collections.sort(l)
    #expect(try l.get(0) == 7)
  }

  @Test("sort with comparator sorts strings by length descending")
  func testSortComparator() throws {
    let l = list("bb", "aaa", "c", "dddd")
    java.util.Collections.sort(l) { a, b in b.count - a.count }
    #expect(try l.get(0) == "dddd")
    #expect(try l.get(3) == "c")
  }

  // MARK: - reverse

  @Test("reverse flips element order")
  func testReverse() {
    let l = list(1, 2, 3, 4, 5)
    java.util.Collections.reverse(l)
    #expect(l.toArray().compactMap { $0 } == [5, 4, 3, 2, 1])
  }

  @Test("reverse on empty list does nothing")
  func testReverseEmpty() {
    let l: java.util.ArrayList<Int> = java.util.Collections.emptyList()
    java.util.Collections.reverse(l)
    #expect(l.isEmpty())
  }

  @Test("reverse on single-element list is a no-op")
  func testReverseSingle() throws {
    let l = list(42)
    java.util.Collections.reverse(l)
    #expect(try l.get(0) == 42)
  }

  // MARK: - shuffle (with java.util.Random)

  @Test("shuffle(list, rng) preserves all elements")
  func testShuffleWithRng() {
    let l = list(1, 2, 3, 4, 5)
    let rng = java.util.Random(42)
    java.util.Collections.shuffle(l, rng)
    #expect(l.size() == 5)
    for v in [1, 2, 3, 4, 5] { #expect(java.util.Collections.frequency(l, v) == 1) }
  }

  @Test("shuffle(list, rng) with seeded Random produces deterministic permutation")
  func testShuffleDeterministic() {
    let l1 = list(1, 2, 3, 4, 5)
    let l2 = list(1, 2, 3, 4, 5)
    java.util.Collections.shuffle(l1, java.util.Random(99))
    java.util.Collections.shuffle(l2, java.util.Random(99))
    #expect(l1.toArray().compactMap { $0 } == l2.toArray().compactMap { $0 })
  }

  @Test("shuffle() convenience overload preserves all elements")
  func testShuffleConvenience() {
    let l = list(10, 20, 30)
    java.util.Collections.shuffle(l)
    #expect(l.size() == 3)
    for v in [10, 20, 30] {
      #expect(java.util.Collections.frequency(l, v) == 1)
    }
  }

  // MARK: - binarySearch (natural order)

  @Test("binarySearch finds existing element")
  func testBinarySearchFound() {
    let l = list(1, 3, 5, 7, 9)
    #expect(java.util.Collections.binarySearch(l, 7) == 3)
  }

  @Test("binarySearch returns negative when not found")
  func testBinarySearchNotFound() {
    let l = list(1, 3, 5, 7, 9)
    let idx = java.util.Collections.binarySearch(l, 4)
    // insertion point 2 → -(2)-1 == -3
    #expect(idx == -3)
  }

  @Test("binarySearch on empty list returns -1")
  func testBinarySearchEmpty() {
    let l: java.util.ArrayList<Int> = java.util.Collections.emptyList()
    #expect(java.util.Collections.binarySearch(l, 0) == -1)
  }

  @Test("binarySearch with comparator finds element in descending list")
  func testBinarySearchComparator() {
    let l = list(9, 7, 5, 3, 1)
    #expect(java.util.Collections.binarySearch(l, 5) { a, b in b - a } == 2)
  }

  // MARK: - min / max

  @Test("min returns smallest element")
  func testMin() { #expect(java.util.Collections.min(list(3, 1, 4, 1, 5)) == 1) }

  @Test("max returns largest element")
  func testMax() { #expect(java.util.Collections.max(list(3, 1, 4, 1, 5)) == 5) }

  @Test("min on empty list returns nil")
  func testMinEmpty() { #expect(java.util.Collections.min(java.util.Collections.emptyList() as java.util.ArrayList<Int>) == nil) }

  @Test("max on empty list returns nil")
  func testMaxEmpty() { #expect(java.util.Collections.max(java.util.Collections.emptyList() as java.util.ArrayList<Int>) == nil) }

  @Test("min with comparator returns shortest string")
  func testMinComparator() {
    #expect(java.util.Collections.min(list("hello", "hi", "howdy")) { a, b in a.count - b.count } == "hi")
  }

  @Test("max with comparator returns longest string")
  func testMaxComparator() {
    #expect(java.util.Collections.max(list("hello", "hi", "howdy")) { a, b in a.count - b.count } == "hello")
  }

  // MARK: - frequency

  @Test("frequency counts occurrences correctly")
  func testFrequency() {
    let l = list(1, 2, 2, 3, 2)
    #expect(java.util.Collections.frequency(l, 2) == 3)
    #expect(java.util.Collections.frequency(l, 1) == 1)
    #expect(java.util.Collections.frequency(l, 9) == 0)
  }

  // MARK: - disjoint

  @Test("disjoint returns true for non-overlapping lists")
  func testDisjointTrue() {
    #expect(java.util.Collections.disjoint(list(1, 2, 3), list(4, 5, 6)))
  }

  @Test("disjoint returns false when lists share an element")
  func testDisjointFalse() {
    #expect(!java.util.Collections.disjoint(list(1, 2, 3), list(3, 4, 5)))
  }

  @Test("disjoint returns true when either list is empty")
  func testDisjointEmpty() {
    let empty: java.util.ArrayList<Int> = java.util.Collections.emptyList()
    #expect(java.util.Collections.disjoint(empty, list(1, 2)))
    #expect(java.util.Collections.disjoint(list(1, 2), empty))
  }

  // MARK: - fill

  @Test("fill replaces all elements")
  func testFill() throws {
    let l = list(1, 2, 3, 4)
    java.util.Collections.fill(l, 0)
    #expect(l.size() == 4)
    for i in 0..<4 { #expect(try l.get(i) == 0) }
  }

  @Test("fill on empty list does nothing")
  func testFillEmpty() {
    let l: java.util.ArrayList<Int> = java.util.Collections.emptyList()
    java.util.Collections.fill(l, 99)
    #expect(l.isEmpty())
  }

  // MARK: - copy

  @Test("copy transfers src elements into dest")
  func testCopy() throws {
    let src = list(10, 20, 30)
    let dest = list(0, 0, 0)
    java.util.Collections.copy(dest, src)
    #expect(try dest.get(0) == 10)
    #expect(try dest.get(1) == 20)
    #expect(try dest.get(2) == 30)
  }

  // MARK: - addAll (varargs)

  @Test("addAll appends variadic elements to collection")
  func testAddAll() throws {
    let l = java.util.ArrayList<Int>()
    let changed = java.util.Collections.addAll(l, 1, 2, 3)
    #expect(changed)
    #expect(l.size() == 3)
    #expect(try l.get(2) == 3)
  }

  // MARK: - reverseOrder()

  @Test("reverseOrder() sorts integers descending")
  func testReverseOrderInts() {
    let l = list(3, 1, 4, 1, 5, 9)
    let cmp = java.util.Collections.reverseOrder() as any java.util.Comparator<Int>
    java.util.Collections.sort(l) { cmp.compare($0, $1) }
    #expect(l.toArray().compactMap { $0 } == [9, 5, 4, 3, 1, 1])
  }

  @Test("reverseOrder() sorts strings descending")
  func testReverseOrderStrings() throws {
    let l = list("banana", "apple", "cherry")
    let cmp = java.util.Collections.reverseOrder() as any java.util.Comparator<String>
    java.util.Collections.sort(l) { cmp.compare($0, $1) }
    #expect(try l.get(0) == "cherry")
    #expect(try l.get(2) == "apple")
  }

  @Test("reverseOrder(_ cmp:) double-reversal yields ascending order")
  func testReverseOrderWrapsComparator() {
    let l = list(3, 1, 4, 1, 5)
    // reverseOrder() → descending; reverseOrder(descending) → ascending again
    let descCmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let ascCmp = java.util.Collections.reverseOrder(descCmp)
    java.util.Collections.sort(l) { ascCmp.compare($0, $1) }
    #expect(l.toArray().compactMap { $0 } == [1, 1, 3, 4, 5])
  }

  // MARK: - EMPTY_LIST / EMPTY_SET / EMPTY_MAP constants

  @Test("EMPTY_LIST is empty and is an ArrayList")
  func testEmptyListConstant() {
    let l = java.util.Collections.EMPTY_LIST
    #expect(l.isEmpty())
    #expect(l.size() == 0)
  }

  @Test("EMPTY_SET constant is empty")
  func testEmptySetConstant() {
    let s = java.util.Collections.EMPTY_SET
    #expect(s.isEmpty())
    #expect(s.size() == 0)
  }

  @Test("EMPTY_MAP constant is empty")
  func testEmptyMapConstant() {
    let m = java.util.Collections.EMPTY_MAP
    #expect(m.isEmpty())
    #expect(m.size() == 0)
  }

  // MARK: - unmodifiableSequencedCollection

  @Test("unmodifiableSequencedCollection returns UnmodifiableList")
  func testUnmodifiableSequencedCollection() {
    let l = list(1, 2, 3)
    let wrapped = java.util.Collections.unmodifiableSequencedCollection(l)
    #expect(wrapped is java.util.Collections.UnmodifiableList<Int>)
    #expect(wrapped.size() == 3)
    #expect(throws: (any Error).self) { try wrapped.add(4) }
  }

  // MARK: - unmodifiableSequencedSet

  @Test("unmodifiableSequencedSet returns UnmodifiableLinkedHashSet")
  func testUnmodifiableSequencedSet() throws {
    let s = java.util.LinkedHashSet<Int>()
    for v in [10, 20, 30] { _ = try s.add(v) }
    let wrapped = java.util.Collections.unmodifiableSequencedSet(s)
    #expect(wrapped is java.util.Collections.UnmodifiableLinkedHashSet<Int>)
    #expect(wrapped.size() == 3)
    #expect(wrapped.contains(20))
  }

  @Test("unmodifiableSequencedSet blocks add")
  func testUnmodifiableSequencedSetBlocksAdd() throws {
    let s = java.util.LinkedHashSet<Int>()
    _ = try s.add(1)
    let wrapped = java.util.Collections.unmodifiableSequencedSet(s)
    #expect(throws: (any Error).self) { try wrapped.add(2) }
  }

  @Test("unmodifiableSequencedSet blocks addFirst")
  func testUnmodifiableSequencedSetBlocksAddFirst() throws {
    let s = java.util.LinkedHashSet<Int>()
    _ = try s.add(1)
    let wrapped = java.util.Collections.unmodifiableSequencedSet(s)
    #expect(throws: (any Error).self) { try wrapped.addFirst(0) }
  }

  @Test("unmodifiableSequencedSet blocks removeFirst")
  func testUnmodifiableSequencedSetBlocksRemoveFirst() throws {
    let s = java.util.LinkedHashSet<Int>()
    _ = try s.add(1)
    let wrapped = java.util.Collections.unmodifiableSequencedSet(s)
    #expect(throws: (any Error).self) { try wrapped.removeFirst() }
  }

  @Test("unmodifiableSequencedSet read-through: getFirst / getLast")
  func testUnmodifiableSequencedSetReadThrough() throws {
    let s = java.util.LinkedHashSet<Int>()
    for v in [5, 3, 7] { _ = try s.add(v) }
    let wrapped = java.util.Collections.unmodifiableSequencedSet(s)
    #expect(try wrapped.getFirst() == 5)
    #expect(try wrapped.getLast() == 7)
  }

  // MARK: - unmodifiableSequencedMap

  @Test("unmodifiableSequencedMap returns UnmodifiableLinkedHashMap")
  func testUnmodifiableSequencedMap() {
    let m = java.util.LinkedHashMap<String, Int>()
    _ = m.put("a", 1); _ = m.put("b", 2)
    let wrapped = java.util.Collections.unmodifiableSequencedMap(m)
    #expect(wrapped is java.util.Collections.UnmodifiableLinkedHashMap<String, Int>)
    #expect(wrapped.size() == 2)
    #expect(wrapped.get("a") == 1)
  }

  @Test("unmodifiableSequencedMap read-through after wrap: get works")
  func testUnmodifiableSequencedMapGetWorks() {
    // put/remove/clear/pollFirst/pollLastEntry call fatalError (untestable without crashing),
    // so we verify that read operations work correctly on the wrapped map.
    let m = java.util.LinkedHashMap<String, Int>()
    _ = m.put("x", 1); _ = m.put("y", 2)
    let wrapped = java.util.Collections.unmodifiableSequencedMap(m)
    #expect(wrapped.get("x") == 1)
    #expect(wrapped.get("y") == 2)
    #expect(wrapped.containsKey("x"))
    #expect(!wrapped.containsKey("z"))
  }

  @Test("unmodifiableSequencedMap blocks putFirst/putLast via throws")
  func testUnmodifiableSequencedMapBlocksPutFirst() {
    let m = java.util.LinkedHashMap<String, Int>()
    _ = m.put("a", 1)
    let wrapped = java.util.Collections.unmodifiableSequencedMap(m)
    #expect(throws: (any Error).self) { try wrapped.putFirst("z", 99) }
    #expect(throws: (any Error).self) { try wrapped.putLast("z", 99) }
  }

  @Test("unmodifiableSequencedMap read-through: firstEntry / lastEntry")
  func testUnmodifiableSequencedMapReadThrough() {
    let m = java.util.LinkedHashMap<String, Int>()
    _ = m.put("first", 1); _ = m.put("last", 2)
    let wrapped = java.util.Collections.unmodifiableSequencedMap(m)
    #expect(wrapped.firstEntry()?.key == "first")
    #expect(wrapped.lastEntry()?.key == "last")
  }

  // MARK: - synchronizedSequencedCollection

  @Test("synchronizedSequencedCollection returns SynchronizedList")
  func testSynchronizedSequencedCollection() throws {
    let l = list(1, 2, 3)
    let wrapped = java.util.Collections.synchronizedSequencedCollection(l)
    #expect(wrapped is java.util.Collections.SynchronizedList<Int>)
    _ = try wrapped.add(4)
    #expect(wrapped.size() == 4)
  }

  // MARK: - synchronizedSequencedSet

  @Test("synchronizedSequencedSet returns SynchronizedLinkedHashSet")
  func testSynchronizedSequencedSet() throws {
    let s = java.util.LinkedHashSet<Int>()
    for v in [1, 2, 3] { _ = try s.add(v) }
    let wrapped = java.util.Collections.synchronizedSequencedSet(s)
    #expect(wrapped is java.util.Collections.SynchronizedLinkedHashSet<Int>)
    _ = try wrapped.add(4)
    #expect(wrapped.size() == 4)
    #expect(wrapped.contains(4))
  }

  @Test("synchronizedSequencedSet getFirst / getLast delegate correctly")
  func testSynchronizedSequencedSetFirstLast() throws {
    let s = java.util.LinkedHashSet<Int>()
    for v in [10, 20, 30] { _ = try s.add(v) }
    let wrapped = java.util.Collections.synchronizedSequencedSet(s)
    #expect(try wrapped.getFirst() == 10)
    #expect(try wrapped.getLast() == 30)
  }

  // MARK: - synchronizedSequencedMap

  @Test("synchronizedSequencedMap returns SynchronizedLinkedHashMap")
  func testSynchronizedSequencedMap() {
    let m = java.util.LinkedHashMap<String, Int>()
    _ = m.put("a", 1)
    let wrapped = java.util.Collections.synchronizedSequencedMap(m)
    #expect(wrapped is java.util.Collections.SynchronizedLinkedHashMap<String, Int>)
    _ = wrapped.put("b", 2)
    #expect(wrapped.size() == 2)
    #expect(wrapped.get("b") == 2)
  }

  @Test("synchronizedSequencedMap firstEntry / lastEntry work correctly")
  func testSynchronizedSequencedMapFirstLast() {
    let m = java.util.LinkedHashMap<String, Int>()
    _ = m.put("first", 1); _ = m.put("last", 2)
    let wrapped = java.util.Collections.synchronizedSequencedMap(m)
    #expect(wrapped.firstEntry()?.key == "first")
    #expect(wrapped.lastEntry()?.key == "last")
  }

  // MARK: - Collection.toArray(_ generator:) — Java 11

  @Test("toArray(generator:) returns all elements via ArrayList")
  func testToArrayGenerator() {
    let l = list(10, 20, 30)
    let result = l.toArray { _ in [Int]() }
    #expect(result == [10, 20, 30])
  }

  @Test("toArray(generator:) on empty collection returns empty array")
  func testToArrayGeneratorEmpty() {
    let l: java.util.ArrayList<Int> = java.util.ArrayList()
    let result = l.toArray { _ in [Int]() }
    #expect(result.isEmpty)
  }

  @Test("toArray(generator:) generator closure receives collection size")
  func testToArrayGeneratorReceivesSize() {
    let l = list(1, 2, 3, 4, 5)
    var capturedSize = -1
    _ = l.toArray { size in
      capturedSize = size
      return [Int]()
    }
    #expect(capturedSize == 5)
  }

  @Test("toArray(generator:) works on LinkedHashSet")
  func testToArrayGeneratorLinkedHashSet() throws {
    let s = java.util.LinkedHashSet<String>()
    for v in ["x", "y", "z"] { _ = try s.add(v) }
    let result = s.toArray { _ in [String]() }
    #expect(result.count == 3)
    #expect(Set(result) == Set(["x", "y", "z"]))
  }

  // MARK: - Java 1.4: swap / rotate / replaceAll / indexOfSubList

  @Test("swap exchanges two elements")
  func testSwap() throws {
    let l = list(1, 2, 3, 4, 5)
    try java.util.Collections.swap(l, 1, 3)
    #expect(l.toArray().compactMap { $0 } == [1, 4, 3, 2, 5])
  }

  @Test("swap same index is no-op")
  func testSwapSameIndex() throws {
    let l = list(10, 20, 30)
    try java.util.Collections.swap(l, 1, 1)
    #expect(l.toArray().compactMap { $0 } == [10, 20, 30])
  }

  @Test("rotate positive distance moves tail to front")
  func testRotatePositive() {
    let l = list(1, 2, 3, 4, 5)
    java.util.Collections.rotate(l, 2)
    // [4,5] prepended: [4,5,1,2,3]
    #expect(l.toArray().compactMap { $0 } == [4, 5, 1, 2, 3])
  }

  @Test("rotate negative distance moves head to back")
  func testRotateNegative() {
    let l = list(1, 2, 3, 4, 5)
    java.util.Collections.rotate(l, -2)
    // Equivalent to rotate by +3: [3,4,5] prepended: [3,4,5,1,2]
    #expect(l.toArray().compactMap { $0 } == [3, 4, 5, 1, 2])
  }

  @Test("rotate by 0 is no-op")
  func testRotateZero() {
    let l = list(1, 2, 3)
    java.util.Collections.rotate(l, 0)
    #expect(l.toArray().compactMap { $0 } == [1, 2, 3])
  }

  @Test("rotate by list size is no-op")
  func testRotateFullCycle() {
    let l = list(1, 2, 3)
    java.util.Collections.rotate(l, 3)
    #expect(l.toArray().compactMap { $0 } == [1, 2, 3])
  }

  @Test("replaceAll replaces matching elements and returns true")
  func testReplaceAll() {
    let l = list(1, 2, 3, 2, 4)
    let changed = java.util.Collections.replaceAll(l, 2, 99)
    #expect(changed == true)
    #expect(l.toArray().compactMap { $0 } == [1, 99, 3, 99, 4])
  }

  @Test("replaceAll with no match returns false and leaves list unchanged")
  func testReplaceAllNoMatch() {
    let l = list(1, 2, 3)
    let changed = java.util.Collections.replaceAll(l, 9, 99)
    #expect(changed == false)
    #expect(l.toArray().compactMap { $0 } == [1, 2, 3])
  }

  @Test("indexOfSubList finds first occurrence")
  func testIndexOfSubList() {
    let src = list(1, 2, 3, 4, 3, 4, 5)
    let tgt = list(3, 4)
    #expect(java.util.Collections.indexOfSubList(src, tgt) == 2)
  }

  @Test("indexOfSubList returns -1 when not found")
  func testIndexOfSubListNotFound() {
    let src = list(1, 2, 3)
    let tgt = list(4, 5)
    #expect(java.util.Collections.indexOfSubList(src, tgt) == -1)
  }

  @Test("indexOfSubList with empty target returns 0")
  func testIndexOfSubListEmptyTarget() {
    let src = list(1, 2, 3)
    let tgt = java.util.ArrayList<Int>()
    #expect(java.util.Collections.indexOfSubList(src, tgt) == 0)
  }

  @Test("lastIndexOfSubList finds last occurrence")
  func testLastIndexOfSubList() {
    let src = list(1, 2, 3, 4, 3, 4, 5)
    let tgt = list(3, 4)
    #expect(java.util.Collections.lastIndexOfSubList(src, tgt) == 4)
  }

  @Test("lastIndexOfSubList returns -1 when not found")
  func testLastIndexOfSubListNotFound() {
    let src = list(1, 2, 3)
    let tgt = list(4, 5)
    #expect(java.util.Collections.lastIndexOfSubList(src, tgt) == -1)
  }

  @Test("lastIndexOfSubList with empty target returns source.size()")
  func testLastIndexOfSubListEmptyTarget() {
    let src = list(1, 2, 3)
    let tgt = java.util.ArrayList<Int>()
    #expect(java.util.Collections.lastIndexOfSubList(src, tgt) == 3)
  }

  // MARK: - singleton / singletonMap (P3)

  @Test("singleton returns size-1 unmodifiable HashSet containing the element")
  func testSingleton() throws {
    let s = java.util.Collections.singleton(42)
    #expect(s.size() == 1)
    #expect(s.contains(42))
    #expect(!s.contains(99))
    #expect(throws: (any Error).self) { try s.add(43) }
  }

  @Test("singletonMap returns size-1 unmodifiable HashMap")
  func testSingletonMap() {
    let m = java.util.Collections.singletonMap("key", 99)
    #expect(m.size() == 1)
    #expect(m.get("key") == 99)
    #expect(m.containsKey("key"))
    #expect(!m.containsKey("missing"))
  }

  // MARK: - unmodifiableSet / unmodifiableMap (P3)

  @Test("unmodifiableSet wraps HashSet with read-through and blocked add")
  func testUnmodifiableSet() throws {
    let s = java.util.HashSet<Int>()
    _ = try s.add(1); _ = try s.add(2); _ = try s.add(3)
    let wrapped = java.util.Collections.unmodifiableSet(s)
    #expect(wrapped.size() == 3)
    #expect(wrapped.contains(2))
    #expect(!wrapped.contains(9))
    #expect(throws: (any Error).self) { try wrapped.add(4) }
  }

  @Test("unmodifiableMap wraps HashMap with read-through")
  func testUnmodifiableMap() {
    let m = java.util.HashMap<String, Int>()
    _ = m.put("a", 1); _ = m.put("b", 2)
    let wrapped = java.util.Collections.unmodifiableMap(m)
    #expect(wrapped.size() == 2)
    #expect(wrapped.get("a") == 1)
    #expect(wrapped.containsKey("b"))
  }

  // MARK: - synchronizedSet / synchronizedMap (P3)

  @Test("synchronizedSet wraps HashSet and allows mutations")
  func testSynchronizedSet() throws {
    let s = java.util.HashSet<Int>()
    _ = try s.add(1)
    let wrapped = java.util.Collections.synchronizedSet(s)
    _ = try wrapped.add(2)
    #expect(wrapped.size() == 2)
    #expect(wrapped.contains(2))
    _ = wrapped.remove(1)
    #expect(wrapped.size() == 1)
  }

  @Test("synchronizedMap wraps HashMap and allows mutations")
  func testSynchronizedMap() {
    let m = java.util.HashMap<String, Int>()
    let wrapped = java.util.Collections.synchronizedMap(m)
    _ = wrapped.put("x", 10)
    #expect(wrapped.get("x") == 10)
    _ = wrapped.remove("x")
    #expect(wrapped.containsKey("x") == false)
  }

  // MARK: - enumeration / list (P3)

  @Test("enumeration wraps ArrayList and iterates all elements")
  func testEnumeration() throws {
    let l = list(10, 20, 30)
    var e = java.util.Collections.enumeration(l)
    var collected: [Int] = []
    while e.hasMoreElements() {
      collected.append(try e.nextElement())
    }
    #expect(collected == [10, 20, 30])
  }

  @Test("list converts Enumeration back to ArrayList")
  func testListFromEnumeration() throws {
    let original = list(5, 6, 7)
    let e = java.util.Collections.enumeration(original)
    let result: java.util.ArrayList<Int> = java.util.Collections.list(e)
    #expect(result.size() == 3)
    #expect(try result.get(0) == 5)
    #expect(try result.get(2) == 7)
  }

  @Test("list from empty enumeration returns empty ArrayList")
  func testListFromEmptyEnumeration() {
    let empty: java.util.ArrayList<Int> = java.util.Collections.emptyList()
    let e = java.util.Collections.enumeration(empty)
    let result: java.util.ArrayList<Int> = java.util.Collections.list(e)
    #expect(result.isEmpty())
  }

  // MARK: - emptyIterator / emptyListIterator / emptyEnumeration (P3)

  @Test("emptyIterator hasNext returns false")
  func testEmptyIterator() {
    let it: any java.util.Iterator<Int?> = java.util.Collections.emptyIterator()
    #expect(!it.hasNext())
    let isNull = ((try? it.next() ?? nil) == nil)
    #expect(isNull)
  }

  @Test("emptyIterator next() throws NoSuchElementException")
  func testEmptyIteratorNextThrows() {
    let it: any java.util.Iterator<Int> = java.util.Collections.emptyIterator()
    #expect(throws: java.util.NoSuchElementException.self) { try it.next() }
  }

  @Test("emptyListIterator hasNext and hasPrevious both false")
  func testEmptyListIterator() {
    let it: any java.util.ListIterator<String> = java.util.Collections.emptyListIterator()
    #expect(!it.hasNext())
    #expect(!it.hasPrevious())
    #expect(it.nextIndex() == 0)
    #expect(it.previousIndex() == -1)
  }

  @Test("emptyEnumeration hasMoreElements returns false")
  func testEmptyEnumeration() {
    var e: any java.util.Enumeration<Int?> = java.util.Collections.emptyEnumeration()
    #expect(!e.hasMoreElements())
    #expect(e.next() == nil)
  }

  // MARK: - checkedList / checkedSet / checkedMap (P3)

  @Test("checkedList returns the same list")
  func testCheckedList() throws {
    let l = list(1, 2, 3)
    let checked = java.util.Collections.checkedList(l, Int.self)
    #expect(checked.size() == 3)
    #expect(try checked.get(0) == 1)
  }

  @Test("checkedSet returns the same set")
  func testCheckedSet() throws {
    let s = java.util.HashSet<String>()
    _ = try s.add("hello")
    let checked = java.util.Collections.checkedSet(s, String.self)
    #expect(checked.size() == 1)
    #expect(checked.contains("hello"))
  }

  @Test("checkedMap returns the same map")
  func testCheckedMap() {
    let m = java.util.HashMap<String, Int>()
    _ = m.put("k", 99)
    let checked = java.util.Collections.checkedMap(m, String.self, Int.self)
    #expect(checked.get("k") == 99)
  }

  // MARK: - unmodifiableNavigableSet / unmodifiableNavigableMap (Java 8)

  @Test("unmodifiableNavigableSet wraps TreeSet with read-through")
  func testUnmodifiableNavigableSet() throws {
    let s = java.util.TreeSet<Int>()
    _ = try s.add(1); _ = try s.add(2); _ = try s.add(3)
    let wrapped = java.util.Collections.unmodifiableNavigableSet(s)
    #expect(wrapped.size() == 3)
    #expect(wrapped.contains(2))
    #expect(try wrapped.first() == 1)
    #expect(try wrapped.last() == 3)
    #expect(wrapped.lower(2) == 1)
    #expect(wrapped.higher(2) == 3)
  }

  @Test("unmodifiableNavigableSet blocks add")
  func testUnmodifiableNavigableSetBlocksAdd() throws {
    let s = java.util.TreeSet<Int>()
    _ = try s.add(1)
    let wrapped = java.util.Collections.unmodifiableNavigableSet(s)
    #expect(throws: (any Error).self) { try wrapped.add(2) }
  }

  @Test("unmodifiableNavigableMap wraps TreeMap with read-through")
  func testUnmodifiableNavigableMap() throws {
    let m = java.util.TreeMap<String, Int>()
    _ = m.put("a", 1); _ = m.put("b", 2); _ = m.put("c", 3)
    let wrapped = java.util.Collections.unmodifiableNavigableMap(m)
    #expect(wrapped.size() == 3)
    #expect(wrapped.get("b") == 2)
    #expect(try wrapped.firstKey() == "a")
    #expect(try wrapped.lastKey() == "c")
    #expect(wrapped.lowerEntry("b")?.key == "a")
    #expect(wrapped.higherEntry("b")?.key == "c")
  }

  // MARK: - emptyNavigableSet / emptyNavigableMap (Java 8)

  @Test("emptyNavigableSet returns size-0 immutable TreeSet")
  func testEmptyNavigableSet() {
    let s: java.util.TreeSet<Int> = java.util.Collections.emptyNavigableSet()
    #expect(s.isEmpty())
    #expect(s.size() == 0)
    #expect(!s.contains(1))
    #expect(throws: (any Error).self) { try s.add(1) }
  }

  @Test("emptyNavigableMap returns size-0 immutable TreeMap")
  func testEmptyNavigableMap() {
    let m: java.util.TreeMap<String, Int> = java.util.Collections.emptyNavigableMap()
    #expect(m.isEmpty())
    #expect(m.size() == 0)
    #expect(m.get("a") == nil)
  }

  // MARK: - checkedNavigableSet / checkedNavigableMap / checkedQueue (Java 8)

  @Test("checkedNavigableSet returns the same set")
  func testCheckedNavigableSet() throws {
    let s = java.util.TreeSet<Int>()
    _ = try s.add(42)
    let checked = java.util.Collections.checkedNavigableSet(s, Int.self)
    #expect(checked.size() == 1)
    #expect(checked.contains(42))
  }

  @Test("checkedNavigableMap returns the same map")
  func testCheckedNavigableMap() {
    let m = java.util.TreeMap<String, Int>()
    _ = m.put("x", 7)
    let checked = java.util.Collections.checkedNavigableMap(m, String.self, Int.self)
    #expect(checked.get("x") == 7)
  }

  @Test("checkedQueue returns the same PriorityQueue")
  func testCheckedQueue() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try? q.add(5); _ = try? q.add(3); _ = try? q.add(8)
    let checked = java.util.Collections.checkedQueue(q, Int.self)
    #expect(checked.size() == 3)
    #expect(checked.peek() == 3)   // min-heap
  }
}
