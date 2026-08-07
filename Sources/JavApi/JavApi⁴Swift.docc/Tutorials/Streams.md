# Streams and Sequences

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Processing collections lazily with Java Streams, Swift Sequences, and JavApi⁴Swift.

## Overview

Java 8 introduced the Stream API as a way to express collection pipelines — filter, transform, and aggregate data without explicit loops. Swift provides the same capability through `Sequence`, `LazySequence`, and higher-order functions.

This article shows the same operations written three ways:

1. **Java** — the original Stream API
2. **Swift** — idiomatic Swift using `Sequence` and `LazySequence`
3. **JavApi⁴Swift** — for code being ported directly from Java (coming soon)

---

## The Pipeline Model

Both Java Streams and Swift Sequences follow the same pipeline model:

```
source → intermediate operations → terminal operation
```

**Intermediate operations** are lazy — they describe a transformation but do no work until a terminal operation pulls values through the pipeline.

**Terminal operations** trigger evaluation and produce a result (a value, a collection, or a side effect).

---

## Java: Stream API

### Creating a Stream

```java
// From a List
List<String> names = List.of("Alice", "Bob", "Carol", "Dave");
Stream<String> stream = names.stream();

// From values directly
Stream<Integer> numbers = Stream.of(1, 2, 3, 4, 5);

// Infinite stream
Stream<Integer> naturals = Stream.iterate(0, n -> n + 1);
```

### Intermediate Operations

```java
List<String> names = List.of("Alice", "Bob", "Carol", "Dave", "Anna");

// filter — keep elements matching a predicate
List<String> aNames = names.stream()
    .filter(name -> name.startsWith("A"))
    .collect(Collectors.toList());
// → ["Alice", "Anna"]

// map — transform each element
List<Integer> lengths = names.stream()
    .map(String::length)
    .collect(Collectors.toList());
// → [5, 3, 5, 4, 4]

// flatMap — flatten nested collections
List<List<Integer>> nested = List.of(List.of(1, 2), List.of(3, 4));
List<Integer> flat = nested.stream()
    .flatMap(Collection::stream)
    .collect(Collectors.toList());
// → [1, 2, 3, 4]

// sorted, distinct, limit, skip
List<Integer> nums = List.of(3, 1, 4, 1, 5, 9, 2, 6, 5);
List<Integer> result = nums.stream()
    .distinct()
    .sorted()
    .limit(5)
    .collect(Collectors.toList());
// → [1, 2, 3, 4, 5]
```

### Terminal Operations

```java
List<Integer> numbers = List.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// forEach — side effect
numbers.stream().forEach(System.out::println);

// count
long count = numbers.stream().filter(n -> n % 2 == 0).count();
// → 5

// reduce
int sum = numbers.stream().reduce(0, Integer::sum);
// → 55

// findFirst
Optional<Integer> first = numbers.stream().filter(n -> n > 5).findFirst();
// → Optional[6]

// anyMatch / allMatch / noneMatch
boolean hasEven   = numbers.stream().anyMatch(n -> n % 2 == 0);  // true
boolean allPos    = numbers.stream().allMatch(n -> n > 0);        // true
boolean noneNeg   = numbers.stream().noneMatch(n -> n < 0);       // true

// min / max
Optional<Integer> min = numbers.stream().min(Integer::compareTo); // Optional[1]
Optional<Integer> max = numbers.stream().max(Integer::compareTo); // Optional[10]

// collect to different containers
Set<Integer>    asSet  = numbers.stream().collect(Collectors.toSet());
String          joined = Stream.of("a", "b", "c").collect(Collectors.joining(", "));
// → "a, b, c"
```

### Collectors

```java
List<String> words = List.of("apple", "banana", "avocado", "blueberry", "cherry");

// groupingBy — Map<K, List<V>>
Map<Character, List<String>> byFirstLetter = words.stream()
    .collect(Collectors.groupingBy(w -> w.charAt(0)));
// → {a=[apple, avocado], b=[banana, blueberry], c=[cherry]}

// counting
Map<Character, Long> countByLetter = words.stream()
    .collect(Collectors.groupingBy(w -> w.charAt(0), Collectors.counting()));
// → {a=2, b=2, c=1}

// joining with prefix/suffix
String formatted = words.stream()
    .collect(Collectors.joining(", ", "[", "]"));
// → "[apple, banana, avocado, blueberry, cherry]"
```

---

## Swift: Sequence and LazySequence

Swift's `Sequence` protocol is the direct counterpart to Java's `Iterable`, while `LazySequence` corresponds to `Stream` — it applies transformations lazily.

### Creating a Sequence

```swift
// From an Array (conforms to Sequence automatically)
let names = ["Alice", "Bob", "Carol", "Dave"]

// Lazy wrapper — like calling .stream() in Java
let lazyNames = names.lazy

// Infinite sequence
let naturals = sequence(first: 0, next: { $0 + 1 })
```

### Intermediate Operations (Lazy)

```swift
let names = ["Alice", "Bob", "Carol", "Dave", "Anna"]

// filter
let aNames = names.lazy
    .filter { $0.hasPrefix("A") }
// Materialise to Array when needed:
let aNamesList = Array(aNames)
// → ["Alice", "Anna"]

// map
let lengths = names.lazy
    .map { $0.count }
let lengthsList = Array(lengths)
// → [5, 3, 5, 4, 4]

// flatMap
let nested = [[1, 2], [3, 4]]
let flat = Array(nested.lazy.flatMap { $0 })
// → [1, 2, 3, 4]

// sorted, prefix (= limit), dropFirst (= skip)
let nums = [3, 1, 4, 1, 5, 9, 2, 6, 5]
let result = Array(
    Set(nums)           // distinct (order not guaranteed — use sorted afterwards)
        .sorted()
        .prefix(5)
)
// → [1, 2, 3, 4, 5]
```

> **Note on `distinct`:** Swift has no lazy `distinct()`. The idiomatic approach is
> `Set(sequence)` for unordered deduplication, or a manual filter with a `seen` set for
> order-preserving deduplication.

### Terminal Operations

```swift
let numbers = Array(1...10)

// forEach
numbers.forEach { print($0) }

// count (after filter)
let evenCount = numbers.filter { $0 % 2 == 0 }.count
// → 5

// reduce
let sum = numbers.reduce(0, +)
// → 55

// first(where:) — equivalent to findFirst()
let firstOver5 = numbers.first { $0 > 5 }
// → Optional(6)

// contains(where:) — anyMatch
let hasEven = numbers.contains { $0 % 2 == 0 }  // true

// allSatisfy — allMatch
let allPos = numbers.allSatisfy { $0 > 0 }       // true

// !contains(where:) — noneMatch
let noneNeg = !numbers.contains { $0 < 0 }       // true

// min / max
let minVal = numbers.min()   // Optional(1)
let maxVal = numbers.max()   // Optional(10)

// joined — Collectors.joining equivalent
let joined = ["a", "b", "c"].joined(separator: ", ")
// → "a, b, c"
```

### Grouping — Collectors.groupingBy Equivalent

```swift
let words = ["apple", "banana", "avocado", "blueberry", "cherry"]

// Dictionary(grouping:by:) — equivalent to Collectors.groupingBy
let byFirstLetter = Dictionary(grouping: words) { $0.first! }
// → ["a": ["apple", "avocado"], "b": ["banana", "blueberry"], "c": ["cherry"]]

// counting per group
let countByLetter = byFirstLetter.mapValues { $0.count }
// → ["a": 2, "b": 2, "c": 1]

// joining with prefix/suffix
let formatted = "[" + words.joined(separator: ", ") + "]"
// → "[apple, banana, avocado, blueberry, cherry]"
```

### Comparison Table: Java → Swift

| Java Stream | Swift equivalent | Lazy? |
|---|---|---|
| `stream()` | `.lazy` | — |
| `filter(predicate)` | `.filter { }` | ✅ via `.lazy` |
| `map(function)` | `.map { }` | ✅ via `.lazy` |
| `flatMap(function)` | `.flatMap { }` | ✅ via `.lazy` |
| `distinct()` | `Set(...)` or manual | ❌ |
| `sorted()` | `.sorted()` | ❌ |
| `limit(n)` | `.prefix(n)` | ✅ via `.lazy` |
| `skip(n)` | `.dropFirst(n)` | ✅ via `.lazy` |
| `peek(action)` | no direct equivalent | — |
| `forEach(action)` | `.forEach { }` | — |
| `count()` | `.count` | — |
| `reduce(identity, op)` | `.reduce(identity, op)` | — |
| `findFirst()` | `.first(where:)` | — |
| `anyMatch(pred)` | `.contains(where:)` | — |
| `allMatch(pred)` | `.allSatisfy { }` | — |
| `noneMatch(pred)` | `!contains(where:)` | — |
| `min(comparator)` | `.min()` / `.min(by:)` | — |
| `max(comparator)` | `.max()` / `.max(by:)` | — |
| `collect(toList())` | `Array(...)` | — |
| `collect(toSet())` | `Set(...)` | — |
| `collect(joining(","))` | `.joined(separator:)` | — |
| `collect(groupingBy(f))` | `Dictionary(grouping:by:)` | — |
| `Stream.of(...)` | `[...].lazy` or `sequence(...)` | — |
| `Stream.generate(supplier)` | `sequence(state:next:)` | ✅ |
| `Stream.iterate(seed, f)` | `sequence(first:next:)` | ✅ |
| `parallel()` | see JavApi⁴Swift section | — |

---

## JavApi⁴Swift: Porting Java Stream Code

> **Work in progress.** The `java.util.stream` package is planned for a future release of
> JavApi⁴Swift. This section will be filled in once `Stream<T>` and `Collectors` are
> implemented. Track progress in
> <doc:Util-Implementation> under the *Java 8 — java.util.stream* section.

When available, ported Java code like:

```java
List<String> result = names.stream()
    .filter(name -> name.startsWith("A"))
    .map(String::toUpperCase)
    .collect(Collectors.toList());
```

will be expressible in JavApi⁴Swift as:

```swift
// Planned API — not yet implemented
let result = names.stream()
    .filter { $0.hasPrefix("A") }
    .map { $0.uppercased() }
    .collect(Collectors.toList())
```

Until `java.util.stream` is available, replace Java Stream pipelines with the Swift
`Sequence` / `LazySequence` patterns shown in the previous section.

---

## See Also

- <doc:Collections> — Lists, maps, stacks, and sets.
- <doc:Java2Swift> — Mechanical translation rules for porting Java to Swift.
- <doc:Util-Implementation> — Implementation status and open tasks for `java.util`.
