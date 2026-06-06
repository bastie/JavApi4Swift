# Linux

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Platform notes for running JavApi⁴Swift on Linux.

## Overview

JavApi⁴Swift is fully supported on Linux. The Swift Package Manager does not require any special configuration — Linux support is implicit.

## Foundation

On Linux, Apple's `Foundation` framework is replaced by [swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation). Networking types (`URLSession`, `URLRequest`, `HTTPURLResponse`) live in a separate module:

```swift
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
```

JavApi⁴Swift handles this import internally. No action is required in consuming code.

## C standard library

POSIX socket functions and other C APIs are provided by `Glibc` (on glibc-based distributions such as Ubuntu, Fedora) or `Musl` (on Alpine Linux). JavApi⁴Swift imports the correct module automatically:

```swift
#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif
```

## Type differences

Some C types differ between Darwin and Linux:

| Type | Darwin | Linux |
|------|--------|-------|
| `timeval.tv_usec` | `Int32` | `Int` |
| `SOCK_STREAM` | `Int32` | `__socket_type` (needs `.rawValue`) |
| `SOCK_DGRAM` | `Int32` | `__socket_type` (needs `.rawValue`) |

JavApi⁴Swift handles all these differences internally with `#if canImport(Darwin)` guards.

## CryptoKit

`CryptoKit` is not available on Linux. JavApi⁴Swift's `MessageDigest` (MD5, SHA-1, SHA-256, SHA-384, SHA-512) provides its own implementation that does not depend on CryptoKit.

## Fully supported

All `java.lang`, `java.io`, `java.util`, and `java.net` classes are fully supported on Linux.

## AWT on Linux

`java.awt` compiles on Linux but runs in headless mode — no windows are shown. The `HeadlessToolkit` is selected automatically and all window operations are no-ops.

To add real windowing support (GTK, SDL2, Wayland, X11, …), implement a custom `Toolkit` subclass. See <doc:ImplementingAToolkit> for a step-by-step guide and a complete checklist of what must be implemented.
