# Java 23

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

2024-09-17 release of Java 23.

## Overview

Java 23 introduced `java.io.IO` as a preview API — a lightweight helper type for simple console I/O without requiring `System.out` or `System.in` directly. It was later moved to `java.lang.IO` in Java 25.

### How to read?

- Header type name (count of fields or methods/ count of implemented of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

> **Note:** `java.io.IO` was a **preview feature** in Java 23. It is retained here as a deprecated typealias pointing to `java.lang.IO` (introduced in Java 25).

## java.io — Java 23 additions

##### java.io.IO (1/1/0)

Lightweight console I/O helper — added as a preview API in Java 23, deprecated in favour of `java.lang.IO` in Java 25.

The JavApi⁴Swift implementation provides `java.io.IO` as a `typealias` to `java.lang.IO` and marks it `@available(*, deprecated, renamed: "java.lang.IO")` to guide migration.

version | implemented | tested | type     | name          | more informations
------- | ----------- | ------ | -------- | ------------- | -----------------
23      | ✔️          | 🪄     | typealias | IO            | deprecated → java.lang.IO

## Not in scope for this implementation

