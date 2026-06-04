# Input and Output

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Reading and writing data with streams, byte arrays, and files.

## Overview

Programs are rarely self-contained. They read configuration files, write log output, receive data over the network, and pass bytes between components. Java's `java.io` package provides a uniform model for all of these through *streams* — objects that produce or consume sequences of bytes.

JavApi⁴Swift implements the most commonly used `java.io` types. This article covers the ones you will reach for first.

## The Stream Model

Java I/O is built on two abstract base types:

- **`InputStream`** — a source of bytes. You read from it.
- **`OutputStream`** — a destination for bytes. You write to it.

Everything else is either a concrete implementation (where the bytes come from or go to) or a *filter* (which wraps another stream and transforms the bytes on the way through).

```
[Source]  →  InputStream  →  (optional Filter)  →  your code
your code →  OutputStream →  (optional Filter)  →  [Destination]
```

## ByteArrayInputStream

`ByteArrayInputStream` reads bytes from an in-memory byte array. It is the simplest stream — no files, no network, no threading. Use it for testing, for parsing binary data you already have in memory, or for feeding bytes into a filter stream.

```swift
import JavApi

let data: [UInt8] = [72, 101, 108, 108, 111]   // "Hello" in ASCII

let stream = java.io.ByteArrayInputStream(data)

// Read one byte at a time
var byte = stream.read()
while byte != -1 {
    print(Character(UnicodeScalar(byte)!), terminator: "")
    byte = stream.read()
}
// Output: Hello
```

### Reading Multiple Bytes at Once

```swift
let stream2 = java.io.ByteArrayInputStream(data)

var buffer = [UInt8](repeating: 0, count: 3)
let bytesRead = stream2.read(&buffer, 0, buffer.count)

print(bytesRead)   // 3
print(buffer)      // [72, 101, 108]  ("Hel")
```

## ByteArrayOutputStream

`ByteArrayOutputStream` collects bytes into an in-memory buffer. Write to it freely, then retrieve the accumulated bytes when you are done.

```swift
import JavApi

let output = java.io.ByteArrayOutputStream()

output.write(72)   // 'H'
output.write(105)  // 'i'

let result: [UInt8] = output.toByteArray()
print(result)   // [72, 105]
print(String(bytes: result, encoding: .utf8)!)   // "Hi"
```

### Writing an Array of Bytes

```swift
let output2 = java.io.ByteArrayOutputStream()

let greeting: [UInt8] = Array("Hello".utf8)
output2.write(greeting, 0, greeting.count)

print(output2.size())   // 5
```

## File

`java.io.File` represents a path in the file system — not necessarily a file that exists. Think of it as a named location.

```swift
import JavApi

let file = java.io.File("/tmp/example.txt")

// Query the path
print(file.getName())           // "example.txt"
print(file.getAbsolutePath())   // "/tmp/example.txt"

// Test existence and type
print(file.isDirectory())   // false (for a .txt path)
print(file.canRead())       // false (file doesn't exist yet)
```

### Listing a Directory

```swift
let tmpDir = java.io.File("/tmp")

if tmpDir.isDirectory(), let entries = tmpDir.listFiles() {
    for entry in entries {
        print(entry.getName())
    }
}
```

### Filtering Directory Contents

```swift
class SwiftFileFilter: java.io.FileFilter {
    func accept(_ file: java.io.File) -> Bool {
        file.getName().endsWith(".log")
    }
    typealias FileFilter = SwiftFileFilter
}

let logsDir  = java.io.File("/var/log")
let logFiles = logsDir.listFiles(SwiftFileFilter())
```

### Hidden Files

A file is considered hidden when its name begins with a dot (`.`) — the POSIX convention used on Linux and macOS:

```swift
print(java.io.File("/.hidden").isHidden())           // true
print(java.io.File("/tmp/normal.txt").isHidden())    // false
```

## System Streams

`java.lang.System` provides the three standard streams:

```swift
import JavApi

// Print to standard output  
java.lang.System.out.println("Standard output")

// Print to standard error
java.lang.System.err.println("Error output")

// Standard input (for reading from the terminal)
// let input = java.lang.System.in
```

In practice, for output you will usually use Swift's built-in `print()` and `Swift.print(to: &errorStream)`. The JavApi versions are useful when you are translating Java code that uses `System.out` directly.

## System.arraycopy

Copying a range of elements between arrays is a common low-level operation. `System.arraycopy` does it efficiently:

```swift
import JavApi

let source: [UInt8] = [1, 2, 3, 4, 5]
var dest:   [UInt8] = [0, 0, 0, 0, 0]

// Copy 3 bytes starting at source[1] into dest starting at dest[0]
System.arraycopy(source, 1, &dest, 0, 3)

print(dest)   // [2, 3, 4, 0, 0]
```

## Questions and Exercises

1. Create a `ByteArrayOutputStream`, write the bytes for the string `"JavApi"` into it, then read them back with a `ByteArrayInputStream` and print each character.
2. Use `java.io.File` to list all entries in `/tmp` and print only the names that start with a dot (hidden files). Does `isHidden()` give the same result?
3. Use `System.arraycopy` to reverse the first four elements of `[10, 20, 30, 40, 50]` into a new array.
4. What does `ByteArrayInputStream.read()` return when there are no more bytes to read?

## What You Have Learned

You now know the fundamentals of the `java.io` model: streams as sources and sinks of bytes, `ByteArrayInputStream` and `ByteArrayOutputStream` for in-memory I/O, `File` for working with paths, and `System.arraycopy` for bulk byte copying.

For network I/O, binary data parsing, and more advanced stream filtering, explore the `java.io` and `java.nio` API documentation.
