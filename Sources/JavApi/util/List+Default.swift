/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

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
  
  /// Reverse order in a new `SequencedCollection`
  /// - Returns: a new `ArrayList` with elements in reverse order.
  public func reversed() -> any java.util.SequencedCollection<E> {
    let arr = toArray()
    let result = java.util.ArrayList<E>()
    for e in arr.reversed() {
      if let e { _ = try? result.add(e) }
    }
    return result
  }
  
  // MARK: - Java 8 default methods for List
  
  /// Replaces each element of this list with the result of applying the given
  /// operator to that element.
  ///
  /// The default implementation iterates over all indices and calls ``set(_:_:)``
  /// with the result of `op.apply(element)`.
  ///
  /// - Parameter op: The operator to apply to each element.
  /// - Since: Java 8
  public func replaceAll(_ op: some java.util.function.UnaryOperator<E>) {
    for i in 0..<size() {
      // try? on E?-returning throwing func: SE-0230 flattens to E?
      if let current = try? get(i) {
        let newVal = op.apply(current)
        _ = try? set(i, newVal)
      }
    }
  }
  
  /// Sorts this list according to the order induced by the given comparator.
  ///
  /// The default implementation extracts all elements to a Swift array, sorts
  /// them using `comparator`, and writes the sorted values back via ``set(_:_:)``.
  ///
  /// - Parameter c: The comparator to determine the order of the list.
  /// - Since: Java 8
  public func sort(_ c: some java.util.Comparator<E>) {
    let arr = toArray().compactMap { $0 }
    let sorted = arr.sorted { c.compare($0, $1) < 0 }
    for (i, elem) in sorted.enumerated() {
      _ = try? set(i, elem)
    }
  }
}
