/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util.Enumeration {

  // IteratorProtocol.next()  ←  Java hasMoreElements() + nextElement()
  mutating func next() -> Element? {
    guard hasMoreElements() else { return nil }
    do {
      let elem = try nextElement()
      return elem
    }
    catch {
      return nil
    }
  }

  // Sequence.makeIterator()  →  self ist gleichzeitig der Iterator
  func makeIterator() -> Self { self }

  /// Wraps this `Enumeration` in a `java.util.Iterator`.
  ///
  /// The returned iterator does not support `remove()`.
  ///
  /// - Since: Java 9
  public func asIterator() -> any java.util.Iterator<Element> {
    // Collect eagerly — works for both value-type and reference-type enumerations.
    var elements: [Element] = []
    var copy = self
    while copy.hasMoreElements() {
      if let e = try? copy.nextElement() {
        elements.append(e)
      }
    }
    return _EnumerationIterator(elements)
  }
}

// MARK: - Private bridge iterator

private final class _EnumerationIterator<E>: java.util.Iterator, IteratorProtocol {
  public typealias Element = E

  private let storage: [E]
  private var index: Int = 0

  init(_ storage: [E]) { self.storage = storage }

  public func hasNext() -> Bool { index < storage.count }

  public func next() throws(java.util.NoSuchElementException) -> E {
    guard index < storage.count else { throw java.util.NoSuchElementException() }
    defer { index += 1 }
    return storage[index]
  }

  public func next() -> E? {
    guard index < storage.count else { return nil }
    defer { index += 1 }
    return storage[index]
  }

  public func remove() throws(java.lang.IllegalStateException) {
    throw java.lang.IllegalStateException("remove() not supported on Enumeration-backed iterator")
  }

  public func makeIterator() -> _EnumerationIterator<E> { self }
}
