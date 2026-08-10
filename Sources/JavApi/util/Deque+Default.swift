/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

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
  public func pop() throws -> E { try removeFirst() }

  /// Default: returns elements in reverse order via `descendingIterator()`.
  public func reversed() -> any java.util.SequencedCollection<E> {
    let result = java.util.ArrayList<E>()
    let it = descendingIterator()
    while it.hasNext() {
      if let e = try? it.next() { _ = try? result.add(e) }
    }
    return result
  }

  // Queue defaults that map to Deque first-end operations:

  /// `peek` returns the first element (head of queue).
  public func peek() -> E? { peekFirst() }

  /// `poll` removes and returns the first element (head of queue).
  public func poll() -> E? { pollFirst() }
}
