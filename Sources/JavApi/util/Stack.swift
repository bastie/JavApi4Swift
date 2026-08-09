/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  
  /// A last-in-first-out (LIFO) stack of objects.
  ///
  /// Mirrors `java.util.Stack<E>`, which extends `Vector<E>` and adds
  /// exactly five methods: `push`, `pop`, `peek`, `empty`, and `search`.
  ///
  /// All inherited `Vector` methods (and their thread-safety guarantee)
  /// are available without any additional code.
  ///
  /// ```swift
  /// let stack = Java.util.Stack<NSString>()
  /// stack.push("a")
  /// stack.push("b")
  /// print(try stack.peek())    // → b
  /// print(try stack.pop())     // → b
  /// print(stack.search("a"))   // → 1  (1-based distance from top)
  /// ```
  public final class Stack<E>: Vector<E> where E: Equatable {
    
    /// Creates an empty stack.
    public init() {
      try! super.init(0,0)
    }
    
    // =========================================================================
    // MARK: - Stack API  (java.util.Stack)
    // =========================================================================
    
    /// Pushes `item` onto the top of this stack and returns it.
    ///
    /// Equivalent to `addElement(item)`.
    @discardableResult
    public func push(_ item: E) -> E {
      addElement(item)
      return item
    }
    
    /// Removes and returns the object at the top of this stack.
    ///
    /// - Throws: `java.util.EmptyStackException` when the stack is empty.
    @discardableResult
    public func pop() throws -> E {
      try withLock {
        guard elementCount > 0 else {
          throw java.util.EmptyStackException()
        }
        return try _removeAt(elementCount - 1)!   // inherited private helper
      }
    }
    
    /// Returns the object at the top of this stack without removing it.
    ///
    /// - Throws: `java.util.EmptyStackException` when the stack is empty.
    public func peek() throws -> E {
      try withLock {
        guard elementCount > 0 else {
          throw java.util.EmptyStackException()
        }
        return elementData[elementCount - 1]!
      }
    }
    
    /// Returns `true` if this stack contains no elements.
    ///
    /// Shadows `Vector.isEmpty()` with the idiomatic Java Stack name.
    public func empty() -> Bool {
      isEmpty()
    }

    /// Returns the 1-based distance from the top of the stack to the first
    /// occurrence of `o`, or `-1` if the object is not present.
    ///
    /// The topmost item is at distance 1, the item beneath it at distance 2,
    /// and so on. Equality is tested with `==` (requires `E: Equatable`).
    ///
    /// Matches `java.util.Stack.search(Object o)` exactly.
    public func search(_ o: Any?) -> Int {
      withLock { () -> Int in
        for i in stride(from: elementCount - 1, through: 0, by: -1) {
          let elem = elementData[i]
          if let target = o as? E, let elem {
            if elem == target { return elementCount - i }
          } else if o == nil && elem == nil {
            return elementCount - i
          }
        }
        return -1
      }
    }

  }
}
