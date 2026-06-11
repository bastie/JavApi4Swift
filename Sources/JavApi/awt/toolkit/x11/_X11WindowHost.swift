/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
import Glibc
import Foundation
import CoreFoundation

// =============================================================================
// MARK: X11 type aliases (avoid collision with java.awt.Window)
// =============================================================================

typealias X11DisplayPtr = UnsafeMutableRawPointer
typealias X11WindowID   = UInt   // XID / unsigned long on 64-bit

// =============================================================================
// MARK: X11 function signatures
// =============================================================================

private typealias XOpenDisplayFunc          = @convention(c) (UnsafePointer<CChar>?) -> X11DisplayPtr?
private typealias XCloseDisplayFunc         = @convention(c) (X11DisplayPtr) -> Int32
private typealias XDefaultScreenFunc        = @convention(c) (X11DisplayPtr) -> Int32
private typealias XDefaultRootWindowFunc    = @convention(c) (X11DisplayPtr) -> X11WindowID
private typealias XBlackPixelFunc           = @convention(c) (X11DisplayPtr, Int32) -> UInt
private typealias XWhitePixelFunc           = @convention(c) (X11DisplayPtr, Int32) -> UInt
private typealias XCreateSimpleWindowFunc   = @convention(c) (X11DisplayPtr, X11WindowID, Int32, Int32, UInt32, UInt32, UInt32, UInt, UInt) -> X11WindowID
private typealias XStoreNameFunc            = @convention(c) (X11DisplayPtr, X11WindowID, UnsafePointer<CChar>?) -> Int32
private typealias XInternAtomFunc           = @convention(c) (X11DisplayPtr, UnsafePointer<CChar>?, Int32) -> UInt
private typealias XChangePropertyFunc       = @convention(c) (X11DisplayPtr, X11WindowID, UInt, UInt, Int32, Int32, UnsafePointer<UInt8>?, Int32) -> Int32
private typealias XSetWMProtocolsFunc       = @convention(c) (X11DisplayPtr, X11WindowID, UnsafeMutablePointer<UInt>?, Int32) -> Int32
private typealias XSelectInputFunc          = @convention(c) (X11DisplayPtr, X11WindowID, CLong) -> Int32
private typealias XMapWindowFunc            = @convention(c) (X11DisplayPtr, X11WindowID) -> Int32
private typealias XUnmapWindowFunc          = @convention(c) (X11DisplayPtr, X11WindowID) -> Int32
private typealias XDestroyWindowFunc        = @convention(c) (X11DisplayPtr, X11WindowID) -> Int32
private typealias XFlushFunc                = @convention(c) (X11DisplayPtr) -> Int32
private typealias XNextEventFunc            = @convention(c) (X11DisplayPtr, UnsafeMutableRawPointer) -> Int32
private typealias XPendingFunc              = @convention(c) (X11DisplayPtr) -> Int32
private typealias XFillRectangleFunc        = @convention(c) (X11DisplayPtr, X11WindowID, UnsafeMutableRawPointer, Int32, Int32, UInt32, UInt32) -> Int32
private typealias XCreateGCFunc             = @convention(c) (X11DisplayPtr, X11WindowID, UInt, UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?
private typealias XFreeGCFunc               = @convention(c) (X11DisplayPtr, UnsafeMutableRawPointer) -> Int32
private typealias XSetForegroundFunc        = @convention(c) (X11DisplayPtr, UnsafeMutableRawPointer, UInt) -> Int32
private typealias XResizeWindowFunc         = @convention(c) (X11DisplayPtr, X11WindowID, UInt32, UInt32) -> Int32
private typealias XMoveResizeWindowFunc     = @convention(c) (X11DisplayPtr, X11WindowID, Int32, Int32, UInt32, UInt32) -> Int32
private typealias XGetDefaultFunc           = @convention(c) (X11DisplayPtr, UnsafePointer<CChar>, UnsafePointer<CChar>) -> UnsafePointer<CChar>?

// X11 event type constants (from X.h)
private let X11_ExposureMask:   CLong = 1 << 15
private let X11_KeyPressMask:   CLong = 1 << 0
private let X11_ButtonPressMask:CLong = 1 << 2
private let X11_StructureNotifyMask: CLong = 1 << 17

private let X11_Expose:         Int32 = 12
private let X11_KeyPress:       Int32 = 2
private let X11_ButtonPress:    Int32 = 4
private let X11_ConfigureNotify:Int32 = 22
private let X11_ClientMessage:  Int32 = 33
private let X11_DestroyNotify:  Int32 = 17

// XEvent buffer size — 192 bytes on x86_64, use 512 for safety on all archs
private let X11EventBufferSize = 512

// =============================================================================
// MARK: _X11WindowHost  (Singleton)
// =============================================================================

/// Singleton bridge between `java.awt.Window` and the X11 window system.
///
/// Mirrors `_Win32WindowHost` for Linux / FreeBSD.
/// Loads `libX11.so.6` dynamically via `dlopen` — no `Package.swift` entry needed.
///
/// ### Integration
/// ```swift
/// // Entry point — before any AWT code:
/// try? System.setProperty("awt.toolkit", "X11")
/// ```
// _X11WindowHost is NOT @MainActor — the X11 event loop runs on a dedicated
// background thread. All mutable state is protected by a lock. Window-opening
// and hide() are called from the main thread; handleEvent dispatches AWT events
// back to the main thread via DispatchQueue.main.async.
public final class _X11WindowHost: @unchecked Sendable {

  public static let shared = _X11WindowHost()
  private init() { loadLibrary() }

  private let lock = NSLock()

  // ---------------------------------------------------------------------------
  // MARK: Library handle (lives for the entire application lifetime)
  // ---------------------------------------------------------------------------

  private var libHandle: UnsafeMutableRawPointer?
  private var display:   X11DisplayPtr?

  // Resolved function pointers
  private var fnOpenDisplay:       XOpenDisplayFunc?
  private var fnCloseDisplay:      XCloseDisplayFunc?
  private var fnDefaultScreen:     XDefaultScreenFunc?
  private var fnDefaultRootWindow: XDefaultRootWindowFunc?
  private var fnBlackPixel:        XBlackPixelFunc?
  private var fnWhitePixel:        XWhitePixelFunc?
  private var fnCreateSimpleWindow:XCreateSimpleWindowFunc?
  private var fnStoreName:         XStoreNameFunc?
  private var fnSelectInput:       XSelectInputFunc?
  private var fnMapWindow:         XMapWindowFunc?
  private var fnUnmapWindow:       XUnmapWindowFunc?
  private var fnDestroyWindow:     XDestroyWindowFunc?
  private var fnFlush:             XFlushFunc?
  private var fnNextEvent:         XNextEventFunc?
  private var fnPending:           XPendingFunc?
  private var fnCreateGC:          XCreateGCFunc?
  private var fnFreeGC:            XFreeGCFunc?
  private var fnSetForeground:     XSetForegroundFunc?
  private var fnResizeWindow:      XResizeWindowFunc?
  private var fnMoveResizeWindow:  XMoveResizeWindowFunc?
  private var fnInternAtom:        XInternAtomFunc?
  private var fnChangeProperty:    XChangePropertyFunc?
  private var fnSetWMProtocols:    XSetWMProtocolsFunc?
  private var fnGetDefault:        XGetDefaultFunc?

  // Cached atoms
  private var atomWMDeleteWindow: UInt = 0

  // HiDPI scale factor: Xft.dpi / 96.0 (1.0 on standard displays, 2.0 on HiDPI)
  private(set) var scaleFactor: Double = 1.0

  // ---------------------------------------------------------------------------
  // MARK: Window registry
  // ---------------------------------------------------------------------------

  private var registry: [X11WindowID: java.awt.Window] = [:]
  private var reverseRegistry: [ObjectIdentifier: X11WindowID] = [:]
  private var gcRegistry: [X11WindowID: UnsafeMutableRawPointer] = [:]

  // ---------------------------------------------------------------------------
  // MARK: Library loading
  // ---------------------------------------------------------------------------

  private func loadLibrary() {
    // Try versioned name first, then unversioned fallback
    let candidates = ["libX11.so.6", "libX11.so"]
    for name in candidates {
      if let handle = dlopen(name, RTLD_LAZY | RTLD_GLOBAL) {
        libHandle = handle
        break
      }
    }
    guard let lib = libHandle else {
      print("[X11Toolkit] ERROR: libX11 not found — running headless.")
      return
    }

    func resolve<F>(_ symbol: String, as _: F.Type) -> F? {
      guard let raw = dlsym(lib, symbol) else { return nil }
      return unsafeBitCast(raw, to: F.self)
    }

    fnOpenDisplay        = resolve("XOpenDisplay",        as: XOpenDisplayFunc.self)
    fnCloseDisplay       = resolve("XCloseDisplay",       as: XCloseDisplayFunc.self)
    fnDefaultScreen      = resolve("XDefaultScreen",      as: XDefaultScreenFunc.self)
    fnDefaultRootWindow  = resolve("XDefaultRootWindow",  as: XDefaultRootWindowFunc.self)
    fnBlackPixel         = resolve("XBlackPixel",         as: XBlackPixelFunc.self)
    fnWhitePixel         = resolve("XWhitePixel",         as: XWhitePixelFunc.self)
    fnCreateSimpleWindow = resolve("XCreateSimpleWindow", as: XCreateSimpleWindowFunc.self)
    fnStoreName          = resolve("XStoreName",          as: XStoreNameFunc.self)
    fnSelectInput        = resolve("XSelectInput",        as: XSelectInputFunc.self)
    fnMapWindow          = resolve("XMapWindow",          as: XMapWindowFunc.self)
    fnUnmapWindow        = resolve("XUnmapWindow",        as: XUnmapWindowFunc.self)
    fnDestroyWindow      = resolve("XDestroyWindow",      as: XDestroyWindowFunc.self)
    fnFlush              = resolve("XFlush",              as: XFlushFunc.self)
    fnNextEvent          = resolve("XNextEvent",          as: XNextEventFunc.self)
    fnPending            = resolve("XPending",            as: XPendingFunc.self)
    fnCreateGC           = resolve("XCreateGC",           as: XCreateGCFunc.self)
    fnFreeGC             = resolve("XFreeGC",             as: XFreeGCFunc.self)
    fnSetForeground      = resolve("XSetForeground",      as: XSetForegroundFunc.self)
    fnResizeWindow       = resolve("XResizeWindow",       as: XResizeWindowFunc.self)
    fnMoveResizeWindow   = resolve("XMoveResizeWindow",   as: XMoveResizeWindowFunc.self)
    fnInternAtom         = resolve("XInternAtom",         as: XInternAtomFunc.self)
    fnChangeProperty     = resolve("XChangeProperty",     as: XChangePropertyFunc.self)
    fnSetWMProtocols     = resolve("XSetWMProtocols",     as: XSetWMProtocolsFunc.self)
    fnGetDefault         = resolve("XGetDefault",         as: XGetDefaultFunc.self)
  }

  // ---------------------------------------------------------------------------
  // MARK: Display lifecycle
  // ---------------------------------------------------------------------------

  /// Opens the X11 display connection. Called once by `X11Toolkit.runEventLoop()`.
  func openDisplay() -> Bool {
    guard display == nil, let fn = fnOpenDisplay else { return display != nil }
    // Enable locale-aware multibyte text so XCreateFontSet / XmbDrawString
    // can handle UTF-8. Derived from java.util.Locale.getDefault() so the
    // X11 locale matches the JavApi locale rather than raw env variables.
    let posixLocale = java.util.Locale.getDefault().toPosixLocale()
    _ = Glibc.setlocale(LC_ALL, posixLocale)
    guard let dpy = fn(nil) else {
      print("[X11Toolkit] ERROR: Cannot connect to X server (check $DISPLAY).")
      return false
    }
    display = dpy

    // Query HiDPI scale factor from Xft.dpi (set by desktop environment).
    // Standard DPI baseline is 96; a value of 192 means 2× scaling.
    // Falls back to 1.0 if Xft.dpi is not set.
    if let fnDef = fnGetDefault,
       let cstr  = fnDef(dpy, "Xft", "dpi"),
       let xftDpi = Double(String(cString: cstr)), xftDpi > 0 {
      scaleFactor = (xftDpi / 96.0).rounded()
    }
    print("[X11Toolkit] scaleFactor=\(scaleFactor)")

    // Cache WM_DELETE_WINDOW atom once — reused for every window
    if let fnAtom = fnInternAtom {
      atomWMDeleteWindow = fnAtom(dpy, "WM_DELETE_WINDOW", 0)
    }
    return true
  }

  // ---------------------------------------------------------------------------
  // MARK: Window lifecycle
  // ---------------------------------------------------------------------------

  @MainActor
  public func openWindow(for awtWindow: java.awt.Window) {
    guard let dpy = display,
          let fnScreen  = fnDefaultScreen,
          let fnRoot    = fnDefaultRootWindow,
          let fnBlack   = fnBlackPixel,
          let fnWhite   = fnWhitePixel,
          let fnCreate  = fnCreateSimpleWindow,
          let fnSel     = fnSelectInput,
          let fnMap     = fnMapWindow,
          let fnFlush   = fnFlush,
          let fnGC      = fnCreateGC
    else { return }

    awtWindow.validate()

    let screen  = fnScreen(dpy)
    let root    = fnRoot(dpy)
    let black   = fnBlack(dpy, screen)
    let white   = fnWhite(dpy, screen)
    let w       = UInt32(max(Int(Double(awtWindow.getWidth())  * scaleFactor), 1))
    let h       = UInt32(max(Int(Double(awtWindow.getHeight()) * scaleFactor), 1))

    let xwin = fnCreate(dpy, root, 100, 100, w, h, 1, black, white)

    // Window title — use _NET_WM_NAME (UTF-8) for full Unicode support,
    // XStoreName as Latin-1 fallback for older window managers.
    let title = (awtWindow as? java.awt.Frame)?.getTitle() ?? ""
    if let fnName = fnStoreName {
      _ = fnName(dpy, xwin, title)  // Latin-1 fallback
    }
    if let fnAtom = fnInternAtom, let fnProp = fnChangeProperty {
      let wmName    = fnAtom(dpy, "_NET_WM_NAME", 0)
      let utf8Atom  = fnAtom(dpy, "UTF8_STRING",  0)
      let bytes = Array(title.utf8)
      bytes.withUnsafeBufferPointer { buf in
        _ = fnProp(dpy, xwin, wmName, utf8Atom, 8, 0 /*PropModeReplace*/,
                   buf.baseAddress, Int32(bytes.count))
      }
    }

    // Subscribe to events
    let mask = X11_ExposureMask | X11_KeyPressMask | X11_ButtonPressMask | X11_StructureNotifyMask
    _ = fnSel(dpy, xwin, mask)

    // Create a GC for this window
    let gc = fnGC(dpy, xwin, 0, nil)
    gcRegistry[xwin] = gc

    registry[xwin] = awtWindow
    reverseRegistry[ObjectIdentifier(awtWindow)] = xwin

    // Register WM_DELETE_WINDOW so the close button sends a ClientMessage
    // instead of forcibly killing the X connection.
    if let fnProto = fnSetWMProtocols, atomWMDeleteWindow != 0 {
      var atom = atomWMDeleteWindow
      _ = fnProto(dpy, xwin, &atom, 1)
    }

    _ = fnMap(dpy, xwin)
    _ = fnFlush(dpy)
  }

  @MainActor
  public func hide(_ window: java.awt.Window) {
    let id = ObjectIdentifier(window)
    guard let xwin = reverseRegistry[id], let dpy = display else { return }
    if let gc = gcRegistry[xwin], let fnFree = fnFreeGC {
      _ = fnFree(dpy, gc)
      gcRegistry.removeValue(forKey: xwin)
    }
    _ = fnUnmapWindow?(dpy, xwin)
    _ = fnDestroyWindow?(dpy, xwin)
    _ = fnFlush?(dpy)
    registry.removeValue(forKey: xwin)
    reverseRegistry.removeValue(forKey: id)
  }

  // ---------------------------------------------------------------------------
  // MARK: Event loop
  // ---------------------------------------------------------------------------

  private let quitSemaphore = DispatchSemaphore(value: 0)

  /// Starts the X11 event loop on a background thread and blocks the calling
  /// thread (main thread) until `terminate()` is called.
  func runEventLoop() {
    guard openDisplay() else { return }
    MainActor.assumeIsolated { java.awt.EventQueue.drainAndMarkRunning() }

    guard display != nil, fnNextEvent != nil else {
      print("[X11Toolkit] ERROR: No display or XNextEvent — cannot run event loop.")
      return
    }

    // Spin the blocking XNextEvent loop on a background thread so that
    // terminate() can be called from the main thread (via WindowListener).
    // Use Foundation.Thread directly — java.awt.Thread requires a Runnable object.
    let thread = Foundation.Thread {
      self.eventLoopBody()
      self.quitSemaphore.signal()
    }
    thread.name = "X11EventLoop"
    thread.start()

    // Spin the main thread's RunLoop so that DispatchQueue.main.async blocks
    // dispatched from the background event loop can execute.
    // We cannot use quitSemaphore.wait() here — that would block the main
    // thread and prevent async dispatch from running (deadlock).
    while !shouldQuit {
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.016))
    }
    // Wait for background thread to finish cleanup
    quitSemaphore.wait()

    // Teardown on main thread
    if let dpy = display {
      _ = fnCloseDisplay?(dpy)
      display = nil
    }
    if let lib = libHandle {
      dlclose(lib)
      libHandle = nil
    }
  }

  private func eventLoopBody() {
    let eventBuffer = UnsafeMutableRawPointer.allocate(byteCount: X11EventBufferSize, alignment: 8)
    defer { eventBuffer.deallocate() }
    guard let dpy = display, let fnNext = fnNextEvent, let fnPend = fnPending else {
      return
    }
    // Poll-based loop: XPending checks for queued events without blocking.
    // If no events are pending, sleep briefly so we can check shouldQuit
    // regularly without busy-waiting. This allows terminate() to take effect
    // within ~16 ms without needing a wakeup event.
    while !shouldQuit {
      if fnPend(dpy) > 0 {
        _ = fnNext(dpy, eventBuffer)
        let bytes = Array(UnsafeBufferPointer(
          start: eventBuffer.assumingMemoryBound(to: UInt8.self),
          count: X11EventBufferSize))
        DispatchQueue.main.async {
          self.handleEventBytes(bytes)
        }
      } else {
        // No events queued — sleep 16ms before polling again
        Glibc.usleep(16_000)
      }
    }
  }

  private var _shouldQuit = false
  private var shouldQuit: Bool {
    get { lock.withLock { _shouldQuit } }
    set { lock.withLock { _shouldQuit = newValue } }
  }

  func terminate() {
    // Signal the event loop to exit and immediately wake the main thread's
    // RunLoop so it doesn't wait up to 16ms for the current run(until:) to time out.
    shouldQuit = true
    CFRunLoopStop(CFRunLoopGetMain())
  }

  // ---------------------------------------------------------------------------
  // MARK: Event dispatch
  // ---------------------------------------------------------------------------
  // handleEvent is always called via DispatchQueue.main.sync, so we are
  // guaranteed to be on the main thread. MainActor.assumeIsolated lets us
  // access @MainActor-isolated types without a runtime assertion failure.

  // Called on main thread via DispatchQueue.main.sync with a copied [UInt8] array.
  // The pointer is created locally inside the @MainActor method to avoid
  // Swift 6 Sendable violations.
  private func handleEventBytes(_ bytes: [UInt8]) {
    MainActor.assumeIsolated {
      _handleEventIsolated(bytes)
    }
  }

  @MainActor
  private func _handleEventIsolated(_ bytes: [UInt8]) {
    bytes.withUnsafeBytes { rawBuf in
      guard let base = rawBuf.baseAddress else { return }
      let buf = UnsafeMutableRawPointer(mutating: base)
      _dispatchEvent(buf)
    }
  }

  @MainActor
  private func _dispatchEvent(_ buf: UnsafeMutableRawPointer) {
    let eventType = buf.load(as: Int32.self)
    // XAnyEvent layout on 64-bit Linux (with alignment padding):
    // type(Int32/4) + pad(4) + serial(UInt/8) + send_event(Int32/4) + pad(4)
    // + display*(8) + window(UInt/8)  → window offset = 4+4+8+4+4+8 = 32
    let xwin = buf.load(fromByteOffset: 32, as: X11WindowID.self)

    guard let awtWindow = registry[xwin] else {
      return
    }

    switch eventType {

    case X11_Expose:
      repaint(awtWindow, xwin: xwin)

    case X11_ConfigureNotify:
      // XConfigureEvent: after the common fields comes x(Int32), y(Int32), width(Int32), height(Int32)
      let baseOffset = MemoryLayout<Int32>.size      // type
                     + MemoryLayout<UInt>.size       // serial
                     + MemoryLayout<Int32>.size      // send_event
                     + MemoryLayout<UnsafeRawPointer>.size // display
                     + MemoryLayout<X11WindowID>.size      // event window
                     + MemoryLayout<X11WindowID>.size      // window
                     + MemoryLayout<Int32>.size      // x
                     + MemoryLayout<Int32>.size      // y
      // X11 reports physical pixels; convert back to logical AWT coordinates
      let physW = Int(buf.load(fromByteOffset: baseOffset,                        as: Int32.self))
      let physH = Int(buf.load(fromByteOffset: baseOffset + MemoryLayout<Int32>.size, as: Int32.self))
      let logW = Int((Double(physW) / scaleFactor).rounded())
      let logH = Int((Double(physH) / scaleFactor).rounded())
      if logW > 0 && logH > 0 &&
         (logW != awtWindow.getWidth() || logH != awtWindow.getHeight()) {
        awtWindow.setBounds(awtWindow.getX(), awtWindow.getY(), logW, logH)
        awtWindow.validate()
        repaint(awtWindow, xwin: xwin)
      }

    case X11_ButtonPress:
      // XButtonEvent: after common fields: root, subwindow, time, x, y (relative to window)
      let btnBaseOffset = MemoryLayout<Int32>.size
                        + MemoryLayout<UInt>.size
                        + MemoryLayout<Int32>.size
                        + MemoryLayout<UnsafeRawPointer>.size
                        + MemoryLayout<X11WindowID>.size  // event window
                        + MemoryLayout<X11WindowID>.size  // root
                        + MemoryLayout<X11WindowID>.size  // subwindow
                        + MemoryLayout<UInt>.size          // time
      let clickX = Int(buf.load(fromByteOffset: btnBaseOffset,                        as: Int32.self))
      let clickY = Int(buf.load(fromByteOffset: btnBaseOffset + MemoryLayout<Int32>.size, as: Int32.self))
      let hit = _AWTHitTest.find(x: clickX, y: clickY, in: awtWindow)
      _X11FocusManager.shared.requestFocus(hit)
      _AWTHitTest.dispatch(click: hit ?? awtWindow)

    case X11_KeyPress:
      // Minimal key handling — full implementation needs XLookupString
      // KeySym offset: after common + root/sub/time/x/y/x_root/y_root/state/keycode
      // For now route raw keycode to focus manager as a placeholder
      break

    case X11_ClientMessage:
      // XClientMessageEvent layout (64-bit Linux):
      // type(4) + pad(4) + serial(8) + send_event(4) + pad(4)
      // + display*(8) + window(8) + message_type(8) + format(4) + pad(4)
      // + data[0](8)
      // window=32, message_type=40, format=48, data[0]=56
      let dataOffset = 56
      let data0 = buf.load(fromByteOffset: dataOffset, as: UInt.self)
      if data0 == atomWMDeleteWindow {
        // Already on main thread via DispatchQueue.main.sync in eventLoopBody
        awtWindow.processWindowEvent(
          java.awt.event.WindowEvent(awtWindow, java.awt.event.WindowEvent.WINDOW_CLOSING))
      }

    case X11_DestroyNotify:
      // X connection already gone — just clean up registry, do not fire WINDOW_CLOSING again
      registry.removeValue(forKey: xwin)
      reverseRegistry.removeValue(forKey: ObjectIdentifier(awtWindow))

    default:
      break
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Rendering
  // ---------------------------------------------------------------------------

  @MainActor
  private func repaint(_ awtWindow: java.awt.Window, xwin: X11WindowID) {
    guard let dpy = display, let gc = gcRegistry[xwin] else { return }
    let g = java.awt.toolkit.x11._X11Graphics(display: dpy, drawable: xwin, gc: gc,
                                               scaleFactor: scaleFactor)
    awtWindow.paint(g)
    _ = fnFlush?(dpy)
  }
}
#endif
