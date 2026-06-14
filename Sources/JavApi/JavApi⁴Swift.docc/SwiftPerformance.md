# Swift Performance Notes

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Performance observations and patterns collected during the JavApi4Swift port.

## Overview

This document collects Swift-specific performance notes that are relevant when porting Java code or implementing JavApi4Swift wrapper types. It is a living document — add new findings as they are discovered.

---

### Overflow operators `&+` / `&-` / `&*`

Swift's standard arithmetic operators (`+`, `-`, `*`) include overflow checks that emit extra CPU instructions (`cmp` + conditional trap) in both debug and release builds. The overflow operators `&+`, `&-`, `&*` skip these checks entirely.

**When to use them:**

Use `&+`, `&-`, `&*` inside the JavApi4Swift *wrapper-class implementations* of `Integer`, `Long`, `Short`, and `Byte`. Java integer arithmetic always wraps silently on overflow (two's complement), so this also gives correct Java semantics — the performance gain is a free bonus.

```swift
// correct and faster — no overflow trap instructions emitted
public static func + (lhs: Integer, rhs: Integer) -> Self {
  return .init(integerLiteral: lhs.value &+ rhs.value)
}
```

**When NOT to use them:**

Do not replace `+`/`-`/`*` with `&+`/`&-`/`&*` in ported Java *application code*. That would require touching every arithmetic expression in the entire codebase and is out of scope. The normal Swift operators on primitive types (`Int`, `Int64`, `Int16`, `Int8`) are correct for ported code as long as the types have the same width as the corresponding Java types.

**Magnitude of the gain:**

The difference is small per operation but measurable in tight loops with millions of iterations (e.g. image processing, graphics, codec math). In typical UI code the effect is negligible.

---

### `final` classes

Mark wrapper classes (`Integer`, `Long`, `Short`, `Byte`) as `public final class`. This matches Java's specification (all are `final` in `java.lang`) and allows the Swift compiler to devirtualize method calls — no vtable lookup needed.

---

### `@unchecked Sendable`

Wrapper classes that hold a single immutable or manually-synchronized value are annotated `@unchecked Sendable`. This suppresses the Swift 6 concurrency warning without adding runtime overhead (no lock, no atomic). Only use it when you can reason that no data race is possible.

---

