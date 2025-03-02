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
  public func makeIterator() -> Iterator {
    self.iterator() as! Self.Iterator
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
}

