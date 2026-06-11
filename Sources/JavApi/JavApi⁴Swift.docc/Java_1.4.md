# Java 1.4

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

2002-02-06 release of Java 1.4 (Merlin).

## Overview

Java 1.4 introduced NIO (non-blocking I/O), logging (`java.util.logging`), assertions, regular expressions, XML parsing, and IPv6 support.

### How to read?

- Header type name (count of fields or methods/ count of implemented of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

## Java Core Packages

### java.lang

#### java.lang.Runtime — Java 1.4 additions

##### java.lang.Runtime (2/2/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.4     | ✔️          | ⭕️       | method        | availableProcessors()   | ()->int
1.4     | ✔️          | ⭕️       | method        | maxMemory()             | ()->long

### java.util.logging

Java 1.4 introduced the `java.util.logging` package as the standard logging framework.

##### java.util.logging.Filter (1/1/🪄)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | method        | isLoggable()   | (LogRecord)->boolean

##### java.util.logging.Formatter (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | constructor   | Formatter()    |
1.4     | ✔️          | ⭕️       | method        | format()       | (LogRecord)->String — abstract
1.4     | ✔️          | 🪄       | method        | getHead()      | (Handler)->String
1.4     | ✔️          | 🪄       | method        | getTail()      | (Handler)->String

##### java.util.logging.Handler (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | constructor   | Handler()      |
1.4     | ✔️          | ⭕️       | method        | setLevel()     | (Level)
1.4     | ✔️          | ⭕️       | method        | getLevel()     | ()->Level

##### java.util.logging.Level (12/12/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.4     | ✔️          | 🪄       | field         | OFF                     | static
1.4     | ✔️          | 🪄       | field         | SEVERE                  | static
1.4     | ✔️          | 🪄       | field         | WARNING                 | static
1.4     | ✔️          | 🪄       | field         | INFO                    | static
1.4     | ✔️          | 🪄       | field         | CONFIG                  | static
1.4     | ✔️          | 🪄       | field         | FINE                    | static
1.4     | ✔️          | 🪄       | field         | FINER                   | static
1.4     | ✔️          | 🪄       | field         | FINEST                  | static
1.4     | ✔️          | 🪄       | field         | ALL                     | static
1.4     | ✔️          | ⭕️       | constructor   | Level()                 | (String, int)
1.4     | ✔️          | ⭕️       | constructor   | Level()                 | (String, int, String?)
1.4     | ✔️          | ⭕️       | method        | intValue()              | ()->int
1.4     | ✔️          | ⭕️       | method        | getName()               | ()->String
1.4     | ✔️          | ⭕️       | method        | getResourceBundleName() | ()->String?
1.4     | ✔️          | ⭕️       | method        | parse()                 | (String)->Level

##### java.util.logging.LogManager (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | method        | getLogManager()| ()->LogManager — static singleton
1.4     | ✔️          | ⭕️       | method        | addLogger()    | (Logger)->boolean

##### java.util.logging.LogRecord (8/8/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | constructor   | LogRecord()    | (Level, String?)
1.4     | ✔️          | ⭕️       | method        | setLoggerName()| (String?)
1.4     | ✔️          | ⭕️       | method        | getLoggerName()| ()->String?
1.4     | ✔️          | ⭕️       | method        | setInstant()   | (Instant)
1.4     | ✔️          | ⭕️       | method        | getInstant()   | ()->Instant
1.4     | ✔️          | ⭕️       | method        | setMessage()   | (String?)
1.4     | ✔️          | ⭕️       | method        | getMessage()   | ()->String?
1.4     | ✔️          | ⭕️       | method        | setMillis()    | (long) — deprecated since Java 9, use setInstant()
1.4     | ✔️          | ⭕️       | method        | getMillis()    | ()->long — deprecated since Java 9, use getInstant()

##### java.util.logging.Logger (7/7/⭕️)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.4     | ✔️          | 🪄       | field         | GLOBAL_LOGGER_NAME  | static String
1.4     | ✔️          | ⭕️       | method        | getLogger()         | (String)->Logger — static
1.4     | ✔️          | ⭕️       | method        | getAnonymousLogger()| ()->Logger — static
1.4     | ✔️          | ⭕️       | method        | getName()           | ()->String?
1.4     | ✔️          | ⭕️       | method        | addHandler()        | (Handler)
1.4     | ✔️          | ⭕️       | method        | removeHandler()     | (Handler)
1.4     | ✔️          | ⭕️       | method        | getHandlers()       | ()->[Handler]
1.4     | ✔️          | ⭕️       | method        | log()               | (LogRecord)
