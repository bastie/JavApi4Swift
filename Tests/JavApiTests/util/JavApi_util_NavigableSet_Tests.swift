/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Minimal `NavigableSet` implementation backed by a sorted array — used only in tests.
///
/// Extends `AbstractSet` to inherit `makeIterator()` (Swift Sequence bridge) and
/// all `Collection` / `Set` default implementations.
private final class SimpleNavigableSet<E: Comparable & Hashable>
    : java.util.AbstractSet<E>, java.util.NavigableSet {

  private var _elements: [E] = []

  override func size() -> Int { _elements.count }
  override func isEmpty() -> Bool { _elements.isEmpty }
  override func contains(_ e: E?) -> Bool {
    guard let e else { return false }; return _elements.contains(e)
  }
  override func iterator() -> any java.util.Iterator<E> { _ArrayIterator(_elements) }
  override func add(_ e: E?) throws -> Bool {
    guard let e, !_elements.contains(e) else { return false }
    let idx = _elements.firstIndex(where: { $0 > e }) ?? _elements.endIndex
    _elements.insert(e, at: idx)
    return true
  }
  override func remove(_ e: E?) -> Bool {
    guard let e, let idx = _elements.firstIndex(of: e) else { return false }
    _elements.remove(at: idx); return true
  }

  // SortedSet
  func first() throws -> E {
    guard let f = _elements.first else { throw java.util.NoSuchElementException() }
    return f
  }
  func last() throws -> E {
    guard let l = _elements.last else { throw java.util.NoSuchElementException() }
    return l
  }
  func headSet(_ toElement: E) -> any java.util.SortedSet<E> {
    SimpleNavigableSet(sorted: _elements.filter { $0 < toElement })
  }
  func tailSet(_ fromElement: E) -> any java.util.SortedSet<E> {
    SimpleNavigableSet(sorted: _elements.filter { $0 >= fromElement })
  }
  func subSet(_ from: E, _ to: E) -> any java.util.SortedSet<E> {
    SimpleNavigableSet(sorted: _elements.filter { $0 >= from && $0 < to })
  }
  func comparator() -> (any java.util.Comparator<E>)? { nil }

  // NavigableSet
  func lower(_ e: E) -> E? { _elements.filter { $0 < e }.last }
  func floor(_ e: E) -> E? { _elements.filter { $0 <= e }.last }
  func ceiling(_ e: E) -> E? { _elements.first(where: { $0 >= e }) }
  func higher(_ e: E) -> E? { _elements.first(where: { $0 > e }) }

  func pollFirst() -> E? {
    guard !_elements.isEmpty else { return nil }
    return _elements.removeFirst()
  }
  func pollLast() -> E? {
    guard !_elements.isEmpty else { return nil }
    return _elements.removeLast()
  }

  func descendingSet() -> any java.util.NavigableSet<E> {
    SimpleNavigableSet(sorted: _elements.reversed())
  }
  func descendingIterator() -> any java.util.Iterator<E> {
    _ArrayIterator(_elements.reversed())
  }

  func subSet(_ from: E, _ fromInc: Bool, _ to: E, _ toInc: Bool) -> any java.util.NavigableSet<E> {
    let result = _elements.filter { e in
      let low  = fromInc ? e >= from : e > from
      let high = toInc   ? e <= to   : e < to
      return low && high
    }
    return SimpleNavigableSet(sorted: result)
  }
  func headSet(_ to: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
    SimpleNavigableSet(sorted: _elements.filter { inclusive ? $0 <= to : $0 < to })
  }
  func tailSet(_ from: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
    SimpleNavigableSet(sorted: _elements.filter { inclusive ? $0 >= from : $0 > from })
  }

  // Convenience init
  override init() { super.init() }
  private init(sorted: [E]) { _elements = sorted; super.init() }
}

private final class _ArrayIterator<E>: java.util.Iterator, IteratorProtocol {
  typealias Element = E
  private let data: [E]
  private var idx = 0
  init(_ data: [E]) { self.data = data }
  func hasNext() -> Bool { idx < data.count }
  func next() throws(java.util.NoSuchElementException) -> E {
    guard idx < data.count else { throw java.util.NoSuchElementException() }
    defer { idx += 1 }; return data[idx]
  }
  func next() -> E? { guard idx < data.count else { return nil }; defer { idx += 1 }; return data[idx] }
  func remove() throws(java.lang.IllegalStateException) { throw java.lang.IllegalStateException() }
  func makeIterator() -> _ArrayIterator<E> { self }
}

@Suite("java.util.NavigableSet")
struct JavApi_util_NavigableSet_Tests {

  private func makeSet() -> SimpleNavigableSet<Int> {
    let s = SimpleNavigableSet<Int>()
    [3, 1, 4, 1, 5, 9, 2, 6].forEach { _ = try? s.add($0) }
    return s  // contains: 1,2,3,4,5,6,9
  }

  @Test("lower() returns greatest element strictly less than given")
  func testLower() {
    let s = makeSet()
    #expect(s.lower(4) == 3)
    #expect(s.lower(1) == nil)
  }

  @Test("floor() returns greatest element <= given")
  func testFloor() {
    let s = makeSet()
    #expect(s.floor(4) == 4)
    #expect(s.floor(7) == 6)
    #expect(s.floor(0) == nil)
  }

  @Test("ceiling() returns least element >= given")
  func testCeiling() {
    let s = makeSet()
    #expect(s.ceiling(4) == 4)
    #expect(s.ceiling(7) == 9)
    #expect(s.ceiling(10) == nil)
  }

  @Test("higher() returns least element strictly greater than given")
  func testHigher() {
    let s = makeSet()
    #expect(s.higher(4) == 5)
    #expect(s.higher(9) == nil)
  }

  @Test("pollFirst() removes and returns smallest element")
  func testPollFirst() {
    let s = makeSet()
    let first = s.pollFirst()
    #expect(first == 1)
    #expect(!s.contains(1))
  }

  @Test("pollLast() removes and returns largest element")
  func testPollLast() {
    let s = makeSet()
    let last = s.pollLast()
    #expect(last == 9)
    #expect(!s.contains(9))
  }

  @Test("descendingSet() reverses element order")
  func testDescendingSet() throws {
    let s = makeSet()
    let desc = s.descendingSet()
    #expect(try desc.first() == 9)
    #expect(try desc.last() == 1)
  }

  @Test("headSet(to:inclusive:) with inclusive=true includes boundary")
  func testHeadSetInclusive() {
    let s = makeSet()
    let head = s.headSet(4, true)
    #expect(head.contains(4))
    #expect(!head.contains(5))
  }

  @Test("tailSet(from:inclusive:) with inclusive=false excludes boundary")
  func testTailSetExclusive() {
    let s = makeSet()
    let tail = s.tailSet(4, false)
    #expect(!tail.contains(4))
    #expect(tail.contains(5))
  }

  @Test("subSet with both inclusive boundaries")
  func testSubSetBothInclusive() {
    let s = makeSet()
    let sub = s.subSet(2, true, 5, true)
    #expect(sub.contains(2) && sub.contains(5))
    #expect(!sub.contains(1) && !sub.contains(6))
  }
}
