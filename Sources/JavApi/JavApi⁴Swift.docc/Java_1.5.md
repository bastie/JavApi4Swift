# Java 1.5

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

2004-09-30 release of Java 1.5 (Tiger).

## Overview

Java 1.5 introduced generics, autoboxing/unboxing, enhanced for-loop, varargs, static imports, annotations, enumerations, and `java.util.concurrent`.

### How to read?

- Header type name (count of fields or methods/ count of implemented of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

## Java Core Packages

### java.lang

#### java.lang.System — Java 1.5 additions

##### java.lang.System (3/3/⭕️)

version | implemented | tested   | type          | name             | more informations
------- | ----------- | -------- | ------------- | ---------------- | -----------------
1.5     | ✔️          | ⭕️       | method        | getenv()         | ()->Map<String,String>
1.5     | ✔️          | ⭕️       | method        | getenv()         | (String)->String?

#### java.lang.System.clearProperty — Java 1.5 addition

version | implemented | tested   | type          | name             | more informations
------- | ----------- | -------- | ------------- | ---------------- | -----------------
1.5     | ✔️          | ⭕️       | method        | clearProperty()  | (String)->String?
