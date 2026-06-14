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
used by AWT, with its own `SwiftLookAndFeel` that produces a macOS/iOS-native
appearance.

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
  └── "ButtonUI"  → SwiftButtonUI   ← paints JButton
  └── "LabelUI"   → SwiftLabelUI    ← paints JLabel
  └── "PanelUI"   → SwiftPanelUI    ← paints JPanel
  └── …
```

The active L&F is managed by `UIManager`:

```swift
// Query the active L&F
let laf = UIManager.getLookAndFeel()
print(laf.getName())   // "Swift"

// Install a different L&F (must call updateUI on all components afterwards)
UIManager.setLookAndFeel(MyCustomLookAndFeel())
```

JavApi⁴Swift ships one built-in L&F: **`SwiftLookAndFeel`** (package
`javax.swing.plaf.swift`).  It is selected automatically on Apple platforms.

## JFrame — the Swing top-level window

`JFrame` extends `java.awt.Frame` and adds Swing's **root pane** architecture:

```
JFrame
  └── JRootPane
        ├── contentPane  (JPanel, BorderLayout)  ← add your widgets here
        ├── glassPane    (JComponent, invisible)  ← for overlays / drag & drop
        └── JMenuBar (optional)
```

Always add components to the *content pane*, not directly to the frame:

```swift
// coming soon
```

> **Status:** `JFrame`, `JRootPane`, `JLayeredPane`, `JPanel`, and `JComponent`
> are not yet implemented.  This article will be expanded as each class is added.

## Implementing a custom Look & Feel

Subclass `javax.swing.LookAndFeel` and override the required methods:

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

## What You Will Learn

This article will be extended to cover:

- `JFrame` and the root pane hierarchy
- `JComponent` — `paintComponent`, borders, opacity
- `JPanel`, `JLabel`, `JButton`, `JTextField`, `JTextArea`
- `JMenuBar`, `JMenu`, `JMenuItem`
- `JDialog` and `JOptionPane`
- `JScrollPane`, `JList`, `JComboBox`, `JTable`, `JTree`
- `UIManager` and `UIDefaults`
- Writing a custom `ComponentUI`
- Writing a complete custom `LookAndFeel`

## Next Steps

- <doc:AWT> — the AWT foundation that Swing builds on
- <doc:ImplementingAToolkit> — how the platform rendering backend works
