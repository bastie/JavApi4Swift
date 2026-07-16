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

## java.lang.StrictMath (65/65/65)

> `StrictMath` was introduced in Java 1.3 as a companion to `java.lang.Math`.
> All methods are required to produce bit-for-bit identical results on every platform
> (using the `fdlibm` reference implementation). In JavApi4Swift both classes delegate
> to Foundation's math functions; the distinction is that `StrictMath` uses fixed
> Javadoc literal constants for PI, E, and TAU instead of Swift's `Double.pi` / `M_E`.
>
> **Bug fixed (2026-06):** `toDegrees()` was incorrectly multiplying by `PI/180` instead of
> `180/PI` — same bug existed in `Math`. Fixed in `StrictMath.swift`.
>
> **Not yet implemented:** `powExact`, `unsignedMultiplyExact`, `unsignedMultiplyHigh`,
> `unsignedPowExact`, `ceilDivExact`, `ceilDivMod` — require unsigned 64-bit semantics
> or are low-priority. `random()` delegates to Swift's PRNG, not `java.util.Random`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.3     | ✔️          | ✔️       | final field   | PI                      | 3.141592653589793 (fixed Javadoc literal)
1.3     | ✔️          | ✔️       | final field   | E                       | 2.718281828459045 (fixed Javadoc literal)
1.3     | ✔️          | ✔️       | final field   | TAU                     | 6.283185307179586 (fixed Javadoc literal)
1.3     | ✔️          | ✔️       | static method | abs()                   | (double/int/long)->same
1.3     | ✔️          | ✔️       | static method | acos()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | asin()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | atan()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | atan2()                 | (double,double)->double
1.3     | ✔️          | ✔️       | static method | cbrt()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | ceil()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | cos()                   | (double)->double
1.3     | ✔️          | ✔️       | static method | cosh()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | exp()                   | (double)->double
1.3     | ✔️          | ✔️       | static method | expm1()                 | (double)->double
1.3     | ✔️          | ✔️       | static method | floor()                 | (double)->double
1.3     | ✔️          | ✔️       | static method | IEEEremainder()         | (double,double)->double
1.3     | ✔️          | ✔️       | static method | log()                   | (double)->double
1.3     | ✔️          | ✔️       | static method | log10()                 | (double)->double
1.3     | ✔️          | ✔️       | static method | log1p()                 | (double)->double
1.3     | ✔️          | ✔️       | static method | max() / min()           | (T,T)->T
1.3     | ✔️          | ✔️       | static method | pow()                   | (double,double)->double
1.3     | ✔️          | ✔️       | static method | rint()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | round()                 | (double)->long, (float)->int
1.3     | ✔️          | ✔️       | static method | sin()                   | (double)->double
1.3     | ✔️          | ✔️       | static method | sinh()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | sqrt()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | tan()                   | (double)->double
1.3     | ✔️          | ✔️       | static method | tanh()                  | (double)->double
1.3     | ✔️          | ✔️       | static method | random()                | ()->double in [0.0, 1.0)
1.3     | ✔️          | ✔️       | static method | toDegrees()             | (double)->double — bug fixed 2026-06
1.3     | ✔️          | ✔️       | static method | toRadians()             | (double)->double
5.0     | ✔️          | ✔️       | static method | hypot()                 | (double,double)->double
9       | ✔️          | ✔️       | static method | fma()                   | (double,double,double)->double, (float,float,float)->float
9       | ✔️          | ✔️       | static method | multiplyFull()          | (int,int)->long
9       | ✔️          | ✔️       | static method | multiplyHigh()          | (long,long)->long — high 64 bits of 128-bit product
6       | ✔️          | ✔️       | static method | copySign()              | (double,double)->double, (float,float)->float
6       | ✔️          | ✔️       | static method | getExponent()           | (double)->int, (float)->int — unbiased IEEE exponent
6       | ✔️          | ✔️       | static method | nextAfter()             | (double,double)->double, (float,double)->float
6       | ✔️          | ✔️       | static method | nextDown()              | (double)->double, (float)->float
6       | ✔️          | ✔️       | static method | nextUp()                | (double)->double, (float)->float
6       | ✔️          | ✔️       | static method | scalb()                 | (double,int)->double, (float,int)->float
6       | ✔️          | ✔️       | static method | signum()                | (double)->double, (float)->float
6       | ✔️          | ✔️       | static method | ulp()                   | (double)->double, (float)->float
8       | ✔️          | ✔️       | static method | addExact()              | (int,int)->int, (long,long)->long — throws ArithmeticException on overflow
8       | ✔️          | ✔️       | static method | decrementExact()        | (int)->int, (long)->long — throws ArithmeticException on overflow
8       | ✔️          | ✔️       | static method | floorDiv()              | (int,int)->int, (long,long)->long — throws ArithmeticException on /0
8       | ✔️          | ✔️       | static method | floorMod()              | (int,int)->int, (long,long)->long — throws ArithmeticException on /0
8       | ✔️          | ✔️       | static method | incrementExact()        | (int)->int, (long)->long — throws ArithmeticException on overflow
8       | ✔️          | ✔️       | static method | multiplyExact()         | (int,int)->int, (long,long)->long — throws ArithmeticException on overflow
8       | ✔️          | ✔️       | static method | negateExact()           | (int)->int, (long)->long — throws ArithmeticException on overflow
8       | ✔️          | ✔️       | static method | subtractExact()         | (int,int)->int, (long,long)->long — throws ArithmeticException on overflow
8       | ✔️          | ✔️       | static method | toIntExact()            | (long)->int — throws ArithmeticException on overflow
15      | ✔️          | ✔️       | static method | absExact()              | (int)->int, (long)->long — throws ArithmeticException for MIN_VALUE
18      | ✔️          | ✔️       | static method | ceilDiv()               | (int,int)->int, (long,long)->long — throws ArithmeticException on /0
18      | ✔️          | ✔️       | static method | ceilMod()               | (int,int)->int, (long,long)->long — throws ArithmeticException on /0
18      | ✔️          | ✔️       | static method | divideExact()           | (int,int)->int, (long,long)->long — throws on non-exact or /0
21      | ✔️          | ✔️       | static method | clamp()                 | (double,double,double)->double, (float,float,float)->float, (long,long,long)->long, (int,int,int)->int

---

## java.util — Java 1.3 additions

### java.util.TimerTask (✔️/⭕️)

> Abstract base for tasks submitted to `java.util.Timer`. In Java this is an
> abstract class; following the Java2Swift convention it is a Swift `protocol`
> with a default implementation for `scheduledExecutionTime()`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.3     | ✔️          | ⭕️       | protocol      | TimerTask               | AnyObject & Sendable; Sources/JavApi/util/TimerTask.swift
1.3     | ✔️          | ⭕️       | method        | run()                   | () — implement with task body
1.3     | ✔️          | ⭕️       | method        | scheduledExecutionTime()| ()->Int64 — default returns -1

### java.util.Timer (✔️/⭕️)

> Schedules `TimerTask` instances for one-shot or repeating execution on a
> **background actor** — the Swift equivalent of Java's single timer-thread.
> Unlike `javax.swing.Timer`, callbacks are **not** on the main actor; call
> `Task { @MainActor in … }` inside `run()` for UI updates.
>
> **Swift 6 concurrency:** `Timer` is `@unchecked Sendable`. A private
> `TimerActor` serialises all task executions (= Java's single timer-thread
> model). Scheduling uses `Task.sleep` — no Foundation `Timer` or Combine
> dependency. `scheduleAtFixedRate` tracks the next scheduled instant and
> catches up missed firings; `schedule` sleeps *after* each execution (fixed
> delay). Cancellation is cooperative via `Task.isCancelled`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.3     | ✔️          | ⭕️       | final class   | Timer                   | @unchecked Sendable; Sources/JavApi/util/Timer.swift
1.3     | ✔️          | ⭕️       | constructor   | Timer()                 | ()
1.3     | ✔️          | ⭕️       | constructor   | Timer(isDaemon:)        | (Bool) — arg ignored, present for API compat
1.3     | ✔️          | ⭕️       | constructor   | Timer(String)           | (name) — name unused at runtime
1.3     | ✔️          | ⭕️       | constructor   | Timer(String,isDaemon:) | (name, Bool)
1.3     | ✔️          | ⭕️       | method        | schedule()              | (TimerTask, delay:Int64) — one-shot after delay ms
1.3     | ✔️          | ⭕️       | method        | schedule()              | (TimerTask, time:Int64) — one-shot at epoch-ms
1.3     | ✔️          | ⭕️       | method        | schedule()              | (TimerTask, delay:Int64, period:Int64) — fixed delay
1.3     | ✔️          | ⭕️       | method        | schedule()              | (TimerTask, time:Int64, period:Int64) — fixed delay from time
1.3     | ✔️          | ⭕️       | method        | scheduleAtFixedRate()   | (TimerTask, delay:Int64, period:Int64)
1.3     | ✔️          | ⭕️       | method        | scheduleAtFixedRate()   | (TimerTask, time:Int64, period:Int64)
1.3     | ✔️          | ⭕️       | method        | cancel()                | () — cancels timer and all pending tasks
1.3     | ✔️          | ⭕️       | method        | purge()                 | ()->Int — no-op stub; returns 0

---

## Not in scope for Java 1.3

- **Java Sound** (`javax.sound.sampled`, `javax.sound.midi`) — not in scope
- **JNDI** (`javax.naming`) — not in scope
- **JPDA** (Java Platform Debugger Architecture) — **will not be implemented.**
  JPDA is a wire protocol + native-agent API (`jdwp`, `com.sun.jdi`) for
  attaching external debuggers to a running JVM. There is no Swift runtime
  equivalent to instrument, and no realistic host process to attach to.
  This is a permanent exclusion, not a deferral.
- **`java.awt.JobAttributes` / `java.awt.PageAttributes`** — low priority;
  attribute-set classes for the legacy `java.awt.PrintJob` (1.1) print/page
  dialogs. Not yet implemented; stubs possible if needed.
  (Note: `java.awt.print.PrinterJob` — the Java 1.2 print API — **is**
  implemented; see `Java_1.2.md`.)
