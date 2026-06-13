# Building UIs with java.awt

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Create windows, organise components with layout managers, draw custom graphics, and react to user input using the Abstract Window Toolkit.

## Overview

The Abstract Window Toolkit (`java.awt`) is Java's original GUI framework, introduced in Java 1.0.
JavApi⁴Swift implements it on top of SwiftUI on Apple platforms and as a headless no-op on Linux —
so the same Java-style UI code compiles everywhere.

This article covers the fundamental building blocks:

- `Frame` — a top-level window
- `Panel` — a container for grouping components
- `Canvas` — a surface for custom drawing
- Layout managers — `BorderLayout`, `FlowLayout`, `GridLayout`, `CardLayout`, `GridBagLayout`
- `Label` — a read-only text component
- `Button`, `Checkbox`, `TextField`, `TextArea` — interactive controls
- `Scrollbar` — a standalone scroll-bar component
- `ScrollPane` — a scrollable container for oversized content
- `Choice` — a drop-down selection list
- `List` — a scrollable multi-item selection list
- `FileDialog` — a native open/save panel
- `MenuBar`, `Menu`, `MenuItem` — a full pull-down menu system
- `PopupMenu` — a context menu attached to any component
- `Dialog` — a secondary modal or modeless window
- `WindowListener` — reacting to window lifecycle events
- `BufferedImage` — off-screen image drawing
- `MouseListener`, `MouseMotionListener`, `KeyListener`, `FocusListener`, `ComponentListener` — the 1.1 delegation event model

## Frames

A `Frame` is the starting point for every AWT application. It is a top-level window with a title bar.

```swift
import JavApi

let frame = java.awt.Frame("My Window")
frame.setSize(480, 360)
frame.setVisible(true)
```

Always assign a layout manager before adding children:

```swift
frame.setLayout(java.awt.BorderLayout())
```

## Layout Managers

AWT separates *what* to display from *where* to display it. A layout manager computes the
position and size of every child whenever the container is resized or a child is added or removed.

**FlowLayout** places components left-to-right and wraps to the next row when the row is full.
It is the default for `Panel`.

```swift
let panel  = java.awt.Panel()   // FlowLayout by default
let panel2 = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))
```

**BorderLayout** divides the container into five named regions: NORTH, SOUTH, EAST, WEST, CENTER.
Each region holds at most one component. CENTER expands to fill the remaining space.

```swift
frame.setLayout(java.awt.BorderLayout())
frame.add(toolbar,   java.awt.BorderLayout.NORTH)
frame.add(sidebar,   java.awt.BorderLayout.WEST)
frame.add(canvas,    java.awt.BorderLayout.CENTER)
frame.add(statusbar, java.awt.BorderLayout.SOUTH)
```

**GridLayout** arranges components in a uniform grid of equal-sized cells, filling left-to-right, top-to-bottom.
Pass rows and columns; set either to 0 to let the layout calculate it automatically.

```swift
let grid = java.awt.Panel(java.awt.GridLayout(3, 4, hgap: 4, vgap: 4))
for i in 1...12 {
    grid.add(java.awt.Button("\(i)"))
}
```

**CardLayout** stacks multiple components in the same space and shows only one at a time — ideal for wizard steps or tab-body panels.

```swift
let deck  = java.awt.Panel()
let cards = java.awt.CardLayout()
deck.setLayout(cards)
deck.add(pageOne,  "page1")
deck.add(pageTwo,  "page2")
deck.add(pageThree,"page3")

cards.show(deck, "page2")   // jump to a named card
cards.next(deck)            // advance one card
cards.first(deck)           // go back to the first card
```

**GridBagLayout** is the most flexible layout manager. Each component gets its own `GridBagConstraints` that specifies its cell coordinates, spanning, fill, and weight.

```swift
let gbl = java.awt.GridBagLayout()
let panel = java.awt.Panel()
panel.setLayout(gbl)

func add(_ comp: java.awt.Component, gridx: Int, gridy: Int,
         gridwidth: Int = 1, gridheight: Int = 1,
         fill: Int = java.awt.GridBagConstraints.NONE,
         weightx: Double = 0, weighty: Double = 0) {
    let c = java.awt.GridBagConstraints()
    c.gridx = gridx; c.gridy = gridy
    c.gridwidth = gridwidth; c.gridheight = gridheight
    c.fill = fill; c.weightx = weightx; c.weighty = weighty
    gbl.setConstraints(comp, c)
    panel.add(comp)
}

add(java.awt.Label("Name:"),       gridx: 0, gridy: 0)
add(java.awt.TextField(20),        gridx: 1, gridy: 0, fill: java.awt.GridBagConstraints.HORIZONTAL, weightx: 1.0)
add(java.awt.Label("Address:"),    gridx: 0, gridy: 1)
add(java.awt.TextArea("", 3, 20),  gridx: 1, gridy: 1, fill: java.awt.GridBagConstraints.BOTH, weightx: 1.0, weighty: 1.0)
```

## Panel

`Panel` is the simplest container. Use it to group related components and give them their
own layout policy, independently of the parent container.

```swift
let controls = java.awt.Panel(
    java.awt.FlowLayout(java.awt.FlowLayout.LEFT, hgap: 8, vgap: 4))

controls.add(myButton)
controls.add(myTextField)

frame.add(controls, java.awt.BorderLayout.SOUTH)
```

Panels can be nested freely. A panel inside a panel inside a frame is perfectly normal AWT code.

## Canvas

`Canvas` is a blank rectangular component you use for custom drawing. Subclass it and
override `paint(_ g: Graphics)`:

```swift
@MainActor
final class ColourGridCanvas: java.awt.Canvas {

    private let colours: [java.awt.Color] = [
        .red, .green, .blue, .yellow, .cyan,
        .magenta, .orange, .pink, .white, .lightGray
    ]

    override func paint(_ g: java.awt.Graphics) {
        let cols  = 5
        let cellW = bounds.width  / cols
        let cellH = bounds.height / 2

        for (i, colour) in colours.enumerated() {
            g.setColor(colour)
            g.fillRect(bounds.x + (i % cols) * cellW,
                       bounds.y + (i / cols) * cellH,
                       cellW, cellH)
        }
        g.setColor(.black)
        g.drawRect(bounds.x, bounds.y, bounds.width - 1, bounds.height - 1)
    }
}
```

The `Graphics` object provides: `fillRect`, `drawRect`, `drawLine`, `fillOval`, `drawOval`, `drawString`, and more.

## Label

`Label` displays a single line of read-only text. The alignment constant controls how the
text is positioned within the component's bounds:

```swift
let caption = java.awt.Label("Name:")
caption.bounds = java.awt.Rectangle(0, 0, 80, 24)

let centred = java.awt.Label("AWT Showcase", java.awt.Label.CENTER)
centred.bounds = java.awt.Rectangle(0, 0, 300, 32)

let right = java.awt.Label("Value:", java.awt.Label.RIGHT)
right.bounds = java.awt.Rectangle(0, 0, 80, 24)
```

Available alignment constants are `Label.LEFT` (default), `Label.CENTER`, and `Label.RIGHT`.
Change the text at any time with `setText(_:)`; read it back with `getText()`.

## Button

`Button` is a push-button with a text label. Register an `ActionListener` to react to clicks:

```swift
let btn = java.awt.Button("OK")
btn.bounds = java.awt.Rectangle(0, 0, 80, 28)

btn.addActionListener(MyListener())

// In your listener class:
final class MyListener: java.awt.event.ActionListener {
    func actionPerformed(_ e: java.awt.event.ActionEvent) {
        print("Button clicked: \(e.actionCommand)")
    }
}
```

`doClick()` fires the action programmatically (useful for testing).

## TextField

`TextField` is a single-line text-input field:

```swift
let field = java.awt.TextField("initial text", columns: 20)
field.bounds = java.awt.Rectangle(0, 0, 180, 28)

// React to text changes:
field.addTextListener(MyTextListener())

// React to Return key:
field.addActionListener(MyActionListener())

// Password field:
let password = java.awt.TextField(columns: 12)
password.setEchoChar("•")
```

Read and write the content with `getText()` / `setText(_:)`.

## TextArea

`TextArea` is a multi-line text-input field. The constructor accepts optional row and column
hints and a scroll-bar visibility constant:

```swift
// Default: 5 rows, 20 columns, both scroll bars
let area = java.awt.TextArea("Edit me here…\nLine 2\nLine 3")
area.bounds = java.awt.Rectangle(0, 0, 240, 120)

// Explicit size, vertical scroll bar only
let log = java.awt.TextArea("", 10, 40, java.awt.TextArea.SCROLLBARS_VERTICAL_ONLY)
log.bounds = java.awt.Rectangle(0, 0, 320, 160)
log.setEditable(false)
```

Scroll-bar visibility constants are `SCROLLBARS_BOTH` (default), `SCROLLBARS_VERTICAL_ONLY`,
`SCROLLBARS_HORIZONTAL_ONLY`, and `SCROLLBARS_NONE`.

Append, insert, or replace text at any time:

```swift
area.append("\nNew line")
area.insert("prefix: ", 0)
area.replaceRange("replacement", 0, 6)
```

`getText()` and `setText(_:)` work just like on `TextField`. To react to changes register
a `TextListener` with `addTextListener(_:)`.

## Scrollbar

`Scrollbar` is a standalone scroll-bar component. Use it when you need fine-grained control
over scrolling that is separate from a `TextArea`.

```swift
let sb = java.awt.Scrollbar(
    java.awt.Scrollbar.VERTICAL,
    value:   0,
    visible: 20,
    minimum: 0,
    maximum: 100)
sb.bounds = java.awt.Rectangle(0, 0, 18, 300)
panel.add(sb)
```

Orientation constants are `Scrollbar.VERTICAL` and `Scrollbar.HORIZONTAL`. The `visibleAmount`
controls the thumb size relative to the total range (`minimum` … `maximum`).

React to thumb movement with an `AdjustmentListener`:

```swift
sb.addAdjustmentListener(MyScrollListener())

final class MyScrollListener: java.awt.event.AdjustmentListener {
    func adjustmentValueChanged(_ e: java.awt.event.AdjustmentEvent) {
        print("Scroll value: \(e.value)")
    }
}
```

`getValue()` / `setValue(_:)` read and set the current position programmatically.
Fine-grained increments are controlled by `setUnitIncrement(_:)` (arrow key / click)
and `setBlockIncrement(_:)` (page key / track click).

## ScrollPane

`ScrollPane` is a container that holds exactly one child component and automatically clips
and scrolls it when the child is larger than the visible viewport. Unlike a standalone
`Scrollbar`, `ScrollPane` manages both scroll bars and the clipping itself — you only set
the child's full size and let `ScrollPane` handle the rest.

```swift
let pane = java.awt.ScrollPane()              // SCROLLBARS_AS_NEEDED
pane.bounds = java.awt.Rectangle(0, 0, 200, 150)

let bigCanvas = MyLargeCanvas()
bigCanvas.bounds = java.awt.Rectangle(0, 0, 800, 600)
pane.add(bigCanvas)

frame.add(pane, java.awt.BorderLayout.CENTER)
```

The scroll-bar display policy is passed to the constructor:

```swift
let always = java.awt.ScrollPane(java.awt.ScrollPane.SCROLLBARS_ALWAYS)
let never  = java.awt.ScrollPane(java.awt.ScrollPane.SCROLLBARS_NEVER)
```

Constants are `SCROLLBARS_AS_NEEDED` (default), `SCROLLBARS_ALWAYS`, and `SCROLLBARS_NEVER`.

Read the current scroll offset with `getScrollPosition()` (returns a `Point`) or the
`scrollX` / `scrollY` properties. Jump to a specific position with `setScrollPosition(_:_:)`:

```swift
pane.setScrollPosition(0, 100)   // scroll to y = 100
let pos = pane.getScrollPosition()
print("x: \(pos.x)  y: \(pos.y)")
```

`getViewportSize()` returns the actual visible area after accounting for the scrollbar strips.

## Choice

`Choice` is a drop-down (combo-box) component that lets the user pick exactly one item from
a list. The selected item is always visible; the full list appears when the user clicks it.

```swift
let choice = java.awt.Choice()
choice.bounds = java.awt.Rectangle(0, 0, 120, 28)

choice.add("Red")
choice.add("Green")
choice.add("Blue")
choice.select("Green")          // select by name …
choice.select(0)                // … or by index
```

Read the current selection with `getSelectedItem()` (returns `String?`) or
`getSelectedIndex()` (returns `Int`). `getItemCount()` tells you how many items exist;
`getItem(_:)` retrieves one by index.

React to selection changes with an `ItemListener`:

```swift
choice.addItemListener(MyChoiceListener())

final class MyChoiceListener: java.awt.event.ItemListener {
    func itemStateChanged(_ e: java.awt.event.ItemEvent) {
        if e.stateChange == java.awt.event.ItemEvent.SELECTED {
            print("Selected: \(e.item)")
        }
    }
}
```

## List

`List` is a scrollable box that displays multiple items at once. It supports both
single-selection and multi-selection modes.

```swift
// Single-selection (default)
let list = java.awt.List()
list.bounds = java.awt.Rectangle(0, 0, 140, 100)

// Multi-selection: pass true as second argument
let multiList = java.awt.List(6, true)
multiList.bounds = java.awt.Rectangle(0, 0, 140, 120)

for colour in ["Red", "Green", "Blue", "Yellow", "Cyan"] {
    list.add(colour)
}
list.select(0)
```

The first constructor argument is the preferred visible row count. Read selections with
`getSelectedItem()` / `getSelectedIndex()` for single mode, or `getSelectedItems()` /
`getSelectedIndexes()` for multi-selection. Use `deselect(_:)` and `isIndexSelected(_:)` to
inspect or modify individual entries.

`List` fires two kinds of events — register the appropriate listener:

```swift
// Single click → ItemEvent (SELECTED / DESELECTED)
list.addItemListener(MyListItemListener())

// Double click → ActionEvent
list.addActionListener(MyListActionListener())

final class MyListItemListener: java.awt.event.ItemListener {
    func itemStateChanged(_ e: java.awt.event.ItemEvent) {
        print("Item state changed: \(e.item)")
    }
}

final class MyListActionListener: java.awt.event.ActionListener {
    func actionPerformed(_ e: java.awt.event.ActionEvent) {
        print("Double-clicked: \(e.actionCommand)")
    }
}
```

## FileDialog

`FileDialog` opens a native open or save panel. It is always modal — `setVisible(true)`
blocks until the user confirms or cancels.

```swift
// Open panel
let openDlg = java.awt.FileDialog(frame, "Open File", java.awt.FileDialog.LOAD)
openDlg.setVisible(true)
if let file = openDlg.getFile(), let dir = openDlg.getDirectory() {
    print("Opened: \(dir)\(file)")
}

// Save panel
let saveDlg = java.awt.FileDialog(frame, "Save File", java.awt.FileDialog.SAVE)
saveDlg.setDirectory("/tmp")
saveDlg.setFile("untitled.txt")
saveDlg.setVisible(true)
if let file = saveDlg.getFile() {
    print("Save to: \(saveDlg.getDirectory() ?? "")\(file)")
}
```

Mode constants are `FileDialog.LOAD` and `FileDialog.SAVE`. After `setVisible(true)` returns,
`getFile()` is `nil` when the user cancelled, non-nil when they confirmed.
On macOS `LOAD` maps to `NSOpenPanel` and `SAVE` to `NSSavePanel`.

## Checkbox and Radio Buttons

`Checkbox` works as an independent toggle (checkbox) or as part of a `CheckboxGroup` (radio button):

```swift
// Independent checkboxes
let bold   = java.awt.Checkbox("Bold")
let italic = java.awt.Checkbox("Italic", state: true)

bold.addItemListener(MyItemListener())

// Radio buttons — only one selected at a time
let group  = java.awt.CheckboxGroup()
let small  = java.awt.Checkbox("Small",  state: true,  group: group)
let medium = java.awt.Checkbox("Medium", state: false, group: group)
let large  = java.awt.Checkbox("Large",  state: false, group: group)

// In your listener:
final class MyItemListener: java.awt.event.ItemListener {
    func itemStateChanged(_ e: java.awt.event.ItemEvent) {
        let selected = e.stateChange == java.awt.event.ItemEvent.SELECTED
        print("Item \(selected ? "selected" : "deselected")")
    }
}
```

Query state with `getState()`, change it with `setState(_:)`.

## MenuBar and Menus

A `MenuBar` holds one or more `Menu` objects and is attached to a `Frame` with
`setMenuBar(_:)`. Each `Menu` contains `MenuItem` entries, separators, and optionally
nested sub-menus (a `Menu` is itself a `MenuItem`).

```swift
let menuBar = java.awt.MenuBar()

// File menu with keyboard shortcuts
let fileMenu = java.awt.Menu("File")
let openItem = java.awt.MenuItem("Open…", java.awt.MenuShortcut(79))   // Cmd+O
openItem.addActionListener(MyActionListener())
let saveItem = java.awt.MenuItem("Save…", java.awt.MenuShortcut(83))   // Cmd+S
saveItem.addActionListener(MyActionListener())
fileMenu.add(openItem)
fileMenu.add(saveItem)
fileMenu.addSeparator()
let quitItem = java.awt.MenuItem("Quit",  java.awt.MenuShortcut(81))   // Cmd+Q
quitItem.addActionListener(MyActionListener())
fileMenu.add(quitItem)
menuBar.add(fileMenu)

// View menu with CheckboxMenuItem and a sub-menu
let viewMenu = java.awt.Menu("View")
let toolbarItem = java.awt.CheckboxMenuItem("Toolbar", true)
toolbarItem.addItemListener(MyItemListener())
viewMenu.add(toolbarItem)
viewMenu.addSeparator()

let zoomMenu = java.awt.Menu("Zoom")          // sub-menu
for label in ["50 %", "100 %", "200 %"] {
    let item = java.awt.MenuItem(label)
    item.addActionListener(MyActionListener())
    zoomMenu.add(item)
}
viewMenu.add(zoomMenu)
menuBar.add(viewMenu)

// Help menu — platform may render it at the trailing edge
let helpMenu = java.awt.Menu("Help")
helpMenu.add(java.awt.MenuItem("About…"))
menuBar.setHelpMenu(helpMenu)

frame.setMenuBar(menuBar)
```

`MenuShortcut` takes an ASCII key code (e.g. `79` = O). `CheckboxMenuItem` works like
`Checkbox` in a menu — `getState()` / `setState(_:)` and `ItemListener`.
`setEnabled(_:)` / `enable()` / `disable()` work on any `MenuItem`.

## PopupMenu

`PopupMenu` is a context menu that can be attached to any `Component` via its
`popupMenu` property. The platform bridge shows it automatically on a right-click
(or Ctrl-click on macOS).

```swift
let popup = java.awt.PopupMenu("Edit")
let copyItem  = java.awt.MenuItem("Copy")
let pasteItem = java.awt.MenuItem("Paste")
copyItem.addActionListener(MyActionListener())
pasteItem.addActionListener(MyActionListener())
popup.add(copyItem)
popup.add(pasteItem)
popup.addSeparator()
popup.add(java.awt.MenuItem("Select All"))

myCanvas.popupMenu = popup
```

You can also trigger it programmatically with `popup.show(component, x, y)`.

## Dialog

`Dialog` is a secondary window, typically modal. Build its content the same way as a
`Frame` — assign a layout manager and add components — then call `setVisible(true)` to
show it. Call `dispose()` to close it from within a listener.

```swift
let dialog = java.awt.Dialog(frame, "About", true)   // true = modal
dialog.setLayout(java.awt.BorderLayout())
dialog.setPreferredSize(java.awt.Dimension(320, 260))
dialog.bounds = java.awt.Rectangle(0, 0, 320, 260)

let info = java.awt.Label("JavApi⁴Swift  •  Java AWT for Swift", java.awt.Label.CENTER)
info.setPreferredSize(java.awt.Dimension(320, 40))
dialog.add(info, java.awt.BorderLayout.CENTER)

let closeBtn = java.awt.Button("Close")
closeBtn.setPreferredSize(java.awt.Dimension(100, 30))
closeBtn.addActionListener(CloseListener(dialog: dialog))
let south = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER))
south.add(closeBtn)
dialog.add(south, java.awt.BorderLayout.SOUTH)

dialog.validate()
dialog.setVisible(true)        // blocks until dispose() is called (modal)

// In CloseListener:
final class CloseListener: java.awt.event.ActionListener {
    private weak var dialog: java.awt.Dialog?
    init(dialog: java.awt.Dialog) { self.dialog = dialog }
    func actionPerformed(_ e: java.awt.event.ActionEvent) { dialog?.dispose() }
}
```

`Dialog` constructor variants: `Dialog(owner: Frame?, title:, modal:)` and
`Dialog(owner: Window?, title:, modal:)`.

## WindowListener

Register a `WindowListener` on any `Frame` or `Dialog` to react to lifecycle events such
as the user clicking the close button.

```swift
frame.addWindowListener(MyWindowListener())

final class MyWindowListener: java.awt.event.WindowListener {
    func windowOpened     (_ e: java.awt.event.WindowEvent) { print("opened")      }
    func windowClosing    (_ e: java.awt.event.WindowEvent) { print("closing")     }
    func windowClosed     (_ e: java.awt.event.WindowEvent) { print("closed")      }
    func windowIconified  (_ e: java.awt.event.WindowEvent) { print("iconified")   }
    func windowDeiconified(_ e: java.awt.event.WindowEvent) { print("deiconified") }
    func windowActivated  (_ e: java.awt.event.WindowEvent) { print("activated")   }
    func windowDeactivated(_ e: java.awt.event.WindowEvent) { print("deactivated") }
}
```

The most commonly used callbacks are `windowClosing` (user clicks the red button) and
`windowOpened` (first time the window becomes visible).

## Mouse and Keyboard Input

Any `Component` can receive mouse and keyboard events via listeners registered in Java 1.1's delegation event model.

**MouseListener** reacts to press, release, click, enter, and exit:

```swift
myCanvas.addMouseListener(MyMouseListener())

final class MyMouseListener: java.awt.event.MouseListener {
    func mouseClicked (_ e: java.awt.event.MouseEvent) { print("click at \(e.x),\(e.y)") }
    func mousePressed (_ e: java.awt.event.MouseEvent) { print("pressed") }
    func mouseReleased(_ e: java.awt.event.MouseEvent) { print("released") }
    func mouseEntered (_ e: java.awt.event.MouseEvent) { print("entered") }
    func mouseExited  (_ e: java.awt.event.MouseEvent) { print("exited") }
}
```

`e.getClickCount()` returns 1 for a single click, 2 for a double click. `e.getX()` / `e.getY()` give the position relative to the component.

**MouseMotionListener** tracks dragging and hovering:

```swift
myCanvas.addMouseMotionListener(MyMotionListener())

final class MyMotionListener: java.awt.event.MouseMotionListener {
    func mouseDragged(_ e: java.awt.event.MouseEvent) { print("drag \(e.x),\(e.y)") }
    func mouseMoved  (_ e: java.awt.event.MouseEvent) { print("move \(e.x),\(e.y)") }
}
```

**KeyListener** reacts to key press, release, and typed events. The component must have focus:

```swift
myTextField.addKeyListener(MyKeyListener())

final class MyKeyListener: java.awt.event.KeyListener {
    func keyPressed (_ e: java.awt.event.KeyEvent) { print("pressed:  \(e.keyCode)") }
    func keyReleased(_ e: java.awt.event.KeyEvent) { print("released: \(e.keyCode)") }
    func keyTyped   (_ e: java.awt.event.KeyEvent) { print("typed:    \(e.keyChar)") }
}
```

Use `e.getKeyCode()` for virtual key codes (`KeyEvent.VK_ENTER`, `VK_ESCAPE`, etc.) and `e.getKeyChar()` for the resulting Unicode character. Modifier state is available via `e.getModifiers()` (`InputEvent.SHIFT_MASK`, `CTRL_MASK`, `ALT_MASK`).

**FocusListener** reacts when a component gains or loses keyboard focus:

```swift
myTextField.addFocusListener(MyFocusListener())

final class MyFocusListener: java.awt.event.FocusListener {
    func focusGained(_ e: java.awt.event.FocusEvent) { print("focus gained") }
    func focusLost  (_ e: java.awt.event.FocusEvent) { print("focus lost") }
}
```

**ComponentListener** reacts to resize, move, show, and hide events:

```swift
frame.addComponentListener(MyComponentListener())

final class MyComponentListener: java.awt.event.ComponentListener {
    func componentResized(_ e: java.awt.event.ComponentEvent) { print("resized") }
    func componentMoved  (_ e: java.awt.event.ComponentEvent) { print("moved") }
    func componentShown  (_ e: java.awt.event.ComponentEvent) { print("shown") }
    func componentHidden (_ e: java.awt.event.ComponentEvent) { print("hidden") }
}
```

## BufferedImage

`BufferedImage` is an off-screen ARGB image you can draw into pixel-by-pixel and then
render via `Graphics.drawImage`. Use it to pre-render expensive graphics once and cache
the result.

```swift
let img = java.awt.image.BufferedImage(200, 100)
img.fill(.white)

// Draw pixel-by-pixel
let blue = (255 << 24) | (52 << 16) | (120 << 8) | 246   // ARGB
for y in 0..<100 {
    for x in 0..<200 {
        img.setRGB(x, y, blue)
    }
}

// Render in a Canvas
override func paint(_ g: java.awt.Graphics) {
    g.drawImage(img, bounds.x, bounds.y, bounds.width, bounds.height)
}
```

`img.fill(_:)` flood-fills with a `java.awt.Color`. `setRGB(_:_:_:)` writes a packed
ARGB `Int` — `(alpha << 24) | (red << 16) | (green << 8) | blue`.

## Putting It Together

The code below mirrors the AWT Showcase that ships with JavApi⁴Swift. It combines every
widget covered in this article into a single window. Components use `setPreferredSize` and
`setMinimumSize` so the layout manager can size them correctly when the window is resized.
The full source (including `LogoCanvas`, `AboutListener`, and all listener classes) lives
in `Sources/AWTShowcase/AWTShowcase.swift`.

```swift
let frame = java.awt.Frame("JavApi⁴Swift – AWT Showcase")
frame.setSize(520, 420)
frame.setMinimumSize(java.awt.Dimension(380, 280))
frame.setLayout(java.awt.BorderLayout())

// ── NORTH: centred title label ───────────────────────────────────────────────
let title = java.awt.Label(
    "Panel · Canvas · Button · Checkbox · TextField · Label · TextArea" +
    " · Scrollbar · ScrollPane · Choice · List",
    java.awt.Label.CENTER)
title.setPreferredSize(java.awt.Dimension(520, 40))
title.setMinimumSize(java.awt.Dimension(200, 30))
frame.add(title, java.awt.BorderLayout.NORTH)

// ── CENTER: ScrollPane+Canvas (left) + TextArea (right) ─────────────────────
let centerPanel = java.awt.Panel(java.awt.BorderLayout())

// Canvas is double the viewport height — ScrollPane shows a scrollable slice
let bigCanvas = ColourGridCanvas()
bigCanvas.bounds = java.awt.Rectangle(0, 0, 260, 560)   // virtual size

let scrollPane = java.awt.ScrollPane()
scrollPane.setPreferredSize(java.awt.Dimension(260, 280))
scrollPane.setMinimumSize(java.awt.Dimension(80, 60))
scrollPane.add(bigCanvas)
centerPanel.add(scrollPane, java.awt.BorderLayout.WEST)

let textArea = java.awt.TextArea("Edit me here…\nLine 2\nLine 3", 5, 20)
centerPanel.add(textArea, java.awt.BorderLayout.CENTER)   // fills remaining space

frame.add(centerPanel, java.awt.BorderLayout.CENTER)

// ── EAST: standalone vertical Scrollbar ──────────────────────────────────────
let scrollbar = java.awt.Scrollbar(
    java.awt.Scrollbar.VERTICAL,
    value: 0, visible: 20, minimum: 0, maximum: 100)
scrollbar.setPreferredSize(java.awt.Dimension(18, 280))
scrollbar.setMinimumSize(java.awt.Dimension(12, 40))
frame.add(scrollbar, java.awt.BorderLayout.EAST)

// ── SOUTH: controls panel ─────────────────────────────────────────────────────
let controls = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, hgap: 8, vgap: 4))
controls.setPreferredSize(java.awt.Dimension(520, 100))
controls.setMinimumSize(java.awt.Dimension(200, 60))

// Button
let btn = java.awt.Button("Click me")
btn.setPreferredSize(java.awt.Dimension(80, 28))
controls.add(btn)

// TextField
let field = java.awt.TextField("Type here…", columns: 12)
field.setPreferredSize(java.awt.Dimension(140, 28))
controls.add(field)

// Independent checkboxes
let chk1 = java.awt.Checkbox("Bold")
chk1.setPreferredSize(java.awt.Dimension(60, 24))
controls.add(chk1)

let chk2 = java.awt.Checkbox("Italic", state: true)
chk2.setPreferredSize(java.awt.Dimension(60, 24))
controls.add(chk2)

// Radio buttons
let group = java.awt.CheckboxGroup()
for (i, name) in ["Small", "Medium", "Large"].enumerated() {
    let rb = java.awt.Checkbox(name, state: i == 0, group: group)
    rb.setPreferredSize(java.awt.Dimension(75, 24))
    controls.add(rb)
}

// Choice (drop-down)
let choice = java.awt.Choice()
for fruit in ["Apple", "Banana", "Cherry", "Durian"] { choice.add(fruit) }
choice.setPreferredSize(java.awt.Dimension(100, 24))
controls.add(choice)

// List (4 visible rows, single-select)
let list = java.awt.List(4, false)
for colour in ["Red", "Green", "Blue", "Yellow", "Cyan", "Magenta"] { list.add(colour) }
list.setPreferredSize(java.awt.Dimension(90, 80))
controls.add(list)

// FileDialog buttons
let openBtn = java.awt.Button("Open…")
openBtn.setPreferredSize(java.awt.Dimension(70, 28))
openBtn.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.LOAD))
controls.add(openBtn)

let saveBtn = java.awt.Button("Save…")
saveBtn.setPreferredSize(java.awt.Dimension(70, 28))
saveBtn.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.SAVE))
controls.add(saveBtn)

frame.add(controls, java.awt.BorderLayout.SOUTH)

// MenuBar
let menuBar = java.awt.MenuBar()
let fileMenu = java.awt.Menu("File")
fileMenu.add(java.awt.MenuItem("Open…", java.awt.MenuShortcut(79)))
fileMenu.add(java.awt.MenuItem("Save…", java.awt.MenuShortcut(83)))
fileMenu.addSeparator()
fileMenu.add(java.awt.MenuItem("Quit",  java.awt.MenuShortcut(81)))
menuBar.add(fileMenu)

let viewMenu = java.awt.Menu("View")
viewMenu.add(java.awt.CheckboxMenuItem("Toolbar", true))
let zoomMenu = java.awt.Menu("Zoom")
for z in ["50 %", "100 %", "200 %"] { zoomMenu.add(java.awt.MenuItem(z)) }
viewMenu.add(zoomMenu)
menuBar.add(viewMenu)

let helpMenu = java.awt.Menu("Help")
helpMenu.add(java.awt.MenuItem("About…"))
menuBar.setHelpMenu(helpMenu)
frame.setMenuBar(menuBar)

// PopupMenu on the canvas
let popup = java.awt.PopupMenu("Edit")
popup.add(java.awt.MenuItem("Copy"))
popup.add(java.awt.MenuItem("Paste"))
popup.addSeparator()
popup.add(java.awt.MenuItem("Select All"))
bigCanvas.popupMenu = popup

// WindowListener
frame.addWindowListener(MyWindowListener())

frame.setVisible(true)
```

## Dialog Memory Management

Unlike Java (where the garbage collector reclaims unreachable objects automatically),
Swift uses Automatic Reference Counting (ARC). ARC frees an object only when no strong
references to it remain. Dialogs create several objects that hold references to each
other — understanding this prevents memory leaks.

### Always use `weak` in close-button listeners

The close-button listener holds a reference to the dialog it closes. If that reference
is strong, a cycle forms:

```
dialog → south Panel → closeBtn → ActionListener → dialog  (cycle!)
```

Declare the dialog reference `weak` to break the cycle:

```swift
final class CloseListener: java.awt.event.ActionListener {
  private weak var dialog: java.awt.Dialog?          // weak — no cycle
  init(dialog: java.awt.Dialog) { self.dialog = dialog }
  func actionPerformed(_ e: java.awt.event.ActionEvent) { dialog?.dispose() }
}
```

`DialogCloseListener` (the built-in utility class in AWTShowcase) already does this.
When you write your own listener, follow the same pattern.

### Call `dispose()`, not `setVisible(false)`

`setVisible(false)` hides the dialog but keeps the entire component hierarchy
(children, listeners, layout manager) alive. `dispose()` releases all of it:

1. Tears down the native window (NSPanel on macOS).
2. Fires `WINDOW_CLOSING` / `WINDOW_CLOSED` to registered `WindowListener`s.
3. Removes the dialog from the toolkit registry.
4. Calls `removeAll()` recursively — empties every `children` array and calls
   `dispose()` on each child component, which in turn clears all listener arrays.

```swift
// ✗ only hides — component tree stays alive
dialog.setVisible(false)

// ✓ hides + fully releases resources
dialog.dispose()
```

### Re-entrancy is handled automatically

`Dialog.dispose()` sets an internal `_disposing` flag before it begins. If the native
close button fires a second `WINDOW_CLOSING` event during teardown, the flag prevents
`dispose()` from running a second time.  You do not need to guard against this yourself.

### Listener arrays are cleared on dispose

Every component class (`Button`, `Checkbox`, `Choice`, `List`, `TextField`,
`TextArea`, `Scrollbar`, …) clears its own listener arrays when `dispose()` is called.
This means all `ActionListener`, `ItemListener`, `TextListener`, and similar objects are
released at dispose time, even if the caller still holds a strong reference to the
dialog — the listeners go away because the components no longer reference them.

### Summary checklist

- Use `weak var dialog` in every ActionListener that closes a dialog.
- Call `dispose()` (not `setVisible(false)`) to close a dialog.
- Do not hold long-lived strong references to a closed dialog — the `_disposing` flag
  prevents double-dispose, but a stale strong reference delays ARC deallocation.

## Platform Notes

On **macOS and iOS**, `setVisible(true)` opens a native window via SwiftUI.

On **Linux**, the **X11 toolkit** is available for X11-based desktops (including XWayland).
Activate it before any AWT code:

```swift
try? System.setProperty("awt.toolkit", "X11")
```

The X11 toolkit renders menus, buttons, and all other components by drawing directly onto the X11
window — there are no native widgets.  It requires `libX11.so.6` and `libXft.so.2` (for Unicode text).
Without `libXft`, text falls back to `Xutf8DrawString` + `XFontSet`, which may not render all characters
correctly depending on the installed fonts.

Without setting `awt.toolkit`, the `HeadlessToolkit` is selected automatically — `setVisible` is a
no-op and no window appears.  This allows the same code to compile and run on servers or CI systems
that have no X server.

## What You Have Learned

- `Frame` is the top-level window; always assign a layout manager before adding children.
- `Panel` groups components and defines its own layout policy; panels can be freely nested.
- `Canvas` is for custom drawing — override `paint(_ g: Graphics)`.
- `BorderLayout` divides a container into five regions; `FlowLayout` flows components left-to-right.
- `GridLayout` fills a uniform grid of equal-sized cells; set either rows or cols to 0 for automatic calculation.
- `CardLayout` stacks components and shows one at a time; use `show`, `next`, `previous`, `first`, `last` to navigate.
- `GridBagLayout` is the most flexible layout manager; each component gets its own `GridBagConstraints` specifying cell, span, fill, and weight.
- `Label` shows read-only text; use `Label.LEFT`, `Label.CENTER`, or `Label.RIGHT` to control alignment.
- `Button` fires `ActionEvent` on click; register an `ActionListener` to handle it.
- `TextField` provides single-line text input; `TextListener` reacts to changes, `ActionListener` to Return.
- `TextArea` provides multi-line text input; `append`, `insert`, and `replaceRange` modify the content programmatically.
- `Scrollbar` is a standalone scroll control; `AdjustmentListener` reacts to thumb movement.
- `ScrollPane` wraps exactly one child and scrolls it automatically; set the child's full size and `ScrollPane` handles clipping and scroll bars.
- `Choice` is a drop-down that always shows exactly one selection; react to changes with `ItemListener`.
- `List` shows multiple items at once and supports single- or multi-selection; `ItemListener` reacts to clicks, `ActionListener` to double-clicks.
- `FileDialog` opens a native open/save panel; after `setVisible(true)` returns, `getFile()` is non-nil on confirmation.
- `MenuBar` is attached to a `Frame` with `setMenuBar`; `Menu` holds `MenuItem` entries, separators, and sub-menus; `MenuShortcut` binds a keyboard shortcut; `CheckboxMenuItem` adds a toggle item.
- `PopupMenu` is a context menu assigned to a component's `popupMenu` property; right-click triggers it automatically.
- `Dialog` is a secondary window (modal or modeless); call `dispose()` to close it.
- `WindowListener` reacts to `windowOpened`, `windowClosing`, `windowClosed`, and other lifecycle events.
- `BufferedImage` enables off-screen ARGB drawing via `fill`, `setRGB`, and `drawImage`.
- `MouseListener` handles click/press/release/enter/exit; `MouseMotionListener` tracks drag and move; `KeyListener` handles key press/release/typed; `FocusListener` reacts to focus changes; `ComponentListener` reacts to resize/move/show/hide.
- `Checkbox` is a toggle; add it to a `CheckboxGroup` to make it a radio button.
- Use `setPreferredSize` and `setMinimumSize` to give the layout manager size hints; avoid hard-coding `bounds` for components inside a layout manager.

## Next Steps

The next article in the series explores `Graphics2D` for advanced 2-D drawing —
transforms, strokes, and rendering hints.
