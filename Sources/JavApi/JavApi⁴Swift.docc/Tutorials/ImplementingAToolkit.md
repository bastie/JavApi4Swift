# Implementing a Custom AWT Toolkit

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

How to port JavApi⁴Swift's AWT to a new platform (Linux desktop, FreeBSD, Windows, …) by implementing a custom `Toolkit`.

## Overview

JavApi⁴Swift ships two toolkit implementations out of the box:

- **`java.awt.toolkit.swiftui.SwiftUIToolkit`** — macOS, iOS, tvOS, visionOS (uses AppKit/UIKit + SwiftUI)
- **`java.awt.toolkit.gdi.GDIToolkit`** — Windows (Win32 GDI for rendering, Win32 for windowing/events)
- **`java.awt.toolkit.HeadlessToolkit`** — all other platforms (no-op, for headless/server use)

If you want real windowing on Linux (e.g. via GTK, SDL2, Wayland, or X11), Windows (via GDI/Win32), or FreeBSD, you need to write a third toolkit. This document explains what you must implement and how to plug it in.

## Architecture

```
java.awt.Frame.setVisible(true)
    └── java.awt.Toolkit.getDefaultToolkit()   ← selects your toolkit
            └── YourToolkit.show(_:)           ← opens a native window
                    └── renders Component.paint(_ g: Graphics)
```

The rendering pipeline is entirely custom — there is no native widget per component. Every `Button`, `TextField`, `Label` etc. draws itself via `paint(_ g: Graphics)` onto a `CGContext` (Apple) or whatever graphics surface you provide.

Platform-specific toolkit code lives under `Sources/JavApi/awt/toolkit/`. Each backend is organised as a Swift enum-as-namespace:

```
java.awt.toolkit                   (Sources/JavApi/awt/toolkit/)
├── HeadlessToolkit                (HeadlessToolkit.swift)
└── swiftui                        (swiftui/)
    ├── SwiftUIToolkit             (SwiftUIToolkit.swift)
    ├── _SwiftUIWindowHost         (_SwiftUIWindowHost.swift + +macOS.swift)
    ├── _SwiftUIWindowSizeDelegate (_SwiftUIWindowSizeDelegate.swift)
    ├── _SwiftUIPopupMenu          (_SwiftUIPopupMenu.swift)
    └── …
```

Add your own backend as `java.awt.toolkit.myplatform` following the same pattern.

## Step 1 — Declare your namespace

Create `Sources/JavApi/awt/toolkit/myplatform/java.awt.toolkit.myplatform.swift`:

```swift
#if os(MyPlatform)   // e.g. os(Windows), os(Linux)
extension java.awt.toolkit {
    public enum myplatform {}
}
#endif
```

> **Note:** Wrap all platform-specific toolkit files in `#if os(MyPlatform)` so they compile only on the target.  The SwiftUI toolkit uses `#if canImport(SwiftUI)` for the same reason.

## Step 2 — Subclass `java.awt.Toolkit`

Create `Sources/JavApi/awt/toolkit/myplatform/MyPlatformToolkit.swift`:

```swift
#if os(MyPlatform)
extension java.awt.toolkit.myplatform {

    @MainActor
    public final class MyPlatformToolkit: java.awt.Toolkit {

        public static let shared = MyPlatformToolkit()
        private override init() {}

        // Called when frame.setVisible(true) is invoked.
        // FileDialog manages its own native panel — skip it here
        // (see SwiftUIToolkit for the pattern).
        public override func show(_ window: java.awt.Window) {
            if window is java.awt.FileDialog { return }
            if let dialog = window as? java.awt.Dialog {
                _MyPlatformWindowHost.shared.openDialog(dialog)
                return
            }
            _MyPlatformWindowHost.shared.openWindow(for: window)
        }

        // Called when frame.setVisible(false) or frame.dispose()
        public override func hide(_ window: java.awt.Window) {
            _MyPlatformWindowHost.shared.hide(window)
        }

        // Called when frame.setMenuBar(_:) is invoked
        public override func attachMenuBar(_ menuBar: java.awt.MenuBar?,
                                           to frame: java.awt.Frame) {
            // TODO: map java.awt.MenuBar to native menu
            // MenuBar.getMenus() returns [java.awt.Menu]
            // Menu.getItems() returns [java.awt.MenuItem]
            // item.isSeparator == true → render as native separator
            // CheckboxMenuItem / PopupMenu are subclasses of MenuItem
        }

        // Called by PopupMenu.show()
        public override func showPopupMenu(_ menu: java.awt.PopupMenu,
                                           origin: java.awt.Component,
                                           x: Int, y: Int) {
            // TODO: show a contextual menu at (x, y) relative to origin
        }

        // Called by Component.isFocusOwner
        public override func isFocusOwner(_ component: java.awt.Component) -> Bool {
            return _MyPlatformFocusManager.shared.focusOwner === component
        }

        // Called by Dialog.dispose()
        public override func closeDialog(_ dialog: java.awt.Dialog) {
            _MyPlatformWindowHost.shared.closeDialog(dialog)
        }

        // Screen size — override for accurate values
        public override func getScreenSize() -> java.awt.Dimension {
            // TODO: query native screen metrics
            return java.awt.Dimension(0, 0)
        }

        // Screen DPI — Java AWT convention: 96 dpi baseline on Windows/Linux
        public override func getScreenResolution() -> Int {
            // TODO: query native DPI (e.g. GetDpiForSystem() on Windows)
            return 96
        }

        // Font list — enumerate system fonts
        public override func getFontList() -> [String] {
            // TODO: return system font family names
            return super.getFontList()
        }

        // Color model — modern displays use 32-bit ARGB
        public override func getColorModel() -> java.awt.image.ColorModel {
            return java.awt.image.ColorModel.getRGBdefault()
        }

        // ── Application lifecycle ────────────────────────────────────────────

        /// Java 1.0 entry point — shows frame and starts the event loop.
        public override func run(frame: java.awt.Frame) {
            frame.setVisible(true)
            runEventLoop()
        }

        /// Drains pending EventQueue runnables and enters the native event loop.
        ///
        /// Override this method to spin your platform's event loop.
        /// Always call `java.awt.EventQueue.drainAndMarkRunning()` first so
        /// that any `invokeLater` runnables queued before the loop started are
        /// executed.  This method must **not return** until the application exits.
        public override func runEventLoop() {
            java.awt.EventQueue.drainAndMarkRunning()
            // TODO: spin your native event loop here, e.g.:
            // while myPlatformGetNextEvent(&event) { myPlatformDispatch(event) }
        }

        /// Terminates the application.
        public override func terminate() {
            // TODO: post a quit event to your native loop, e.g.:
            // myPlatformPostQuit()
            exit(0)
        }

        /// Loads a named image from the application bundle.
        public override func loadImage(named name: String) -> java.awt.Image? {
            // TODO: load image via your platform's image API and convert to
            // java.awt.image.BufferedImage(cgImage:) or build pixel data manually.
            return nil
        }
    }
}
#endif
```

> **Screen DPI baselines:** macOS uses 72 dpi as historical baseline (×2 = 144 on Retina); iOS/watchOS use 160 dpi; Windows and Linux conventionally use **96 dpi**. See `SwiftUIToolkit.getScreenResolution()` for the Apple reference implementation.

## Step 3 — Provide a `Graphics` implementation

`java.awt.Graphics` has two internal variants depending on compile-time imports:

- **Platforms with `CoreGraphics`** (`#if canImport(CoreGraphics)` — Apple and Linux with swift-corelibs): backed by a real `CGContext`.
- **Platforms without `CoreGraphics`** (Windows, bare Linux without swift-corelibs): `CGContext` is a **local stub protocol** defined in `Graphics.swift`, and `_StubCGContext` is a concrete no-op struct that conforms to it.  `Graphics.stub` returns a `Graphics(_StubCGContext())` instance for use outside paint cycles.

On a new platform you subclass `Graphics` and override all drawing methods to route to your native surface.  Pass `_StubCGContext()` to `super.init()` — all real drawing happens in your overrides:

```swift
// Replace MySurface with your platform's actual graphics context type
public final class MyGraphics: java.awt.Graphics {

    private let surface: MySurface

    public init(surface: MySurface) {
        self.surface = surface
        // CGContext is the local stub protocol on non-Apple platforms.
        // _StubCGContext() satisfies the compiler; drawing is done in overrides.
        super.init(_StubCGContext())
    }

    public override func fillRect(_ x: Int, _ y: Int,
                                  _ width: Int, _ height: Int) {
        surface.fillRect(x: x, y: y, width: width, height: height)
    }

    public override func drawLine(_ x1: Int, _ y1: Int,
                                  _ x2: Int, _ y2: Int) {
        surface.drawLine(x1: x1, y1: y1, x2: x2, y2: y2)
    }

    public override func drawString(_ str: String, _ x: Int, _ y: Int) {
        surface.drawText(str, at: x, y: y, font: font)
    }

    public override func drawImage(_ img: java.awt.Image,
                                   _ x: Int, _ y: Int,
                                   _ observer: java.awt.ImageObserver? = nil) -> Bool {
        guard let bi = img as? java.awt.image.BufferedImage else { return false }
        // Blit bi's pixel data (bi.getRGB(x,y)) onto surface
        surface.drawPixels(bi, at: x, y: y)
        return true
    }

    // Also override: fillOval, drawOval, drawRect, drawPolygon, fillPolygon,
    //                clipRect, translate, save, restore
    // See Graphics.swift for the full list of open methods.
}
```

> **Complete method list:** `Graphics.swift` declares every `open` method that a subclass may override.  On non-CoreGraphics platforms all of them are already stubs — you only need to override what your surface actually supports.

> **Windows graphics API note (Swift 6.3):** Swift's WinSDK overlay does **not** expose Direct2D (`d2d1.h`) or DirectWrite (`dwrite.h`) as Swift modules — the `explicit module DirectX` in `winsdk_um.modulemap` contains only Direct3D 11/12, DXGI, XAudio, XInput, and DirectInput. For 2D rendering without a C bridging target, use **GDI** via `import WinSDK` (includes `wingdi.h`). Win32 event handling, cursor management, menus, and clipboard are rendering-API-independent — separate your `_Win32WindowHost` (events/windowing) from your `_GDIRenderTarget` (drawing) so you can swap in a D3D11 renderer later without touching the event layer.

### Critical: GDI coordinate system pitfalls

GDI has two coordinate spaces that do **not** automatically stay in sync:

**Logical vs. Device coordinates.** `SetViewportOrgEx` shifts the logical origin so that subsequent drawing calls are offset. However, several GDI functions always work in **device (absolute) coordinates** regardless of the viewport origin:

- `FillRect` — **ignores** `SetViewportOrgEx`. Use `Rectangle` with a null pen instead, which respects the viewport.
- `CreateRectRgn` / `ExtSelectClipRgn` — clip regions are always in device coordinates. After a `translate(dx, dy)`, you must add the current viewport origin when constructing a clip region: query `GetViewportOrgEx` and add `(pt.x, pt.y)` to your `(x, y)` before calling `CreateRectRgn`.

```swift
// Correct clipRect implementation on GDI:
// IntersectClipRect works in *logical* coordinates (after SetViewportOrgEx),
// so no manual coordinate conversion is needed.  It replaces the clip region
// with the intersection of the current clip and the given rectangle.
public override func clipRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
    IntersectClipRect(hdc, INT32(x), INT32(y), INT32(x + w), INT32(y + h))
}
```

> **Do not use `CreateRectRgn` + `ExtSelectClipRgn` for `clipRect`.** `CreateRectRgn` always takes device coordinates, which diverge from logical coordinates after `SetViewportOrgEx` — you would need to query `GetViewportOrgEx` and add the offset manually. `IntersectClipRect` takes logical coordinates and is simpler and correct.

**`translate` must NOT shift the clip region.** Do not call `OffsetClipRgn` inside `translate` — the clip was intentionally set in device coordinates and should stay fixed in screen space. `translate` only moves the viewport origin:

```swift
public override func translate(_ dx: Int, _ dy: Int) {
    var pt = POINT(x: 0, y: 0)
    GetViewportOrgEx(hdc, &pt)
    SetViewportOrgEx(hdc, pt.x + LONG(dx), pt.y + LONG(dy), nil)
    // Do NOT call OffsetClipRgn here — clip stays in device coords
}
```

**`save` / `restore` via `SaveDC` / `RestoreDC`.** `SaveDC` saves the entire GDI state including the viewport origin and clip region. `RestoreDC(hdc, -1)` restores to the most recent saved state. Always bracket `translate` + `clipRect` calls with `save`/`restore` so each component's paint cannot affect siblings.

### ScrollPane paint pattern

`ScrollPane.paint` uses `translate` to scroll the child into view. The correct pattern is to clip first (in screen-absolute terms), then translate, then paint the child:

```swift
g.save()
g.clipRect(x, y, viewportWidth, viewportHeight)   // clip in current (pre-translate) coords
g.translate(x - scrollX, y - scrollY)             // move origin: child (0,0) → screen (x-scrollX, y-scrollY)
child.paint(g)                                     // child paints at its own (0,0)
g.restore()
```

The child's `bounds` must be set with `(0, 0, contentWidth, contentHeight)` — i.e. content-local, not absolute window coordinates — because after the translate the child's (0,0) already maps to the correct screen position.

### FontMetrics on GDI

`java.awt.FontMetrics` has a platform-specific factory (`FontMetrics.make(for:)`) that selects the best available implementation at compile time. On Windows, subclass `FontMetrics` and use GDI text metrics for accurate measurements:

```swift
#if os(Windows)
final class _GDIFontMetrics: java.awt.FontMetrics {
    private let ascent: Int, descent: Int, leading: Int

    override init(_ font: java.awt.Font) {
        var a=0, d=0, l=0
        if let memDC = CreateCompatibleDC(nil),
           let hFont = createHFont(font) {
            let old = SelectObject(memDC, hFont)
            var tm = TEXTMETRICW()
            if GetTextMetricsW(memDC, &tm) {
                a=Int(tm.tmAscent); d=Int(tm.tmDescent); l=Int(tm.tmExternalLeading)
            }
            SelectObject(memDC, old); DeleteObject(hFont); DeleteDC(memDC)
        }
        ascent=a; descent=d; leading=l
        super.init(font)
    }

    override func getAscent()  -> Int { ascent  }
    override func getDescent() -> Int { descent }
    override func getLeading() -> Int { leading }

    override func stringWidth(_ str: String) -> Int {
        guard !str.isEmpty, let memDC = CreateCompatibleDC(nil) else { return 0 }
        defer { DeleteDC(memDC) }
        guard let hFont = createHFont(font) else { return 0 }
        let old = SelectObject(memDC, hFont)
        defer { SelectObject(memDC, old); DeleteObject(hFont) }
        let wide = Array(str.utf16)
        var size = SIZE()
        return GetTextExtentPoint32W(memDC, wide, INT(wide.count), &size) ? Int(size.cx) : 0
    }
}
#endif
```

Register it in `FontMetrics.make(for:)`:

```swift
static func make(for font: java.awt.Font) -> java.awt.FontMetrics {
#if canImport(CoreText)
    return CoreTextFontMetrics(font)
#elseif os(Windows)
    return _GDIFontMetrics(font)
#else
    return FontMetrics(font)   // headless approximation
#endif
}
```

> **Why this matters:** The headless fallback uses a fixed 0.6× ratio for character width. Without a proper GDI implementation, `Label` centering, `TextField` caret positioning, and any layout depending on text measurements will be visibly wrong.

### Scrollbar and ScrollPane arrow buttons

When a user clicks an arrow button on a `Scrollbar` or `ScrollPane`, the correct Java AWT behaviour is to scroll by `unitIncrement` (default 1 for `Scrollbar`, `scrollbarSize` pixels for `ScrollPane`) — not jump to the clicked position. In your mouse-down handler, check the arrow button rects **before** checking the thumb and track:

```swift
// Scrollbar — check arrows first
if let r = sb.decrementButtonRect(), r.contains(x, y) {
    let newVal = sb.getValue() - sb.getUnitIncrement()
    sb.setValue(max(sb.getMinimum(), newVal))
    sb.fireAdjustmentEvent(.UNIT_DECREMENT)
} else if let r = sb.incrementButtonRect(), r.contains(x, y) {
    let newVal = sb.getValue() + sb.getUnitIncrement()
    sb.setValue(min(sb.getMaximum() - sb.getVisibleAmount(), newVal))
    sb.fireAdjustmentEvent(.UNIT_INCREMENT)
} else if let thumb = sb.thumbRect(), thumb.contains(x, y) {
    // start thumb drag …
} else if let track = sb.trackRect(), track.contains(x, y) {
    // block jump …
}

// ScrollPane — same pattern using scrollbarSize as step
let (maxX, maxY) = sp.maxScroll()
if let r = sp.vDecrementButtonRect(), r.contains(x, y) {
    sp.setScrollPosition(sp.scrollX, max(0, sp.scrollY - sp.scrollbarSize))
} else if let r = sp.vIncrementButtonRect(), r.contains(x, y) {
    sp.setScrollPosition(sp.scrollX, min(maxY, sp.scrollY + sp.scrollbarSize))
} // … hDecrement / hIncrement / thumb / track …
```

### Image loading and alpha blending on GDI

Override `Toolkit.loadImage(named:)` to find and decode PNG files. On Windows, SPM does not deploy `.xcassets` resources automatically — search for the file relative to the running executable:

```swift
public override func loadImage(named name: String) -> java.awt.Image? {
    var exePath = [WCHAR](repeating: 0, count: Int(MAX_PATH))
    GetModuleFileNameW(nil, &exePath, DWORD(MAX_PATH))
    let nullIdx  = exePath.firstIndex(of: 0) ?? exePath.endIndex
    let fullPath = String(decoding: exePath[..<nullIdx], as: UTF16.self)
    let exeDir   = String(fullPath[..<(fullPath.lastIndex(of: "\\") ?? fullPath.endIndex)])
    let xcassets = "Assets.xcassets\\AppIcon.appiconset\\\(name).png"
    let candidates = [
        "\(exeDir)\\\(name).png",
        "\(exeDir)\\..\\..\\..\\..\\Sources\\AWTShowcase\\\(xcassets)",
        "Sources\\AWTShowcase\\\(xcassets)",
    ]
    for path in candidates {
        if let img = _PNGLoader.load(path: path) { return img }
    }
    return nil
}
```

`_PNGLoader` is a pure-Swift PNG decoder (no zlib bindings needed) included in `Sources/JavApi/awt/toolkit/gdi/_PNGLoader.swift`.

To render a `BufferedImage` with correct per-pixel alpha, use `AlphaBlend` instead of `StretchBlt`. Load it dynamically to avoid a hard link against `Msimg32.lib`:

```swift
typealias AlphaBlendFn = @convention(c) (
    HDC, INT, INT, INT, INT, HDC, INT, INT, INT, INT, BLENDFUNCTION) -> WindowsBool

var bf = BLENDFUNCTION()
bf.BlendOp = BYTE(AC_SRC_OVER); bf.SourceConstantAlpha = 255
bf.AlphaFormat = BYTE(AC_SRC_ALPHA)   // per-pixel alpha from bitmap

if let hMsimg = LoadLibraryA("Msimg32.dll"),
   let raw = GetProcAddress(hMsimg, "AlphaBlend") {
    let fn = unsafeBitCast(raw, to: AlphaBlendFn.self)
    fn(hdc, INT(dx), INT(dy), INT(dw), INT(dh), memDC, 0, 0, INT(sw), INT(sh), bf)
    FreeLibrary(hMsimg)
}
```

> **Premultiply alpha before blitting.** `AC_SRC_ALPHA` requires premultiplied BGRA pixels. Multiply each colour channel by `alpha/255` before copying into the `DIBSection`. Passing straight-alpha pixels produces incorrect colours (too dark) in semi-transparent regions.

> **`Msimg32.dll` is always present** on Windows XP and later — the `GetProcAddress` fallback to `StretchBlt` will never be reached in practice.

## Step 4 — Window host and render loop

Create a singleton `_MyPlatformWindowHost` that manages native window handles and bridges window lifecycle to AWT.  Model it after `_SwiftUIWindowHost`:

```swift
@MainActor
public final class _MyPlatformWindowHost {
    public static let shared = _MyPlatformWindowHost()
    private init() {}

    private var registry: [ObjectIdentifier: NativeWindowHandle] = [:]

    public func openWindow(for awtWindow: java.awt.Window) {
        awtWindow.validate()   // run all LayoutManagers first
        // TODO: create native window; start render loop (see below)
    }

    public func hide(_ window: java.awt.Window) {
        let id = ObjectIdentifier(window)
        registry[id]?.close()
        registry.removeValue(forKey: id)
    }
}
```

The render loop must call `component.paint(graphics)` on every redraw:

```swift
func startRenderLoop(for awtWindow: java.awt.Window,
                     nativeWindow: MyNativeWindow) {
    // Sync AWT bounds to the actual client area and validate BEFORE showing
    // the window.  On Win32, ShowWindow dispatches WM_SIZE and WM_PAINT
    // synchronously on the calling thread — if validate() has not run yet,
    // the first paint sees stale (or zero) component bounds.
    let clientSize = nativeWindow.clientSize()
    awtWindow.bounds = java.awt.Rectangle(0, 0, clientSize.width, clientSize.height)
    awtWindow.validate()

    nativeWindow.show()   // NOW safe to show — layout is ready

    nativeWindow.onRedraw = { surface in
        let g = MyGraphics(surface: surface)
        awtWindow.paint(g)
    }

    nativeWindow.onResize = { newWidth, newHeight in
        Task { @MainActor in
            awtWindow.bounds = java.awt.Rectangle(0, 0, newWidth, newHeight)
            awtWindow.validate()   // re-runs all LayoutManagers
            nativeWindow.redraw()
        }
    }

    nativeWindow.onClose = {
        // Fire WINDOW_CLOSING synchronously — use MainActor.assumeIsolated
        // if you are already on the main thread, so that listeners calling
        // terminate() take effect immediately.
        MainActor.assumeIsolated {
            awtWindow.processWindowEvent(
                java.awt.event.WindowEvent(awtWindow,
                    java.awt.event.WindowEvent.WINDOW_CLOSING))
        }
        // Do NOT call awtWindow.setVisible(false) here —
        // that is the listener's responsibility (e.g. via dispose()).
        // setVisible(false) fires WINDOW_CLOSED but not WINDOW_CLOSING.
    }
}
```

> **Window close event semantics**
>
> - `WINDOW_CLOSING` fires in two situations: (a) your native `onClose` handler above, and (b) `Window.dispose()` for programmatic closes.
> - `setVisible(false)` fires `WINDOW_DEACTIVATED` and `WINDOW_CLOSED` only — **not** `WINDOW_CLOSING`. This matches Java AWT behaviour.
> - Guard against duplicate `onClose` calls with a `didFireClosing` boolean flag, as shown in `_SwiftUIWindowSizeDelegate.windowWillClose(_:)`.
> - `WINDOW_ACTIVATED` / `WINDOW_DEACTIVATED` are fired when the window gains or loses OS focus (key state). Fire them from your native focus-change callbacks.

### Menu bar and client area

Attaching a native menu bar **reduces the client area** of the window, which invalidates the AWT layout. The sequence that works reliably:

1. Call `AdjustWindowRect` with `bMenu = false` when creating the HWND — do not pre-account for a menu bar.
2. After `SetMenu` + `DrawMenuBar`, recalculate the AWT bounds immediately. On Win32, `SetMenu` does **not** fire `WM_SIZE`, so you cannot rely on the resize handler. Instead:
   - Use `GetSystemMetrics(SM_CYMENU)` to obtain the menu-bar row height.
   - Subtract that value from `awtWindow.bounds.height` directly and call `awtWindow.validate()`.
3. Never call `AdjustWindowRect` with `bMenu = true` if you attach the menu after window creation — it would double-count the menu-bar height.

### Cursor management on Win32

The idiomatic approach uses only `WM_SETCURSOR`:
- Register the window class with `wc.hCursor = nil` so Win32 does not override the cursor.
- Handle `WM_SETCURSOR`: when `LOWORD(lParam) == HTCLIENT`, call `SetCursor(LoadCursorW(...))` and `return 1`.
- Walk the **parent chain** in your hit-test to find an explicit cursor — a component may inherit its cursor from an ancestor.
- Implicit cursors: `TextComponent` subclasses default to `IDC_IBEAM` even without an explicit `setCursor` call.
- `WM_MOUSEMOVE`: call `SetCursor` and then **`return DefWindowProcW(...)`** — returning 0 suppresses mouse-tracking messages and prevents `WM_SETCURSOR` from being generated by the default handler.

## Step 5 — Modal dialogs

Modal dialogs need a nested event / message loop that blocks the calling thread until the dialog is dismissed.  The AWT `Dialog.isModal()` property controls this.

On macOS, `NSApp.runModal(for:)` provides this loop.  On Win32, you spin your own:

```swift
// Win32 modal loop example
func runModalLoop(until flag: UnsafeMutablePointer<Bool>) {
    var msg = MSG()
    while !flag.pointee {
        if GetMessageW(&msg, nil, 0, 0) > 0 {
            TranslateMessage(&msg)
            DispatchMessageW(&msg)
        }
    }
}
```

The `openDialog` method should:
1. Create the native panel/window (same as a regular window).
2. If `dialog.isModal()`: run the nested loop until a `closeDialog` call sets an exit flag.
3. `closeDialog(_:)` sets the flag, destroys the panel, and calls `hide(_:)`.

> **Note:** `Toolkit.closeDialog(_:)` is the dedicated entry point — it is called by `Dialog.dispose()`. The base implementation falls back to `hide(_:)`; override it for proper modal teardown.

## Step 6 — Input events

Hit-testing is a **platform-independent** utility that can be used directly from any backend:

- `_AWTHitTest.find(x:y:in:)` — recursively finds the deepest visible component at a point in AWT coordinates (Y from top). Lives in `toolkit/_AWTHitTest.swift`; no CoreGraphics or SwiftUI dependency.
- `_AWTHitTest.dispatch(click:)` — dispatches a click to the hit component (Button, Checkbox, TextField, …).

**Focus management is platform-specific.** Each backend provides its own focus manager with identical text-input logic but a platform-native clipboard implementation:

| Backend | Focus manager class | Clipboard API |
|---------|--------------------|--------------------|
| Apple (SwiftUI) | `_SwiftUIFocusManager` | `NSPasteboard` / `UIPasteboard` |
| Windows (GDI) | `_Win32FocusManager` | `OpenClipboard` / `SetClipboardData` |
| New platform | `_MyPlatformFocusManager` | platform clipboard API |

For your new backend, copy `_Win32FocusManager.swift` as a starting point — the text-input methods are identical across all backends, only the clipboard section needs replacing.

Translate your native events into AWT coordinates, then call these utilities:

```swift
// Mouse click at native coordinates (nx, ny)
// Win32 / Linux: Y is already from top — no flip needed (same as AWT)
// NSEvent on non-flipped NSView: flip with  y = windowHeight - ny
let hit = _AWTHitTest.find(x: nx, y: ny, in: awtWindow)
_MyPlatformFocusManager.shared.requestFocus(hit)
_AWTHitTest.dispatch(click: hit ?? awtWindow)

// Key input — printable characters
_MyPlatformFocusManager.shared.typeCharacter(character)

// Special keys
_MyPlatformFocusManager.shared.handleBackspace()
_MyPlatformFocusManager.shared.handleDelete()
_MyPlatformFocusManager.shared.handleEnter()
_MyPlatformFocusManager.shared.moveCaret(by: 1, extending: false)  // Right arrow
_MyPlatformFocusManager.shared.moveCaretUp(extending: false)
_MyPlatformFocusManager.shared.moveCaretToEnd(end: true, extending: false)

// Clipboard (Ctrl+C / Ctrl+V / Ctrl+X on Windows/Linux — Cmd on macOS)
_MyPlatformFocusManager.shared.copySelection()
_MyPlatformFocusManager.shared.pasteText()
_MyPlatformFocusManager.shared.cutSelection()
```

> **ScrollPane coordinate translation:** `_AWTHitTest.find(x:y:in:)` already handles `ScrollPane` by translating the hit-point into the child's scrolled coordinate space. No extra work is needed in your input handler.

> **CGPoint convenience:** The SwiftUI backend provides `_SwiftUIHitTest` as a thin CGPoint wrapper around `_AWTHitTest`. Use it when you already hold a `CGPoint`; otherwise call `_AWTHitTest` directly.

For scrollbars, Choice popups, List selection, and TextArea scrolling, see `_SwiftUINativeCanvas` — it is the complete reference for translating mouse drag and scroll-wheel events into AWT component operations.

## Step 7 — Separator rendering

`MenuItem.isSeparator` is `true` for separator items created via `Menu.addSeparator()`. Use it to render a native divider line instead of a menu label:

```swift
for item in menu.getItems() {
    if item.isSeparator {
        // render native separator — should be Dark Mode aware
    } else {
        // render normal item
    }
}
```

On Apple platforms `NSMenuItem.separator()` handles Dark Mode automatically. On Win32 use `AppendMenuW(hMenu, MF_SEPARATOR, 0, nil)`. On GTK use `gtk_separator_menu_item_new()`.

## Step 8 — FileDialog

`SwiftUIToolkit.show(_:)` has an explicit early return for `java.awt.FileDialog` — the dialog manages its own native panel in `setVisible`. Your toolkit must do the same:

```swift
public override func show(_ window: java.awt.Window) {
    if window is java.awt.FileDialog { return }   // self-managed
    // … rest of show logic
}
```

Implement the actual native file chooser inside `java.awt.FileDialog.setVisible(_:)` using a platform extension (e.g. `extension java.awt.FileDialog { … }` under `#if os(Windows)`), following the same pattern as the macOS implementation.  On Win32 use `IFileOpenDialog` / `IFileSaveDialog` (preferred) or the legacy `GetOpenFileNameW`.

## Step 9 — Register your toolkit and write the entry point

Add your toolkit to `Toolkit.getDefaultToolkit()` in `Toolkit.swift`:

```swift
case "MyPlatform":
#if os(MyPlatform)
    return java.awt.toolkit.myplatform.MyPlatformToolkit.shared
#else
    return java.awt.toolkit.HeadlessToolkit()
#endif
```

The supported property values are `"Headless"`, `"SwiftUI"`, `"GDI"`, and your new `"MyPlatform"`.

Your application's entry point should follow the **Java 1.1** style using `EventQueue.invokeLater` — no platform-specific imports needed:

```swift
@main
struct MyApp {
    @MainActor
    static func main() {
        java.awt.EventQueue.invokeLater {
            let f = java.awt.Frame("My App")
            f.setSize(640, 480)
            f.setVisible(true)
        }
        java.awt.Toolkit.getDefaultToolkit().runEventLoop()
    }
}
```

`runEventLoop()` drains all queued `invokeLater` runnables (opening windows) and then enters the native event loop. It does **not** return until the application exits.

For the **Java 1.0** style (frame passed directly) use:

```swift
java.awt.Toolkit.getDefaultToolkit().run(frame: myFrame)
```

This calls `frame.setVisible(true)` and `runEventLoop()` in one step.

## Checklist

Before shipping your toolkit, verify these are working:

- [ ] `Frame.setVisible(true)` opens a window with the correct size
- [ ] Window resize calls `frame.validate()` and triggers a repaint
- [ ] `Frame.setMinimumSize` / `getMinimumSize` is enforced during resize
- [ ] `Frame.setMenuBar` attaches menus to the native menu bar
- [ ] Separator items (`item.isSeparator == true`) render as native divider lines
- [ ] Mouse click on a `Button` triggers `actionPerformed`
- [ ] Keyboard input reaches the focused `TextField` / `TextArea`
- [ ] `Dialog` (modal and non-modal) blocks / does not block correctly
- [ ] `FileDialog` opens the native file chooser
- [ ] `Window.dispose()` fires `WINDOW_CLOSING` then `WINDOW_CLOSED`
- [ ] Native close button fires `WINDOW_CLOSING` exactly once
- [ ] `WindowListener` receives `opened`, `closing`, `closed`, `activated`, `deactivated`
- [ ] `PopupMenu.show` appears at the correct screen position
- [ ] `Choice` popup appears and dismisses correctly
- [ ] `List` scrolls and fires `ItemEvent` / `ActionEvent`
- [ ] `Scrollbar` fires `AdjustmentEvent`
- [ ] `Graphics.drawImage` renders a `BufferedImage` correctly
- [ ] Clipboard copy/paste works in `TextField` and `TextArea`
- [ ] `ScrollPane` child is clipped to viewport and scrolls correctly (clip before translate)
- [ ] `Graphics.fillRect` respects `translate` — do not use `FillRect` on GDI (ignores viewport origin); use `Rectangle` with a null pen
- [ ] `Graphics.clipRect` converts logical to device coordinates by adding the current viewport origin
- [ ] AWT bounds are set and `validate()` is called **before** `ShowWindow` / the first native show call
- [ ] Attaching a menu bar after window creation subtracts `SM_CYMENU` from client height and calls `validate()` — does not rely on `WM_SIZE`
- [ ] Cursor changes when `Component.setCursor` is called; parent-chain walk finds inherited cursors
- [ ] `WM_MOUSEMOVE` returns `DefWindowProcW` (not 0) so mouse-tracking and `WM_SETCURSOR` remain active
- [ ] Dialog close button fires `WINDOW_CLOSING` without terminating the application (`PostQuitMessage` only for non-dialog windows)
- [ ] `EventQueue.invokeLater` runnable executes after `runEventLoop()` is called
- [ ] `runEventLoop()` calls `EventQueue.drainAndMarkRunning()` before entering the native loop
- [ ] `Toolkit.terminate()` causes `runEventLoop()` to return
- [ ] `Toolkit.loadImage(named:)` returns a valid `BufferedImage` for bundled assets
- [ ] `Graphics.drawImage` renders transparency correctly (premultiplied BGRA + `AlphaBlend`, not `StretchBlt`)
- [ ] `FontMetrics` uses native text measurements (`GetTextMetricsW` / `GetTextExtentPoint32W`), not the fixed 0.6× fallback — required for correct `Label` centering and caret positioning
- [ ] `Scrollbar` arrow buttons scroll by `unitIncrement`, not to the clicked position
- [ ] `ScrollPane` arrow buttons scroll by `scrollbarSize` pixels, not to the clicked position
- [ ] Arrow button hit-tests are checked **before** thumb and track in the mouse-down handler

## Reference implementations

| File | What it shows |
|------|--------------|
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIWindowHost.swift` + `+macOS.swift` | Complete implementation for Apple platforms — window lifecycle, render loop, input dispatch, menu bar, dialogs |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIWindowSizeDelegate.swift` | NSWindowDelegate — size constraints, `WINDOW_CLOSING` dispatch with `didFireClosing` duplicate guard, `WINDOW_ACTIVATED` / `WINDOW_DEACTIVATED` |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUINativeCanvas.swift` | Full mouse, keyboard, scroll-wheel, cursor, and right-click handling for macOS and iOS |
| `Sources/JavApi/awt/toolkit/_AWTHitTest.swift` | Platform-independent AWT hit-test and click-dispatch — no CoreGraphics dependency, usable from any backend |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIHitTest.swift` | Thin CGPoint wrapper around `_AWTHitTest` for SwiftUI/CoreGraphics callers |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIFocusManager.swift` | Platform-independent keyboard focus and text-input routing (clipboard section needs platform adaptation) |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIPopupMenu.swift` | PopupMenu rendering on macOS |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIMenuItemTarget.swift` | Objective-C action target bridging `NSMenuItem` → `java.awt.MenuItem.doAction()` |
| `Sources/JavApi/awt/toolkit/swiftui/SwiftUIToolkit.swift` | How `Toolkit` delegates to the platform host; FileDialog early-return pattern; screen size/DPI/font/color-model overrides |
| `Sources/JavApi/awt/toolkit/gdi/GDIToolkit.swift` | Windows GDI toolkit — screen metrics, font enumeration via `EnumFontFamiliesExW`, event loop |
| `Sources/JavApi/awt/toolkit/gdi/_Win32WindowHost.swift` | Win32 window lifecycle, WndProc, mouse/keyboard/scroll events, menu bar, popup menus — independent of rendering API |
| `Sources/JavApi/awt/toolkit/gdi/_Win32FocusManager.swift` | Keyboard focus + text routing with Win32 clipboard (`OpenClipboard`/`SetClipboardData`/`GetClipboardData`) |
| `Sources/JavApi/awt/toolkit/gdi/_GDIRenderTarget.swift` | GDI-backed `Graphics` subclass — `HDC`-based rendering, `SaveDC`/`RestoreDC` for save/restore, `CreateDIBSection` for image blitting |
| `Sources/JavApi/awt/toolkit/HeadlessToolkit.swift` | Minimal no-op toolkit — starting point for a new backend |
| `Sources/JavApi/awt/Toolkit.swift` | `getDefaultToolkit()` selection logic, `awt.toolkit` system property, `run(frame:)` / `runEventLoop()` base implementation |
| `Sources/JavApi/awt/EventQueue.swift` | `invokeLater`, `invokeAndWait`, `isDispatchThread`, pending-runnable queue drained by `runEventLoop()` |
| `Sources/JavApi/awt/Graphics.swift` | `#if canImport(CoreGraphics)` split — real `CGContext` vs. stub protocol + `_StubCGContext`; full list of `open` methods to override |
| `Sources/JavApi/awt/Window.swift` | `setVisible(_:)` event sequence; `dispose()` → `WINDOW_CLOSING` + `setVisible(false)` |
| `Sources/JavApi/awt/Frame.swift` | `setMenuBar(_:)` → `Toolkit.attachMenuBar(_:to:)` call chain |
