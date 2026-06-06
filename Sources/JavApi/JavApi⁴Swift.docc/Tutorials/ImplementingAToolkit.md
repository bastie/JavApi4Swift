# Implementing a Custom AWT Toolkit

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

How to port JavApi⁴Swift's AWT to a new platform (Linux desktop, FreeBSD, Windows, …) by implementing a custom `Toolkit`.

## Overview

JavApi⁴Swift ships two toolkit implementations out of the box:

- **`SwiftUIToolkit`** — macOS, iOS, tvOS, visionOS (uses AppKit/UIKit + SwiftUI)
- **`HeadlessToolkit`** — all other platforms (no-op, for headless/server use)

If you want real windowing on Linux (e.g. via GTK, SDL2, Wayland, or X11) or FreeBSD, you need to write a third toolkit. This document explains what you must implement and how to plug it in.

## Architecture

```
java.awt.Frame.setVisible(true)
    └── java.awt.Toolkit.getDefaultToolkit()   ← selects your toolkit
            └── YourToolkit.show(_:)           ← opens a native window
                    └── renders Component.paint(_ g: Graphics)
```

The rendering pipeline is entirely custom — there is no native widget per component. Every `Button`, `TextField`, `Label` etc. draws itself via `paint(_ g: Graphics)` onto a `CGContext` (Apple) or whatever graphics surface you provide.

## Step 1 — Subclass `java.awt.Toolkit`

```swift
import JavApi

@MainActor
public final class MyLinuxToolkit: java.awt.Toolkit {

    public static let shared = MyLinuxToolkit()
    private override init() {}

    // Called when frame.setVisible(true) is invoked
    public override func show(_ window: java.awt.Window) {
        // TODO: open a native window (GTK, SDL2, X11, Wayland, …)
        // and start rendering loop that calls window.paint(graphics)
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
        // CheckboxMenuItem / PopupMenu are subclasses of MenuItem
    }
}
```

## Step 2 — Provide a `Graphics` implementation

`java.awt.Graphics` wraps a `CGContext` on Apple platforms. On other platforms you need to provide your own drawing surface. The cleanest approach is to subclass `Graphics` and override all drawing methods:

```swift
// TODO: replace SkiaContext with your platform's actual graphics context type
public final class MyGraphics: java.awt.Graphics {

    // On non-Apple platforms the CGContext protocol is a local stub in Graphics.swift.
    // You can pass any conforming object; all real drawing happens in the overrides below.
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

## Step 3 — Render loop

Your toolkit must call `component.paint(graphics)` whenever the window needs to be redrawn. A minimal render loop looks like this:

```swift
func startRenderLoop(for awtWindow: java.awt.Window, nativeWindow: MyNativeWindow) {
    // Validate layout first
    awtWindow.validate()

    // Fire WINDOW_OPENED
    // (Window.setVisible already does this via processWindowEvent)

    nativeWindow.onRedraw = { surface in
        let g = MyGraphics(surface: surface)
        // Flip Y so AWT's top-left origin matches native bottom-left origin (if needed)
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
        Task { @MainActor in
            awtWindow.processWindowEvent(
                java.awt.event.WindowEvent(awtWindow,
                    java.awt.event.WindowEvent.WINDOW_CLOSING))
            awtWindow.setVisible(false)
        }
    }
}
```

## Step 4 — Input events

Mouse and keyboard events must be translated from native events into AWT hit-tests and focus management. Use the existing `AWTHitTest` and `AWTFocusManager` utilities:

```swift
// Mouse click at native coordinates (nx, ny) — Y may need flipping
let pt = CGPoint(x: CGFloat(nx), y: CGFloat(windowHeight - ny))  // AWT: Y from top
let hit = AWTHitTest.find(at: pt, in: awtWindow)
AWTFocusManager.shared.requestFocus(hit)
AWTHitTest.dispatch(click: hit)

// Key input
AWTFocusManager.shared.typeCharacter(character)
```

For scrollbars, Choice popups, List selection etc. follow the pattern in
`_AWTNativeCanvas.mouseDown(with:)` in `AWTWindowHost.swift` — that file is
the complete reference implementation for Apple platforms.

## Step 5 — Register your toolkit

Set the `awt.toolkit` system property **before** any AWT code runs:

```swift
// In your app's entry point, before calling frame.setVisible(true):
try? System.setProperty("awt.toolkit", "MyLinuxToolkit")
```

Then add your toolkit name to `Toolkit.getDefaultToolkit()`:

```swift
// In Toolkit.swift, add a case to the switch:
case "MyLinuxToolkit":
    return MyLinuxToolkit.shared
```

Alternatively — and more cleanly — detect your platform via `os.name`:

```swift
case "Linux":
    return MyLinuxToolkit.shared
```

## Checklist

Before shipping your toolkit, verify these are working:

- [ ] `Frame.setVisible(true)` opens a window with the correct size
- [ ] Window resize calls `frame.validate()` and triggers a repaint
- [ ] `Frame.setMinimumSize` / `getMinimumSize` is enforced during resize
- [ ] `Frame.setMenuBar` attaches menus to the native menu bar
- [ ] Mouse click on a `Button` triggers `actionPerformed`
- [ ] Keyboard input reaches the focused `TextField` / `TextArea`
- [ ] `Dialog` (modal and non-modal) blocks / does not block correctly
- [ ] `FileDialog` opens the native file chooser
- [ ] `Window.dispose()` closes the window and fires `WINDOW_CLOSED`
- [ ] `WindowListener` receives `opened`, `closing`, `closed`, `activated`, `deactivated`
- [ ] `PopupMenu.show` appears at the correct screen position
- [ ] `Choice` popup appears and dismisses correctly
- [ ] `List` scrolls and fires `ItemEvent` / `ActionEvent`
- [ ] `Scrollbar` fires `AdjustmentEvent`
- [ ] `Graphics.drawImage` renders a `BufferedImage` correctly

## Reference implementations

| File | What it shows |
|------|--------------|
| `Sources/JavApi/SwiftExtensions/SwiftUI/AWTWindowHost.swift` | Complete Apple implementation — window lifecycle, render loop, input dispatch |
| `Sources/JavApi/awt/HeadlessToolkit.swift` | Minimal no-op toolkit — starting point for a new backend |
| `Sources/JavApi/awt/SwiftUIToolkit.swift` | How `Toolkit` delegates to the platform host |
| `Sources/JavApi/awt/Toolkit.swift` | `getDefaultToolkit()` selection logic and `awt.toolkit` system property |
| `Sources/JavApi/SwiftExtensions/SwiftUI/AWTHitTest.swift` | Component hit-testing — reuse in your input handler |
| `Sources/JavApi/SwiftExtensions/AWTFocusManager.swift` | Keyboard focus and text input — reuse directly |
