# Getting Started

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Add JavApi⁴Swift to a project and write your first Java-style code in Swift.

## Overview

JavApi⁴Swift is a Swift library that brings the Java standard API to the Swift world — without a Java Virtual Machine. You write Swift, you compile Swift, you run Swift. But the types and methods feel familiar if you know Java.

Why would you want that? There are two common reasons:

- You have existing Java code you want to bring to an Apple platform or a Linux server written in Swift.
- You learned programming with Java and want to use your existing knowledge while learning Swift.

This article covers neither reason deeply — it just gets you running.

## Adding JavApi⁴Swift to Your Project

JavApi⁴Swift is distributed as a Swift Package. In Xcode, choose **File → Add Package Dependencies** and enter the repository URL. In a `Package.swift` file, add it as a dependency:

```swift
dependencies: [
    .package(url: "https://github.com/bastie/JavApi4Swift.git", from: "0.1.0")
],
targets: [
    .target(name: "MyTarget", dependencies: ["JavApi"])
]
```

Then import the library at the top of any Swift file:

```swift
import JavApi
```

## Your First Program

In Java a classic first program looks like this:

```java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

With JavApi⁴Swift in a Swift file you can write almost the same thing:

```swift
import JavApi

java.lang.System.out.println("Hello, World!")
```

Swift already has `print()` built in, so in practice you would just write `print("Hello, World!")`. But the JavApi version is useful when you are translating Java code line by line and want the translation to stay recognizable.

## The Package Structure

Java organizes its types into packages like `java.lang`, `java.util`, and `java.time`. JavApi⁴Swift mirrors this structure using Swift enums as namespaces:

```swift
// A Java string method
let text: java.lang.String = "Hello"
let trimmed = text.trim()

// A Java list
var list = java.util.ArrayList<String>()
_ = list.add("one")
_ = list.add("two")

// A Java date
let today = java.time.LocalDate.now()
```

You do not need to write `java.lang.String` for every string — `String` in Swift already has all the Java string methods added through extensions. But writing the full package name makes it clear which API you are using.

## What You Have Learned

- JavApi⁴Swift is a Swift Package that adds Java API methods to Swift.
- Import it with `import JavApi`.
- Java packages like `java.util` are available as nested Swift enums.
- Swift's own types like `String` and `Array` are extended with Java methods directly.

## Next Steps

Continue to <doc:BasicTypes> to learn how Java's primitive types map to Swift.
