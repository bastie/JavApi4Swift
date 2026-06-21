/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// In-process clipboard backend for headless and WASI builds.
///
/// ## Headless (server / CI)
///
/// On headless builds (no display attached) there is no OS clipboard to write
/// to.  The in-memory buffer lets copy → paste work correctly within the
/// running process, which is sufficient for server-side AWT rendering,
/// automated tests, and document-generation pipelines.
///
/// ## WASI / WebAssembly (browser)
///
/// When Swift is compiled to WebAssembly and run in a browser, the host
/// environment exposes `navigator.clipboard` via the JavaScript engine.
/// However, Java's `Clipboard` API is **synchronous**, while
/// `navigator.clipboard.readText()` / `writeText()` return JavaScript
/// `Promise`s — there is no way to block a WASM thread on a JS `Promise`
/// without SharedArrayBuffer + Atomics, which requires specific COOP/COEP
/// HTTP headers not always available.
///
/// **Extension point:** If your embedding provides
/// [JavaScriptKit](https://github.com/swiftwasm/JavaScriptKit) as a
/// dependency, you can replace this provider with a custom
/// ``java.awt.toolkit.ClipboardProvider`` that bridges to the JS clipboard:
///
/// ```swift
/// // Example (JavaScriptKit required):
/// // import JavaScriptKit
/// // let navigator = JSObject.global.navigator
/// // navigator.clipboard.writeText(text)   // fire-and-forget Promise
/// // — reading is harder (async); store locally and read from buffer
/// ```
///
/// Until then, WASI gets the same in-memory buffer: copy → paste works
/// inside the module; cross-app / cross-tab transfer requires the JS bridge.
///
/// - Since: JavaApi (Java 1.1 datatransfer)
extension java.awt.toolkit {

  public final class _HeadlessClipboardProvider: ClipboardProvider, @unchecked Sendable {

    private var _text: String? = nil
    private let lock = CrossPlatformMutex(0)

    public init() {}

    public func _getClipboardText() -> String? {
      var result: String? = nil
      lock.withLock { _ in result = _text }
      return result
    }

    public func _setClipboardText(_ text: String) {
      lock.withLock { _ in _text = text }
    }
  }
}
