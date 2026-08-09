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

## java.util.function: Functional Interfaces as a Migration Layer

Java 8 introduced `java.util.function` — a set of standard functional interfaces such as
`Predicate<T>`, `Function<T,R>`, `Consumer<T>`, and `BiFunction<T,U,R>`. These interfaces
appear throughout the Java standard library wherever lambdas are used (e.g., `Collection.removeIf`,
`Map.forEach`, `Comparator.comparing`).

JavApi⁴Swift implements these as Swift protocols so that Java code that references them
can be ported mechanically, without rewriting every call site.

### Recommendation: Prefer Swift closures for new code

For new Swift code, **always prefer closures** over the `java.util.function` protocols.
Swift closures are concise, integrate natively with the language, and work directly with
`Sequence`, `Array`, `Dictionary`, and all Swift collection APIs:

```swift
// ✅ Idiomatic Swift — use this for new code
let names = ["Alice", "Bob", "Anna", "Carol"]
let aNames = names.filter { $0.hasPrefix("A") }         // ["Alice", "Anna"]
let lengths = names.map { $0.count }                     // [5, 3, 4, 5]
names.forEach { print($0) }
```

### When to use java.util.function

Use the `java.util.function` protocols when:

- Porting existing Java code that passes `Predicate`, `Function`, or `Consumer` objects explicitly
- Writing library code that must expose a Java-compatible API
- Working with JavApi⁴Swift collection methods that accept these functional interfaces
  (e.g., a future `Collection.removeIf(Predicate)`)

### Available types

| Java type | JavApi⁴Swift protocol | Concrete wrapper | Main method |
|---|---|---|---|
| `Predicate<T>` | `java.util.function.Predicate<T>` | `AnyPredicate<T>` | `test(_ t: T) -> Bool` |
| `Function<T,R>` | `java.util.function.Function<T,R>` | `AnyFunction<T,R>` | `apply(_ t: T) -> R` |
| `Consumer<T>` | `java.util.function.Consumer<T>` | `AnyConsumer<T>` | `accept(_ t: T)` |
| `BiConsumer<T,U>` | `java.util.function.BiConsumer<T,U>` | `AnyBiConsumer<T,U>` | `accept(_ t: T, _ u: U)` |
| `BiFunction<T,U,R>` | `java.util.function.BiFunction<T,U,R>` | `AnyBiFunction<T,U,R>` | `apply(_ t: T, _ u: U) -> R` |
| `UnaryOperator<T>` | `java.util.function.UnaryOperator<T>` | `AnyUnaryOperator<T>` | `apply(_ t: T) -> T` |
| `BinaryOperator<T>` | `java.util.function.BinaryOperator<T>` | `AnyBinaryOperator<T>` | `apply(_ t: T, _ u: T) -> T` |
| `Supplier<T>` | `java.util.function.Supplier<T>` | *(implement your own)* | `get() -> T` |

### Usage: wrapping a closure

Each protocol has a corresponding `Any*` concrete wrapper that takes a Swift closure.
This is the bridge between Swift closures and the Java-compatible protocols:

```swift
// Java: Predicate<String> startsWithA = s -> s.startsWith("A");
let startsWithA = java.util.function.AnyPredicate<String> { $0.hasPrefix("A") }
startsWithA.test("Alice")   // true
startsWithA.test("Bob")     // false
```

### Default methods: composition

All types support the same default-method composition as their Java counterparts:

```swift
let isPositive = java.util.function.AnyPredicate<Int> { $0 > 0 }
let isEven     = java.util.function.AnyPredicate<Int> { $0 % 2 == 0 }

// Predicate.and / or / negate
let isPositiveEven = isPositive.and(isEven)
let isPositiveOrEven = isPositive.or(isEven)
let isNonPositive = isPositive.negate()
let isNotEven = java.util.function.AnyPredicate<Int>.not(isEven)

// Function.andThen / compose
let toLength  = java.util.function.AnyFunction<String, Int> { $0.count }
let isLong    = toLength.andThen(java.util.function.AnyFunction<Int, Bool> { $0 > 3 })
isLong.apply("hi")      // false
isLong.apply("hello")   // true

// Consumer.andThen — chains side effects
var log: [String] = []
let logger = java.util.function.AnyConsumer<String> { log.append($0) }
let printer = java.util.function.AnyConsumer<String> { print($0) }
let both = logger.andThen(printer)
both.accept("event")   // appends to log AND prints
```

### Implementing your own conforming type

You can conform any Swift type to a `java.util.function` protocol directly:

```swift
struct StartsWithPredicate: java.util.function.Predicate {
  typealias T = String
  let prefix: String
  func test(_ t: String) -> Bool { t.hasPrefix(prefix) }
}

let check = StartsWithPredicate(prefix: "A")
check.test("Alice")   // true
```

### Side-by-side comparison: Migration step by step

The table below shows a typical migration from Java through the JavApi⁴Swift compatibility
layer to idiomatic Swift.

| Step | Code |
|---|---|
| **Java** | `list.removeIf(s -> s.isEmpty());` |
| **JavApi⁴Swift (compatibility)** | `list.removeIf(AnyPredicate { $0.isEmpty })` |
| **Idiomatic Swift** | `list.removeAll { $0.isEmpty }` |

| Step | Code |
|---|---|
| **Java** | `map.forEach((k, v) -> System.out.println(k + "=" + v));` |
| **JavApi⁴Swift (compatibility)** | `map.forEach(AnyBiConsumer { k, v in print("\(k)=\(v)") })` |
| **Idiomatic Swift** | `map.forEach { k, v in print("\(k)=\(v)") }` |

---

## See Also

- <doc:Collections> — Lists, maps, stacks, and sets.
- <doc:Java2Swift> — Mechanical translation rules for porting Java to Swift.
- <doc:Util-Implementation> — Implementation status and open tasks for `java.util`.
