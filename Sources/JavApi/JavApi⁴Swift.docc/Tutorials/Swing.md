# Building UIs with javax.swing

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Create modern, lightweight GUIs with Swing — Java's pluggable Look & Feel toolkit.

## Overview

Swing (`javax.swing`) is Java's second-generation GUI framework, introduced with
JDK 1.2 as part of the Java Foundation Classes (JFC 1.0).  Unlike AWT, Swing
components are *lightweight*: they paint themselves entirely via `Graphics2D` rather
than delegating to native OS widgets.  The visual appearance is controlled by a
pluggable **Look & Feel** (L&F).

JavApi⁴Swift implements Swing on top of the same `Graphics2D` / CoreGraphics stack
used by AWT, with `BasicLookAndFeel` as the default L&F that produces a clean,
cross-platform appearance.

> **Note:** Swing builds on AWT.  If you are new to JavApi⁴Swift, read
> <doc:AWT> first — concepts like `Graphics`, layout managers, and event listeners
> are not repeated here.

## Swing vs. AWT — key differences

| | AWT | Swing |
|---|---|---|
| Component rendering | Native OS widget (peer) | Self-drawn via `Graphics2D` |
| Package | `java.awt` | `javax.swing` |
| Top-level window | `Frame` | `JFrame` |
| Panel | `Panel` | `JPanel` |
| Look & Feel | Fixed (OS-native) | Pluggable |
| Component prefix | none (`Button`) | `J` (`JButton`) |

## Look & Feel architecture

Every Swing component delegates painting and input handling to a **UI delegate**
(`ComponentUI` subclass).  The active Look & Feel is a factory that supplies the
correct delegate for each component type:

```
LookAndFeel.getDefaults()
  └── "MenuBarUI"   → BasicMenuBarUI    ← paints JMenuBar
  └── "PopupMenuUI" → BasicPopupMenuUI  ← paints JPopupMenu
  └── …
```

The active L&F is managed by `UIManager`:

```swift
// Query the active L&F
let laf = UIManager.getLookAndFeel()
print(laf.getName())   // "Basic"

// Install a different L&F (must call updateUI on all components afterwards)
UIManager.setLookAndFeel(MyCustomLookAndFeel())
```

JavApi⁴Swift ships one built-in L&F: **`BasicLookAndFeel`** (package
`javax.swing.plaf.basic`).  It is selected automatically.

## JFrame — the Swing top-level window

`JFrame` extends `java.awt.Frame` and adds Swing's **root pane** architecture.
The internal hierarchy is:

```
JFrame
  └── JRootPane
        ├── JLayeredPane
        │     ├── contentPane  (FRAME_CONTENT_LAYER, -30000)
        │     ├── JMenuBar     (FRAME_CONTENT_LAYER, -30000)
        │     └── JPopupMenu   (POPUP_LAYER, 300)  ← added at runtime
        └── glassPane (invisible overlay)
```

Always add components to the *content pane*, not directly to the frame:

```swift
let frame = javax.swing.JFrame("My App")
frame.setSize(640, 480)
frame.setDefaultCloseOperation(javax.swing.JFrame.EXIT_ON_CLOSE)

// Access the content pane
let content = frame.getContentPane()
// content.add(myPanel)    // coming soon: JPanel, JLabel, etc.

frame.setVisible(true)
```

### doLayout and the root pane chain

When the frame is resized, `JFrame.doLayout()` sets the root pane's bounds to
fill the window, then calls `rootPane.validate()`. `JRootPane.doLayout()` then
distributes that space between the menu bar (if any), the layered pane, and the
content pane:

```
JFrame.doLayout()
  └── rootPane.bounds = (0, 0, w, h)
        └── JRootPane.doLayout()
              ├── layeredPane.bounds = (0, 0, w, h)
              ├── glassPane.bounds   = (0, 0, w, h)
              ├── menuBar.bounds     = (0, 0, w, barH)   // if present
              └── contentPane.bounds = (0, barH, w, h-barH)
```

Both `JFrame` and `JRootPane` call `setLayout(nil)` to prevent the default
`FlowLayout` from overwriting the computed bounds during `validate()`.

## JMenuBar, JMenu, and JMenuItem

A `JMenuBar` is a horizontal strip of `JMenu` titles.  Clicking a title opens a
`JPopupMenu` drop-down showing the menu's `JMenuItem` entries.

```swift
let menuBar = javax.swing.JMenuBar()

// File menu
let fileMenu = javax.swing.JMenu("File")
fileMenu.add(javax.swing.JMenuItem("Open…")).addActionListener { _ in
    print("File > Open…")
}
fileMenu.add(javax.swing.JMenuItem("Save…")).addActionListener { _ in
    print("File > Save…")
}
fileMenu.addSeparator()
let quitItem = javax.swing.JMenuItem("Quit")
quitItem.addActionListener { _ in java.lang.System.exit(0) }
fileMenu.add(quitItem)
menuBar.add(fileMenu)

// Edit menu
let editMenu = javax.swing.JMenu("Edit")
editMenu.add(javax.swing.JMenuItem("Cut")).addActionListener   { _ in print("Cut")   }
editMenu.add(javax.swing.JMenuItem("Copy")).addActionListener  { _ in print("Copy")  }
editMenu.add(javax.swing.JMenuItem("Paste")).addActionListener { _ in print("Paste") }
menuBar.add(editMenu)

frame.setJMenuBar(menuBar)
```

### Menu interaction model

The SwiftUI toolkit handles all menu interaction directly in
`_SwiftUINativeCanvas` — no additional setup is required in application code:

- **Click** on a menu title → opens the drop-down (`JPopupMenu`)
- **Hover** over another menu title while one is open → switches to that menu
- **Click** on a menu item → fires all registered `ActionListener` closures
- **Click outside** any open menu → closes the drop-down

### Dynamic sizing

All sizes are computed from `FontMetrics`, not hardcoded pixel values, so the
menu bar and drop-down items scale with the system font on every platform:

```swift
// JMenuBar.defaultHeight — not a constant, a computed property:
public static var defaultHeight: Int {
    let fm = java.awt.FontMetrics.make(for: java.awt.Font("Dialog", java.awt.Font.PLAIN, 12))
    return fm.getHeight() + verticalPad
}
```

`BasicPopupMenuUI` uses the same pattern: `itemHeight = fm.getHeight() + itemVerticalPad`.

## JLayeredPane — Z-order layers

`JLayeredPane` manages its children in named layers.  Components in higher-numbered
layers are painted on top:

| Constant | Value | Typical use |
|---|---|---|
| `FRAME_CONTENT_LAYER` | -30000 | Content pane, menu bar |
| `DEFAULT_LAYER` | 0 | Normal components |
| `PALETTE_LAYER` | 100 | Floating toolbars |
| `MODAL_LAYER` | 200 | Modal blocking overlays |
| `POPUP_LAYER` | 300 | Drop-down menus, tool tips |
| `DRAG_LAYER` | 400 | Dragged components |

When a menu is opened, the `JPopupMenu` is added to `POPUP_LAYER` so it paints
on top of the content pane.  `JLayeredPane.paintChildren` sorts children by layer
and translates the graphics context to each child's origin before painting:

```swift
for child in sorted where child.visible {
    let dx = child.bounds.x
    let dy = child.bounds.y
    g.translate(dx, dy)
    child.paint(g)
    g.translate(-dx, -dy)
}
```

## Complete example — SwingShowcase

```swift
import JavApi

@main
struct SwingShowcaseApp {

    @MainActor
    static func main() {
        java.awt.EventQueue.invokeLater {
            SwingShowcaseApp().buildShowcase().setVisible(true)
        }
        java.awt.Toolkit.getDefaultToolkit().runEventLoop()
    }

    @MainActor
    private func buildShowcase() -> javax.swing.JFrame {
        let frame = javax.swing.JFrame("JavApi⁴Swift – Swing Showcase")
        frame.setSize(520, 400)
        frame.setDefaultCloseOperation(javax.swing.JFrame.EXIT_ON_CLOSE)

        let menuBar = javax.swing.JMenuBar()

        let fileMenu = javax.swing.JMenu("File")
        fileMenu.add(javax.swing.JMenuItem("Open…")).addActionListener { _ in print("File > Open…") }
        fileMenu.add(javax.swing.JMenuItem("Save…")).addActionListener { _ in print("File > Save…") }
        fileMenu.addSeparator()
        let quitItem = javax.swing.JMenuItem("Quit")
        quitItem.addActionListener { _ in java.lang.System.exit(0) }
        fileMenu.add(quitItem)
        menuBar.add(fileMenu)

        let editMenu = javax.swing.JMenu("Edit")
        editMenu.add(javax.swing.JMenuItem("Cut")).addActionListener   { _ in print("Edit > Cut")   }
        editMenu.add(javax.swing.JMenuItem("Copy")).addActionListener  { _ in print("Edit > Copy")  }
        editMenu.add(javax.swing.JMenuItem("Paste")).addActionListener { _ in print("Edit > Paste") }
        menuBar.add(editMenu)

        let helpMenu = javax.swing.JMenu("Help")
        helpMenu.add(javax.swing.JMenuItem("About…")).addActionListener { _ in print("Help > About…") }
        menuBar.add(helpMenu)

        frame.setJMenuBar(menuBar)
        return frame
    }
}
```

## Implementing a custom Look & Feel

### ComponentUI — painting one component

A `ComponentUI` subclass is responsible for painting one type of `JComponent`.
Override `paint(_:on:)`, `getPreferredSize(of:)`, `installUI(_:)`, and
`uninstallUI(_:)`:

```swift
import JavApi

final class MyMenuBarUI: javax.swing.plaf.ComponentUI {

    private let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 13)

    override func getPreferredSize(of component: javax.swing.JComponent) -> java.awt.Dimension? {
        guard let bar = component as? javax.swing.JMenuBar else { return nil }
        let fm = java.awt.FontMetrics.make(for: font)
        let w  = bar.getMenus().reduce(0) { $0 + fm.stringWidth($1.getText()) + 16 }
        return java.awt.Dimension(w, fm.getHeight() + 8)
    }

    override func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
        guard let bar = component as? javax.swing.JMenuBar else { return }
        // fill background
        g.setColor(java.awt.Color.darkGray)
        g.fillRect(0, 0, bar.bounds.width, bar.bounds.height)
        // draw titles …
    }
}
```

Each `JComponent` calls `updateUI()` to fetch the correct delegate:

```swift
open class MyJMenuBar: javax.swing.JMenuBar {
    override open func updateUI() {
        setUI(MyMenuBarUI())
    }
}
```

### LookAndFeel — the factory

Subclass `javax.swing.LookAndFeel` to provide a complete set of delegates:

```swift
import JavApi

final class MyLookAndFeel: javax.swing.LookAndFeel {

    override func getName()        -> String { "My L&F" }
    override func getID()          -> String { "MyLaF" }
    override func getDescription() -> String { "A custom Look & Feel" }

    override func isSupportedLookAndFeel() -> Bool { true }
    override func isNativeLookAndFeel()    -> Bool { false }

    override func initialize()   { /* allocate shared resources */ }
    override func uninitialize() { /* release shared resources  */ }

    // override func getDefaults() → UIDefaults  (once UIDefaults is available)
}
```

Install it before any components are created:

```swift
javax.swing.UIManager.setLookAndFeel(MyLookAndFeel())
```

### Colour conventions

`BasicLookAndFeel` uses `java.awt.SystemColor` constants so colours adapt to
the platform's appearance mode (Light / Dark):

| Role | SystemColor constant |
|---|---|
| Menu bar background | `SystemColor.menu` |
| Menu bar text | `SystemColor.menuText` |
| Selected menu title background | `SystemColor.textHighlight` |
| Selected menu title text | `SystemColor.textHighlightText` |
| Popup background | `SystemColor.menu` |
| Armed item background | `SystemColor.textHighlight` |
| Border / separator | `SystemColor.controlShadow` |

### Naming pitfalls when subclassing Swing components

Some Swift names shadow identifiers from `java.awt` and its subpackages.  Known
cases to avoid:

| Symbol you want | Conflict | Safe alternative |
|---|---|---|
| `JMenu.popupMenu` | `java.awt.Component.popupMenu: PopupMenu?` | `swingPopupMenu` |
| `JPopupMenu.hide()` | `java.awt.Component.hide()` | `closePopup()` |
| `JPopupMenu.removeAll()` | `java.awt.Container.removeAll()` | `removeAllItems()` |

## JPanel

`JPanel` is the standard lightweight container. It is opaque by default and uses `FlowLayout`
unless you pass a different layout manager to the constructor:

```swift
// FlowLayout (default)
let panel = javax.swing.JPanel()

// BorderLayout
let border = javax.swing.JPanel(java.awt.BorderLayout())
border.add(myLabel,  java.awt.BorderLayout.NORTH)
border.add(myButton, java.awt.BorderLayout.SOUTH)
```

`setBackground(_:)` and `setForeground(_:)` set the panel's colours. Because `JPanel` is
opaque by default, the background is filled automatically before children are painted.

## JLabel

`JLabel` displays a single, non-interactive line of text:

```swift
let label = javax.swing.JLabel("Hello, Swing!")
label.setHorizontalAlignment(javax.swing.SwingConstants.CENTER)
label.setVerticalAlignment(javax.swing.SwingConstants.CENTER)
label.setForeground(java.awt.Color.white)
```

Alignment constants live in `javax.swing.SwingConstants`:

| Constant | Value |
|---|---|
| `SwingConstants.LEFT` | 2 |
| `SwingConstants.CENTER` | 0 |
| `SwingConstants.RIGHT` | 4 |
| `SwingConstants.TOP` | 1 |
| `SwingConstants.BOTTOM` | 3 |

`JLabel.CENTER` is **not** defined — always use `SwingConstants.CENTER`.

## JButton

`JButton` is a push button that fires registered `ActionListener` closures when clicked:

```swift
let btn = javax.swing.JButton("OK")
btn.addActionListener { _ in
    print("Clicked!")
}
panel.add(btn)
```

The visual state (pressed / rollover) is tracked internally and triggers a `repaint()`.
The appearance is painted by `BasicButtonUI` — a 3D raised rectangle with centred text.
`doClick()` programmatically fires all action listeners without a real mouse event.

## JDialog

`JDialog` is a secondary window with Swing's root-pane architecture — identical to
`JFrame` but without a menu bar slot:

```swift
let dialog = javax.swing.JDialog(owner: frame, title: "Settings", modal: false)
dialog.setSize(380, 240)

// Add to content pane (same as JFrame)
let label = javax.swing.JLabel("CardLayout — 3 Karten")
label.setHorizontalAlignment(javax.swing.SwingConstants.CENTER)
dialog.add(label, java.awt.BorderLayout.NORTH)

let closeBtn = javax.swing.JButton("Schließen")
closeBtn.addActionListener { [dialog] _ in
    dialog.setVisible(false)   // hides the NSPanel; use dispose() to release resources
}
let south = javax.swing.JPanel()
south.add(closeBtn)
dialog.add(south, java.awt.BorderLayout.SOUTH)

dialog.setVisible(true)
```

`defaultCloseOperation` constants:

| Constant | Value | Behaviour |
|---|---|---|
| `DO_NOTHING_ON_CLOSE` | 0 | Nothing |
| `HIDE_ON_CLOSE` | 1 | `setVisible(false)` (default) |
| `DISPOSE_ON_CLOSE` | 2 | Disposes and releases resources |

On macOS, `JDialog` opens as an `NSPanel`. Calling `setVisible(false)` correctly closes
the panel via `SwiftUIToolkit.hide()` → `closeDialog()` → `NSPanel.orderOut(nil)`.

## CardLayout demo with JPanel, JLabel, JButton

The following pattern mirrors the AWT `CardLayout` demo but uses Swing components:

```swift
@MainActor
final class SwingCardDemoPanel: javax.swing.JPanel {

    private let cards   = java.awt.CardLayout()
    private let cardBox = javax.swing.JPanel()

    init() {
        super.init(java.awt.BorderLayout())
        cardBox.setLayout(cards)

        cardBox.add(makeCard("Karte 1", java.awt.Color(0x33, 0x66, 0xFF)), "1")
        cardBox.add(makeCard("Karte 2", java.awt.Color(0x22, 0xAA, 0x44)), "2")
        cardBox.add(makeCard("Karte 3", java.awt.Color(0xCC, 0x33, 0x33)), "3")
        add(cardBox, java.awt.BorderLayout.CENTER)

        let nav = javax.swing.JPanel()
        let prevBtn = javax.swing.JButton("◀")
        prevBtn.addActionListener { [weak self] _ in
            guard let self else { return }
            self.cards.previous(self.cardBox)   // triggers repaint automatically
        }
        let nextBtn = javax.swing.JButton("▶")
        nextBtn.addActionListener { [weak self] _ in
            guard let self else { return }
            self.cards.next(self.cardBox)
        }
        nav.add(prevBtn)
        nav.add(nextBtn)
        nav.setPreferredSize(java.awt.Dimension(200, 36))
        add(nav, java.awt.BorderLayout.SOUTH)
    }

    private func makeCard(_ text: String, _ bg: java.awt.Color) -> javax.swing.JPanel {
        let panel = javax.swing.JPanel()
        panel.setLayout(java.awt.BorderLayout())
        panel.setBackground(bg)
        let label = javax.swing.JLabel(text)
        label.setHorizontalAlignment(javax.swing.SwingConstants.CENTER)
        label.setForeground(java.awt.Color.white)
        panel.add(label, java.awt.BorderLayout.CENTER)
        return panel
    }
}
```

`CardLayout.next(_:)` and `previous(_:)` call `parent.repaint()` automatically after
switching visibility — no manual redraw is needed.

## Hit-test coordinate system

The `_SwingHitTest.find(x:y:in:)` function translates coordinates into each child's local
space before recursing. This is essential for the Swing component hierarchy, where all
layout managers place children at **local** (0,0-relative) coordinates:

```
JDialog (0,0,380,240)
  └── JRootPane (0,0,380,240)         ← local to JDialog
        └── JLayeredPane (0,0,380,240) ← local to JRootPane
              └── contentPane (0,0,380,240) ← local to JLayeredPane
                    └── myPanel (0,20,380,200) ← local to contentPane
                          └── myButton (5,5,80,28) ← local to myPanel
```

When the user clicks at window coordinate (45, 37), the hit test translates at each level:
- Into contentPane: (45, 37)
- Into myPanel: (45, 37-20) = (45, 17)
- Into myButton: (45-5, 17-5) = (40, 12) ✓

Without this translation every child panel at y=20+ would receive wrong coordinates and
click events would land on the wrong component or miss entirely.

## What comes next

The following Swing components are planned:

- `JTextField`, `JTextArea`
- `JOptionPane`
- `JScrollPane`, `JList`, `JComboBox`, `JTable`, `JTree`
- `UIManager` and `UIDefaults` lookup table

## Next Steps

- <doc:AWT> — the AWT foundation that Swing builds on
- <doc:ImplementingAToolkit> — how the platform rendering backend works
