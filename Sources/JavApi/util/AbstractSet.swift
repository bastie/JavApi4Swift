/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Abstract base implementation of `java.util.Set<E>`.
  ///
  /// Subclasses must implement `iterator()` and `size()` (inherited from
  /// `AbstractCollection`). The uniqueness invariant is enforced by `add(_:)`,
  /// which must be overridden in concrete subclasses.
  ///
  /// - Since: Java 1.2
  open class AbstractSet<E>: AbstractCollection<E>, java.util.Set where E: Equatable {

    // iterator() and size() are inherited as fatalError stubs from AbstractCollection.
    // Concrete subclasses (HashSet, TreeSet) must override both.

    // MARK: - Equality

    /// Two sets are equal when they have the same size and every element of
    /// `other` is contained in `self`.
    open func equals(_ other: AbstractSet<E>) -> Bool {
      guard other.size() == size() else { return false }
      // Walk other's iterator and check each element against self.
      let it = other.iterator()
      while it.hasNext() {
        guard let e = try? it.next() else { continue }
        if !self.contains(e) { return false }
      }
      return true
    }

    // MARK: - hashCode

    /// Sum of element hash values (order-independent), matching Java's contract.
    ///
    /// Requires `E: Hashable`. For non-Hashable element types the default
    /// implementation from `AbstractCollection` (which returns 0) applies.
    open func hashCode() -> Int where E: Hashable {
      var h = 0
      let it = iterator()
      while it.hasNext() {
        if let e = try? it.next() {
          h &+= e.hashValue
        }
      }
      return h
    }

    // MARK: - removeAll (optimised for Set: iterate the smaller collection)

    open override func removeAll(_ collection: any java.util.Collection<E?>) -> Bool {
      var modified = false
      if size() > collection.size() {
        let it = collection.iterator()
        while it.hasNext() {
          if let e = try? it.next() {
            if remove(e) { modified = true }
          }
        }
      } else {
        let it = iterator()
        while it.hasNext() {
          let e: E? = try? it.next()
          if collection.contains(e) {
            try? it.remove()
            modified = true
          }
        }
      }
      return modified
    }

    /// Overload accepting a non-optional `Collection<E>` — bridges the `E` vs `E?`
    /// gap so callers passing `ConcreteSet<E>` (which is `Collection<E>`) compile.
    @discardableResult
    open func removeAll(_ collection: any java.util.Collection<E>) -> Bool {
      var modified = false
      if size() > collection.size() {
        let it = collection.iterator()
        while it.hasNext() {
          if let e = try? it.next() {
            if remove(e) { modified = true }
          }
        }
      } else {
        let it = iterator()
        while it.hasNext() {
          if let e: E = try? it.next() {
            if collection.contains(e) {
              try? it.remove()
              modified = true
            }
          }
        }
      }
      return modified
    }
  }
}
