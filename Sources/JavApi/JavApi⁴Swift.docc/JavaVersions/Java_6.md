# Java 1.6

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

2006-12-11 release of Java 1.6 (Mustang).

## Overview

Java 1.6 introduced scripting support (`javax.script`), improvements to `java.util.concurrent`, pluggable annotation processing, JDBC 4.0, and various additions to existing APIs.

### How to read?

- Header type name (count of fields or methods/ count of implemented of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

## java.text

### java.text.DecimalFormat — Java 1.6 additions

##### java.text.DecimalFormat (RoundingMode)

version | implemented | tested   | type          | name                          | more informations
------- | ----------- | -------- | ------------- | ----------------------------- | -----------------
1.6     | ✔️          | ✔️       | method        | getRoundingMode()             | ()->java.math.RoundingMode — default HALF_UP
1.6     | ✔️          | ✔️       | method        | setRoundingMode(RoundingMode) | maps to Foundation.NumberFormatter.roundingMode
