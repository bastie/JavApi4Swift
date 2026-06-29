/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Java's `java.util.Deque` — a double-ended queue that supports element insertion
  /// and removal at both ends.
  ///
  /// `Deque` extends `Queue` and adds symmetric first/last operations.
  /// `LinkedList` implements this interface since Java 6.
  ///
  /// - Since: Java 6
  public protocol Deque<E>: Queue {
    // E is inherited from Queue/Collection.

    // MARK: - First-end operations

    /// Inserts `elem` at the front; throws if capacity constraints prevent it.
    func addFirst(_ elem: E) throws

    /// Inserts `elem` at the tail; throws if capacity constraints prevent it.
    func addLast(_ elem: E) throws

    /// Inserts `elem` at the front; returns `false` instead of throwing on failure.
    func offerFirst(_ elem: E) -> Bool

    /// Inserts `elem` at the tail; returns `false` instead of throwing on failure.
    func offerLast(_ elem: E) -> Bool

    /// Retrieves, but does not remove, the first element; throws if empty.
    func getFirst() throws -> E?

    /// Retrieves, but does not remove, the last element; throws if empty.
    func getLast() throws -> E?

    /// Retrieves, but does not remove, the first element; returns `nil` if empty.
    func peekFirst() -> E?

    /// Retrieves, but does not remove, the last element; returns `nil` if empty.
    func peekLast() -> E?

    /// Retrieves and removes the first element; throws if empty.
    func removeFirst() throws -> E?

    /// Retrieves and removes the last element; throws if empty.
    func removeLast() throws -> E?

    /// Retrieves and removes the first element; returns `nil` if empty.
    func pollFirst() -> E?

    /// Retrieves and removes the last element; returns `nil` if empty.
    func pollLast() -> E?

    // MARK: - Stack operations

    /// Pushes `elem` onto the stack represented by this deque (inserts at front).
    /// Equivalent to `addFirst`.
    func push(_ elem: E) throws

    /// Pops an element from the stack represented by this deque (removes from front).
    /// Equivalent to `removeFirst`.
    func pop() throws -> E?

    // MARK: - Occurrence removal

    /// Removes the first occurrence of `elem`; returns `true` if the deque changed.
    func removeFirstOccurrence(_ elem: E?) -> Bool

    /// Removes the last occurrence of `elem`; returns `true` if the deque changed.
    func removeLastOccurrence(_ elem: E?) -> Bool

    // MARK: - Reverse iteration

    /// Returns an iterator over elements in reverse sequential order.
    func descendingIterator() -> any java.util.Iterator<E>
  }

}

// MARK: - Default implementations

extension java.util.Deque {

  /// Default: `addFirst` delegates to `offerFirst` (throws `IllegalStateException` on failure).
  public func addFirst(_ elem: E) throws {
    guard offerFirst(elem) else { throw java.lang.IllegalStateException("Deque full") }
  }

  /// Default: `addLast` delegates to `offerLast` (throws `IllegalStateException` on failure).
  public func addLast(_ elem: E) throws {
    guard offerLast(elem) else { throw java.lang.IllegalStateException("Deque full") }
  }

  /// Default: `push` = `addFirst`.
  public func push(_ elem: E) throws { try addFirst(elem) }

  /// Default: `pop` = `removeFirst`.
  public func pop() throws -> E? { try removeFirst() }

  // Queue defaults that map to Deque first-end operations:

  /// `peek` returns the first element (head of queue).
  public func peek() -> E? { peekFirst() }

  /// `poll` removes and returns the first element (head of queue).
  public func poll() -> E? { pollFirst() }
}
