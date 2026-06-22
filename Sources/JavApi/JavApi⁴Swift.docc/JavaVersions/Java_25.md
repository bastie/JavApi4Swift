# Java 25

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

2025-09-16 release of Java 25 (LTS).

## Overview

Java 25 is a Long-Term Support release. It standardised `java.lang.IO` (previously a `java.io.IO` preview in Java 23) as the canonical lightweight console I/O helper.

### How to read?

- Header type name (count of fields or methods/ count of implemented of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

## java.lang — Java 25 additions

##### java.lang.IO (5/5/0)

Lightweight console I/O helper — standardised in Java 25 after preview in Java 23 (`java.io.IO`).
Provides simple `print`, `println`, and `readln` operations on `System.out` / `System.in` without importing stream classes.

version | implemented | tested | type        | name              | more informations
------- | ----------- | ------ | ----------- | ----------------- | -----------------
25      | ✔️          | ⭕️    | method      | println(String)   | prints string + newline to System.out
25      | ✔️          | ⭕️    | method      | println()         | prints newline to System.out
25      | ✔️          | ⭕️    | method      | print(Any)        | prints string representation to System.out
25      | ✔️          | ⭕️    | method      | readln()          | reads next line from System.in, returns String?
25      | ✔️          | ⭕️    | method      | readln(String?)   | prints prompt, then reads line from System.in

> **Note:** The Java 25 API defines `readln()` to return `String` (never `null`). The JavApi⁴Swift implementation returns `String?` to reflect the possibility of EOF on the underlying `BufferedReader`.

## Not in scope for this implementation
