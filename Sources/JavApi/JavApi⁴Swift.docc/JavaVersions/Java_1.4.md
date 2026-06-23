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

### java.nio — New I/O

Java 1.4 introduced the `java.nio` package (NIO) with buffer classes and channels.

##### java.nio.ByteOrder (5/5/5)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | ✔️       | field         | BIG_ENDIAN     | static
1.4     | ✔️          | ✔️       | field         | LITTLE_ENDIAN  | static
1.4     | ✔️          | ✔️       | static method | nativeOrder()  | ()->ByteOrder
1.4     | ✔️          | ✔️       | method        | toString()     | ()->String
1.4     | ✔️          | ✔️       | method        | equals()       | (ByteOrder)->boolean

##### java.nio.BufferOverflowException (1/1/1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | ✔️       | constructor   | BufferOverflowException() |

##### java.nio.BufferUnderflowException (1/1/1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | ✔️       | constructor   | BufferUnderflowException() |

##### java.nio.ByteBuffer (21/21/21)

version | implemented | tested   | type          | name                       | more informations
------- | ----------- | -------- | ------------- | -------------------------- | -----------------
1.4     | ✔️          | ✔️       | static method | allocate(int)              | throws IllegalArgumentException for negative capacity
1.4     | ✔️          | ✔️       | static method | wrap(byte[])               |
1.4     | ✔️          | ✔️       | static method | wrap(byte[], int, int)     | offset + length window
1.4     | ✔️          | ✔️       | method        | capacity()                 | ()->int
1.4     | ✔️          | ✔️       | method        | limit()                    | ()->int
1.4     | ✔️          | ✔️       | method        | limit(int)                 | throws IllegalArgumentException
1.4     | ✔️          | ✔️       | method        | position()                 | ()->int
1.4     | ✔️          | ✔️       | method        | position(int)              | throws IllegalArgumentException
1.4     | ✔️          | ✔️       | method        | remaining()                | ()->int
1.4     | ✔️          | ✔️       | method        | hasRemaining()             | ()->boolean
1.4     | ✔️          | ✔️       | method        | flip()                     | ()->ByteBuffer
1.4     | ✔️          | ✔️       | method        | clear()                    | ()->ByteBuffer
1.4     | ✔️          | ✔️       | method        | rewind()                   | ()->ByteBuffer
1.4     | ✔️          | ✔️       | method        | order()                    | ()->ByteOrder
1.4     | ✔️          | ✔️       | method        | order(ByteOrder)           | ()->ByteBuffer; sets decode order, does not reorder existing bytes
1.4     | ✔️          | ✔️       | method        | array()                    | ()->[UInt8]; returns full backing array
1.4     | ✔️          | ✔️       | method        | put(byte)                  | throws BufferOverflowException
1.4     | ✔️          | ✔️       | method        | put(byte[])                | throws BufferOverflowException
1.4     | ✔️          | ✔️       | method        | put(byte[], int, int)      | throws IndexOutOfBoundsException, BufferOverflowException
1.4     | ✔️          | ✔️       | method        | get()                      | throws BufferUnderflowException
1.4     | ✔️          | ✔️       | method        | get(int)                   | absolute; throws IndexOutOfBoundsException

> **Note:** `getInt()`, `putInt()`, `getLong()`, `putLong()`, `getFloat()`, `putFloat()` and similar
> multi-byte primitive accessors are not yet implemented. They require the `ByteOrder` setting to be
> respected during encoding/decoding.

### java.net — Java 1.4 additions

##### java.net.URLEncoder — encode(String, String) (1/1/0)

> **Note:** `URLEncoder.encode(String, String)` with explicit charset name was added in Java 1.4.
> The single-argument `encode(String)` (Java 1.0) was simultaneously deprecated.
> Both are implemented in `net/URLEncoder.swift`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | ⭕️       | static method | encode()       | (String, String) throws — charset-aware; replaces deprecated encode(String)

### java.lang

#### java.lang.Runtime — Java 1.4 additions

##### java.lang.Runtime (2/2/0)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.4     | ✔️          | ⭕️       | method        | availableProcessors()   | ()->int
1.4     | ✔️          | ⭕️       | method        | maxMemory()             | ()->long

### java.util.logging

Java 1.4 introduced the `java.util.logging` package as the standard logging framework.

##### java.util.logging.Filter (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | method        | isLoggable()   | (LogRecord)->boolean

##### java.util.logging.Formatter (4/4/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | constructor   | Formatter()    |
1.4     | ✔️          | ⭕️       | method        | format()       | (LogRecord)->String — abstract
1.4     | ✔️          | 🪄       | method        | getHead()      | (Handler)->String
1.4     | ✔️          | 🪄       | method        | getTail()      | (Handler)->String

##### java.util.logging.Handler (3/3/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | constructor   | Handler()      |
1.4     | ✔️          | ⭕️       | method        | setLevel()     | (Level)
1.4     | ✔️          | ⭕️       | method        | getLevel()     | ()->Level

##### java.util.logging.Level (15/15/0)

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

##### java.util.logging.LogManager (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | 🪄       | method        | getLogManager()| ()->LogManager — static singleton
1.4     | ✔️          | ⭕️       | method        | addLogger()    | (Logger)->boolean

##### java.util.logging.LogRecord (9/9/0)

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

##### java.util.logging.Logger (8/8/0)

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


### javax.swing.text — Swing Formatter classes (new in 1.4)

##### javax.swing.JFormattedTextField

version | implemented | tested   | type          | name                                       | more informations
------- | ----------- | -------- | ------------- | ------------------------------------------ | -----------------
1.4     | ✔️          | ⭕️       | constructor   | JFormattedTextField()                      |
1.4     | ✔️          | ⭕️       | constructor   | JFormattedTextField(Format, Any)           |
1.4     | ✔️          | ⭕️       | constructor   | JFormattedTextField(Any)                   |
1.4     | ✔️          | ⭕️       | constructor   | JFormattedTextField(AbstractFormatter)     |
1.4     | ✔️          | ⭕️       | method        | getValue()                                 |
1.4     | ✔️          | ⭕️       | method        | setValue(Object)                           |
1.4     | ✔️          | ⭕️       | method        | commitEdit()                               | throws ParseException
1.4     | ✔️          | ⭕️       | method        | setFormatterFactory(AbstractFormatterFactory) |
1.4     | ✔️          | ⭕️       | method        | getFormatter()                             |

##### javax.swing.JFormattedTextField.AbstractFormatter

version | implemented | tested   | type          | name                        | more informations
------- | ----------- | -------- | ------------- | --------------------------- | -----------------
1.4     | ✔️          | ⭕️       | method        | stringToValue(String)       | abstract, throws ParseException
1.4     | ✔️          | ⭕️       | method        | valueToString(Object)       | abstract, throws ParseException

##### javax.swing.JFormattedTextField.AbstractFormatterFactory

version | implemented | tested   | type          | name                                         | more informations
------- | ----------- | -------- | ------------- | -------------------------------------------- | -----------------
1.4     | ✔️          | ⭕️       | method        | getFormatter(JFormattedTextField)            | abstract

##### javax.swing.text.DefaultFormatter

version | implemented | tested   | type          | name                        | more informations
------- | ----------- | -------- | ------------- | --------------------------- | -----------------
1.4     | ✔️          | ⭕️       | method        | setAllowsInvalid(boolean)   |
1.4     | ✔️          | ⭕️       | method        | setCommitsOnValidEdit(boolean) |
1.4     | ✔️          | ⭕️       | method        | setOverwriteMode(boolean)   |
1.4     | ✔️          | ⭕️       | method        | stringToValue(String)       |
1.4     | ✔️          | ⭕️       | method        | valueToString(Object)       |

##### javax.swing.text.InternationalFormatter

version | implemented | tested   | type          | name                        | more informations
------- | ----------- | -------- | ------------- | --------------------------- | -----------------
1.4     | ✔️          | ⭕️       | constructor   | InternationalFormatter(Format) |
1.4     | ✔️          | ⭕️       | method        | setMinimum(Comparable)      |
1.4     | ✔️          | ⭕️       | method        | setMaximum(Comparable)      |
1.4     | ✔️          | ⭕️       | method        | stringToValue(String)       |
1.4     | ✔️          | ⭕️       | method        | valueToString(Object)       |

##### javax.swing.text.NumberFormatter

version | implemented | tested   | type          | name                           | more informations
------- | ----------- | -------- | ------------- | ------------------------------ | -----------------
1.4     | ✔️          | ⭕️       | constructor   | NumberFormatter(NumberFormat)  |

##### javax.swing.text.DateFormatter

version | implemented | tested   | type          | name                           | more informations
------- | ----------- | -------- | ------------- | ------------------------------ | -----------------
1.4     | ✔️          | ⭕️       | constructor   | DateFormatter(DateFormat)      |

##### javax.swing.text.MaskFormatter

version | implemented | tested   | type          | name                              | more informations
------- | ----------- | -------- | ------------- | --------------------------------- | -----------------
1.4     | ✔️          | ⭕️       | constructor   | MaskFormatter(String)             | throws ParseException
1.4     | ✔️          | ⭕️       | method        | setPlaceholderCharacter(char)     |
1.4     | ✔️          | ⭕️       | method        | setPlaceholder(String)            |
1.4     | ✔️          | ⭕️       | method        | setValueContainsLiteralCharacters(boolean) |
1.4     | ✔️          | ⭕️       | method        | stringToValue(String)             |
1.4     | ✔️          | ⭕️       | method        | valueToString(Object)             |

> **Mask characters:** `#` digit, `A` letter/digit, `?` letter, `*` any, `U` upper, `L` lower, `H` hex digit, `'` quote literal.

---

## java.util — Java 1.4 additions

### java.util.IdentityHashMap (⭕️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.4     | ⭕️          | ⭕️       | open class    | IdentityHashMap         | implements Map; uses reference equality (==) instead of equals()
