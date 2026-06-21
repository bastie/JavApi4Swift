# Java 7

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

2011-07-28 release of Java 7 (Dolphin).

## Overview

Java 7 introduced try-with-resources (`AutoCloseable`), the diamond operator, multi-catch, NIO.2 (`java.nio.file`), `ForkJoinPool`, and `invokedynamic`.

### How to read?

- Header type name (count of fields or methods/ count of implemented of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

## java.io — Java 7 additions

### Try-with-resources

##### java.io.AutoCloseable (1/1/✔️)

> **Note:** Java 7 moved `AutoCloseable` to `java.lang`; for historical and Swift-namespace reasons it lives in `java.io` in this project, extending `java.io.Closeable`.
>
> The Swift equivalent of try-with-resources is provided via the `tryWith { }` extension method on `AutoCloseable`. See ``java.io.AutoCloseable`` for usage examples.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
7       | ✔️          | 🪄       | protocol      | AutoCloseable  | extends Closeable — `close()` inherited
7       | ✔️          | 🪄       | method (ext)  | tryWith()      | Swift replacement for try-with-resources — calls `close()` in `defer`
7       | ✔️          | 🪄       | method (ext)  | try()          | alias for `tryWith()` using backtick escaping

## java.nio.charset — Java 7 additions

##### java.nio.charset.StandardCharsets (6/6/⭕️)

Konstante Charset-Referenzen für die sechs garantiert verfügbaren Zeichensätze — hinzugefügt in Java 7, ersetzt Magic-Strings wie `"UTF-8"` durch typsichere Felder.

version | implemented | tested | type     | name        | more informations
------- | ----------- | ------ | -------- | ----------- | -----------------
7       | ✔️          | ⭕️    | field    | ISO_8859_1  | Latin-1
7       | ✔️          | ⭕️    | field    | US_ASCII    | 7-Bit ASCII
7       | ✔️          | ⭕️    | field    | UTF_8       | Unicode UTF-8
7       | ✔️          | ⭕️    | field    | UTF_16      | Unicode UTF-16, Byte-Order per BOM
7       | ✔️          | ⭕️    | field    | UTF_16BE    | Unicode UTF-16, Big-Endian
7       | ✔️          | ⭕️    | field    | UTF_16LE    | Unicode UTF-16, Little-Endian

## Not in scope for this implementation

- **NIO.2 / `java.nio.file`** — `Path`, `Files`, `FileSystem`, `WatchService` etc. Swift Foundation provides equivalent APIs natively.
- **`java.util.concurrent.ForkJoinPool`** — GCD / Swift Concurrency are the native equivalents.
- **`invokedynamic` / `java.lang.invoke`** — JVM bytecode feature, not a library API.
- **`java.util.Objects`** — tracked when relevant callers are ported.
