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

### java.util.Formatter — new in 1.5

##### java.util.Formatter

version | implemented | tested   | type          | name                        | more informations
------- | ----------- | -------- | ------------- | --------------------------- | -----------------
1.5     | ✔️          | ✔️       | constructor   | Formatter()                 |
1.5     | ✔️          | ✔️       | method        | format(String, Object...)   | returns self
1.5     | ✔️          | ✔️       | method        | toString()                  |
1.5     | ✔️          | ⭕️       | method        | out()                       | returns StringBuilder

### java.lang.String — Java 1.5 additions

##### java.lang.String (format)

version | implemented | tested   | type          | name                        | more informations
------- | ----------- | -------- | ------------- | --------------------------- | -----------------
1.5     | ✔️          | ✔️       | static        | format(String, Object...)   | via Java2SwiftFormatter

### java.io.PrintStream — Java 1.5 additions

##### java.io.PrintStream (printf/format)

version | implemented | tested   | type          | name                        | more informations
------- | ----------- | -------- | ------------- | --------------------------- | -----------------
1.5     | ✔️          | ⭕️       | method        | printf(String, Object...)   | returns self
1.5     | ✔️          | ⭕️       | method        | format(String, Object...)   | returns self

### java.util.Locale — Java 1.5 additions

##### java.util.Locale (setDefault)

version | implemented | tested   | type          | name                        | more informations
------- | ----------- | -------- | ------------- | --------------------------- | -----------------
1.5     | ✔️          | ✔️       | static        | setDefault(Locale)          |

> **Format specifiers supported by Java2SwiftFormatter:** `%s/%S`, `%d`, `%f`, `%e/%E`, `%g/%G`, `%o`, `%x/%X`, `%b/%B`, `%c`, `%n`, `%%`, `%,d`/`%,f` (grouping), `%tY`/`%tm`/… (date/time), `%1$s` (argument index). Decimal and grouping separators are locale-sensitive via `Locale.setDefault()`.
