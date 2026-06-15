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
private typealias XClearWindowFunc          = @convention(c) (X11DisplayPtr, X11WindowID) -> Int32
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
// XLookupString: translates a key event to a string + keysym
// XKeyEvent* is passed as raw pointer; keysym_return is UnsafeMutablePointer<UInt>?
private typealias XLookupStringFunc         = @convention(c) (UnsafeMutableRawPointer, UnsafeMutablePointer<CChar>?, Int32, UnsafeMutablePointer<UInt>?, UnsafeMutableRawPointer?) -> Int32
// Cursor functions
private typealias XCreateFontCursorFunc     = @convention(c) (X11DisplayPtr, UInt32) -> UInt   // returns Cursor (XID)
private typealias XDefineCursorFunc         = @convention(c) (X11DisplayPtr, X11WindowID, UInt) -> Int32
private typealias XUndefineCursorFunc       = @convention(c) (X11DisplayPtr, X11WindowID) -> Int32
private typealias XFreeCursorFunc           = @convention(c) (X11DisplayPtr, UInt) -> Int32

// X11 event type constants (from X.h)
private let X11_ExposureMask:        CLong = 1 << 15
private let X11_KeyPressMask:        CLong = 1 << 0
private let X11_KeyReleaseMask:      CLong = 1 << 1
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

// XK keysym constants (from keysymdef.h) for special keys
private let XK_BackSpace: UInt = 0xFF08
private let XK_Tab:       UInt = 0xFF09
private let XK_Return:    UInt = 0xFF0D
private let XK_Delete:    UInt = 0xFFFF
private let XK_Left:      UInt = 0xFF51
private let XK_Up:        UInt = 0xFF52
private let XK_Right:     UInt = 0xFF53
private let XK_Down:      UInt = 0xFF54
private let XK_Home:      UInt = 0xFF50
private let XK_End:       UInt = 0xFF57

// X11 modifier mask bits (from X.h)
private let X11_ShiftMask:   UInt32 = 1 << 0
private let X11_ControlMask: UInt32 = 1 << 2

// X Font Cursor shapes (from cursorfont.h)
private let XC_xterm:         UInt32 = 152
private let XC_left_ptr:      UInt32 = 68
private let XC_crosshair:     UInt32 = 34
private let XC_watch:         UInt32 = 150
private let XC_hand2:         UInt32 = 60
private let XC_fleur:         UInt32 = 52   // move
private let XC_top_side:      UInt32 = 138  // N resize
private let XC_bottom_side:   UInt32 = 16   // S resize
private let XC_right_side:    UInt32 = 96   // E resize
private let XC_left_side:     UInt32 = 70   // W resize
private let XC_top_right_corner:    UInt32 = 136  // NE
private let XC_top_left_corner:     UInt32 = 134  // NW
private let XC_bottom_right_corner: UInt32 = 14   // SE
private let XC_bottom_left_corner:  UInt32 = 12   // SW

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
  private var fnClearWindow:       XClearWindowFunc?
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
  private var fnLookupString:      XLookupStringFunc?
  private var fnCreateFontCursor:  XCreateFontCursorFunc?
  private var fnDefineCursor:      XDefineCursorFunc?
  private var fnUndefineCursor:    XUndefineCursorFunc?
  private var fnFreeCursor:        XFreeCursorFunc?

  // Cursor cache: AWT cursor type → X11 Cursor XID
  private var cursorCache: [Int: UInt] = [:]

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

  // Modal dialog bookkeeping — set to true by closeDialog() to break the nested RunLoop
  @MainActor private var modalDoneFlags: [ObjectIdentifier: Bool] = [:]

  // ---------------------------------------------------------------------------
  // MARK: Drag state (mouse-button held)
  // ---------------------------------------------------------------------------

  // Scrollbar being thumb-dragged (cleared on ButtonRelease)
  @MainActor private weak var draggingScrollbar:  java.awt.Scrollbar?
  // ScrollPane whose thumb is being dragged (cleared on ButtonRelease)
  @MainActor private weak var draggingScrollPane: java.awt.ScrollPane?
  // TextComponent being selection-dragged (cleared on ButtonRelease)
  @MainActor private weak var draggingTextComponent: java.awt.TextComponent?
  // List whose scrollbar thumb is being dragged (cleared on ButtonRelease)
  @MainActor private weak var draggingList: java.awt.List?
  // TextArea whose internal scrollbar thumb is being dragged (cleared on ButtonRelease)
  @MainActor private weak var draggingTextAreaScroll: java.awt.TextArea?
  // Currently open Choice — tracked so outside clicks close it
  @MainActor private weak var openChoice: java.awt.Choice?
  // Currently open Swing JMenu — tracked so outside clicks close the popup
  @MainActor private weak var openSwingMenu: javax.swing.JMenu?
  // Button being held down — isPressed set on ButtonPress, doClick() on ButtonRelease
  @MainActor private weak var pressedButton: java.awt.Button?
  @MainActor private weak var pressedButtonWindow: java.awt.Window?
  // Double-click detection: timestamp (ms) and position of last ButtonPress
  @MainActor private var lastClickTime: UInt = 0
  @MainActor private var lastClickX:    Int  = -1
  @MainActor private var lastClickY:    Int  = -1
  private let doubleClickIntervalMs: UInt = 400
  private let doubleClickRadius:     Int  = 4

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
    fnClearWindow        = resolve("XClearWindow",        as: XClearWindowFunc.self)
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
    fnLookupString       = resolve("XLookupString",       as: XLookupStringFunc.self)
    fnCreateFontCursor   = resolve("XCreateFontCursor",   as: XCreateFontCursorFunc.self)
    fnDefineCursor       = resolve("XDefineCursor",       as: XDefineCursorFunc.self)
    fnUndefineCursor     = resolve("XUndefineCursor",     as: XUndefineCursorFunc.self)
    fnFreeCursor         = resolve("XFreeCursor",         as: XFreeCursorFunc.self)
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

    // Register platform FontMetrics factory so FontMetrics.make(for:) returns
    // Xft-backed metrics on Linux/FreeBSD — caret positioning agrees with rendering.
    java.awt.FontMetrics._platformFactory = { [weak self] font in
      guard let dpy = self?.display else { return nil }
      return java.awt.toolkit.x11._X11FontMetrics.make(for: font, display: dpy)
    }

    return true
  }

  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // MARK: Swing menu helpers
  // ---------------------------------------------------------------------------

  /// Walks the AWT tree of `root` and returns the first `JMenuBar` found, or nil.
  @MainActor private func _swingMenuBar(in root: java.awt.Component) -> javax.swing.JMenuBar? {
    if let bar = root as? javax.swing.JMenuBar { return bar }
    if let c = root as? java.awt.Container {
      for child in c.getComponents() {
        if let found = _swingMenuBar(in: child) { return found }
      }
    }
    return nil
  }

  /// Opens `menu`'s popup in the POPUP_LAYER of the JFrame's layered pane.
  @MainActor private func _openSwingMenu(_ menu: javax.swing.JMenu,
                                          bar: javax.swing.JMenuBar,
                                          awtWindow: java.awt.Window,
                                          xwin: X11WindowID) {
    guard let barUI = bar.ui as? javax.swing.plaf.basic.BasicMenuBarUI,
          let entry = barUI.menuRects.first(where: { $0.menu === menu })
    else { return }

    // Walk up to JLayeredPane
    var node: java.awt.Component? = bar
    var layeredPane: javax.swing.JLayeredPane? = nil
    while let n = node {
      if let lp = n as? javax.swing.JLayeredPane { layeredPane = lp; break }
      node = n.parent
    }
    guard let lp = layeredPane else { return }

    menu.setSelected(true)
    openSwingMenu   = menu

    let popup = menu.swingPopupMenu
    let barY  = bar.bounds.y
    let popX  = bar.bounds.x + entry.rect.x
    let popY  = barY + javax.swing.JMenuBar.defaultHeight
    lp.add(popup, layer: javax.swing.JLayeredPane.POPUP_LAYER)
    popup.show(x: popX, y: popY)
    repaint(awtWindow, xwin: xwin)
  }

  /// Closes the currently open Swing popup, if any.
  @MainActor private func _closeOpenSwingMenu(awtWindow: java.awt.Window,
                                               xwin: X11WindowID,
                                               repaintAfter: Bool) {
    guard let menu = openSwingMenu else { return }
    menu.setSelected(false)
    let popup = menu.swingPopupMenu
    popup.parent?.remove(popup)
    popup.closePopup()
    openSwingMenu = nil
    if repaintAfter { repaint(awtWindow, xwin: xwin) }
  }

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
    // JFrame is a Swing window — it draws its own JMenuBar via JRootPane/JLayeredPane,
    // so we must NOT register an _X11MenuBar for it (that would double-draw a menu bar
    // and incorrectly shrink the AWT bounds that JFrame.doLayout() manages itself).
    if !(awtWindow is javax.swing.JFrame) && !(awtWindow is javax.swing.JDialog),
       let frame = awtWindow as? java.awt.Frame, let mb = frame.getMenuBar() {
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

    // NOTE: X11 modal blocking is not implemented here.
    // openWindow() is called from within a DispatchQueue.main.async block
    // (via btn.doClick → actionPerformed → setVisible → show → openWindow).
    // Spinning RunLoop.main.run(until:) inside an already-running main-queue
    // dispatch block does not drain new async blocks — the nested run loop
    // cannot execute new DispatchQueue.main.async items while the outer
    // async block is still on the stack. This causes a deadlock: the dialog
    // window appears empty and no further mouse/keyboard events are processed.
    //
    // Dialogs therefore open non-modally on X11 for now. The AWT-level
    // modal flag (dialog.isModal()) is preserved and checked by closeDialog().
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

  /// Closes a dialog and releases all associated X11 resources.
  @MainActor
  public func closeDialog(_ dialog: java.awt.Dialog) {
    // Dismiss any open popup menu — it may hold strong refs to Menu/MenuItem
    // objects belonging to this dialog's menu bar.
    if let popup = _X11PopupWindow.activePopup {
      popup.dismiss(repaint: false)
    }

    // Release the _X11MenuBar for this dialog's X window before hide()
    // destroys it. _X11MenuBar holds a strong ref to java.awt.MenuBar and
    // its Menu children.
    let dialogId = ObjectIdentifier(dialog)
    if let xwin = reverseRegistry[dialogId] {
      menuBarRegistry.removeValue(forKey: xwin)
    }

    hide(dialog)
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
      //  72: x_root(int) 76: y_root(int)  80: state(uint)  84: button(uint)
      let physClickX = Int(buf.load(fromByteOffset: 64, as: Int32.self))
      let physClickY = Int(buf.load(fromByteOffset: 68, as: Int32.self))
      let buttonNum  = buf.load(fromByteOffset: 84, as: UInt32.self)
      // Convert physical pixels back to logical coordinates for hit testing
      let clickX = Int((Double(physClickX) / scaleFactor).rounded())
      let clickY = Int((Double(physClickY) / scaleFactor).rounded())
      // XButtonEvent: time field at offset 56 (unsigned long)
      let eventTime = buf.load(fromByteOffset: 56, as: UInt.self)

      // ── Button 3 = right-click → PopupMenu ──────────────────────────────────
      if buttonNum == 3 {
        // contentY for hit-testing (below menu bar); clickX/clickY for popup position
        let contentX = clickX
        let contentY = menuBarRegistry[xwin] != nil
                     ? clickY - _X11MenuBar.menuBarHeight : clickY
        if let hit = _AWTHitTest.find(x: contentX, y: contentY, in: awtWindow),
           let popup = hit.popupMenu {
          // Popup top-left corner = cursor position in window coordinates
          _X11PopupWindow.show(menu: popup,
                               at: clickX, y: clickY,
                               host: self, ownerXwin: xwin,
                               ownerWindow: awtWindow)
        }
        return
      }

      // ── Double-click detection (Button 1) ────────────────────────────────────
      let isDoubleClick: Bool
      let timeDelta = eventTime > lastClickTime ? eventTime - lastClickTime : UInt.max
      let dx = abs(clickX - lastClickX), dy = abs(clickY - lastClickY)
      if buttonNum == 1
          && timeDelta < doubleClickIntervalMs
          && dx <= doubleClickRadius && dy <= doubleClickRadius {
        isDoubleClick = true
      } else {
        isDoubleClick = false
      }
      lastClickTime = eventTime
      lastClickX    = clickX
      lastClickY    = clickY

      // ── Button 4/5 = vertical scroll wheel, 6/7 = horizontal ───────────────
      if buttonNum >= 4 && buttonNum <= 7 {
        let linesY = buttonNum == 4 ? -3 : (buttonNum == 5 ? 3 : 0)
        let linesX = buttonNum == 6 ? -3 : (buttonNum == 7 ? 3 : 0)
        let contentX = clickX
        let contentY = menuBarRegistry[xwin] != nil
                     ? clickY - _X11MenuBar.menuBarHeight : clickY
        if let hit = _AWTHitTest.find(x: contentX, y: contentY, in: awtWindow) {
          // Walk up the parent chain to find the nearest ScrollPane —
          // the hit may land on a child component (e.g. Canvas) inside the pane.
          if let sp = _AWTHitTest.nearestScrollPane(hit) {
            let (maxX, maxY) = sp.maxScroll()
            // Use ~10% of viewport size as scroll step, minimum 20px
            let vp   = sp.getViewportSize()
            let stepY = max(20, vp.height / 10)
            let stepX = max(20, vp.width  / 10)
            sp.setScrollPosition(
              max(0, min(maxX, sp.scrollX + linesX * stepX / 3)),
              max(0, min(maxY, sp.scrollY + linesY * stepY / 3)))
          } else if let ta = hit as? java.awt.TextArea {
            let lineH    = max(1, ta.getFontMetrics(ta.font).getHeight())
            let totalH   = ta.computeLines().count * lineH
            let visibleH = ta.bounds.height - 2 * ta.padY
            ta.scrollOffsetY = max(0, min(max(0, totalH - visibleH),
                                          ta.scrollOffsetY + linesY))
          } else if let sb = hit as? java.awt.Scrollbar {
            let old = sb.value
            sb.value = sb.value + (sb.orientation == java.awt.Scrollbar.VERTICAL
                                    ? linesY : -linesY)
            if sb.value != old {
              sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_INCREMENT)
            }
          } else if let list = hit as? java.awt.List {
            list.scrollOffset = max(0, min(list.maxScrollOffset(),
                                           list.scrollOffset + linesY))
          }
        }
        repaint(awtWindow, xwin: xwin)
        return
      }

      // ── Swing JMenu popup handling (JFrame/JDialog; must come before AWT checks) ──
      if awtWindow is javax.swing.JFrame || awtWindow is javax.swing.JDialog {
        if let menu = openSwingMenu {
          let popup = menu.swingPopupMenu
          let pb    = popup.bounds
          if pb.contains(clickX, clickY) {
            // Click inside open Swing popup → fire item, close
            let localX = clickX - pb.x
            let localY = clickY - pb.y
            if let item = popup.itemAt(x: localX, y: localY) {
              _closeOpenSwingMenu(awtWindow: awtWindow, xwin: xwin, repaintAfter: false)
              item.doClick()
            } else {
              _closeOpenSwingMenu(awtWindow: awtWindow, xwin: xwin, repaintAfter: false)
            }
            repaint(awtWindow, xwin: xwin)
            return
          } else {
            // Click outside popup — close; may fall through to open another menu title
            _closeOpenSwingMenu(awtWindow: awtWindow, xwin: xwin, repaintAfter: false)
          }
        }
        // Check if click is in the JMenuBar
        if let bar = _swingMenuBar(in: awtWindow) {
          let bb = bar.bounds
          if bb.contains(clickX, clickY) {
            if let barUI = bar.ui as? javax.swing.plaf.basic.BasicMenuBarUI,
               let hitMenu = barUI.menu(at: clickX - bb.x, y: clickY - bb.y) {
              if hitMenu.isSelected() {
                _closeOpenSwingMenu(awtWindow: awtWindow, xwin: xwin, repaintAfter: true)
              } else {
                _closeOpenSwingMenu(awtWindow: awtWindow, xwin: xwin, repaintAfter: false)
                _openSwingMenu(hitMenu, bar: bar, awtWindow: awtWindow, xwin: xwin)
              }
            } else {
              _closeOpenSwingMenu(awtWindow: awtWindow, xwin: xwin, repaintAfter: true)
            }
            return
          }
        }
        // Normal Swing content click — hit-test and dispatch via _AWTHitTest
        if let hit = _AWTHitTest.find(x: clickX, y: clickY, in: awtWindow) {
          _X11FocusManager.shared.requestFocus(hit)
          _AWTHitTest.dispatch(click: hit)
          repaint(awtWindow, xwin: xwin)
        }
        return
      }

      // If a popup is open: check click in popup first, dismiss if outside
      if let popup = _X11PopupWindow.activePopup {
        if popup.contains(clickX, clickY) {
          if let (item, _) = popup.item(at: clickX, py: clickY) {
            // Clear menu highlight BEFORE activate() so the dismiss-repaint
            // inside activate() already sees openMenu == nil
            if let x11mb = menuBarRegistry[xwin] { x11mb.openMenu = nil }
            popup.activate(item: item)
          }
        } else {
          // Click outside popup — dismiss
          if let x11mb = menuBarRegistry[xwin] { x11mb.openMenu = nil }
          popup.dismiss()
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

        // ── Choice popup handling (must come before normal hit-test) ──────────
        if let choice = openChoice {
          let pr = choice.popupRect()
          if pr.contains(contentX, contentY) {
            // Click inside popup → select item and close
            if let idx = choice.popupItemIndex(atY: contentY) {
              choice.select(idx)
              choice.fireItemEvent(index: idx)
            }
            choice.isOpen = false
            openChoice    = nil
            repaint(awtWindow, xwin: xwin)
            return
          } else {
            // Click outside popup → close it and consume the event entirely.
            // Do NOT fall through — the click that dismissed the popup should
            // not simultaneously activate whatever is underneath it (matches
            // standard Java AWT / GDI behaviour).
            choice.isOpen = false
            openChoice    = nil
            repaint(awtWindow, xwin: xwin)
            return
          }
        }

        let hit = _AWTHitTest.find(x: contentX, y: contentY, in: awtWindow)
        let prevFocus = _X11FocusManager.shared.focusOwner
        _X11FocusManager.shared.requestFocus(hit)
        // Set caret position on click for TextField/TextArea BEFORE repaint
        var needsTextRepaint = false
        if let ta = hit as? java.awt.TextArea {
          ta.setCaretPosition(ta._charIndex(atX: contentX, atY: contentY))
          draggingTextComponent = ta
          needsTextRepaint = true
        } else if let tf = hit as? java.awt.TextField {
          tf.setCaretPosition(tf._charIndex(at: contentX))
          draggingTextComponent = tf
          needsTextRepaint = true
        }
        // Repaint on focus change OR on any TextComponent click (collapses selection)
        if prevFocus !== hit || needsTextRepaint { repaint(awtWindow, xwin: xwin) }

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

        // --- Choice ---
        } else if let ch = hit as? java.awt.Choice {
          ch.isOpen  = !ch.isOpen
          openChoice = ch.isOpen ? ch : nil
          repaint(awtWindow, xwin: xwin)

        // --- List ---
        } else if let list = hit as? java.awt.List {
          if let thumb = list.scrollbarThumbRect(), thumb.contains(contentX, contentY) {
            draggingList             = list
            list.isScrollbarDragging = true
            list.scrollDragStartY    = contentY
            list.scrollDragStartOff  = list.scrollOffset
          } else if let track = list.scrollbarTrackRect(), track.contains(contentX, contentY) {
            let maxOff = list.maxScrollOffset()
            list.scrollOffset        = max(0, min(maxOff, (contentY - track.y) * maxOff / max(1, track.height)))
            draggingList             = list
            list.isScrollbarDragging = true
            list.scrollDragStartY    = contentY
            list.scrollDragStartOff  = list.scrollOffset
          } else {
            if let idx = list.itemIndex(atY: contentY) {
              list.select(idx)
              list.fireItemEvent(index: idx,
                                 stateChange: java.awt.event.ItemEvent.SELECTED)
            }
          }
          repaint(awtWindow, xwin: xwin)

        // --- TextArea internal scrollbar ---
        } else if let ta = hit as? java.awt.TextArea,
                  let thumb = ta.verticalScrollbarThumbRect(),
                  thumb.contains(contentX, contentY) {
          draggingTextAreaScroll  = ta
          ta.isScrollbarDragging  = true
          ta.scrollDragStartY     = contentY
          ta.scrollDragStartOff   = ta.scrollOffsetY

        } else if let btn = hit as? java.awt.Button {
          // Set pressed state for visual feedback; dispatch on ButtonRelease (AWT convention)
          btn.isPressed = true
          pressedButton       = btn
          pressedButtonWindow = awtWindow
          repaint(awtWindow, xwin: xwin)
        } else if isDoubleClick, let list = hit as? java.awt.List {
          // Double-click on List fires actionPerformed (same as GDI onDoubleClick)
          if let idx = list.itemIndex(atY: contentY) {
            list.fireActionEvent(index: idx)
          }
        } else {
          _AWTHitTest.dispatch(click: hit ?? awtWindow)
        }
      }

    case X11_ButtonRelease:
      if let sb = draggingScrollbar        { sb.isDragging         = false }
      if let sp = draggingScrollPane       { sp.isDraggingV = false; sp.isDraggingH = false }
      if let list = draggingList           { list.isScrollbarDragging = false }
      if let ta = draggingTextAreaScroll   { ta.isScrollbarDragging   = false }
      draggingScrollbar      = nil
      draggingScrollPane     = nil
      draggingList           = nil
      draggingTextAreaScroll = nil
      draggingTextComponent  = nil
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
      // List scrollbar thumb drag
      if let list = draggingList {
        guard list.needsScrollbar() else { break }
        let maxOff = list.maxScrollOffset()
        let dy     = contentMY - list.scrollDragStartY
        list.scrollOffset = max(0, min(maxOff,
          list.scrollDragStartOff + dy * maxOff / max(1, list.bounds.height)))
        needsRepaint = true
      }
      // TextArea internal scrollbar thumb drag
      if let ta = draggingTextAreaScroll {
        let fm       = ta.getFontMetrics(ta.font)
        let lineH    = max(1, fm.getHeight())
        let totalH   = ta.computeLines().count * lineH
        let visibleH = ta.bounds.height - 2 * ta.padY
        guard totalH > visibleH else { break }
        let dy     = contentMY - ta.scrollDragStartY
        let newOff = ta.scrollDragStartOff + dy * totalH / max(1, ta.bounds.height)
        ta.scrollOffsetY = max(0, min(totalH - visibleH, newOff))
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
      // ── Swing JFrame/JDialog hover handling ─────────────────────────────────
      if awtWindow is javax.swing.JFrame || awtWindow is javax.swing.JDialog {
        // Switch open menu when hovering over a different menu title
        if openSwingMenu != nil,
           let bar = _swingMenuBar(in: awtWindow) {
          let bb = bar.bounds
          if bb.contains(mx, my),
             let barUI = bar.ui as? javax.swing.plaf.basic.BasicMenuBarUI,
             let hitMenu = barUI.menu(at: mx - bb.x, y: my - bb.y),
             hitMenu !== openSwingMenu {
            _closeOpenSwingMenu(awtWindow: awtWindow, xwin: xwin, repaintAfter: false)
            _openSwingMenu(hitMenu, bar: bar, awtWindow: awtWindow, xwin: xwin)
            needsRepaint = false   // _openSwingMenu calls repaint() already
          }
        }
        // Hover-highlight (armed) inside an open Swing popup
        if let menu = openSwingMenu {
          let popup = menu.swingPopupMenu
          let pb    = popup.bounds
          if pb.contains(mx, my),
             let popupUI = popup.ui as? javax.swing.plaf.basic.BasicPopupMenuUI {
            let localX = mx - pb.x
            let localY = my - pb.y
            if popupUI.updateArmed(at: localX, y: localY) { needsRepaint = true }
          } else if !pb.contains(mx, my) {
            // Cursor left popup — clear armed state; check if moved to another title
            if let popupUI = popup.ui as? javax.swing.plaf.basic.BasicPopupMenuUI {
              if popupUI.updateArmed(at: -1, y: -1) { needsRepaint = true }
            }
            if let bar = _swingMenuBar(in: awtWindow) {
              let bb = bar.bounds
              if bb.contains(mx, my),
                 let barUI = bar.ui as? javax.swing.plaf.basic.BasicMenuBarUI,
                 let hitMenu = barUI.menu(at: mx - bb.x, y: my - bb.y),
                 hitMenu !== openSwingMenu {
                _closeOpenSwingMenu(awtWindow: awtWindow, xwin: xwin, repaintAfter: false)
                _openSwingMenu(hitMenu, bar: bar, awtWindow: awtWindow, xwin: xwin)
                needsRepaint = false
              }
            }
          }
        }
        if needsRepaint { repaint(awtWindow, xwin: xwin) }
        break
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
      // Menu bar hover highlight — update hoveredMenu and repaint if changed.
      // If another menu is already open and the pointer moves over a different
      // menu title, switch immediately (standard menu-bar hot-tracking behaviour).
      if let menuBarHelper = menuBarRegistry[xwin] {
        let newHover: java.awt.Menu? = my < _X11MenuBar.menuBarHeight
          ? menuBarHelper.menu(at: mx, y: my)
          : nil
        if newHover !== menuBarHelper.hoveredMenu {
          menuBarHelper.hoveredMenu = newHover
          needsRepaint = true
        }
        // Hot-track: if a menu is open and pointer moves to another menu title, switch
        if let open = menuBarHelper.openMenu,
           let hovered = newHover,
           hovered !== open {
          // Close old popup, open new one
          _X11PopupWindow.activePopup?.dismiss(repaint: false)
          menuBarHelper.openMenu = hovered
          if let rect = menuBarHelper.menuRects.first(where: { $0.menu === hovered })?.rect {
            _X11PopupWindow.show(menu: hovered,
                                 at: rect.x, y: _X11MenuBar.menuBarHeight,
                                 host: self, ownerXwin: xwin,
                                 ownerWindow: awtWindow)
          }
          needsRepaint = true
        }
      }
      // Text selection drag
      if let tc = draggingTextComponent {
        if let ta = tc as? java.awt.TextArea {
          ta.extendSelection(to: ta._charIndex(atX: mx, atY: contentMY))
        } else if let tf = tc as? java.awt.TextField {
          tf.extendSelection(to: tf._charIndex(at: mx))
        }
        needsRepaint = true
      }
      // Update cursor based on component under pointer
      let hitForCursor = _AWTHitTest.find(x: mx, y: contentMY, in: awtWindow)
      updateCursor(for: hitForCursor, xwin: xwin)

      if needsRepaint { repaint(awtWindow, xwin: xwin) }

    case X11_KeyPress:
      // XKeyEvent layout (64-bit Linux, same header as XButtonEvent):
      //  0:type(4) 8:serial(8) 16:send_event(4)[+4pad] 24:display*(8)
      //  32:window(8) 40:root(8) 48:subwindow(8) 56:time(8)
      //  64:x(4) 68:y(4) 72:x_root(4) 76:y_root(4)
      //  80:state(4=modifiers) 84:keycode(4) 88:same_screen(4)
      let state = buf.load(fromByteOffset: 80, as: UInt32.self)
      let isCtrl  = (state & X11_ControlMask) != 0
      let isShift = (state & X11_ShiftMask)   != 0

      // XLookupString fills a char buffer and returns the keysym
      var keysym: UInt = 0
      var charBuf = [CChar](repeating: 0, count: 16)
      let nChars: Int32
      if let fn = fnLookupString {
        nChars = fn(buf, &charBuf, Int32(charBuf.count), &keysym, nil)
      } else {
        nChars = 0
      }

      let fm = _X11FocusManager.shared
      switch keysym {
      case XK_BackSpace:                    fm.handleBackspace();                          repaint(awtWindow, xwin: xwin)
      case XK_Delete:                       fm.handleDelete();                             repaint(awtWindow, xwin: xwin)
      case XK_Return:                       fm.handleEnter();                              repaint(awtWindow, xwin: xwin)
      case XK_Left  where isCtrl:           fm.moveCaretToEnd(end: false, extending: isShift); repaint(awtWindow, xwin: xwin)
      case XK_Left:                         fm.moveCaret(by: -1, extending: isShift);     repaint(awtWindow, xwin: xwin)
      case XK_Right where isCtrl:           fm.moveCaretToEnd(end: true,  extending: isShift); repaint(awtWindow, xwin: xwin)
      case XK_Right:                        fm.moveCaret(by:  1, extending: isShift);     repaint(awtWindow, xwin: xwin)
      case XK_Up:                           fm.moveCaretUp(extending: isShift);           repaint(awtWindow, xwin: xwin)
      case XK_Down:                         fm.moveCaretDown(extending: isShift);         repaint(awtWindow, xwin: xwin)
      case XK_Home:                         fm.moveCaretToEnd(end: false, extending: isShift); repaint(awtWindow, xwin: xwin)
      case XK_End:                          fm.moveCaretToEnd(end: true,  extending: isShift); repaint(awtWindow, xwin: xwin)
      case 0x61 where isCtrl, 0x41 where isCtrl: // Ctrl+A
        fm.selectAll();                                                                    repaint(awtWindow, xwin: xwin)
      case 0x63 where isCtrl, 0x43 where isCtrl: // Ctrl+C
        fm.copySelection()
      case 0x76 where isCtrl, 0x56 where isCtrl: // Ctrl+V
        fm.pasteText();                                                                    repaint(awtWindow, xwin: xwin)
      case 0x78 where isCtrl, 0x58 where isCtrl: // Ctrl+X
        fm.cutSelection();                                                                 repaint(awtWindow, xwin: xwin)
      default:
        // Printable character from XLookupString
        if nChars > 0,
           let scalar = Unicode.Scalar(charBuf[0] > 0 ? UInt32(UInt8(bitPattern: charBuf[0])) : 0),
           scalar.value >= 32 && scalar.value != 127 {
          fm.typeCharacter(Character(scalar))
          repaint(awtWindow, xwin: xwin)
        }
      }

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

  // ---------------------------------------------------------------------------
  // MARK: Cursor
  // ---------------------------------------------------------------------------

  /// Updates the X11 cursor for `xwin` based on the component under `(x, y)`.
  /// Walks up the parent chain for an explicit cursor, infers from component type.
  @MainActor
  private func updateCursor(for component: java.awt.Component?, xwin: X11WindowID) {
    guard let dpy = display,
          let fnDef = fnDefineCursor,
          let fnCreate = fnCreateFontCursor else { return }

    // Walk parent chain for explicit cursor
    var current: java.awt.Component? = component
    var awtType: Int = java.awt.Cursor.DEFAULT_CURSOR
    while let c = current {
      if let t = c.cursor?.type { awtType = t; break }
      current = c.parent
    }
    // Infer from component type if no explicit cursor set
    if awtType == java.awt.Cursor.DEFAULT_CURSOR {
      if component is java.awt.TextField || component is java.awt.TextArea {
        awtType = java.awt.Cursor.TEXT_CURSOR
      }
    }

    // Map AWT cursor type to X font cursor shape
    let xcShape: UInt32
    switch awtType {
    case java.awt.Cursor.TEXT_CURSOR:        xcShape = XC_xterm
    case java.awt.Cursor.CROSSHAIR_CURSOR:   xcShape = XC_crosshair
    case java.awt.Cursor.WAIT_CURSOR:        xcShape = XC_watch
    case java.awt.Cursor.HAND_CURSOR:        xcShape = XC_hand2
    case java.awt.Cursor.MOVE_CURSOR:        xcShape = XC_fleur
    case java.awt.Cursor.N_RESIZE_CURSOR:    xcShape = XC_top_side
    case java.awt.Cursor.S_RESIZE_CURSOR:    xcShape = XC_bottom_side
    case java.awt.Cursor.E_RESIZE_CURSOR:    xcShape = XC_right_side
    case java.awt.Cursor.W_RESIZE_CURSOR:    xcShape = XC_left_side
    case java.awt.Cursor.NE_RESIZE_CURSOR:   xcShape = XC_top_right_corner
    case java.awt.Cursor.NW_RESIZE_CURSOR:   xcShape = XC_top_left_corner
    case java.awt.Cursor.SE_RESIZE_CURSOR:   xcShape = XC_bottom_right_corner
    case java.awt.Cursor.SW_RESIZE_CURSOR:   xcShape = XC_bottom_left_corner
    default:                                  xcShape = XC_left_ptr
    }

    // Get or create X11 cursor (cached per type)
    let xCursor: UInt
    if let cached = cursorCache[awtType] {
      xCursor = cached
    } else {
      let created = fnCreate(dpy, xcShape)
      cursorCache[awtType] = created
      xCursor = created
    }
    _ = fnDef(dpy, xwin, xCursor)
    _ = fnFlush?(dpy)
  }

  /// Public variant called by `_X11PopupWindow` to trigger a repaint.
  @MainActor
  func repaintWindow(_ awtWindow: java.awt.Window) {
    guard let xwin = reverseRegistry[ObjectIdentifier(awtWindow)] else { return }
    repaint(awtWindow, xwin: xwin)
  }

  @MainActor
  private func repaint(_ awtWindow: java.awt.Window, xwin: X11WindowID) {
    guard let dpy = display, let gc = gcRegistry[xwin] else { return }
    // Clear the window before redrawing so stale pixels (e.g. a closed Choice
    // popup that extends below the component bounds) are erased.
    _ = fnClearWindow?(dpy, xwin)
    let g = java.awt.toolkit.x11._X11Graphics(display: dpy, drawable: xwin, gc: gc,
                                               scaleFactor: scaleFactor)

    if awtWindow is javax.swing.JFrame || awtWindow is javax.swing.JDialog {
      // Swing window: JFrame/JDialog.paint() → JRootPane → JLayeredPane → JMenuBar +
      // contentPane + JPopupMenu (in POPUP_LAYER). The JLayeredPane.paintChildren
      // already translates the graphics context to each child's origin, so no
      // manual translate is needed here.
      awtWindow.paint(g)
    } else {
      // AWT window: draw the menu bar at the top (if any), then shift origin down
      // so component painting starts below it.
      if let x11mb = menuBarRegistry[xwin] {
        x11mb.draw(using: g, windowWidth: awtWindow.getWidth())
        g.translate(0, _X11MenuBar.menuBarHeight)
      }

      awtWindow.paint(g)

      // Draw AWT popup overlay on top (reset origin first)
      if let popup = _X11PopupWindow.activePopup {
        let savedG = java.awt.toolkit.x11._X11Graphics(display: dpy, drawable: xwin, gc: gc,
                                                        scaleFactor: scaleFactor)
        popup.draw(using: savedG)
      }
    }

    _ = fnFlush?(dpy)
  }
}
#endif
