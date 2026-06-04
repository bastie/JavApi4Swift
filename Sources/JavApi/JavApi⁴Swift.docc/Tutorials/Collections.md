# Collections

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Storing and working with groups of objects using List, Map, Stack, and more.

## Overview

A *collection* is an object that holds other objects. Java's `java.util` package provides a rich set of collection types: ordered lists, key-value maps, stacks, and queues. JavApi⁴Swift implements all of these on top of Swift's own collection types.

The most important thing to know upfront: **Java collections are reference types; Swift arrays and dictionaries are value types.** This means that in Swift, assigning a collection to a new variable creates a *copy*, not a second reference to the same object. JavApi⁴Swift's `ArrayList` and `HashMap` are classes (reference types), so they behave like Java.

## ArrayList

`java.util.ArrayList` is an ordered, resizable list — the most commonly used collection in Java.

```swift
import JavApi

var fruits = java.util.ArrayList<String>()

// Adding elements — add() returns true (Java convention)
_ = fruits.add("apple")
_ = fruits.add("banana")
_ = fruits.add("cherry")

// Size
print(fruits.count)          // 3

// Accessing by index (Swift subscript)
print(fruits[0])             // "apple"

// Checking membership
if fruits.contains("banana") {
    print("We have bananas.")
}
```

> **Why does `add()` return `Bool`?** In Java, `Collection.add()` returns `true` when the collection changed. For a list this is always `true`, but discarding the return value with `_ =` makes the intent explicit and silences the Swift compiler warning.

### ArrayList is Just a Swift Array

`java.util.ArrayList<E>` is a typealias for Swift's `Array<E>`. This means you can use every Swift array method on it:

```swift
var numbers = java.util.ArrayList<Int>()
_ = numbers.add(3)
_ = numbers.add(1)
_ = numbers.add(2)

// Swift sort
numbers.sort()
print(numbers)   // [1, 2, 3]

// Swift map
let doubled = numbers.map { $0 * 2 }
print(doubled)   // [2, 4, 6]
```

## LinkedHashMap

`java.util.LinkedHashMap` is a map that remembers insertion order. Use it when the order in which you put things in matters.

```swift
import JavApi

let scores = java.util.LinkedHashMap<String, Int>()

// Inserting — put() returns the previous value, or nil if none
let previous = scores.put("Alice", 95)   // nil (first insert)
_ = scores.put("Bob",   87)
_ = scores.put("Carol", 92)

// Retrieving
if let aliceScore = scores["Alice"] {
    print("Alice scored \(aliceScore)")   // Alice scored 95
}

// Overwriting returns the old value
let old = scores.put("Alice", 98)   // old == 95
print(scores["Alice"]!)              // 98

// Size
print(scores.size())   // 3
```

## HashMap

`java.util.HashMap` is a key-value store where order is not guaranteed. It is faster than `LinkedHashMap` for large datasets because it does not track insertion order.

```swift
import JavApi

let capitals = java.util.HashMap<String, String>()
_ = capitals.put("Germany", "Berlin")
_ = capitals.put("France",  "Paris")
_ = capitals.put("Japan",   "Tokyo")

print(capitals.get("France") ?? "unknown")   // "Paris"
print(capitals.containsKey("Spain"))          // false
```

## Stack

A stack is a last-in, first-out (LIFO) collection. Think of a pile of plates: you always take from the top.

```swift
import JavApi

var stack = java.util.Stack<String>()
_ = stack.add("first")
_ = stack.add("second")
_ = stack.add("third")

// search() returns 1-based distance from top, or -1 if not found
print(stack.search("second"))   // 2  (second from top)
print(stack.search("missing"))  // -1
```

## Collections Utility Class

`java.util.Collections` provides static helper methods:

```swift
import JavApi

// An empty, immutable set
let empty = java.util.Collections.emptySet<Int>()
```

## Arrays Utility Class

`java.util.Arrays` provides helpers for working with Swift arrays:

```swift
import JavApi

// Copy part of an array
let original = [10, 20, 30, 40, 50]
let copy      = java.util.Arrays.copyOfRange(original, 1, 4)   // [20, 30, 40]

// Extend or truncate (pads with zeros)
let shorter = java.util.Arrays.copyOf(original, 3)   // [10, 20, 30]
let longer  = java.util.Arrays.copyOf(original, 7)   // [10, 20, 30, 40, 50, 0, 0]

// Fill a range
var data = [0, 0, 0, 0, 0]
java.util.Arrays.fill(&data, 1, 4, 99)
print(data)   // [0, 99, 99, 99, 0]

// Compare byte arrays
let a: [UInt8] = [1, 2, 3]
let b: [UInt8] = [1, 2, 3]
print(java.util.Arrays.equals(a, b))   // true
```

## Choosing the Right Collection

| Java type | JavApi⁴Swift | Use when |
|---|---|---|
| `ArrayList<E>` | `java.util.ArrayList<E>` | Ordered list, index access |
| `LinkedHashMap<K,V>` | `java.util.LinkedHashMap<K,V>` | Key-value, insertion order matters |
| `HashMap<K,V>` | `java.util.HashMap<K,V>` | Key-value, order irrelevant |
| `Stack<E>` | `java.util.Stack<E>` | LIFO, undo-style access |
| Swift `[E]` | — | When you don't need Java API compatibility |
| Swift `[K:V]` | — | When you don't need Java API compatibility |

## Questions and Exercises

1. Create an `ArrayList<Int>` containing the numbers 5, 3, 8, 1, 9. Sort it using Swift's `.sort()`. What is the result?
2. Use `LinkedHashMap` to store three countries and their capital cities. Print each capital in the order you inserted it.
3. What does `java.util.Arrays.copyOf([1, 2, 3], 5)` return? Why?
4. A `Stack` holds the values `["a", "b", "c"]` (added in that order). What does `search("a")` return?

## Next Steps

Continue to <doc:DateTime> to learn how to work with dates and times using the `java.time` API.
