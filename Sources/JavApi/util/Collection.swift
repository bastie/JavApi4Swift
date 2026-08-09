/*
 * SPDX-FileCopyrightText: 2024, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  public protocol Collection<E> : Iterable, Sequence where E : Equatable {
    associatedtype E
    
    mutating func add(_ element: E?) throws -> Bool
    mutating func addAll(_ collection: any java.util.Collection<E?>) throws -> Bool
    mutating func clear () throws
    func contains(_ element: E?) -> Bool
    func containsAll(_ collection : any java.util.Collection<E?>) -> Bool
    func equals(_ object : Any) -> Bool
    func isEmpty () -> Bool
    func remove(_ element: E?) -> Bool
    func removeAll(_ collection: any java.util.Collection<E?>) -> Bool
    func retainAll(_ collection: any java.util.Collection<E?>) -> Bool
    func size () -> Int
    func toArray () -> [E?]
    func toArray (_ array: inout [E?]) -> [E?]
  }
}


extension java.util.Collection {
  public func equals (_ object : Any) -> Bool {
    if let other = object as? any Collection {
      for each in other {
        if !self.contains(each as? Self.E) { return false }
      }
      return true
    }
    return false
  }

  /// Returns a non-optional array containing all elements of this collection.
  ///
  /// The `generator` is called with the desired size and must return a
  /// pre-allocated (or empty) Swift array; elements are then appended to it.
  /// This matches Java 11's `Collection.toArray(IntFunction<T[]> generator)`.
  ///
  /// - Parameter generator: Closure that receives the collection size and
  ///   returns the backing array to use (may be pre-sized or empty).
  /// - Returns: An array of all elements in iteration order.
  public func toArray(_ generator: (Int) -> [E]) -> [E] {
    var result = generator(size())
    result.removeAll(keepingCapacity: true)
    let it = iterator()
    while it.hasNext() {
      if let e = try? it.next() { result.append(e) }
    }
    return result
  }
}

