# Java 9

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

2017-09-21 release of Java 9 (Project Jigsaw).

## Overview

Java 9 introduced the module system (JPMS), the `java.util.zip.CRC32C` checksum algorithm, collection factory methods, and various API additions.

### How to read?

- Header type name (count of fields or methods/ count of implemented of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

> **Note:** The Java 9 module system (JPMS) has no Swift equivalent and is **not** ported.

## java.util.zip — Java 9 additions

##### java.util.zip.CRC32C (1/1/⭕️)

CRC-32C (Castagnoli) checksum algorithm — added to `java.util.zip` in Java 9.
Implements the same `Checksum` interface as `CRC32`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
9       | ✔️          | ⭕️       | constructor   | CRC32C()       | ()
9       | ✔️          | ⭕️       | method        | update()       | (int) / (byte[],int,int)
9       | ✔️          | ⭕️       | method        | getValue()     | ()->long
9       | ✔️          | ⭕️       | method        | reset()        | ()

## Not in scope for this implementation

- **Java Platform Module System (JPMS)** — `module-info.java`, `requires`, `exports`, `opens` — no Swift equivalent.
- **`jlink` / `jimage`** — JDK tooling, not a library API.
- **`java.lang.ProcessHandle`** — OS process management; Swift provides native alternatives.
- **`java.net.http`** (preview in 9, standardised in 11) — tracked in Java_11.md when implemented.
- **Collection factory methods** (`List.of`, `Set.of`, `Map.of`) — tracked when relevant Java sources require them.
