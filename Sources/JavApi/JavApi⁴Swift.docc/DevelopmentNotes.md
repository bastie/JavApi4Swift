# Development Notes

Lessons learned and non-obvious design decisions for future contributors.

---

## `java.util.ArrayList` — Reference Type Implementation (2026-06)

### Problem
`java.util.ArrayList` was aliased to Swift's `Array` (`typealias ArrayList = Array`).
Swift `Array` is a **value type** (copy-on-write), Java `ArrayList` is a **reference type**.
This is a semantic dead end — aliasing cannot express Java's reference semantics.

### Solution
Implemented `ArrayList<E>` as a Swift `class` inheriting `AbstractList<E>`.
Tests explicitly verify reference semantics vs. Swift Array behavior.

---

## `java.util.Iterator` — Protocol Design (2026-06)

### Problem: Signature conflict
Java's `Iterator.next()` throws; Swift's `IteratorProtocol.next()` returns `Element?`.
Having `java.util.Iterator` inherit `IteratorProtocol` caused an irresolvable conflict:
- Java: `func next() throws -> Element`
- Swift: `func next() -> Element?`
Swift cannot satisfy both from one implementation.

### Solution
`java.util.Iterator` does **not** inherit `IteratorProtocol`.
Concrete iterator classes (`ArrayListIterator`, `ArrayListListIterator`) explicitly conform
to **both** protocols with two distinct overloads:

```swift
// java.util.Iterator — Java API
func next() throws(java.util.NoSuchElementException) -> E

// IteratorProtocol — Swift for-in
func next() -> E?
```

Swift 6 distinguishes the overloads by return type and `throws` clause.
`makeIterator()` returns `self` (concrete type) — no `AnyIterator` boxing needed.

### Why not the Extension default?
`Iterator+Swiftify.swift` provides a default `makeIterator() -> AnyIterator<Element?>`
for any `java.util.Iterator` conformer. However, Swift protocol-extension defaults do
**not** satisfy `Sequence` conformance for concrete types — the compiler requires
`makeIterator()` to be defined on the type itself. The extension default is still useful
for existentials (`any java.util.Iterator`) but cannot substitute for direct conformance.

---

## `java.lang.Iterable` — Not an Iterator (2026-06)

### Problem
`Iterable` had inherited `IteratorProtocol`. An `Iterable` **produces** iterators; it is
not one. This caused SIGABRT via a forced `as! Self.Iterator` cast in a Collection extension.

### Solution
`Iterable` has no `IteratorProtocol` inheritance. It only declares:
```swift
func iterator() -> any java.util.Iterator<E>
```

---

## `AbstractCollection.makeIterator()` (2026-06)

`AbstractCollection` satisfies Swift `Sequence` via:
```swift
public typealias Element = E?
public func makeIterator() -> AnyIterator<E?> {
  return self.iterator().makeIterator()
}
```

The `AnyIterator` wrapper is acceptable here because `AbstractCollection` works with
`any java.util.Iterator<E>` existentials (from subclass `iterator()` overrides) and
there is no single concrete iterator type to return directly.

---

## `remove(_:)` Overload Ambiguity (2026-06)

Java has two `remove` methods on `List`:
- `remove(int index)` — by position
- `remove(Object o)` — by value

In Swift both map to `remove(_:)` with different parameter types (`Int` vs `E?`).
When the element type is `Int`, the call `list.remove(5)` is ambiguous.

**Disambiguate with explicit cast in call sites:**
```swift
list.remove(5)       // ambiguous if E == Int
list.remove(5 as Int?)  // remove by value
try list.remove(0)   // remove by index (throws)
```
