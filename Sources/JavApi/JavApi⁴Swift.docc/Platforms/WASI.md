# WASI (WebAssembly)

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Platform notes for running JavApi⁴Swift on WebAssembly / WASI.

## Overview

Swift can be compiled to WebAssembly using [SwiftWasm](https://swiftwasm.org). JavApi⁴Swift compiles on WASI with the following limitations.

## Networking — unavailable

WASI (WebAssembly System Interface) does not expose POSIX socket APIs in its standard interface. All networking classes that require a socket will throw a `java.net.SocketException` at runtime:

| Class | Behaviour on WASI |
|-------|-------------------|
| `java.net.Socket` | `init` throws `SocketException` |
| `java.net.ServerSocket` | `init` throws `SocketException` |
| `java.net.DatagramSocket` | `init` throws `SocketException` |
| `java.net.URLConnection` | `connect()` throws `IOException` |
| `java.net.InetAddress.getByName` | throws `UnknownHostException` |
| `java.net.InetAddress.getLocalHost` | throws `UnknownHostException` |

The high-level `java.net.URL` class and string parsing (`InetAddress` with a literal IP) work without restriction.

> **WASI preview2** adds socket support via the `wasi:sockets` API. Once SwiftWasm adopts this, the above restrictions may be lifted.

## Threading — limited

`DispatchGroup` and `DispatchSemaphore` are unavailable on WASI. JavApi⁴Swift works around this:

| Feature | Behaviour on WASI |
|---------|-------------------|
| `Thread.sleep(_ ms)` (blocking) | Uses POSIX `usleep` via `WASILibc` |
| `Thread.sleep(milliseconds:)` (async) | Uses `Task.sleep` — fully supported |
| `ThreadGroup.interrupt()` | Supported (uses Swift Task cancellation) |
| `StringBuffer` | Uses `NSLock` fallback — check `_CrossPlatformMutex` availability |

## File I/O

File I/O via `java.io.File`, `FileInputStream`, and `FileOutputStream` is available on WASI through the WASI filesystem interface, subject to the sandbox permissions granted to the module.

## Clipboard (`java.awt.datatransfer`)

`Toolkit.getSystemClipboard()` and `StringSelection` work on WASI, but use
an **in-process in-memory buffer** rather than the browser's OS clipboard.

Copy → paste within the same WASM module works correctly.  Cross-app / cross-tab
transfer requires a JavaScript bridge.

**Why not `navigator.clipboard`?**
`navigator.clipboard.readText()` / `writeText()` return JavaScript `Promise`s.
Java's `Clipboard` API is synchronous, and blocking a WASM thread on a JS
`Promise` requires `SharedArrayBuffer` + `Atomics` with specific COOP/COEP HTTP
headers — not reliably available in all deployments.

**Extension point:** If your embedding provides
[JavaScriptKit](https://github.com/swiftwasm/JavaScriptKit), you can supply a
custom `ClipboardProvider` that fire-and-forgets writes to `navigator.clipboard`
and reads back from a JS-side cache.

| Scenario | Behaviour |
|----------|-----------|
| Copy → paste inside WASM module | ✔ via in-memory buffer |
| Copy from WASM → paste in browser | ✖ requires JS bridge |
| Paste from browser → WASM | ✖ requires JS bridge |

## Supported without restriction

- All `java.lang` types except `Thread.sleep` blocking variant (see above)
- All `java.util` types
- `java.io` streams (byte array, string, buffered)
- `java.net.URL` (parsing only, no I/O)
- `java.net.URLEncoder` / `URLDecoder`
- `java.net.InetAddress` with literal IP strings
