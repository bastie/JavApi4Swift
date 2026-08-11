/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Uses the same Planet enum declared in JavApi_util_EnumMap_Tests.swift
// (shared within the test module as a file-private type — redeclare here.)
private enum Day: CaseIterable, Hashable {
  case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

struct JavApi_util_EnumSet_Tests {

  // MARK: - Factory: noneOf

  @Test("noneOf creates empty set")
  func testNoneOf() {
    let s = java.util.EnumSet<Day>.noneOf()
    #expect(s.isEmpty())
    #expect(s.size() == 0)
  }

  // MARK: - Factory: allOf

  @Test("allOf contains every case")
  func testAllOf() {
    let s = java.util.EnumSet<Day>.allOf()
    #expect(s.size() == Day.allCases.count)
    for d in Day.allCases { #expect(s.contains(d)) }
  }

  // MARK: - Factory: of (variadic)

  @Test("of(variadic) contains exactly the given elements")
  func testOfVariadic() {
    let s = java.util.EnumSet<Day>.of(.saturday, .sunday)
    #expect(s.size() == 2)
    #expect(s.contains(.saturday))
    #expect(s.contains(.sunday))
    #expect(!s.contains(.monday))
  }

  // MARK: - Factory: of (collection)

  @Test("copyOf(collection) builds set from Swift array")
  func testOfCollection() {
    let days: [Day] = [.monday, .wednesday, .friday]
    let s = java.util.EnumSet<Day>.copyOf(days)
    #expect(s.size() == 3)
    #expect(s.contains(.wednesday))
    #expect(!s.contains(.tuesday))
  }

  // MARK: - Factory: copyOf

  @Test("copyOf creates an independent copy")
  func testCopyOf() {
    let original = java.util.EnumSet<Day>.of(.monday)
    let copy = java.util.EnumSet<Day>.copyOf(original)
    copy.add(.tuesday)
    #expect(!original.contains(.tuesday))
    #expect(copy.contains(.monday))
  }

  // MARK: - Factory: complementOf

  @Test("complementOf flips membership")
  func testComplementOf() {
    let weekdays = java.util.EnumSet<Day>.of(.monday, .tuesday, .wednesday, .thursday, .friday)
    let weekend  = java.util.EnumSet<Day>.complementOf(weekdays)
    #expect(weekend.size() == 2)
    #expect(weekend.contains(.saturday))
    #expect(weekend.contains(.sunday))
    #expect(!weekend.contains(.monday))
  }

  // MARK: - Factory: range

  @Test("range includes both endpoints")
  func testRange() {
    let s = java.util.EnumSet<Day>.range(.tuesday, .thursday)
    #expect(s.size() == 3)
    #expect(s.contains(.tuesday))
    #expect(s.contains(.wednesday))
    #expect(s.contains(.thursday))
    #expect(!s.contains(.monday))
    #expect(!s.contains(.friday))
  }

  @Test("range with equal endpoints is a singleton")
  func testRangeSingleton() {
    let s = java.util.EnumSet<Day>.range(.friday, .friday)
    #expect(s.size() == 1)
    #expect(s.contains(.friday))
  }

  @Test("range returns empty set when from > to")
  func testRangeInvalidOrder() {
    let s = java.util.EnumSet<Day>.range(.friday, .monday)
    #expect(s.isEmpty())
  }

  // MARK: - add / remove / contains

  @Test("add returns true when element was absent")
  func testAddNew() {
    let s = java.util.EnumSet<Day>.noneOf()
    let changed = s.add(.monday)
    #expect(changed)
    #expect(s.contains(.monday))
  }

  @Test("add returns false when element already present")
  func testAddDuplicate() {
    let s = java.util.EnumSet<Day>.of(.monday)
    let changed = s.add(.monday)
    #expect(!changed)
    #expect(s.size() == 1)
  }

  @Test("remove returns true when element was present")
  func testRemovePresent() {
    let s = java.util.EnumSet<Day>.of(.friday)
    let changed = s.remove(.friday)
    #expect(changed)
    #expect(!s.contains(.friday))
    #expect(s.isEmpty())
  }

  @Test("remove returns false when element was absent")
  func testRemoveAbsent() {
    let s = java.util.EnumSet<Day>.noneOf()
    let changed = s.remove(.saturday)
    #expect(!changed)
  }

  // MARK: - clear

  @Test("clear empties the set")
  func testClear() {
    let s = java.util.EnumSet<Day>.allOf()
    s.clear()
    #expect(s.isEmpty())
  }

  // MARK: - Bulk operations

  @Test("addAll merges two sets")
  func testAddAll() {
    let a = java.util.EnumSet<Day>.of(.monday)
    let b = java.util.EnumSet<Day>.of(.tuesday, .wednesday)
    a.addAll(b)
    #expect(a.size() == 3)
    #expect(a.contains(.wednesday))
  }

  @Test("removeAll subtracts elements")
  func testRemoveAll() {
    let s = java.util.EnumSet<Day>.of(.monday, .tuesday, .wednesday)
    let r = java.util.EnumSet<Day>.of(.tuesday)
    s.removeAll(r)
    #expect(s.size() == 2)
    #expect(!s.contains(.tuesday))
  }

  @Test("retainAll keeps intersection only")
  func testRetainAll() {
    let s = java.util.EnumSet<Day>.of(.monday, .tuesday, .wednesday)
    let r = java.util.EnumSet<Day>.of(.tuesday, .thursday)
    s.retainAll(r)
    #expect(s.size() == 1)
    #expect(s.contains(.tuesday))
  }

  @Test("containsAll returns true when subset")
  func testContainsAll() {
    let s = java.util.EnumSet<Day>.allOf()
    let sub = java.util.EnumSet<Day>.of(.saturday, .sunday)
    #expect(s.containsAll(sub))
    #expect(!sub.containsAll(s))
  }

  // MARK: - toArray / forEach / Sequence

  @Test("toArray returns elements in declaration order")
  func testToArray() {
    let s = java.util.EnumSet<Day>.of(.wednesday, .monday)
    let arr = s.toArray()
    // Declaration order: monday before wednesday
    #expect(arr == [.monday, .wednesday])
  }

  @Test("forEach visits each element once")
  func testForEach() {
    let s = java.util.EnumSet<Day>.of(.saturday, .sunday)
    var count = 0
    s.forEach { _ in count += 1 }
    #expect(count == 2)
  }

  @Test("for-in iteration works via Sequence conformance")
  func testSequence() {
    let s = java.util.EnumSet<Day>.of(.monday, .friday)
    var result: [Day] = []
    for d in s { result.append(d) }
    #expect(result.count == 2)
    #expect(result.contains(.monday))
    #expect(result.contains(.friday))
  }
}
