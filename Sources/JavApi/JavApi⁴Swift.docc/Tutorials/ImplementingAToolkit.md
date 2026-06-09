# Implementing a Custom AWT Toolkit

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

How to port JavApi⁴Swift's AWT to a new platform (Linux desktop, FreeBSD, Windows, …) by implementing a custom `Toolkit`.

## Overview

JavApi⁴Swift ships two toolkit implementations out of the box:

- **`java.awt.toolkit.swiftui.SwiftUIToolkit`** — macOS, iOS, tvOS, visionOS (uses AppKit/UIKit + SwiftUI)
- **`java.awt.toolkit.HeadlessToolkit`** — all other platforms (no-op, for headless/server use)

If you want real windowing on Linux (e.g. via GTK, SDL2, Wayland, or X11) or FreeBSD, you need to write a third toolkit. This document explains what you must implement and how to plug it in.

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

Create `Sources/JavApi/awt/toolkit/myplatform/package.swift`:

```swift
extension java.awt.toolkit {
    public enum myplatform {}
}
```

## Step 2 — Subclass `java.awt.Toolkit`

Create `Sources/JavApi/awt/toolkit/myplatform/MyPlatformToolkit.swift`:

```swift
import JavApi

extension java.awt.toolkit.myplatform {

    @MainActor
    public final class MyPlatformToolkit: java.awt.Toolkit {

        public static let shared = MyPlatformToolkit()
        private override init() {}

        // Called when frame.setVisible(true) is invoked
        public override func show(_ window: java.awt.Window) {
            // TODO: open a native window (GTK, SDL2, X11, Wayland, …)
            // and start a rendering loop that calls window.paint(graphics)
        }

        // Called when frame.setVisible(false) or frame.dispose()
        public override func hide(_ window: java.awt.Window) {
            // TODO: close / hide the native window
        }

        // Called when frame.setMenuBar(_:) is invoked
        public override func attachMenuBar(_ menuBar: java.awt.MenuBar?,
                                           to frame: java.awt.Frame) {
            // TODO: map java.awt.MenuBar to native menu (GTK GMenu, etc.)
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
            // TODO: query your focus manager
            return false
        }

        // Called by Dialog.dispose()
        public override func closeDialog(_ dialog: java.awt.Dialog) {
            // TODO: close / dismiss the native dialog panel
        }
    }
}
```

## Step 3 — Provide a `Graphics` implementation

`java.awt.Graphics` wraps a `CGContext` on Apple platforms. On other platforms you need to provide your own drawing surface. The cleanest approach is to subclass `Graphics` and override all drawing methods:

```swift
// TODO: replace MySurface with your platform's actual graphics context type
public final class MyGraphics: java.awt.Graphics {

    private let surface: MySurface

    public init(surface: MySurface) {
        self.surface = surface
        // The CGContext parameter is only used by the Apple implementation.
        // Pass a placeholder that satisfies the compiler.
        super.init(MyGraphicsBridge())
    }

    public override func fillRect(_ x: Int, _ y: Int,
                                  _ width: Int, _ height: Int) {
        // TODO: surface.fillRect(...)
    }

    public override func drawLine(_ x1: Int, _ y1: Int,
                                  _ x2: Int, _ y2: Int) {
        // TODO: surface.drawLine(...)
    }

    public override func drawString(_ str: String, _ x: Int, _ y: Int) {
        // TODO: surface.drawText(str, at: x, y, font: font)
    }

    public override func drawImage(_ img: java.awt.Image,
                                   _ x: Int, _ y: Int,
                                   _ observer: java.awt.ImageObserver? = nil) -> Bool {
        guard let bi = img as? java.awt.image.BufferedImage else { return false }
        // TODO: blit bi's pixel data (bi.getRGB(x,y)) onto surface
        return true
    }

    // … override fillOval, drawOval, drawRect, clipRect, translate, save, restore …
}
```

## Step 4 — Render loop

Your toolkit must call `component.paint(graphics)` whenever the window needs to be redrawn. A minimal render loop looks like this:

```swift
func startRenderLoop(for awtWindow: java.awt.Window, nativeWindow: MyNativeWindow) {
    // Validate layout first
    awtWindow.validate()

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
        // if you are already on the main thread (e.g. in a native delegate callback),
        // so that listeners calling terminate() take effect immediately.
        MainActor.assumeIsolated {
            awtWindow.processWindowEvent(
                java.awt.event.WindowEvent(awtWindow,
                    java.awt.event.WindowEvent.WINDOW_CLOSING))
        }
        // Note: do NOT call awtWindow.setVisible(false) here —
        // that is the listener's responsibility (e.g. via dispose()).
        // setVisible(false) fires WINDOW_CLOSED but not WINDOW_CLOSING.
    }
}
```

> **Window close event semantics**
>
> - `WINDOW_CLOSING` is fired in two situations: (a) by your native `onClose` handler above, and (b) by `Window.dispose()` for programmatic closes.
> - `setVisible(false)` fires `WINDOW_DEACTIVATED` and `WINDOW_CLOSED` only — **not** `WINDOW_CLOSING`. This matches Java AWT behaviour.
> - Guard against duplicate `onClose` calls (e.g. `NSApp.terminate` may re-trigger the native close notification). Use a `didFireClosing` boolean flag as shown in `_SwiftUIWindowSizeDelegate`.

## Step 5 — Input events

Mouse and keyboard events must be translated from native events into AWT hit-tests and focus management. Use the existing `_SwiftUIHitTest` and `_SwiftUIFocusManager` utilities as reference:

```swift
// Mouse click at native coordinates (nx, ny) — Y may need flipping
let pt = CGPoint(x: CGFloat(nx), y: CGFloat(windowHeight - ny))  // AWT: Y from top
let hit = _SwiftUIHitTest.find(at: pt, in: awtWindow)
_SwiftUIFocusManager.shared.requestFocus(hit)
_SwiftUIHitTest.dispatch(click: hit)

// Key input
_SwiftUIFocusManager.shared.typeCharacter(character)
```

For scrollbars, Choice popups, List selection etc. follow the pattern in
`_SwiftUIWindowHost+macOS.swift` — that file is the complete reference
implementation for Apple platforms.

## Step 6 — Separator rendering

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

On Apple platforms `NSMenuItem.separator()` handles Dark Mode automatically. On other platforms use the equivalent native separator API or draw a line using the platform's separator colour.

## Step 7 — Register your toolkit

Set the `awt.toolkit` system property **before** any AWT code runs:

```swift
// In your app's entry point, before calling frame.setVisible(true):
try? System.setProperty("awt.toolkit", "MyPlatformToolkit")
```

Then add your toolkit to `Toolkit.getDefaultToolkit()` in `Toolkit.swift`:

```swift
case "MyPlatformToolkit":
    return java.awt.toolkit.myplatform.MyPlatformToolkit.shared
```

Alternatively detect your platform via compile-time conditions:

```swift
#if os(Linux)
    return java.awt.toolkit.myplatform.MyPlatformToolkit.shared
#endif
```

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

## Reference implementations

| File | What it shows |
|------|--------------|
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIWindowHost.swift` + `+macOS.swift` | Complete implementation for Apple platforms — window lifecycle, render loop, input dispatch |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIWindowSizeDelegate.swift` | NSWindowDelegate — size constraints and `WINDOW_CLOSING` dispatch with duplicate guard |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIPopupMenu.swift` | PopupMenu rendering on macOS |
| `Sources/JavApi/awt/toolkit/swiftui/SwiftUIToolkit.swift` | How `Toolkit` delegates to the platform host |
| `Sources/JavApi/awt/toolkit/HeadlessToolkit.swift` | Minimal no-op toolkit — starting point for a new backend |
| `Sources/JavApi/awt/Toolkit.swift` | `getDefaultToolkit()` selection logic and `awt.toolkit` system property |
| `Sources/JavApi/awt/toolkit/swiftui/_SwiftUIComponentView.swift` | Self-drawing component approach (Ansatz A) vs. native SwiftUI elements (Ansatz B) |
