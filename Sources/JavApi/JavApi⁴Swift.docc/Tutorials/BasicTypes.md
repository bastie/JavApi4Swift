# Basic Types

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Strings, numbers, booleans, and characters — the building blocks of any program.

## Overview

Every programming language has a set of basic types for representing text, numbers, and true/false values. Java and Swift share the same concepts but name and handle them differently. This article walks through each type and shows how JavApi⁴Swift bridges the gap.

## Strings

In Java, `String` is a class in `java.lang`. In Swift, `String` is a value type built into the language. JavApi⁴Swift extends Swift's `String` with Java's methods, so both styles work:

```swift
import JavApi

let greeting = "  Hello, World!  "

// Swift style
let swiftTrimmed = greeting.trimmingCharacters(in: .whitespaces)

// Java style — trim() removes only ASCII space (code point ≤ U+0020)
let javaTrimmed = greeting.trim()

// Java style — strip() also removes Unicode whitespace
let javaStripped = greeting.strip()

print(javaTrimmed)   // "Hello, World!"
```

> **Important difference:** Java's `trim()` only removes ASCII spaces (code point ≤ 32). Swift's `trimmingCharacters(in: .whitespaces)` removes all Unicode whitespace. Use `strip()` if you want Java 11+ behaviour with full Unicode support.

### Splitting a String

```swift
let csv = "apple,banana,cherry"

// Java style
let parts = csv.split(",")    // ["apple", "banana", "cherry"]

// Split into individual characters
let chars = csv.split("")     // ["a", "p", "p", "l", "e", ...]
```

### Checking Content

```swift
let filename = "report.pdf"

if filename.endsWith(".pdf") {
    print("This is a PDF file.")
}

if filename.startsWith("report") {
    print("This is a report.")
}
```

### Converting to a Character Array

```swift
let word = "Swift"
let characters: [Character] = word.toCharArray()
// characters == ["S", "w", "i", "f", "t"]
```

### Substrings

```swift
let sentence = "The quick brown fox"

// Java: substring(beginIndex, endIndex) — end is exclusive
let quick = sentence.subSequence(4, 9)   // "quick"

// Java: substring(beginIndex) — from index to end
let rest = sentence.substring(4)          // "quick brown fox"
```

## Numbers

Java has primitive number types (`int`, `long`, `double`, `float`) and wrapper classes (`Integer`, `Long`, `Double`). Swift uses value types directly. JavApi⁴Swift provides the wrapper classes as thin wrappers around Swift's native types.

### Integer

```swift
import JavApi

// Constants
let max = Integer.MAX_VALUE    // 2_147_483_647  (same as Java's Integer.MAX_VALUE)
let min = Integer.MIN_VALUE    // -2_147_483_648

// Parsing
let number = try Integer.parseInt("42")   // 42 as Int
let hex    = Integer.toHexString(255)     // "ff"

// Byte reversal (Java-compatible: treats value as 32-bit int)
let reversed = Integer.reverseBytes(0x00801600)   // 0x00168000
```

### Long

```swift
// Counting bits
let leadingZeros  = Long.numberOfLeadingZeros(1)    // 63
let trailingZeros = Long.numberOfTrailingZeros(8)   // 3

let maxLong = Long.MAX_VALUE    //  9_223_372_036_854_775_807
let minLong = Long.MIN_VALUE    // -9_223_372_036_854_775_808
```

### Math

The `Math` class provides the same static methods as `java.lang.Math`:

```swift
import JavApi

let pi      = Math.PI                      // 3.14159...
let rounded = Math.round(3.7)             // 4
let power   = Math.pow(2.0, 10.0)         // 1024.0
let root    = Math.sqrt(144.0)            // 12.0
let smaller = Math.min(42, 17)            // 17
let larger  = Math.max(42, 17)            // 42
let absVal  = Math.abs(-99)               // 99
```

## Booleans

Java has `boolean` (primitive) and `Boolean` (wrapper). Swift uses `Bool`. No translation is needed — `true` and `false` work the same in both languages.

```swift
let isReady: Bool = true

if isReady {
    print("Ready to go!")
}
```

## Characters

Java's `char` is a 16-bit Unicode character. Swift's `Character` is a full Unicode scalar cluster. JavApi⁴Swift extends `Character` with Java-style methods:

```swift
import JavApi

let letter: Character = "A"

// Compare with integer code point (Java: char == int)
if letter == 65 {
    print("This is the letter A")   // prints
}

// Check type
Character.isLetter("Z")    // true
Character.isLetter(90)     // true (same as 'Z')

// Get numeric value (Java: Character.getNumericValue)
Character.getNumericValue("A")    // 10  (hex digit value)
Character.getNumericValue("9")    // 9

// Convert to integer code point
let codePoint = Int(letter)       // 65
```

> **Note on characters outside the Basic Multilingual Plane:** Swift's `Character` can represent emoji and other multi-byte characters as a single value. `Int(Character("𝄞"))` returns `119070`, the same value Java's `Character.getNumericValue` would return for this musical symbol.

## Questions and Exercises

1. What is the difference between `trim()` and `strip()` in JavApi⁴Swift?
2. Write code that reads `Integer.MAX_VALUE`, adds 1 to it as an `Int64`, and prints the result. What does this tell you about Java's integer overflow behaviour?
3. Use `Math.pow` and `Math.sqrt` to verify that √(2¹⁰) = 2⁵.
4. What does `Character.getNumericValue("¼")` return, and why?

## Next Steps

Continue to <doc:Collections> to learn how Java's collection types — `List`, `Map`, and `Set` — work in JavApi⁴Swift.
