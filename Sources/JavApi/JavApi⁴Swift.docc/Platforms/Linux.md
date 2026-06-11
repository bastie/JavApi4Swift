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

`java.awt` compiles on Linux and runs with the **X11 toolkit** on X11-based desktops (including XWayland).
Activate it by setting the `awt.toolkit` system property before any AWT code:

```swift
try? System.setProperty("awt.toolkit", "X11")
```

The X11 toolkit (`java.awt.toolkit.x11.X11Toolkit`) loads `libX11.so.6` at runtime via `dlopen` — no
additional `Package.swift` entry or linker flag is needed.  It renders text via **Xft** (FreeType/fontconfig,
loaded from `libXft.so.2`) for full Unicode support including Latin Extended (Ö, Ü, …) and other non-ASCII
characters.  Without the `awt.toolkit` property the `HeadlessToolkit` is used and all window operations
are no-ops.

### System requirements

| Library | Package (Debian/Ubuntu) | Notes |
|---------|-------------------------|-------|
| `libX11.so.6` | `libx11-dev` | Core X11 — always present on graphical Linux |
| `libXft.so.2` | `libxft-dev` | X FreeType bridge — enables Unicode text |
| fontconfig | `libfontconfig1` | Font selection for Xft (usually pre-installed) |

On a system without `libXft`, text rendering falls back to `Xutf8DrawString` with an `XFontSet`.
This covers Latin-1 and common UTF-8 characters, but may fail for some scripts depending on
the installed XLFD fonts.

### Important: do not call `dlclose` on `libXft`

`_X11Graphics.resolveSymbols()` opens `libXft.so.2` via `dlopen` to resolve `XftFontOpenName` and related
symbols.  The library handle **must remain open** for the process lifetime.  Calling `dlclose(xftLib)`
immediately after symbol resolution invalidates all resolved function pointers — subsequent calls to
`XftFontOpenName` crash with a bad pointer dereference.  The X11 backend intentionally omits the
`dlclose` call on the Xft handle.

### HiDPI

The X11 toolkit reads `Xft.dpi` via `XGetDefault(display, "Xft", "dpi")` after connecting to the
X server.  A `scaleFactor` is derived as `(xftDpi / 96.0).rounded()`.  All window sizes and drawing
coordinates are multiplied by `scaleFactor` when passed to X11 and divided when converting X11 events
back to logical AWT coordinates.

### X11 event byte offsets (64-bit Linux)

Two event structs have non-obvious field offsets on 64-bit x86_64 Linux.  The X11 backend reads them
with hardcoded byte offsets verified via C `offsetof`:

| Event | Field | Offset | Reason |
|-------|-------|--------|--------|
| `XButtonEvent` | `x` | 64 | Preceded by type(4)+pad(4)+serial(8)+send_event(4)+pad(4)+display*(8)+window(8)+root(8)+subwindow(8)+time(8) |
| `XButtonEvent` | `y` | 68 | Four bytes after `x` |
| `XConfigureEvent` | `width` | 56 | Preceded by type(4)+pad(4)+serial(8)+send_event(4)+pad(4)+display*(8)+event(8)+window(8)+x(4)+y(4) |
| `XConfigureEvent` | `height` | 60 | Four bytes after `width` |
| `XMotionEvent` | `x` | 64 | Same layout as `XButtonEvent` |
| `XMotionEvent` | `y` | 68 | Same layout as `XButtonEvent` |

Using the wrong offsets causes click and resize coordinates to be read from the wrong bytes,
resulting in non-functional menu bars and incorrect window sizes.

To add windowing support on an additional Linux backend (GTK, SDL2, Wayland, …), implement a custom
`Toolkit` subclass. See <doc:ImplementingAToolkit> for a step-by-step guide.
