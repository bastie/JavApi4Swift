/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Helpers

private func makeVector(_ elements: Int...) -> java.util.Vector<Int> {
  let v = java.util.Vector<Int>()
  for e in elements { _ = try? v.add(e) }
  return v
}

private func makeListFrom(_ elements: Int...) -> java.util.ArrayList<Int?> {
  let list = java.util.ArrayList<Int?>()
  for e in elements { _ = try? list.add(e) }
  return list
}

// MARK: - clone()

@Suite("Vector — clone()")
struct VectorCloneTests {

  @Test("clone() erzeugt unabhängige Kopie")
  func testCloneIsIndependent() throws {
    let original = makeVector(1, 2, 3)
    let copy = original.clone()
    _ = try copy.add(4)
    #expect(original.size() == 3)
    #expect(copy.size() == 4)
  }

  @Test("clone() enthält dieselben Elemente")
  func testCloneElements() throws {
    let original = makeVector(10, 20, 30)
    let copy = original.clone()
    #expect(copy.size() == 3)
    #expect(try copy.get(0) == 10)
    #expect(try copy.get(1) == 20)
    #expect(try copy.get(2) == 30)
  }

  @Test("clone() eines leeren Vectors ist leer")
  func testCloneEmpty() {
    let v = java.util.Vector<Int>()
    let copy = v.clone()
    #expect(copy.isEmpty())
  }
}

// MARK: - containsAll()

@Suite("Vector — containsAll()")
struct VectorContainsAllTests {

  @Test("containsAll() gibt true zurück wenn alle Elemente enthalten")
  func testContainsAllTrue() {
    let v = makeVector(1, 2, 3, 4, 5)
    let sub = makeListFrom(2, 4)
    #expect(v.containsAll(sub) == true)
  }

  @Test("containsAll() gibt false zurück wenn ein Element fehlt")
  func testContainsAllFalse() {
    let v = makeVector(1, 2, 3)
    let sub = makeListFrom(2, 9)
    #expect(v.containsAll(sub) == false)
  }

  @Test("containsAll() gibt true für leere Collection")
  func testContainsAllEmpty() {
    let v = makeVector(1, 2)
    let empty = java.util.ArrayList<Int?>()
    #expect(v.containsAll(empty) == true)
  }
}

// MARK: - addAll()

@Suite("Vector — addAll(Collection)")
struct VectorAddAllTests {

  @Test("addAll() fügt alle Elemente am Ende ein")
  func testAddAllAppends() throws {
    let v = makeVector(1, 2)
    let extra = makeListFrom(3, 4)
    _ = v.addAll(extra)
    #expect(v.size() == 4)
    #expect(try v.get(2) == 3)
    #expect(try v.get(3) == 4)
  }

  @Test("addAll() gibt true zurück wenn Collection nicht leer")
  func testAddAllReturnsTrue() {
    let v = makeVector(1)
    let extra = makeListFrom(2)
    #expect(v.addAll(extra) == true)
  }

  @Test("addAll(_ index:) fügt Elemente an der richtigen Position ein")
  func testAddAllAtIndex() throws {
    let v = makeVector(1, 4, 5)
    let insert = makeListFrom(2, 3)
    _ = try v.addAll(1, insert)
    #expect(v.size() == 5)
    #expect(try v.get(0) == 1)
    #expect(try v.get(1) == 2)
    #expect(try v.get(2) == 3)
    #expect(try v.get(3) == 4)
    #expect(try v.get(4) == 5)
  }

  @Test("addAll(_ index:) am Ende fügt korrekt ein")
  func testAddAllAtEnd() throws {
    let v = makeVector(1, 2)
    let extra = makeListFrom(3, 4)
    _ = try v.addAll(2, extra)
    #expect(v.size() == 4)
    #expect(try v.get(2) == 3)
    #expect(try v.get(3) == 4)
  }

  @Test("addAll(_ index:) mit ungültigem Index wirft Exception")
  func testAddAllAtInvalidIndex() {
    let v = makeVector(1, 2)
    let extra = makeListFrom(3)
    #expect(throws: (any Error).self) { try v.addAll(5, extra) }
  }
}

// MARK: - removeAll()

@Suite("Vector — removeAll()")
struct VectorRemoveAllTests {

  @Test("removeAll() entfernt alle Elemente der Collection")
  func testRemoveAll() throws {
    let v = makeVector(1, 2, 3, 4, 5)
    let toRemove = makeListFrom(2, 4)
    _ = v.removeAll(toRemove)
    #expect(v.size() == 3)
    #expect(try v.get(0) == 1)
    #expect(try v.get(1) == 3)
    #expect(try v.get(2) == 5)
  }

  @Test("removeAll() gibt false zurück bei leerer Collection")
  func testRemoveAllEmpty() {
    let v = makeVector(1, 2)
    let empty = java.util.ArrayList<Int?>()
    #expect(v.removeAll(empty) == false)
  }

  @Test("removeAll() gibt true zurück wenn etwas entfernt wurde")
  func testRemoveAllReturnValue() {
    let v = makeVector(1, 2, 3)
    let toRemove = makeListFrom(2)
    #expect(v.removeAll(toRemove) == true)
  }
}

// MARK: - retainAll()

@Suite("Vector — retainAll()")
struct VectorRetainAllTests {

  @Test("retainAll() behält nur Elemente der Collection")
  func testRetainAll() throws {
    let v = makeVector(1, 2, 3, 4, 5)
    let toKeep = makeListFrom(2, 4)
    _ = v.retainAll(toKeep)
    #expect(v.size() == 2)
    #expect(try v.get(0) == 2)
    #expect(try v.get(1) == 4)
  }

  @Test("retainAll() mit leerer Collection leert den Vector")
  func testRetainAllEmpty() {
    let v = makeVector(1, 2, 3)
    let empty = java.util.ArrayList<Int?>()
    _ = v.retainAll(empty)
    #expect(v.isEmpty())
  }

  @Test("retainAll() gibt true zurück wenn etwas entfernt wurde")
  func testRetainAllReturnValue() {
    let v = makeVector(1, 2, 3)
    let toKeep = makeListFrom(1, 2)
    #expect(v.retainAll(toKeep) == true)
  }
}

// MARK: - indexOf / lastIndexOf mit Start-Index

@Suite("Vector — indexOf/lastIndexOf mit Start-Index")
struct VectorIndexOfTests {

  @Test("indexOf(_:_:) findet Element ab Start-Index")
  func testIndexOfFromIndex() {
    let v = makeVector(1, 2, 3, 2, 1)
    #expect(v.indexOf(2, 0) == 1)
    #expect(v.indexOf(2, 2) == 3)  // findet die zweite 2
  }

  @Test("indexOf(_:_:) gibt -1 zurück wenn nicht gefunden")
  func testIndexOfNotFound() {
    let v = makeVector(1, 2, 3)
    #expect(v.indexOf(9, 0) == -1)
  }

  @Test("indexOf(_:_:) gibt -1 zurück wenn Start-Index zu groß")
  func testIndexOfStartBeyondEnd() {
    let v = makeVector(1, 2)
    #expect(v.indexOf(1, 5) == -1)
  }

  @Test("lastIndexOf(_:_:) findet letzte Occurrence bis zum Index")
  func testLastIndexOfFromIndex() throws {
    let v = makeVector(1, 2, 3, 2, 1)
    #expect(try v.lastIndexOf(2, 4) == 3)   // letztes 2 vor Index 4
    #expect(try v.lastIndexOf(2, 2) == 1)   // letztes 2 vor Index 2
  }

  @Test("lastIndexOf(_:_:) gibt -1 zurück wenn nicht gefunden")
  func testLastIndexOfNotFound() throws {
    let v = makeVector(1, 2, 3)
    #expect(try v.lastIndexOf(9, 2) == -1)
  }
}
