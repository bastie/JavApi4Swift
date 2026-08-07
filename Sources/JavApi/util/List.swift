/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  public protocol List<E> : Collection, java.util.SequencedCollection where E : Equatable {
    associatedtype E
    
    func add(_ location : Int, _ element : E?) throws
    func addAll(_ location : Int, collection : any Collection<E?>) -> Bool
    func get(_ location : Int) throws -> E?
    func hashCode() -> Int
    func indexOf(element : Any?) -> Int
    func lastIndexOf(_ element : Any?) -> Int
    func listIterator() -> any java.util.ListIterator<E>
    func listIterator(_ location : Int) -> any java.util.ListIterator<E>
    func remove(_ location : Int) throws -> E?
    func set(_ location : Int, _ element : E?) throws -> E?
    func subList(_ start : Int, _ end : Int) -> any java.util.List
  }
}

// MARK: - SequencedCollection defaults for List

extension java.util.List {

  /// Default: returns the element at index 0; throws `NoSuchElementException` if empty.
  public func getFirst() throws -> E {
    guard size() > 0 else { throw java.util.NoSuchElementException() }
    // get() returns E? — guard let unwraps it; nil means a stored nil element
    guard let e = try get(0) else { throw java.util.NoSuchElementException() }
    return e
  }

  /// Default: returns the element at `size()-1`; throws `NoSuchElementException` if empty.
  public func getLast() throws -> E {
    let s = size()
    guard s > 0 else { throw java.util.NoSuchElementException() }
    guard let e = try get(s - 1) else { throw java.util.NoSuchElementException() }
    return e
  }

  /// Default: inserts `e` at index 0 (prepend).
  public func addFirst(_ e: E) throws { try add(0, e) }

  /// Default: appends `e` at the end (uses positional `add(size(), e)` to avoid `mutating` conflict).
  public func addLast(_ e: E) throws { try add(size(), e) }

  /// Default: removes and returns the element at index 0; throws `NoSuchElementException` if empty.
  public func removeFirst() throws -> E {
    guard size() > 0 else { throw java.util.NoSuchElementException() }
    // remove() returns E? — guard let unwraps it
    guard let e = try remove(0) else { throw java.util.NoSuchElementException() }
    return e
  }

  /// Default: removes and returns the last element; throws `NoSuchElementException` if empty.
  public func removeLast() throws -> E {
    let s = size()
    guard s > 0 else { throw java.util.NoSuchElementException() }
    guard let e = try remove(s - 1) else { throw java.util.NoSuchElementException() }
    return e
  }

  /// Default: returns a new `ArrayList` with elements in reverse order.
  public func reversed() -> any java.util.SequencedCollection<E> {
    let arr = toArray()
    let result = java.util.ArrayList<E>()
    for e in arr.reversed() {
      if let e { try? result.add(e) }
    }
    return result
  }
}
