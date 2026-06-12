/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
#if canImport(Glibc)
import Glibc
import Foundation
import CoreFoundation

private let LC_ALL: CInt = 6
private let RTLD_LAZY: CInt = 0x00001
private let RTLD_GLOBAL: CInt = 0x00100

#else
// MUSL (static or dynamic): declare C functions directly since Glibc module not available
import Foundation
import CoreFoundation

@_silgen_name("usleep")
func usleep(_ useconds: UInt32) -> CInt

@_silgen_name("setlocale")
func setlocale(_ category: CInt, _ locale: UnsafePointer<CChar>?) -> UnsafeMutablePointer<CChar>?

@_silgen_name("readlink")
func readlink(_ path: UnsafePointer<CChar>, _ buf: UnsafeMutablePointer<CChar>, _ bufsiz: Int) -> Int

@_silgen_name("dlopen")
func dlopen(_ filename: UnsafePointer<CChar>?, _ flags: CInt) -> UnsafeMutableRawPointer?

@_silgen_name("dlsym")
func dlsym(_ handle: UnsafeMutableRawPointer?, _ symbol: UnsafePointer<CChar>) -> UnsafeMutableRawPointer?

@_silgen_name("dlclose")
func dlclose(_ handle: UnsafeMutableRawPointer?) -> CInt

private let LC_ALL: CInt = 6
private let RTLD_LAZY: CInt = 0x00001
private let RTLD_GLOBAL: CInt = 0x00100
#endif

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
private let X11_ExposureMask:        CLong = 1 << 15
private let X11_KeyPressMask:        CLong = 1 << 0
private let X11_ButtonPressMask:     CLong = 1 << 2
private let X11_ButtonReleaseMask:   CLong = 1 << 3
private let X11_PointerMotionMask:   CLong = 1 << 6
private let X11_StructureNotifyMask: CLong = 1 << 17

private let X11_Expose:          Int32 = 12
private let X11_KeyPress:        Int32 = 2
private let X11_ButtonPress:     Int32 = 4
private let X11_ButtonRelease:   Int32 = 5
private let X11_MotionNotify:    Int32 = 6
private let X11_ConfigureNotify: Int32 = 22
private let X11_ClientMessage:   Int32 = 33
private let X11_DestroyNotify:   Int32 = 17

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

  /// The open X11 display connection, or `nil` if not yet connected.
  /// Used by `_X11FontMetrics` to create Xft font measurements.
  var currentDisplay: X11DisplayPtr? { display }

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

  // MenuBar attached to each Frame (keyed by X11 window ID)
  @MainActor private var menuBarRegistry: [X11WindowID: _X11MenuBar] = [:]

  // ---------------------------------------------------------------------------
  // MARK: Drag state (mouse-button held)
  // ---------------------------------------------------------------------------

  // Scrollbar being thumb-dragged (cleared on ButtonRelease)
  @MainActor private weak var draggingScrollbar:  java.awt.Scrollbar?
  // ScrollPane whose thumb is being dragged (cleared on ButtonRelease)
  @MainActor private weak var draggingScrollPane: java.awt.ScrollPane?
  // Button being held down — isPressed set on ButtonPress, doClick() on ButtonRelease
  @MainActor private weak var pressedButton: java.awt.Button?
  @MainActor private weak var pressedButtonWindow: java.awt.Window?

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
      #if canImport(Glibc)
      print("[X11Toolkit] ERROR: libX11 not found — running headless.")
      #else
      print("[X11Toolkit] ERROR: dlopen() unavailable (static MUSL build) or libX11 not found.")
      #endif
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
    _ = setlocale(LC_ALL, posixLocale)
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
    let title: String
    if let frame = awtWindow as? java.awt.Frame {
      title = frame.getTitle()
    } else if let dialog = awtWindow as? java.awt.Dialog {
      title = dialog.getTitle()
    } else {
      title = ""
    }
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
    let mask = X11_ExposureMask | X11_KeyPressMask | X11_ButtonPressMask | X11_ButtonReleaseMask | X11_PointerMotionMask | X11_StructureNotifyMask
    _ = fnSel(dpy, xwin, mask)

    // Create a GC for this window
    let gc = fnGC(dpy, xwin, 0, nil)
    gcRegistry[xwin] = gc

    registry[xwin] = awtWindow
    reverseRegistry[ObjectIdentifier(awtWindow)] = xwin

    // If a MenuBar was attached before the window was opened (the common case —
    // frame.setMenuBar() is usually called before setVisible()), attach it now.
    if let frame = awtWindow as? java.awt.Frame, let mb = frame.getMenuBar() {
      menuBarRegistry[xwin] = _X11MenuBar(mb)
      // Shrink AWT content area so layout managers don't paint under the bar
      let logH = awtWindow.getHeight() - _X11MenuBar.menuBarHeight
      if logH > 0 {
        awtWindow.setBounds(awtWindow.getX(), awtWindow.getY(), awtWindow.getWidth(), logH)
        awtWindow.validate()
      }
    }

    // Register WM_DELETE_WINDOW so the close button sends a ClientMessage
    // instead of forcibly killing the X connection.
    if let fnProto = fnSetWMProtocols, atomWMDeleteWindow != 0 {
      var atom = atomWMDeleteWindow
      _ = fnProto(dpy, xwin, &atom, 1)
    }

    _ = fnMap(dpy, xwin)
    _ = fnFlush(dpy)
  }

  // ---------------------------------------------------------------------------
  // MARK: Menu bar
  // ---------------------------------------------------------------------------

  /// Attaches a `MenuBar` to the given frame and redraws.
  /// Called by `X11Toolkit.attachMenuBar(_:to:)`.
  @MainActor
  public func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
    // Window may not be open yet — openWindow() will pick up the menu bar from
    // frame.getMenuBar() once the frame becomes visible.
    guard let xwin = reverseRegistry[ObjectIdentifier(frame)] else { return }
    let alreadyAttached = menuBarRegistry[xwin] != nil
    if let mb = menuBar {
      menuBarRegistry[xwin] = _X11MenuBar(mb)
      if !alreadyAttached {
        // Shrink the AWT content area so layout managers don't paint under the bar
        let logH = frame.getHeight() - _X11MenuBar.menuBarHeight
        if logH > 0 {
          frame.setBounds(frame.getX(), frame.getY(), frame.getWidth(), logH)
          frame.validate()
        }
      }
    } else {
      menuBarRegistry.removeValue(forKey: xwin)
      // Height restore not tracked — just repaint
    }
    repaint(frame, xwin: xwin)
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
      #if canImport(Glibc)
      dlclose(lib)
      #endif
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
        _ = usleep(16_000)
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
      // XConfigureEvent layout on 64-bit Linux (verified via offsetof):
      //   0: type(4)  8: serial(8)  16: send_event(4) [+4 pad]
      //  24: display*(8)  32: event(XID/8)  40: window(XID/8)
      //  48: x(int)  52: y(int)  56: width(int)  60: height(int)
      let physW = Int(buf.load(fromByteOffset: 56, as: Int32.self))
      let physH = Int(buf.load(fromByteOffset: 60, as: Int32.self))
      let logW = Int((Double(physW) / scaleFactor).rounded())
      var logH = Int((Double(physH) / scaleFactor).rounded())
      // On X11 the menu bar is drawn inside the window — subtract its height
      // so AWT layout managers see only the content area below the bar.
      if menuBarRegistry[xwin] != nil {
        logH = max(1, logH - _X11MenuBar.menuBarHeight)
      }
      if logW > 0 && logH > 0 &&
         (logW != awtWindow.getWidth() || logH != awtWindow.getHeight()) {
        awtWindow.setBounds(awtWindow.getX(), awtWindow.getY(), logW, logH)
        awtWindow.validate()
        repaint(awtWindow, xwin: xwin)
      }

    case X11_ButtonPress:
      // XButtonEvent layout on 64-bit Linux (verified via offsetof):
      //   0: type(int/4)  8: serial(ulong/8)  16: send_event(int/4)  [+4 pad]
      //  24: display*(8) 32: window(XID/8)    40: root(XID/8)
      //  48: subwindow(XID/8)  56: time(ulong/8)  64: x(int)  68: y(int)
      let physClickX = Int(buf.load(fromByteOffset: 64, as: Int32.self))
      let physClickY = Int(buf.load(fromByteOffset: 68, as: Int32.self))
      // Convert physical pixels back to logical coordinates for hit testing
      let clickX = Int((Double(physClickX) / scaleFactor).rounded())
      let clickY = Int((Double(physClickY) / scaleFactor).rounded())

      // If a popup is open: check click in popup first, dismiss if outside
      if let popup = _X11PopupWindow.activePopup {
        if popup.contains(clickX, clickY) {
          if let (item, _) = popup.item(at: clickX, py: clickY) {
            popup.activate(item: item)
            // Close open menu highlight
            if let x11mb = menuBarRegistry[xwin] { x11mb.openMenu = nil }
          }
        } else {
          // Click outside popup — dismiss
          popup.dismiss()
          if let x11mb = menuBarRegistry[xwin] { x11mb.openMenu = nil }
          repaint(awtWindow, xwin: xwin)
        }
        return
      }

      // Check if click is in the menu bar
      if let x11mb = menuBarRegistry[xwin],
         clickY < _X11MenuBar.menuBarHeight,
         let menu = x11mb.menu(at: clickX, y: clickY) {
        // Toggle: close if already open, else open
        if x11mb.openMenu === menu {
          x11mb.openMenu = nil
          repaint(awtWindow, xwin: xwin)
        } else {
          x11mb.openMenu = menu
          repaint(awtWindow, xwin: xwin)
          // Show popup — find the title rect for screen-relative positioning
          if let rect = x11mb.menuRects.first(where: { $0.menu === menu })?.rect {
            // Popup coordinates are window-local (logical px)
            _X11PopupWindow.show(menu: menu,
                                 at: rect.x, y: _X11MenuBar.menuBarHeight,
                                 host: self, ownerXwin: xwin,
                                 ownerWindow: awtWindow)
          }
        }
      } else {
        // Normal content area click — adjust y to account for menu bar offset
        let contentX = clickX
        let contentY = menuBarRegistry[xwin] != nil
                     ? clickY - _X11MenuBar.menuBarHeight
                     : clickY
        let hit = _AWTHitTest.find(x: contentX, y: contentY, in: awtWindow)
        _X11FocusManager.shared.requestFocus(hit)

        // --- Scrollbar ---
        if let sb = hit as? java.awt.Scrollbar {
          let isVert = sb.orientation == java.awt.Scrollbar.VERTICAL
          if sb.decrementButtonRect().contains(contentX, contentY) {
            sb.value = sb.value - sb.unitIncrement
            sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_DECREMENT, isAdjusting: false)
          } else if sb.incrementButtonRect().contains(contentX, contentY) {
            sb.value = sb.value + sb.unitIncrement
            sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_INCREMENT, isAdjusting: false)
          } else if sb.thumbRect().contains(contentX, contentY) {
            draggingScrollbar = sb
            sb.isDragging      = true
            sb.dragStartCoord  = isVert ? contentY : contentX
            sb.dragStartValue  = sb.value
          } else {
            // Track click — jump to position, then allow drag
            let coord  = isVert ? contentY : contentX
            let origin = isVert ? sb.bounds.y : sb.bounds.x
            let track  = isVert ? sb.bounds.height : sb.bounds.width
            let range  = sb.maximum - sb.minimum
            let newVal = sb.minimum + (coord - origin) * range / max(1, track) - sb.visibleAmount / 2
            sb.value   = newVal
            sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: false)
            draggingScrollbar = sb
            sb.isDragging      = true
            sb.dragStartCoord  = isVert ? contentY : contentX
            sb.dragStartValue  = sb.value
          }
          repaint(awtWindow, xwin: xwin)

        // --- ScrollPane ---
        } else if let sp = hit as? java.awt.ScrollPane {
          let (maxX, maxY) = sp.maxScroll()
          if let btn = sp.vDecrementButtonRect(), btn.contains(contentX, contentY) {
            sp.setScrollPosition(sp.scrollX, max(0, sp.scrollY - sp.scrollbarSize))
          } else if let btn = sp.vIncrementButtonRect(), btn.contains(contentX, contentY) {
            sp.setScrollPosition(sp.scrollX, min(maxY, sp.scrollY + sp.scrollbarSize))
          } else if let btn = sp.hDecrementButtonRect(), btn.contains(contentX, contentY) {
            sp.setScrollPosition(max(0, sp.scrollX - sp.scrollbarSize), sp.scrollY)
          } else if let btn = sp.hIncrementButtonRect(), btn.contains(contentX, contentY) {
            sp.setScrollPosition(min(maxX, sp.scrollX + sp.scrollbarSize), sp.scrollY)
          } else if let thumb = sp.vThumbRect(), thumb.contains(contentX, contentY) {
            draggingScrollPane  = sp
            sp.isDraggingV      = true
            sp.dragStartY       = contentY
            sp.dragStartScrollY = sp.scrollY
          } else if let track = sp.vScrollbarRect(), track.contains(contentX, contentY) {
            sp.scrollY          = max(0, min(maxY, (contentY - track.y) * maxY / max(1, track.height)))
            draggingScrollPane  = sp
            sp.isDraggingV      = true
            sp.dragStartY       = contentY
            sp.dragStartScrollY = sp.scrollY
          } else if let thumb = sp.hThumbRect(), thumb.contains(contentX, contentY) {
            draggingScrollPane  = sp
            sp.isDraggingH      = true
            sp.dragStartX       = contentX
            sp.dragStartScrollX = sp.scrollX
          } else if let track = sp.hScrollbarRect(), track.contains(contentX, contentY) {
            sp.scrollX          = max(0, min(maxX, (contentX - track.x) * maxX / max(1, track.width)))
            draggingScrollPane  = sp
            sp.isDraggingH      = true
            sp.dragStartX       = contentX
            sp.dragStartScrollX = sp.scrollX
          }
          repaint(awtWindow, xwin: xwin)

        } else if let btn = hit as? java.awt.Button {
          // Set pressed state for visual feedback; dispatch on ButtonRelease (AWT convention)
          btn.isPressed = true
          pressedButton       = btn
          pressedButtonWindow = awtWindow
          repaint(awtWindow, xwin: xwin)
        } else {
          _AWTHitTest.dispatch(click: hit ?? awtWindow)
        }
      }

    case X11_ButtonRelease:
      if let sb = draggingScrollbar  { sb.isDragging  = false }
      if let sp = draggingScrollPane { sp.isDraggingV = false; sp.isDraggingH = false }
      draggingScrollbar  = nil
      draggingScrollPane = nil
      // Fire button action on release (correct AWT behaviour) and clear pressed state
      if let btn = pressedButton, let win = pressedButtonWindow {
        btn.isPressed       = false
        pressedButton       = nil
        pressedButtonWindow = nil
        repaint(win, xwin: xwin)
        btn.doClick()
      }

    case X11_MotionNotify:
      // XMotionEvent has same layout as XButtonEvent — x at offset 64, y at 68
      let physMX = Int(buf.load(fromByteOffset: 64, as: Int32.self))
      let physMY = Int(buf.load(fromByteOffset: 68, as: Int32.self))
      let mx = Int((Double(physMX) / scaleFactor).rounded())
      let my = Int((Double(physMY) / scaleFactor).rounded())
      let contentMY = menuBarRegistry[xwin] != nil ? my - _X11MenuBar.menuBarHeight : my
      var needsRepaint = false

      // Scrollbar thumb drag
      if let sb = draggingScrollbar {
        let isVert = sb.orientation == java.awt.Scrollbar.VERTICAL
        let coord  = isVert ? contentMY : mx
        let delta  = coord - sb.dragStartCoord
        let track  = isVert ? sb.bounds.height : sb.bounds.width
        let range  = sb.maximum - sb.minimum
        sb.value   = sb.dragStartValue + delta * range / max(1, track)
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: true)
        needsRepaint = true
      }
      // ScrollPane thumb drag
      if let sp = draggingScrollPane {
        let (maxX, maxY) = sp.maxScroll()
        if sp.isDraggingV, let track = sp.vScrollbarRect() {
          let delta  = contentMY - sp.dragStartY
          let range  = track.height
          sp.scrollY = max(0, min(maxY, sp.dragStartScrollY + delta * maxY / max(1, range)))
          needsRepaint = true
        }
        if sp.isDraggingH, let track = sp.hScrollbarRect() {
          let delta  = mx - sp.dragStartX
          let range  = track.width
          sp.scrollX = max(0, min(maxX, sp.dragStartScrollX + delta * maxX / max(1, range)))
          needsRepaint = true
        }
      }
      // Popup hover highlight
      if let popup = _X11PopupWindow.activePopup {
        let newIdx = popup.itemRects.indices.first {
          !popup.itemRects[$0].item.isSeparator && popup.itemRects[$0].rect.contains(mx, my)
        } ?? -1
        if newIdx != popup.highlightedIndex {
          popup.highlightedIndex = newIdx
          needsRepaint = true
        }
      }
      // Menu bar hover highlight — update hoveredMenu and repaint if changed
      if let menuBarHelper = menuBarRegistry[xwin] {
        let newHover: java.awt.Menu? = my < _X11MenuBar.menuBarHeight
          ? menuBarHelper.menu(at: mx, y: my)
          : nil
        if newHover !== menuBarHelper.hoveredMenu {
          menuBarHelper.hoveredMenu = newHover
          needsRepaint = true
        }
      }
      if needsRepaint { repaint(awtWindow, xwin: xwin) }

    case X11_KeyPress:
      // Minimal key handling — full implementation needs XLookupString
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

  /// Public variant called by `_X11PopupWindow` to trigger a repaint.
  @MainActor
  func repaintWindow(_ awtWindow: java.awt.Window) {
    guard let xwin = reverseRegistry[ObjectIdentifier(awtWindow)] else { return }
    repaint(awtWindow, xwin: xwin)
  }

  @MainActor
  private func repaint(_ awtWindow: java.awt.Window, xwin: X11WindowID) {
    guard let dpy = display, let gc = gcRegistry[xwin] else { return }
    let g = java.awt.toolkit.x11._X11Graphics(display: dpy, drawable: xwin, gc: gc,
                                               scaleFactor: scaleFactor)

    // Draw menu bar at top if one is attached to this window
    if let x11mb = menuBarRegistry[xwin] {
      x11mb.draw(using: g, windowWidth: awtWindow.getWidth())
      // Shift origin down so component painting starts below the menu bar
      g.translate(0, _X11MenuBar.menuBarHeight)
    }

    awtWindow.paint(g)

    // Draw popup overlay on top of everything (reset origin first)
    if let popup = _X11PopupWindow.activePopup {
      // Restore translation so popup coords are window-relative
      let savedG = java.awt.toolkit.x11._X11Graphics(display: dpy, drawable: xwin, gc: gc,
                                                      scaleFactor: scaleFactor)
      popup.draw(using: savedG)
    }

    _ = fnFlush?(dpy)
  }
}
#endif
