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

##### java.net.URI (35/35/41)

> Fully implemented in `net/URI.swift`. Backed by `URLComponents` on Apple platforms.
> URI parsing, normalization (RFC 2396 dot-segment removal), resolution, relativization,
> comparison, and conversion to `java.net.URL` are all supported.
> `URISyntaxException` is thrown for malformed input.
> `Equatable` and `Comparable` (lexicographic) conformances are provided.

version | implemented | tested   | type          | name                      | more informations
------- | ----------- | -------- | ------------- | ------------------------- | -----------------
1.4     | ✔️          | ✔️       | constructor   | URI()                     | (String) throws URISyntaxException
1.4     | ✔️          | ✔️       | constructor   | URI()                     | (String,String?,String,int,String,String?,String?) throws — component init
1.4     | ✔️          | ✔️       | static method | create()                  | (String)->URI — fatalError on invalid input
1.4     | ✔️          | ✔️       | method        | isAbsolute()              | ()->boolean
1.4     | ✔️          | ✔️       | method        | isOpaque()                | ()->boolean
1.4     | ✔️          | ✔️       | method        | getScheme()               | ()->String?
1.4     | ✔️          | ✔️       | method        | getSchemeSpecificPart()   | ()->String
1.4     | ✔️          | ✔️       | method        | getAuthority()            | ()->String?
1.4     | ✔️          | ✔️       | method        | getUserInfo()             | ()->String?
1.4     | ✔️          | ✔️       | method        | getHost()                 | ()->String?
1.4     | ✔️          | ✔️       | method        | getPort()                 | ()->int — -1 if absent
1.4     | ✔️          | ✔️       | method        | getPath()                 | ()->String
1.4     | ✔️          | ✔️       | method        | getQuery()                | ()->String?
1.4     | ✔️          | ✔️       | method        | getFragment()             | ()->String?
1.4     | ✔️          | ✔️       | method        | normalize()               | ()->URI — RFC 2396 dot-segment removal
1.4     | ✔️          | ✔️       | method        | resolve()                 | (URI)->URI
1.4     | ✔️          | ✔️       | method        | resolve()                 | (String)->URI
1.4     | ✔️          | ✔️       | method        | relativize()              | (URI)->URI
1.4     | ✔️          | ✔️       | method        | toURL()                   | ()->URL throws MalformedURLException for relative URIs
1.4     | ✔️          | ✔️       | method        | toString()                | ()->String
1.4     | ✔️          | ✔️       | method        | toASCIIString()           | ()->String
1.4     | ✔️          | ✔️       | method        | compareTo()               | (URI)->int throws
1.4     | ✔️          | ✔️       | protocol      | Equatable                 | == / != based on toString()
1.4     | ✔️          | ✔️       | protocol      | Comparable                | < based on compareTo()

##### java.net.URISyntaxException (2/2/🪄)

version | implemented | tested   | type          | name                      | more informations
------- | ----------- | -------- | ------------- | ------------------------- | -----------------
1.4     | ✔️          | 🪄       | constructor   | URISyntaxException()      | (String, String)
1.4     | ✔️          | ✔️       | constructor   | URISyntaxException()      | thrown on malformed URI input in URI.init

##### java.net.MalformedURLException (1/1/✔️)

version | implemented | tested   | type          | name                      | more informations
------- | ----------- | -------- | ------------- | ------------------------- | -----------------
1.4     | ✔️          | ✔️       | constructor   | MalformedURLException()   | thrown by URI.toURL() for relative URIs

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

##### java.util.logging.Level (16/16/16)

> `Equatable` conformance added via `extension java.util.logging.Level: Equatable` in `Level.swift`.
> `parse()` is `@MainActor` due to returning a `nonisolated(unsafe)` static instance — test methods must be `@MainActor`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.4     | ✔️          | ✔️       | field         | OFF                     | static; intValue = Int.max
1.4     | ✔️          | ✔️       | field         | SEVERE                  | static; intValue = 1000
1.4     | ✔️          | ✔️       | field         | WARNING                 | static; intValue = 900
1.4     | ✔️          | ✔️       | field         | INFO                    | static; intValue = 800
1.4     | ✔️          | ✔️       | field         | CONFIG                  | static; intValue = 700
1.4     | ✔️          | ✔️       | field         | FINE                    | static; intValue = 500
1.4     | ✔️          | ✔️       | field         | FINER                   | static; intValue = 400
1.4     | ✔️          | ✔️       | field         | FINEST                  | static; intValue = 300
1.4     | ✔️          | ✔️       | field         | ALL                     | static; intValue = Int.min
1.4     | ✔️          | ✔️       | constructor   | Level()                 | (String, int)
1.4     | ✔️          | ✔️       | constructor   | Level()                 | (String, int, String?)
1.4     | ✔️          | ✔️       | method        | intValue()              | ()->int
1.4     | ✔️          | ✔️       | method        | getName()               | ()->String
1.4     | ✔️          | ✔️       | method        | getResourceBundleName() | ()->String?
1.4     | ✔️          | ✔️       | method        | parse()                 | (String)->Level — @MainActor; throws IllegalArgumentException for unknown names
1.4     | ✔️          | ✔️       | protocol      | Equatable               | == based on intValue()

##### java.util.logging.LogManager (3/3/3)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | ✔️       | method        | getLogManager()| ()->LogManager — static singleton
1.4     | ✔️          | ✔️       | method        | addLogger()    | (Logger)->boolean — returns false if already registered
1.4     | ✔️          | ✔️       | method        | getLogger()    | (String)->Logger? — lookup by name

##### java.util.logging.LogRecord (9/9/9)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.4     | ✔️          | ✔️       | constructor   | LogRecord()    | (Level, String?)
1.4     | ✔️          | ✔️       | method        | setLoggerName()| (String?)
1.4     | ✔️          | ✔️       | method        | getLoggerName()| ()->String?
1.4     | ✔️          | ✔️       | method        | setInstant()   | (Instant)
1.4     | ✔️          | ✔️       | method        | getInstant()   | ()->Instant
1.4     | ✔️          | ✔️       | method        | setMessage()   | (String?)
1.4     | ✔️          | ✔️       | method        | getMessage()   | ()->String?
1.4     | ✔️          | ✔️       | method        | setMillis()    | (long) — deprecated since Java 9, use setInstant()
1.4     | ✔️          | ✔️       | method        | getMillis()    | ()->long — deprecated since Java 9, use getInstant()

##### java.util.logging.Logger (22/22/22)

> Full Java-compliant parent-chain implementation. Root logger registered under `""` in `LogManager`.
> `getLogger()` caches loggers by name; new loggers get `rootLogger` as parent.
> Log propagation walks the parent chain while `useParentHandlers == true`.
> `effectiveLevel()` walks the parent chain until a level is set.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.4     | ✔️          | ✔️       | field         | GLOBAL_LOGGER_NAME      | static String = "global"
1.4     | ✔️          | ✔️       | field         | ROOT_LOGGER_NAME        | static String = "" — JavApi4Swift extension
1.4     | ✔️          | ✔️       | field         | rootLogger              | static Logger — registered under "" in LogManager
1.4     | ✔️          | ✔️       | method        | getLogger()             | (String)->Logger — static; cached in LogManager
1.4     | ✔️          | ✔️       | method        | getAnonymousLogger()    | ()->Logger — static; parent = rootLogger, not registered
1.4     | ✔️          | ✔️       | method        | getName()               | ()->String?
1.4     | ✔️          | ✔️       | method        | getParent()             | ()->Logger?
1.4     | ✔️          | ✔️       | method        | setParent()             | (Logger)
1.4     | ✔️          | ✔️       | method        | getUseParentHandlers()  | ()->boolean
1.4     | ✔️          | ✔️       | method        | setUseParentHandlers()  | (boolean)
1.4     | ✔️          | ✔️       | method        | getLevel()              | ()->Level?
1.4     | ✔️          | ✔️       | method        | setLevel()              | (Level?)
1.4     | ✔️          | ✔️       | method        | isLoggable()            | (Level)->boolean — uses effectiveLevel()
1.4     | ✔️          | ✔️       | method        | addHandler()            | (Handler)
1.4     | ✔️          | ✔️       | method        | removeHandler()         | (Handler)
1.4     | ✔️          | ✔️       | method        | getHandlers()           | ()->[Handler]
1.4     | ✔️          | ✔️       | method        | log()                   | (LogRecord)
1.4     | ✔️          | ✔️       | method        | log()                   | (Level, String?)
1.4     | ✔️          | ✔️       | method        | log()                   | (Level, ()->String) — lazy supplier
1.4     | ✔️          | ✔️       | method        | log()                   | (Level, String?, Throwable)
1.4     | ✔️          | ✔️       | method        | severe/warning/info/config/fine/finer/finest() | (String?) convenience methods
1.4     | ✔️          | ✔️       | method        | entering/exiting/throwing() | diagnostic convenience methods


### javax.swing.SpringLayout (✔️/⭕️)

> Constraint-based layout that positions each component's edges using `Spring` values
> relative to other component edges. Common for form layouts where components must be
> aligned relative to each other rather than to the container.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.4     | ✔️          | ⭕️       | open class    | SpringLayout            | extends java.awt.LayoutManager2; @MainActor
1.4     | ✔️          | 🪄       | final field   | NORTH                   | "North"
1.4     | ✔️          | 🪄       | final field   | SOUTH                   | "South"
1.4     | ✔️          | 🪄       | final field   | EAST                    | "East"
1.4     | ✔️          | 🪄       | final field   | WEST                    | "West"
1.4     | ✔️          | 🪄       | final field   | HORIZONTAL_CENTER       | "HorizontalCenter" — horizontal midpoint
1.4     | ✔️          | 🪄       | final field   | VERTICAL_CENTER         | "VerticalCenter" — vertical midpoint
1.4     | ✔️          | 🪄       | final field   | WIDTH                   | "Width" — width spring
1.4     | ✔️          | 🪄       | final field   | HEIGHT                  | "Height" — height spring
1.6     | ✔️          | 🪄       | final field   | BASELINE                | "Baseline" — approx. 75 % of component height
1.6     | ✔️          | 🪄       | final field   | BASELINE_LEADING        | "BaselineLeading"
1.6     | ✔️          | 🪄       | final field   | BASELINE_TRAILING       | "BaselineTrailing"
1.4     | ✔️          | ⭕️       | inner class   | SpringLayout.Constraints| holds edge springs for one component
1.4     | ✔️          | ⭕️       | method        | putConstraint()         | (String,Component,Int,String,Component)
1.4     | ✔️          | ⭕️       | method        | getConstraints()        | (Component)->Constraints
1.4     | ✔️          | ⭕️       | method        | layoutContainer()       | resolves lazy anchors to pixel positions
1.4     | ✔️          | ⭕️       | method        | preferredLayoutSize()   | (Container)->Dimension
1.4     | ✔️          | ⭕️       | method        | minimumLayoutSize()     | (Container)->Dimension (0×0)
1.4     | ✔️          | ⭕️       | method        | maximumLayoutSize()     | (Container)->Dimension (Int.max×Int.max)

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
