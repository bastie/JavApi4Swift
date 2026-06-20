# Java 1.3

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

2000-05-08 release of Java 1.3 (Kestrel).

## Overview

Java 1.3 introduced Java Sound, Java Naming and Directory Interface (JNDI) in the core platform,
the Java Platform Debugger Architecture (JPDA), and `java.awt.Robot` for GUI test automation.

### How to read?

- Header type name (count of fields or methods / count of implemented / count of tests)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members are **not** part of the public API and are
> not ported. Only `public` and `protected` members are in scope.

---

## java.awt — Java 1.3 additions

### java.awt.Robot (✔️/⭕️)

> Generates native system input events (mouse moves, clicks, key presses) and can capture
> pixel colours from the screen. Primary use cases: test automation and self-running demos.
>
> **Platform support:**
> - **macOS** (`#if canImport(AppKit)`) — full implementation via `CGEvent` (mouse/keyboard)
>   and ScreenCaptureKit (`SCScreenshotManager.captureImage`, macOS 14+) for `getPixelColor`.
>   Requires *Screen Recording* permission at runtime.
> - **Linux / FreeBSD** (`#if os(Linux) || os(FreeBSD)`) — stub; XTest extension planned (TODO).
> - **Windows** (`#if canImport(WinSDK)`) — stub; `SendInput` / `GetPixel` planned (TODO).
> - **Headless / WASM / Android / iOS** — no-op fallback; `getPixelColor` returns `Color.BLACK`.
>
> The platform split mirrors the `FileDialog` / `FileDialogProvider` pattern:
> `Robot.swift` holds the public API; platform-specific backing is provided by
> `_Robot+AppKit.swift`, `_Robot+X11.swift`, `_Robot+WinSDK.swift`, `_Robot+Headless.swift`,
> each guarded by `#if`. The `RobotProvider` protocol in `awt/toolkit/RobotProvider.swift`
> declares the internal interface (`_mouseMove`, `_keyPress`, `_getPixelColor`, etc.).
>
> **Swift 6 concurrency:** `Robot` is `@MainActor`. `getPixelColor` bridges ScreenCaptureKit's
> `async` API using `Task.detached` + `DispatchSemaphore` — the detached task runs on
> Swift's cooperative thread pool; `sema.wait()` blocks the calling thread without
> deadlocking the main actor.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.3     | ✔️          | ⭕️       | open class    | Robot                   | @MainActor; conforms to RobotProvider
1.3     | ✔️          | ⭕️       | constructor   | Robot()                 | () throws — headless: no-op (caller should check isHeadless)
1.3     | ✔️          | ⭕️       | constructor   | Robot()                 | (GraphicsDevice) throws — screen arg currently ignored
1.3     | ✔️          | ⭕️       | method        | mouseMove()             | (Int,Int)
1.3     | ✔️          | ⭕️       | method        | mousePress()            | (Int) — BUTTON1/2/3_MASK
1.3     | ✔️          | ⭕️       | method        | mouseRelease()          | (Int)
1.3     | ✔️          | ⭕️       | method        | mouseWheel()            | (Int) — positive scrolls down
1.3     | ✔️          | ⭕️       | method        | keyPress()              | (Int) — VK_* constants
1.3     | ✔️          | ⭕️       | method        | keyRelease()            | (Int)
1.3     | ✔️          | ⭕️       | method        | getPixelColor()         | (Int,Int)->Color — macOS: ScreenCaptureKit
1.3     | ✔️          | ⭕️       | method        | delay()                 | (Int) — milliseconds; Thread.sleep
1.3     | ✔️          | ⭕️       | method        | waitForIdle()           | () — macOS: RunLoop.main.run(until:)
1.3     | ✔️          | ⭕️       | method        | getAutoDelay()          | ()->Int
1.3     | ✔️          | ⭕️       | method        | setAutoDelay()          | (Int) — 0–60 000 ms; enforced by precondition
1.3     | ✔️          | ⭕️       | method        | isAutoWaitForIdle()     | ()->Bool
1.3     | ✔️          | ⭕️       | method        | setAutoWaitForIdle()    | (Bool)

> ``TODO:`` **`createScreenCapture(Rectangle)`** — deferred until a `CGBitmapContext` →
> `BufferedImage` bridge is available.

### java.awt.toolkit.RobotProvider (✔️/🪄)

> Internal `@MainActor` protocol satisfied by platform-specific `Robot` extensions.
> Not part of the public Java API — JavApi4Swift SPI only.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
N/A     | ✔️          | 🪄       | protocol      | RobotProvider           | @MainActor; SPI only
N/A     | ✔️          | 🪄       | method        | _mouseMove()            | (Int,Int)
N/A     | ✔️          | 🪄       | method        | _mousePress()           | (Int)
N/A     | ✔️          | 🪄       | method        | _mouseRelease()         | (Int)
N/A     | ✔️          | 🪄       | method        | _mouseWheel()           | (Int)
N/A     | ✔️          | 🪄       | method        | _keyPress()             | (Int)
N/A     | ✔️          | 🪄       | method        | _keyRelease()           | (Int)
N/A     | ✔️          | 🪄       | method        | _getPixelColor()        | (Int,Int)->Color
N/A     | ✔️          | 🪄       | method        | _waitForIdle()          | ()

---

## Not in scope for Java 1.3

- **Java Sound** (`javax.sound.sampled`, `javax.sound.midi`) — not in scope
- **JNDI** (`javax.naming`) — not in scope
- **JPDA** (Java Platform Debugger Architecture) — not in scope
- **`java.awt.print`** (`PrintJob`, `JobAttributes`, `PageAttributes`) — low priority; stubs planned
