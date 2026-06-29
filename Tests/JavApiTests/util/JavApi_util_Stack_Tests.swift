/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Comprehensive test suite for java.util.Stack<E>
/// Tests all five core Stack methods plus inherited Vector functionality.
/// Covers Java 1.0+ API including proper error handling.
///
/// NOTE: Uses explicit type annotations to disambiguate between
/// Stack.swift (throwing API) and Stack+Swiftify.swift (optional API).
/// Type annotations force the compiler to select the Java throwing variant.
struct JavApi_util_Stack_Tests {

  // MARK: - Initialization & Basic Properties

  @Test("Stack initializes empty")
  func testEmptyStackInit() {
    let stack = java.util.Stack<String>()
    #expect(stack.empty() == true)
    #expect(stack.count == 0)
  }

  // MARK: - push() - Add Elements

  @Test("push() adds element to top and returns it")
  func testPushReturnsElement() {
    let stack = java.util.Stack<String>()
    let result: String = stack.push("first")
    #expect(result == "first")
    #expect(stack.count == 1)
  }

  @Test("push() multiple elements maintains LIFO order")
  func testPushMultipleElements() {
    let stack = java.util.Stack<String>()
    _ = stack.push("a")
    _ = stack.push("b")
    _ = stack.push("c")

    #expect(stack.count == 3)
    #expect(stack.empty() == false)
  }

  // MARK: - pop() - Remove and Return Top (throws EmptyStackException)

  @Test("pop() removes and returns top element")
  func testPopRemovesTop() throws {
    let stack = java.util.Stack<String>()
    _ = stack.push("first")
    _ = stack.push("second")

    let popped: String = try stack.pop()
    #expect(popped == "second")
    #expect(stack.count == 1)
  }

  @Test("pop() respects LIFO order")
  func testPopLIFOOrder() throws {
    let stack = java.util.Stack<Int>()
    _ = stack.push(1)
    _ = stack.push(2)
    _ = stack.push(3)

    let val3: Int = try stack.pop()
    let val2: Int = try stack.pop()
    let val1: Int = try stack.pop()

    #expect(val3 == 3)
    #expect(val2 == 2)
    #expect(val1 == 1)
    #expect(stack.empty())
  }

  @Test("pop() on empty stack throws EmptyStackException")
  func testPopEmptyStackThrows() {
    let stack = java.util.Stack<String>()

    #expect(throws: java.util.EmptyStackException.self) {
      let _: String = try stack.pop()
    }
  }

  @Test("pop() decrements stack size")
  func testPopDecrementsSize() throws {
    let stack = java.util.Stack<String>()
    _ = stack.push("a")
    _ = stack.push("b")
    _ = stack.push("c")

    let _: String = try stack.pop()
    #expect(stack.count == 2)

    let _: String = try stack.pop()
    #expect(stack.count == 1)
  }

  // MARK: - peek() - View Without Removal (throws EmptyStackException)

  @Test("peek() returns top element without removing it")
  func testPeekDoesNotRemove() throws {
    let stack = java.util.Stack<String>()
    _ = stack.push("only")

    let peeked: String = try stack.peek()
    #expect(peeked == "only")
    #expect(stack.count == 1)  // Still there
  }

  @Test("peek() on empty stack throws EmptyStackException")
  func testPeekEmptyStackThrows() {
    let stack = java.util.Stack<String>()

    #expect(throws: java.util.EmptyStackException.self) {
      let _: String = try stack.peek()
    }
  }

  @Test("peek() returns same value as next pop()")
  func testPeekEqualsNextPop() throws {
    let stack = java.util.Stack<Int>()
    _ = stack.push(10)
    _ = stack.push(20)
    _ = stack.push(30)

    let peeked: Int = try stack.peek()
    let popped: Int = try stack.pop()

    #expect(peeked == popped)
    #expect(peeked == 30)
  }

  // MARK: - empty() - Query

  @Test("empty() returns true for new stack")
  func testEmptyOnNewStack() {
    let stack = java.util.Stack<String>()
    #expect(stack.empty())
  }

  @Test("empty() returns false after push()")
  func testEmptyAfterPush() {
    let stack = java.util.Stack<String>()
    _ = stack.push("item")
    #expect(stack.empty() == false)
  }

  @Test("empty() returns true after pop() to zero")
  func testEmptyAfterPopToZero() throws {
    let stack = java.util.Stack<String>()
    _ = stack.push("only")
    let _: String = try stack.pop()
    #expect(stack.empty())
  }

  @Test("empty() is idempotent")
  func testEmptyIdempotent() {
    let stack = java.util.Stack<String>()
    #expect(stack.empty() == stack.empty())
  }

  // MARK: - search() - Element Location (1-based from top)

  @Test("search finds element at position 1 in single-element stack")
  func testSearchSingleElement() {
    let stack = java.util.Stack<String>()
    stack.addElement("HALLO")
    #expect(stack.search("HALLO") == 1)
  }

  @Test("search returns 1-based distance from top")
  func testSearchMultipleElements() {
    let stack = java.util.Stack<String>()
    stack.addElement("HALLO")
    stack.addElement("Welt")
    stack.addElement("!")
    stack.addElement("!")
    stack.addElement("!")
    #expect(stack.search("Welt") == 4)
  }

  @Test("search returns -1 for absent element")
  func testSearchMissing() {
    let stack = java.util.Stack<String>()
    stack.addElement("HALLO")
    stack.addElement("Welt")
    stack.addElement("!")
    stack.addElement("!")
    stack.addElement("!")
    #expect(stack.search("Bastie") == -1)
  }

  @Test("search() finds element at top (position 1)")
  func testSearchTop() {
    let stack = java.util.Stack<String>()
    _ = stack.push("bottom")
    _ = stack.push("top")

    #expect(stack.search("top") == 1)
  }

  @Test("search() finds element in middle")
  func testSearchMiddle() {
    let stack = java.util.Stack<String>()
    _ = stack.push("a")
    _ = stack.push("b")
    _ = stack.push("c")
    _ = stack.push("d")

    // Stack from top: d(1), c(2), b(3), a(4)
    #expect(stack.search("b") == 3)
  }

  @Test("search() finds element at bottom")
  func testSearchBottom() {
    let stack = java.util.Stack<String>()
    _ = stack.push("bottom")
    _ = stack.push("middle")
    _ = stack.push("top")

    #expect(stack.search("bottom") == 3)
  }

  @Test("search() on empty stack returns -1")
  func testSearchEmptyStack() {
    let stack = java.util.Stack<String>()
    #expect(stack.search("anything") == -1)
  }

  @Test("search() with duplicate elements finds first from top")
  func testSearchDuplicates() {
    let stack = java.util.Stack<String>()
    _ = stack.push("x")
    _ = stack.push("x")
    _ = stack.push("x")

    // All three are identical, search returns distance to the closest (top)
    #expect(stack.search("x") == 1)
  }

  @Test("search() returns 1-based indexing, not 0-based")
  func testSearchOneBased() {
    let stack = java.util.Stack<Int>()
    _ = stack.push(1)

    // Top element should be at position 1, not 0
    #expect(stack.search(1) == 1)
    #expect(stack.search(1) != 0)
  }

  // MARK: - Integration: Multiple Operations

  @Test("push/pop/peek sequence")
  func testSequenceOfOperations() throws {
    let stack = java.util.Stack<String>()

    _ = stack.push("a")
    _ = stack.push("b")
    let b: String = try stack.peek()
    #expect(b == "b")

    let _: String = try stack.pop()
    _ = stack.push("c")
    let c: String = try stack.peek()
    #expect(c == "c")

    #expect(stack.count == 2)
    #expect(stack.search("a") == 2)
    #expect(stack.search("c") == 1)
  }

  @Test("stack with numeric types")
  func testNumericStack() throws {
    let stack = java.util.Stack<Int>()

    for i in 1...5 {
      _ = stack.push(i * 10)
    }

    // Stack from top: 50, 40, 30, 20, 10
    let top: Int = try stack.peek()
    #expect(top == 50)

    let popped: Int = try stack.pop()
    #expect(popped == 50)

    // After pop, stack is: 40, 30, 20, 10 (from top)
    // 40 is now at top (position 1)
    #expect(stack.search(40) == 1)
  }

  // MARK: - Edge Cases

  @Test("stack handles nil-able elements")
  func testOptionalElements() throws {
    let stack = java.util.Stack<String?>()

    _ = stack.push("value")
    _ = stack.push(nil)
    _ = stack.push("another")

    let top: String? = try stack.peek()
    #expect(top == "another")

    let popped: String? = try stack.pop()
    #expect(popped == "another")

    let next: String? = try stack.peek()
    #expect(next == nil)
  }

  @Test("stack with large number of elements")
  func testLargeStack() throws {
    let stack = java.util.Stack<Int>()
    let n = 1000

    for i in 0..<n {
      _ = stack.push(i)
    }

    #expect(stack.count == n)

    let top: Int = try stack.peek()
    #expect(top == n - 1)

    for _ in 0..<n {
      let _: Int = try stack.pop()
    }

    #expect(stack.empty())
  }

  @Test("stack reuse after clearing")
  func testReuseAfterEmpty() throws {
    let stack = java.util.Stack<String>()

    // First use
    _ = stack.push("first")
    let _: String = try stack.pop()

    // Reuse
    _ = stack.push("second")
    let second: String = try stack.peek()
    #expect(second == "second")
    #expect(stack.count == 1)
  }

  // MARK: - Inherited Vector Behavior

  @Test("stack supports add() method from Vector")
  func testAddFromVector() {
    let stack = java.util.Stack<String>()
    stack.addElement("x")

    #expect(stack.count == 1)
  }

  @Test("stack supports count property")
  func testCountProperty() {
    let stack = java.util.Stack<String>()
    _ = stack.push("a")
    _ = stack.push("b")

    #expect(stack.count == 2)
  }

  @Test("stack supports subscript access from Vector")
  func testSubscriptAccess() throws {
    let stack = java.util.Stack<String>()
    _ = stack.push("first")
    _ = stack.push("second")

    let first: String = try stack[0]
    let second: String = try stack[1]

    #expect(first == "first")
    #expect(second == "second")
  }

}
