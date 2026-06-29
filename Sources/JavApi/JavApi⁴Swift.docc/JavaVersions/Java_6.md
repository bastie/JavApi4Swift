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

## java.util

### java.util.Deque — new interface

`java.util.Deque<E>` is a double-ended queue that supports element insertion and removal at both ends. It extends `Queue` and serves as both a queue (FIFO) and a stack (LIFO).

##### java.util.Deque (18/18/23)

version | implemented | tested   | type          | name                              | more informations
------- | ----------- | -------- | ------------- | --------------------------------- | -----------------
1.6     | ✔️          | ✔️       | protocol      | Deque                             | `Deque.swift`; extends `Queue`; `LinkedList` is the primary implementation
1.6     | ✔️          | ✔️       | method        | addFirst(E)                       | throws if capacity exceeded; unbounded in `LinkedList`
1.6     | ✔️          | ✔️       | method        | addLast(E)                        | throws if capacity exceeded; unbounded in `LinkedList`
1.6     | ✔️          | ✔️       | method        | offerFirst(E)                     | returns `false` instead of throwing; always `true` in `LinkedList`
1.6     | ✔️          | ✔️       | method        | offerLast(E)                      | returns `false` instead of throwing; always `true` in `LinkedList`
1.6     | ✔️          | ✔️       | method        | removeFirst()                     | throws `NoSuchElementException` if empty
1.6     | ✔️          | ✔️       | method        | removeLast()                      | throws `NoSuchElementException` if empty
1.6     | ✔️          | ✔️       | method        | pollFirst()                       | returns `nil` if empty
1.6     | ✔️          | ✔️       | method        | pollLast()                        | returns `nil` if empty
1.6     | ✔️          | ✔️       | method        | getFirst()                        | throws `NoSuchElementException` if empty
1.6     | ✔️          | ✔️       | method        | getLast()                         | throws `NoSuchElementException` if empty
1.6     | ✔️          | ✔️       | method        | peekFirst()                       | returns `nil` if empty
1.6     | ✔️          | ✔️       | method        | peekLast()                        | returns `nil` if empty
1.6     | ✔️          | ✔️       | method        | push(E)                           | default: delegates to `addFirst`
1.6     | ✔️          | ✔️       | method        | pop()                             | default: delegates to `removeFirst`
1.6     | ✔️          | ✔️       | method        | removeFirstOccurrence(E?)         | removes first match; returns `Bool`
1.6     | ✔️          | ✔️       | method        | removeLastOccurrence(E?)          | removes last match; returns `Bool`
1.6     | ✔️          | ✔️       | method        | descendingIterator()              | `LinkedListDescendingIterator`: tail → head; conforms to Swift `Sequence`

> **Note:** `peek()` and `poll()` from `Queue` are provided as defaults in the `Deque` extension, delegating to `peekFirst()` and `pollFirst()` respectively.

### java.util.LinkedList — Java 1.6 additions

`LinkedList` now implements `Deque` in addition to `List` and `Queue`.

version | implemented | tested   | type          | name                              | more informations
------- | ----------- | -------- | ------------- | --------------------------------- | -----------------
1.6     | ✔️          | ✔️       | conformance   | Deque                             | changed from `: Queue` to `: Deque` (implies `Queue`)
1.6     | ✔️          | ✔️       | method        | offerFirst(E)                     | always returns `true` (unbounded)
1.6     | ✔️          | ✔️       | method        | offerLast(E)                      | always returns `true` (unbounded)
1.6     | ✔️          | ✔️       | method        | peekFirst()                       | returns `nil` if empty
1.6     | ✔️          | ✔️       | method        | peekLast()                        | returns `nil` if empty
1.6     | ✔️          | ✔️       | method        | pollFirst()                       | returns `nil` if empty
1.6     | ✔️          | ✔️       | method        | pollLast()                        | returns `nil` if empty
1.6     | ✔️          | ✔️       | method        | removeFirstOccurrence(E?)         |
1.6     | ✔️          | ✔️       | method        | removeLastOccurrence(E?)          |
1.6     | ✔️          | ✔️       | method        | descendingIterator()              | `LinkedListDescendingIterator` in `LinkedList.swift`

## java.text

### java.text.DecimalFormat — Java 1.6 additions

##### java.text.DecimalFormat (RoundingMode)

version | implemented | tested   | type          | name                          | more informations
------- | ----------- | -------- | ------------- | ----------------------------- | -----------------
1.6     | ✔️          | ✔️       | method        | getRoundingMode()             | ()->java.math.RoundingMode — default HALF_UP
1.6     | ✔️          | ✔️       | method        | setRoundingMode(RoundingMode) | maps to Foundation.NumberFormatter.roundingMode
