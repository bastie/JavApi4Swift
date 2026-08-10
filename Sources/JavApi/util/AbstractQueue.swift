/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Abstract base class providing skeletal implementations of the `Queue` interface.
  ///
  /// A concrete subclass must implement the five abstract primitives:
  /// `offer(_:)`, `poll()`, `peek()`, `iterator()`, and `size()`.
  /// All other `Queue` operations are derived automatically from these five.
  ///
  /// ### Behaviour of derived operations
  ///
  /// | Method | Behaviour |
  /// |--------|-----------|
  /// | `add(_:E)` | calls `offer`; throws `IllegalStateException` if `false` |
  /// | `remove()` | calls `poll`; throws `NoSuchElementException` if `nil` |
  /// | `element()` | calls `peek`; throws `NoSuchElementException` if `nil` |
  /// | `clear()` | polls until `nil` |
  /// | `add(_:E?)` | nil-checks, then delegates to `offer` |
  ///
  /// Mirrors `java.util.AbstractQueue<E>` (Java 5).
  ///
  /// - Since: Java 5
  open class AbstractQueue<E: Equatable>: AbstractCollection<E>, java.util.Queue {

    public override init() {
      super.init()
    }

    // MARK: - Primitives — subclass MUST override

    /// Inserts `elem` if space is available; returns `false` on failure.
    ///
    /// Subclasses must override this method.
    open func offer(_ elem: E) -> Bool {
      preconditionFailure("\(type(of: self)).offer(_:) not implemented")
    }

    /// Retrieves and removes the head; returns `nil` if the queue is empty.
    ///
    /// Subclasses must override this method.
    open func poll() -> E? {
      preconditionFailure("\(type(of: self)).poll() not implemented")
    }

    /// Retrieves, but does not remove, the head; returns `nil` if the queue is empty.
    ///
    /// Subclasses must override this method.
    open func peek() -> E? {
      preconditionFailure("\(type(of: self)).peek() not implemented")
    }

    /// Returns an iterator over the elements in this queue.
    ///
    /// Subclasses must override this method.
    open override func iterator() -> any java.util.Iterator<E> {
      preconditionFailure("\(type(of: self)).iterator() not implemented")
    }

    /// Returns the number of elements in this queue.
    ///
    /// Subclasses must override this method.
    open override func size() -> Int {
      preconditionFailure("\(type(of: self)).size() not implemented")
    }

    // MARK: - Queue: concrete implementations

    /// Inserts `elem`; throws `IllegalStateException` if the queue is full.
    ///
    /// Delegates to `offer(_:)`. Returns `true` on success.
    ///
    /// - Throws: `IllegalStateException` if no space is currently available.
    /// - Since: Java 5
    open func add(_ elem: E) throws -> Bool {
      guard offer(elem) else {
        throw java.lang.IllegalStateException("Queue is full")
      }
      return true
    }

    /// Retrieves and removes the head; throws `NoSuchElementException` if empty.
    ///
    /// Delegates to `poll()`.
    ///
    /// - Throws: `NoSuchElementException` if the queue is empty.
    /// - Since: Java 5
    open func remove() throws -> E {
      guard let e = poll() else {
        throw java.util.NoSuchElementException()
      }
      return e
    }

    /// Retrieves, but does not remove, the head; throws `NoSuchElementException` if empty.
    ///
    /// Delegates to `peek()`.
    ///
    /// - Throws: `NoSuchElementException` if the queue is empty.
    /// - Since: Java 5
    open func element() throws -> E {
      guard let e = peek() else {
        throw java.util.NoSuchElementException()
      }
      return e
    }

    // MARK: - AbstractCollection overrides

    /// Adds `element` to the queue; throws `NullPointerException` for `nil`.
    ///
    /// Overrides `AbstractCollection.add(_:E?)` to delegate to `offer`.
    /// Throws `IllegalStateException` if the queue is full.
    @discardableResult
    open override func add(_ element: E?) throws -> Bool {
      guard let element else {
        throw java.lang.NullPointerException()
      }
      guard offer(element) else {
        throw java.lang.IllegalStateException("Queue is full")
      }
      return true
    }

    /// Removes all elements from this queue by polling until empty.
    open override func clear() {
      while poll() != nil {}
    }
  }
}
