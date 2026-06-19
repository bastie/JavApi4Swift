# Java 1.1

<!--
* SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

1997-02-19 release of Java 1.1.

## Overview

Java 1.1 introduced the delegation event model, inner classes, JavaBeans, JDBC, RMI, reflection, and significant AWT improvements.

### How to read?

- Header type name (count of fields or methods/ count of implemented of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

## Java Core Packages

### java.lang

Changes relative to 1.0 — already tracked in Java_1.0.md where version column shows `1.1`.

Key additions already implemented:

- `Boolean.getBoolean(String)` — case-insensitive variant ✔️
- `Character.getNumericValue(char)` ✔️
- `Character.isWhitespace(char)` ✔️

### java.io

#### java.io.Reader / Writer (new character-stream hierarchy)

##### java.io.Reader (3/3/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | read()         | ()->int
1.1     | ✔️          | 🪄       | method        | read()         | (char[])->int
1.1     | ✔️          | 🪄       | method        | close()        | ()

##### java.io.Writer (3/3/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | write()        | (int)
1.1     | ✔️          | 🪄       | method        | write()        | (char[])
1.1     | ✔️          | 🪄       | method        | close()        | ()

## Java UI Packages

> **Note — Swing / JFC already integrated:** In the Java 1.1 era, Swing was
> not yet part of the standard JDK. It was distributed separately as the
> **Java Foundation Classes (JFC) 1.1** add-on library (`swingall.jar` /
> `jfc.jar`), released in March 1997 alongside the Java 1.1 release.
> Developers had to bundle and reference this JAR explicitly.
>
> In JavApi4Swift, Swing (`javax.swing`) is **not** kept separate — it is
> already integrated directly into the library alongside `java.awt`. The
> Swing API coverage is tracked in ``Java_1.2`` (where Swing became part of
> the standard JDK for the first time).

### java.awt — Java 1.1 additions

Java 1.1 replaced the 1.0 event model with the delegation event model and added several new classes.

#### Delegation Event Model (java.awt.event)

All listener interfaces and event classes are implemented.

##### java.awt.event.ActionEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | ActionEvent    | with ACTION_PERFORMED, getActionCommand(), getModifiers()

##### java.awt.event.ActionListener (1/1/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | actionPerformed() | (ActionEvent)

##### java.awt.event.AdjustmentEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | AdjustmentEvent | with UNIT_INCREMENT, UNIT_DECREMENT, BLOCK_INCREMENT, BLOCK_DECREMENT, TRACK

##### java.awt.event.AdjustmentListener (1/1/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | adjustmentValueChanged() | (AdjustmentEvent)

##### java.awt.event.ComponentEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | ComponentEvent | with COMPONENT_MOVED, COMPONENT_RESIZED, COMPONENT_SHOWN, COMPONENT_HIDDEN

##### java.awt.event.ComponentListener (4/4/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | componentMoved()   | (ComponentEvent)
1.1     | ✔️          | 🪄       | method        | componentResized() | (ComponentEvent)
1.1     | ✔️          | 🪄       | method        | componentShown()   | (ComponentEvent)
1.1     | ✔️          | 🪄       | method        | componentHidden()  | (ComponentEvent)

##### java.awt.event.FocusEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | FocusEvent     | with FOCUS_GAINED, FOCUS_LOST

##### java.awt.event.FocusListener (2/2/✔️)  — see ComponentListener

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | focusGained()  | (FocusEvent)
1.1     | ✔️          | 🪄       | method        | focusLost()    | (FocusEvent)

##### java.awt.event.InputEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | class         | InputEvent     | base for KeyEvent and MouseEvent; SHIFT_MASK, CTRL_MASK, META_MASK, ALT_MASK

##### java.awt.event.ItemEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | ItemEvent      | with SELECTED, DESELECTED, getItem(), getStateChange()

##### java.awt.event.ItemListener (1/1/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | itemStateChanged() | (ItemEvent)

##### java.awt.event.KeyEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | KeyEvent       | with KEY_PRESSED, KEY_RELEASED, KEY_TYPED; VK_* constants; getKeyCode(), getKeyChar()

##### java.awt.event.KeyListener (3/3/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | keyPressed()   | (KeyEvent)
1.1     | ✔️          | 🪄       | method        | keyReleased()  | (KeyEvent)
1.1     | ✔️          | 🪄       | method        | keyTyped()     | (KeyEvent)

##### java.awt.event.MouseEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | MouseEvent     | with MOUSE_CLICKED, MOUSE_PRESSED, MOUSE_RELEASED, MOUSE_ENTERED, MOUSE_EXITED, MOUSE_MOVED, MOUSE_DRAGGED; getX(), getY(), getClickCount()

##### java.awt.event.MouseListener (5/5/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | mouseClicked() | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mouseEntered() | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mouseExited()  | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mousePressed() | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mouseReleased()| (MouseEvent)

##### java.awt.event.MouseMotionListener (2/2/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | mouseDragged() | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mouseMoved()   | (MouseEvent)

##### java.awt.event.TextEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | TextEvent      | with TEXT_VALUE_CHANGED

##### java.awt.event.TextListener (1/1/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | textValueChanged() | (TextEvent)

##### java.awt.event.WindowEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | WindowEvent    | with WINDOW_OPENED, WINDOW_CLOSING, WINDOW_CLOSED, WINDOW_ICONIFIED, WINDOW_DEICONIFIED, WINDOW_ACTIVATED, WINDOW_DEACTIVATED

##### java.awt.event.WindowListener (7/7/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | windowOpened()      | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowClosing()     | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowClosed()      | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowIconified()   | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowDeiconified() | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowActivated()   | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowDeactivated() | (WindowEvent)

#### Printing (new in 1.1)

##### java.awt.PrintJob (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | getGraphics()  | ()->Graphics — returns a Graphics for the next page
1.1     | ⭕️          | ⭕️       | method        | getPageDimension() | ()->Dimension
1.1     | ⭕️          | ⭕️       | method        | getPageResolution() | ()->int — DPI
1.1     | ⭕️          | ⭕️       | method        | lastPageFirst() | ()->boolean
1.1     | ⭕️          | ⭕️       | method        | end()          | () — finishes the print job

> **Note:** `PrintJob` instances are obtained from `Toolkit.getPrintJob(frame, jobTitle, properties)`. The printing API introduced in Java 1.1 was superseded by `java.awt.print` (Java 1.2) and `javax.print` (Java 1.4).

##### java.awt.Toolkit — getPrintJob() (1.1 addition)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | getPrintJob()  | (Frame,String,Properties)->PrintJob

#### New / extended AWT classes

##### java.awt.AWTEvent (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | AWTEvent       | base for all 1.1 events; getID(), getSource(), consume()

##### java.awt.Cursor (0/0/✔️)

Already tracked in Java_1.0.md (version column `1.1`). All constants and methods implemented ✔️.

##### java.awt.MenuShortcut (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | MenuShortcut   | with key, usesShift, getKey(), usesShiftModifier(), equals()

##### java.awt.PopupMenu (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | PopupMenu      | extends Menu; show(Component,int,int); AppKit native on macOS

##### java.awt.ScrollPane (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | final field   | SCROLLBARS_AS_NEEDED  | int
1.1     | ✔️          | ⭕️       | final field   | SCROLLBARS_ALWAYS     | int
1.1     | ✔️          | ⭕️       | final field   | SCROLLBARS_NEVER      | int
1.1     | ✔️          | ⭕️       | constructor   | ScrollPane()          | ()
1.1     | ✔️          | ⭕️       | constructor   | ScrollPane()          | (int)
1.1     | ✔️          | ⭕️       | method        | getScrollPosition()   | ()->Point
1.1     | ✔️          | ⭕️       | method        | setScrollPosition()   | (int,int)
1.1     | ✔️          | ⭕️       | method        | getViewportSize()     | ()->Dimension

##### java.awt.LayoutManager2 (5/5/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | addLayoutComponent() | (Component,Object)
1.1     | ✔️          | 🪄       | method        | maximumLayoutSize()  | (Container)->Dimension
1.1     | ✔️          | 🪄       | method        | getLayoutAlignmentX()| (Container)->float
1.1     | ✔️          | 🪄       | method        | getLayoutAlignmentY()| (Container)->float
1.1     | ✔️          | 🪄       | method        | invalidateLayout()   | (Container)

##### java.awt.GridBagLayout (4/4/✔️)

> **Step 2 (complete)** — gridx/gridy/gridwidth/gridheight, fill, anchor, insets,
> ipadx/ipady, weightx/weighty extra-space distribution, and RELATIVE/REMAINDER
> automatic placement are all implemented.

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | 🪄       | final field   | MAXGRIDSIZE       | int
1.0.2   | ✔️          | 🪄       | final field   | MINSIZE           | int
1.0.2   | ✔️          | 🪄       | final field   | PREFERREDSIZE     | int
1.0.2   | ✔️          | ⭕️       | constructor   | GridBagLayout()   |
1.0.2   | ✔️          | ⭕️       | method        | setConstraints()  | (Component,GridBagConstraints)
1.0.2   | ✔️          | ⭕️       | method        | getConstraints()  | (Component)->GridBagConstraints
1.0.2   | ✔️          | ⭕️       | method        | lookupConstraints()| (Component)->GridBagConstraints
1.0.2   | ✔️          | ⭕️       | method        | layoutContainer() | (Container)
1.0.2   | ✔️          | ⭕️       | method        | preferredLayoutSize()| (Container)->Dimension
1.0.2   | ✔️          | 🪄       | method        | minimumLayoutSize()  | (Container)->Dimension
1.0.2   | ✔️          | 🪄       | method        | maximumLayoutSize()  | (Container)->Dimension
1.0.2   | ✔️          | ⭕️       | field         | weightx/weighty   | extra-space distributed proportionally
1.0.2   | ✔️          | ⭕️       | field         | ipadx/ipady       | internal padding applied to preferred size
1.0.2   | ✔️          | ⭕️       | field         | RELATIVE/REMAINDER | auto-placement fully implemented

##### java.awt.GridBagConstraints (15/15/✔️)

Already tracked and fully implemented — see Java_1.0.md.

#### Component — 1.1 listener additions (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | addMouseListener()        | (MouseListener)
1.1     | ✔️          | ⭕️       | method        | removeMouseListener()     | (MouseListener)
1.1     | ✔️          | ⭕️       | method        | addMouseMotionListener()  | (MouseMotionListener)
1.1     | ✔️          | ⭕️       | method        | removeMouseMotionListener()| (MouseMotionListener)
1.1     | ✔️          | ⭕️       | method        | addKeyListener()          | (KeyListener)
1.1     | ✔️          | ⭕️       | method        | removeKeyListener()       | (KeyListener)
1.1     | ✔️          | ⭕️       | method        | addFocusListener()        | (FocusListener)
1.1     | ✔️          | ⭕️       | method        | removeFocusListener()     | (FocusListener)
1.1     | ✔️          | ⭕️       | method        | addComponentListener()    | (ComponentListener)
1.1     | ✔️          | ⭕️       | method        | removeComponentListener() | (ComponentListener)
1.1     | ✔️          | ⭕️       | method        | setCursor()               | (Cursor)
1.1     | ✔️          | ⭕️       | method        | getCursor()               | ()->Cursor
1.1     | ✔️          | ⭕️       | method        | setEnabled()              | (boolean)
1.1     | ✔️          | ⭕️       | method        | isEnabled()               | ()->boolean
1.1     | ✔️          | ⭕️       | method        | setVisible()              | (boolean)
1.1     | ✔️          | ⭕️       | method        | isVisible()               | ()->boolean
1.1     | ✔️          | ⭕️       | method        | setLocation()             | (int,int)
1.1     | ✔️          | ⭕️       | method        | getLocation()             | ()->Point
1.1     | ✔️          | ⭕️       | method        | setSize()                 | (int,int)
1.1     | ✔️          | ⭕️       | method        | getSize()                 | ()->Dimension
1.1     | ✔️          | ⭕️       | method        | setFont()                 | (Font)
1.1     | ✔️          | ⭕️       | method        | getFont()                 | ()->Font
1.1     | ✔️          | ⭕️       | method        | setBackground()           | (Color)
1.1     | ✔️          | ⭕️       | method        | getBackground()           | ()->Color
1.1     | ✔️          | ⭕️       | method        | setForeground()           | (Color)
1.1     | ✔️          | ⭕️       | method        | getForeground()           | ()->Color

#### Container — 1.1 additions (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | setLayout()    | (LayoutManager)
1.1     | ✔️          | ⭕️       | method        | getLayout()    | ()->LayoutManager
1.1     | ✔️          | ⭕️       | method        | doLayout()     | ()
1.1     | ✔️          | ⭕️       | method        | validate()     | ()
1.1     | ✔️          | ⭕️       | method        | invalidate()   | ()
1.1     | ✔️          | ⭕️       | method        | add()          | (Component,Object)
1.1     | ✔️          | ⭕️       | method        | remove()       | (Component)
1.1     | ✔️          | ⭕️       | method        | removeAll()    | ()

##### java.awt.FontMetrics (9/9/⭕️)

> **Note:** `FontMetrics` is an abstract class. On Apple platforms the concrete
> implementation is `CoreTextFontMetrics` (backed by `CTFont`). On all other
> platforms a proportional-approximation fallback is used. Instances are
> obtained via `Graphics.getFontMetrics()` or `Graphics.getFontMetrics(Font)`.

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0     | ✔️          | ⭕️       | constructor   | FontMetrics()     | (Font) — protected
1.0     | ✔️          | ⭕️       | method        | getFont()         | ()->Font
1.0     | ✔️          | ⭕️       | method        | getAscent()       | ()->int — CoreText: CTFontGetAscent; fallback: font.size×0.75
1.0     | ✔️          | ⭕️       | method        | getDescent()      | ()->int — CoreText: CTFontGetDescent; fallback: font.size×0.20
1.0     | ✔️          | ⭕️       | method        | getLeading()      | ()->int — CoreText: CTFontGetLeading; fallback: font.size×0.10
1.0     | ✔️          | ⭕️       | method        | getHeight()       | ()->int — ascent + descent + leading (final)
1.0     | ✔️          | ⭕️       | method        | getMaxAscent()    | ()->int
1.0     | ✔️          | ⭕️       | method        | getMaxDescent()   | ()->int
1.0     | ✔️          | ⭕️       | method        | getMaxAdvance()   | ()->int — CoreText: advance of 'M'; fallback: -1
1.0     | ✔️          | ⭕️       | method        | charWidth()       | (char)->int — CoreText: CTLine width; fallback: font.size×0.60
1.0     | ✔️          | ⭕️       | method        | charsWidth()      | (char[],int,int)->int
1.0     | ✔️          | ⭕️       | method        | stringWidth()     | (String)->int — CoreText: CTLineGetTypographicBounds
1.0     | ✔️          | ⭕️       | method        | getWidths()       | ()->[int] — widths of first 256 Unicode scalars

## Java Core Packages — Continued

### java.io — Character-Stream Hierarchy (new in 1.1)

#### Concrete Reader implementations

##### java.io.BufferedReader (3/3/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | BufferedReader()     | (Reader)
1.1     | ✔️          | ⭕️       | constructor   | BufferedReader()     | (Reader,int)
1.1     | ✔️          | ⭕️       | method        | readLine()           | ()->String?

##### java.io.CharArrayReader (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | CharArrayReader()    | (char[])
1.1     | ✔️          | ⭕️       | constructor   | CharArrayReader()    | (char[],int,int)

##### java.io.FileReader (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | FileReader()         | (File)
1.1     | ✔️          | ⭕️       | constructor   | FileReader()         | (String)

##### java.io.FilterReader (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | FilterReader()       | (Reader)

##### java.io.InputStreamReader (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | InputStreamReader()  | (InputStream)
1.1     | ✔️          | ⭕️       | constructor   | InputStreamReader()  | (InputStream,String) — charset name

##### java.io.LineNumberReader (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | LineNumberReader()   | (Reader)
1.1     | ✔️          | ⭕️       | method        | getLineNumber()      | ()->int

##### java.io.PipedReader (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | PipedReader()        | ()
1.1     | ✔️          | ⭕️       | constructor   | PipedReader()        | (PipedWriter)

##### java.io.PushbackReader (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | PushbackReader()     | (Reader)
1.1     | ✔️          | ⭕️       | constructor   | PushbackReader()     | (Reader,int)

##### java.io.StringReader (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | StringReader()       | (String)

#### Concrete Writer implementations

##### java.io.BufferedWriter (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | BufferedWriter()     | (Writer)
1.1     | ✔️          | ⭕️       | constructor   | BufferedWriter()     | (Writer,int)
1.1     | ✔️          | ⭕️       | method        | newLine()            | ()

##### java.io.CharArrayWriter (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | CharArrayWriter()    | ()
1.1     | ✔️          | ⭕️       | constructor   | CharArrayWriter()    | (int)
1.1     | ✔️          | ⭕️       | method        | toCharArray()        | ()->char[]
1.1     | ✔️          | ⭕️       | method        | reset()              | ()
1.1     | ✔️          | ⭕️       | method        | size()               | ()->int

##### java.io.FileWriter (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | FileWriter()         | (File)
1.1     | ✔️          | ⭕️       | constructor   | FileWriter()         | (String)
1.1     | ✔️          | ⭕️       | constructor   | FileWriter()         | (String,boolean) — append mode

##### java.io.FilterWriter (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | FilterWriter()       | (Writer)

##### java.io.OutputStreamWriter (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | OutputStreamWriter() | (OutputStream)
1.1     | ✔️          | ⭕️       | constructor   | OutputStreamWriter() | (OutputStream,String) — charset name

##### java.io.PipedWriter (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | PipedWriter()        | ()
1.1     | ✔️          | ⭕️       | constructor   | PipedWriter()        | (PipedReader)

##### java.io.PrintWriter (5/5/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PrintWriter()        | (OutputStream)
1.1     | ✔️          | ✔️       | constructor   | PrintWriter()        | (OutputStream,boolean)
1.1     | ✔️          | ✔️       | method        | println()            | (String)
1.1     | ✔️          | ✔️       | constructor   | PrintWriter()        | (Writer)
1.1     | ✔️          | ✔️       | constructor   | PrintWriter()        | (Writer,boolean)

##### java.io.StringWriter (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | StringWriter()       | ()
1.1     | ✔️          | ⭕️       | constructor   | StringWriter()       | (int)
1.1     | ✔️          | ⭕️       | method        | getBuffer()          | ()->StringBuffer
1.1     | ✔️          | ⭕️       | method        | toString()           | ()->String

##### java.io.ObjectStreamClass (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | static method | lookup()       | (Class)->ObjectStreamClass
1.1     | ⭕️          | ⭕️       | method        | getName()      | ()->String
1.1     | ⭕️          | ⭕️       | method        | getSerialVersionUID() | ()->long

##### java.io.ObjectInputValidation (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | validateObject() | () — callback interface for serialization validation

### java.io — Object Serialization (new in 1.1)

##### java.io.Serializable (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | interface     | Serializable   | marker protocol — no methods

##### java.io.Externalizable (2/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | writeExternal() | (ObjectOutput)
1.1     | ⭕️          | ⭕️       | method        | readExternal()  | (ObjectInput)

##### java.io.ObjectOutput (5/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | writeObject()   | (Object)
1.1     | ✔️          | 🪄       | method        | write()         | (int)
1.1     | ✔️          | 🪄       | method        | write()         | (byte[])
1.1     | ✔️          | 🪄       | method        | flush()         | ()
1.1     | ✔️          | 🪄       | method        | close()         | ()

##### java.io.ObjectInput (4/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | readObject()    | ()->Object
1.1     | ✔️          | 🪄       | method        | read()          | ()->int
1.1     | ✔️          | 🪄       | method        | skip()          | (long)->long
1.1     | ✔️          | 🪄       | method        | close()         | ()

##### java.io.ObjectOutputStream (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ObjectOutputStream() | (OutputStream) — stub

##### java.io.ObjectInputStream (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ObjectInputStream()  | (InputStream) — stub

##### java.io.ObjectStreamException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ObjectStreamException() |

##### java.io.InvalidClassException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | InvalidClassException() | (String)

##### java.io.InvalidObjectException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | InvalidObjectException() | (String)

##### java.io.NotActiveException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | NotActiveException() | (String)

##### java.io.NotSerializableException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | NotSerializableException() | (String)

##### java.io.OptionalDataException (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | field         | eof            | boolean
1.1     | ✔️          | ⭕️       | field         | length         | int

##### java.io.StreamCorruptedException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | StreamCorruptedException() | (String)

##### java.io.WriteAbortedException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | WriteAbortedException() | (String,Exception)

### java.util — New in 1.1

##### java.util.EventObject (2/2/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | EventObject()  | (Object source)
1.1     | ✔️          | ⭕️       | method        | getSource()    | ()->Object

##### java.util.EventListener (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | interface     | EventListener  | marker protocol — no methods

##### java.util.Calendar (0/0/⭕️)

> **Note:** Calendar is a large abstract class. Only the most commonly used public API is listed.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | getInstance()  | ()->Calendar
1.1     | ✔️          | ⭕️       | static method | getInstance()  | (Locale)->Calendar
1.1     | ✔️          | ⭕️       | method        | get()          | (int)->int
1.1     | ✔️          | ⭕️       | method        | set()          | (int,int)
1.1     | ✔️          | ⭕️       | method        | getTime()      | ()->Date
1.1     | ✔️          | ⭕️       | method        | setTime()      | (Date)
1.1     | ✔️          | ⭕️       | final field   | YEAR, MONTH, DAY_OF_MONTH, HOUR, MINUTE, SECOND, MILLISECOND, … | int constants

##### java.util.GregorianCalendar (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | GregorianCalendar()  | ()
1.1     | ✔️          | ⭕️       | constructor   | GregorianCalendar()  | (int,int,int)
1.1     | ✔️          | ⭕️       | method        | isLeapYear()         | (int)->boolean

##### java.util.Locale (0/0/✔️)

> **Note:** Locale delegates to `Foundation.Locale` internally. Constants use the same `init(String)` path and are backed by `Foundation.Locale(identifier:)`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | Locale()       | (String language)
1.1     | ✔️          | ✔️       | constructor   | Locale()       | (String language, String country)
1.1     | ✔️          | ✔️       | static method | getDefault()   | ()->Locale
1.1     | ✔️          | ✔️       | method        | getLanguage()  | ()->String
1.1     | ✔️          | ✔️       | method        | getCountry()   | ()->String
1.1     | ✔️          | ✔️       | static field  | ENGLISH, FRENCH, GERMAN, ITALIAN, JAPANESE, KOREAN, CHINESE | language-only constants
1.1     | ✔️          | ✔️       | static field  | US, UK, CANADA, FRANCE, GERMANY, ITALY, JAPAN, KOREA, CHINA | country/region constants

##### java.util.TimeZone (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | getDefault()    | ()->TimeZone
1.1     | ✔️          | ⭕️       | static method | getTimeZone()   | (String)->TimeZone
1.1     | ✔️          | ⭕️       | method        | getID()         | ()->String
1.1     | ✔️          | ⭕️       | method        | getRawOffset()  | ()->int

### java.lang.reflect — New package in 1.1

> **🔴 KRITISCH - KOMPLETT FEHLEND**
> 
> **Status:** NICHT IMPLEMENTIERT (0/8 Klassen) — Das komplette Paket fehlt!
> 
> Das ist eine fundamentale Lücke für JavApi4Swift. Reflection ist essentiell für:
> - Dynamisches Methoden-Aufrufen
> - Dynamisches Feld-Zugriff
> - Dynamisches Instanzen-Erstellen
> - Beans-Introspection
> 
> Ohne diese API ist keine echte dynamische Programmierung möglich.

##### java.lang.reflect.Field (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | get()          | (Object)->Object
1.1     | ⭕️          | ⭕️       | method        | set()          | (Object,Object)
1.1     | ⭕️          | ⭕️       | method        | getName()      | ()->String
1.1     | ⭕️          | ⭕️       | method        | getType()      | ()->Class

##### java.lang.reflect.Method (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | invoke()       | (Object,Object[])->Object
1.1     | ⭕️          | ⭕️       | method        | getName()      | ()->String
1.1     | ⭕️          | ⭕️       | method        | getReturnType()| ()->Class
1.1     | ⭕️          | ⭕️       | method        | getParameterTypes() | ()->Class[]

##### java.lang.reflect.Constructor (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | newInstance()  | (Object[])->Object
1.1     | ⭕️          | ⭕️       | method        | getName()      | ()->String
1.1     | ⭕️          | ⭕️       | method        | getParameterTypes() | ()->Class[]

##### java.lang.reflect.Modifier (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | static method | isPublic()     | (int)->boolean
1.1     | ⭕️          | ⭕️       | static method | isStatic()     | (int)->boolean
1.1     | ⭕️          | ⭕️       | static method | isFinal()      | (int)->boolean
1.1     | ⭕️          | ⭕️       | static field  | PUBLIC, STATIC, FINAL, … | int constants

##### java.lang.reflect.Array (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | static method | newInstance()  | (Class,int)->Object
1.1     | ⭕️          | ⭕️       | static method | getLength()    | (Object)->int
1.1     | ⭕️          | ⭕️       | static method | get()          | (Object,int)->Object
1.1     | ⭕️          | ⭕️       | static method | set()          | (Object,int,Object)

##### java.lang.reflect.AccessibleObject (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | setAccessible()| (boolean)
1.1     | ⭕️          | ⭕️       | method        | isAccessible() | ()->boolean

##### java.lang.reflect.Member (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | interface     | Member         | getDeclaringClass(), getName(), getModifiers()

##### java.lang.reflect.InvocationTargetException (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | constructor   | InvocationTargetException() | (Throwable)
1.1     | ⭕️          | ⭕️       | method        | getTargetException() | ()->Throwable

#### java.lang.Class — Reflection additions (1.1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | getDeclaredFields()      | ()->Field[]
1.1     | ⭕️          | ⭕️       | method        | getDeclaredMethods()     | ()->Method[]
1.1     | ⭕️          | ⭕️       | method        | getDeclaredConstructors()| ()->Constructor[]
1.1     | ⭕️          | ⭕️       | method        | getFields()              | ()->Field[]
1.1     | ⭕️          | ⭕️       | method        | getMethods()             | ()->Method[]
1.1     | ⭕️          | ⭕️       | method        | getConstructors()        | ()->Constructor[]
1.1     | ⭕️          | ⭕️       | method        | getModifiers()           | ()->int

### java.lang — New wrapper classes in 1.1

##### java.lang.Byte (0/0/✔️)

> **Note:** `byte` in this project is `UInt8` for Swift compatibility. Therefore `Byte` wraps `UInt8`.
> `MIN_VALUE` / `MAX_VALUE` alias `UMIN_VALUE` (0) / `UMAX_VALUE` (255).
> Signed Java constants `SMIN_VALUE` (-128) / `SMAX_VALUE` (127) and `parseSignedByte()` / `signedByteValue()` are in `Byte+Java.swift`.

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | ✔️       | final field   | UMIN_VALUE / MIN_VALUE | UInt8 = 0 (unsigned project-byte minimum)
1.1     | ✔️          | ✔️       | final field   | UMAX_VALUE / MAX_VALUE | UInt8 = 255 (unsigned project-byte maximum)
1.1     | ✔️          | ✔️       | final field   | SMIN_VALUE          | Int8 = -128 (signed Java byte minimum, Byte+Java.swift)
1.1     | ✔️          | ✔️       | final field   | SMAX_VALUE          | Int8 = 127 (signed Java byte maximum, Byte+Java.swift)
1.1     | ✔️          | ✔️       | constructor   | Byte()              | (UInt8)
1.1     | ✔️          | ✔️       | static method | parseByte()         | (String)->UInt8 (unsigned)
1.1     | ✔️          | ✔️       | static method | parseSignedByte()   | (String)->Int8 (Byte+Java.swift)
1.1     | ✔️          | ✔️       | static method | valueOf()           | (String)->Byte
1.1     | ✔️          | ✔️       | method        | byteValue()         | ()->UInt8
1.1     | ✔️          | ✔️       | method        | signedByteValue()   | ()->Int8 (Byte+Java.swift)
1.1     | ✔️          | ✔️       | method        | equals()            | via Equatable
1.1     | ✔️          | ✔️       | method        | toString()          | ()->String

##### java.lang.Short (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | final field   | MIN_VALUE      | Int16 = -32768
1.1     | ✔️          | ✔️       | final field   | MAX_VALUE      | Int16 = 32767
1.1     | ✔️          | ✔️       | constructor   | Short()        | (Int16)
1.1     | ✔️          | ✔️       | static method | parseShort()   | (String)->Int16
1.1     | ✔️          | ✔️       | static method | valueOf()      | (String)->Short
1.1     | ✔️          | ✔️       | method        | shortValue()   | ()->Int16
1.1     | ✔️          | ✔️       | method        | equals()       | via Equatable
1.1     | ✔️          | ✔️       | method        | toString()     | ()->String

##### java.lang.Void (0/0/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | class         | Void           | uninstantiable placeholder; used as type argument for void return types

### java.net — 1.1 additions

##### java.net.URLEncoder.encode(String,String) — already tracked above ✔️

##### java.net.DatagramSocketImpl (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | class         | DatagramSocketImpl | abstract base for datagram socket implementations

##### java.net.HttpURLConnection (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | getResponseCode() | ()->int
1.1     | ⭕️          | ⭕️       | method        | getResponseMessage() | ()->String
1.1     | ⭕️          | ⭕️       | method        | setRequestMethod() | (String)
1.1     | ⭕️          | ⭕️       | method        | disconnect()   | ()
1.1     | ⭕️          | ⭕️       | final field   | HTTP_OK, HTTP_NOT_FOUND, HTTP_MOVED_PERM, … | int constants

##### java.net.MulticastSocket (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | constructor   | MulticastSocket() | ()
1.1     | ⭕️          | ⭕️       | constructor   | MulticastSocket() | (int port)
1.1     | ⭕️          | ⭕️       | method        | joinGroup()    | (InetAddress)
1.1     | ⭕️          | ⭕️       | method        | leaveGroup()   | (InetAddress)

##### java.net.FileNameMap (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ⭕️          | ⭕️       | method        | getContentTypeFor() | (String)->String — interface

### java.util — Internationalization additions in 1.1 (continued)

##### java.util.ResourceBundle (4/4/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | getBundle()    | (String)->ResourceBundle
1.1     | ✔️          | ⭕️       | static method | getBundle()    | (String,Locale)->ResourceBundle
1.1     | ✔️          | ⭕️       | method        | getString()    | (String)->String
1.1     | ✔️          | ⭕️       | method        | getObject()    | (String)->Object

##### java.util.ListResourceBundle (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | ListResourceBundle | abstract subclass of ResourceBundle backed by a list of key/value pairs

##### java.util.PropertyResourceBundle (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | PropertyResourceBundle() | ()
1.1     | ✔️          | ⭕️       | constructor   | PropertyResourceBundle() | (InputStream)

##### java.util.SimpleTimeZone (5/5/✔️)

> **Note:** `@available(*, deprecated)` — deprecated in Java 26 for removal. Use `java.time.ZoneId` / `ZonedDateTime` instead.
> DST rule parameters in the long constructor are accepted for API compatibility; actual DST logic is delegated to `Foundation.TimeZone`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | SimpleTimeZone() | (int rawOffset, String ID)
1.1     | ✔️          | ✔️       | constructor   | SimpleTimeZone() | (int,String,int,int,int,int,int,int,int,int) — with DST rules
1.1     | ✔️          | ✔️       | method        | getID()          | ()->String
1.1     | ✔️          | ✔️       | method        | getRawOffset()   | ()->int — milliseconds
1.1     | ✔️          | ✔️       | method        | inDaylightTime() | (Date)->boolean

### java.math — New package in 1.1

##### java.math.BigInteger (0/0/⭕️)

> **Note:** Fully implemented — see `Sources/JavApi/math/BigInteger.swift`. Only key API listed here.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | BigInteger()   | (String)
1.1     | ✔️          | ⭕️       | constructor   | BigInteger()   | (String,int radix)
1.1     | ✔️          | ⭕️       | static field  | ZERO, ONE, TEN | BigInteger constants
1.1     | ✔️          | ⭕️       | method        | add()          | (BigInteger)->BigInteger
1.1     | ✔️          | ⭕️       | method        | subtract()     | (BigInteger)->BigInteger
1.1     | ✔️          | ⭕️       | method        | multiply()     | (BigInteger)->BigInteger
1.1     | ✔️          | ⭕️       | method        | divide()       | (BigInteger)->BigInteger
1.1     | ✔️          | ⭕️       | method        | mod()          | (BigInteger)->BigInteger
1.1     | ✔️          | ⭕️       | method        | abs()          | ()->BigInteger
1.1     | ✔️          | ⭕️       | method        | negate()       | ()->BigInteger
1.1     | ✔️          | ⭕️       | method        | compareTo()    | (BigInteger)->int
1.1     | ✔️          | ⭕️       | method        | toString()     | ()->String
1.1     | ✔️          | ⭕️       | method        | intValue()     | ()->int
1.1     | ✔️          | ⭕️       | method        | longValue()    | ()->long

##### java.math.BigDecimal (0/0/⭕️)

> **Note:** Implemented as `typealias BigDecimal = Decimal` (Swift Foundation). Key API listed.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | BigDecimal()   | (String)
1.1     | ✔️          | ⭕️       | constructor   | BigDecimal()   | (double)
1.1     | ✔️          | ⭕️       | method        | add()          | (BigDecimal)->BigDecimal
1.1     | ✔️          | ⭕️       | method        | subtract()     | (BigDecimal)->BigDecimal
1.1     | ✔️          | ⭕️       | method        | multiply()     | (BigDecimal)->BigDecimal
1.1     | ✔️          | ⭕️       | method        | divide()       | (BigDecimal,int,int)->BigDecimal
1.1     | ✔️          | ⭕️       | method        | compareTo()    | (BigDecimal)->int
1.1     | ✔️          | ⭕️       | method        | toString()     | ()->String
1.1     | ✔️          | ⭕️       | method        | doubleValue()  | ()->double

### java.security — New package in 1.1

> **Note:** Only the subset relevant for JavApi is implemented. Full java.security.acl and java.security.interfaces are not in scope.

##### java.security.MessageDigest (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | getInstance()  | (String)->MessageDigest
1.1     | ✔️          | ⭕️       | method        | update()       | (byte[])
1.1     | ✔️          | ⭕️       | method        | digest()       | ()->byte[]
1.1     | ✔️          | ⭕️       | method        | reset()        | ()

##### java.security.SecureRandom (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | SecureRandom() | ()
1.1     | ✔️          | ⭕️       | method        | nextBytes()    | (byte[])

##### java.security.Provider (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | getName()      | ()->String
1.1     | ✔️          | ⭕️       | method        | getVersion()   | ()->double

##### java.security.GeneralSecurityException (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | GeneralSecurityException() | (String)

##### java.security.NoSuchAlgorithmException (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | NoSuchAlgorithmException() | (String)

### java.beans — New package in 1.1 (partial)

Only the bound-property and veto-change subset needed for JFC 1.0 / Swing is implemented.
Reflection-based introspection (`BeanDescriptor`, `BeanInfo`, `Introspector`, `MethodDescriptor`, …) is not in scope.

##### java.beans.PropertyChangeEvent (4/4/✔️)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PropertyChangeEvent() | (Object,String,Object,Object)
1.1     | ✔️          | ✔️       | method        | getPropertyName()     | ()->String?
1.1     | ✔️          | ✔️       | method        | getOldValue()         | ()->Object?
1.1     | ✔️          | ✔️       | method        | getNewValue()         | ()->Object?
1.1     | ✔️          | ✔️       | method        | setPropagationId()    | (Object?)
1.1     | ✔️          | ✔️       | method        | getPropagationId()    | ()->Object?

##### java.beans.PropertyChangeListener (1/1/✔️)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | propertyChange()      | (PropertyChangeEvent)

##### java.beans.PropertyChangeSupport (8/8/✔️)

version | implemented | tested   | type          | name                              | more informations
------- | ----------- | -------- | ------------- | --------------------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PropertyChangeSupport()           | (Object sourceBean)
1.1     | ✔️          | ✔️       | method        | addPropertyChangeListener()       | (PropertyChangeListener)
1.1     | ✔️          | ✔️       | method        | addPropertyChangeListener()       | (String,PropertyChangeListener)
1.1     | ✔️          | ✔️       | method        | removePropertyChangeListener()    | (PropertyChangeListener)
1.1     | ✔️          | ✔️       | method        | removePropertyChangeListener()    | (String,PropertyChangeListener)
1.1     | ✔️          | ✔️       | method        | getPropertyChangeListeners()      | ()->[PropertyChangeListener]
1.1     | ✔️          | ✔️       | method        | getPropertyChangeListeners()      | (String)->[PropertyChangeListener]
1.1     | ✔️          | ✔️       | method        | hasListeners()                    | (String)->boolean
1.1     | ✔️          | ✔️       | method        | firePropertyChange()              | (PropertyChangeEvent)
1.1     | ✔️          | ✔️       | method        | firePropertyChange()              | (String,Object,Object)
1.1     | ✔️          | ✔️       | method        | firePropertyChange()              | (String,int,int)
1.1     | ✔️          | ✔️       | method        | firePropertyChange()              | (String,boolean,boolean)

##### java.beans.PropertyVetoException (1/1/✔️)

version | implemented | tested   | type          | name                      | more informations
------- | ----------- | -------- | ------------- | ------------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PropertyVetoException()   | (String,PropertyChangeEvent)
1.1     | ✔️          | ✔️       | method        | getPropertyChangeEvent()  | ()->PropertyChangeEvent

##### java.beans.VetoableChangeListener (1/1/✔️)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | vetoableChange()      | (PropertyChangeEvent) throws

##### java.beans.VetoableChangeSupport (8/8/✔️)

version | implemented | tested   | type          | name                              | more informations
------- | ----------- | -------- | ------------- | --------------------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | VetoableChangeSupport()           | (Object sourceBean)
1.1     | ✔️          | ✔️       | method        | addVetoableChangeListener()       | (VetoableChangeListener)
1.1     | ✔️          | ✔️       | method        | addVetoableChangeListener()       | (String,VetoableChangeListener)
1.1     | ✔️          | ✔️       | method        | removeVetoableChangeListener()    | (VetoableChangeListener)
1.1     | ✔️          | ✔️       | method        | removeVetoableChangeListener()    | (String,VetoableChangeListener)
1.1     | ✔️          | ✔️       | method        | getVetoableChangeListeners()      | ()->[VetoableChangeListener]
1.1     | ✔️          | ✔️       | method        | getVetoableChangeListeners()      | (String)->[VetoableChangeListener]
1.1     | ✔️          | ✔️       | method        | hasListeners()                    | (String)->boolean
1.1     | ✔️          | ✔️       | method        | fireVetoableChange()              | (PropertyChangeEvent) throws
1.1     | ✔️          | ✔️       | method        | fireVetoableChange()              | (String,Object,Object) throws
1.1     | ✔️          | ✔️       | method        | fireVetoableChange()              | (String,int,int) throws
1.1     | ✔️          | ✔️       | method        | fireVetoableChange()              | (String,boolean,boolean) throws

### java.awt.datatransfer — New package in 1.1 (not in scope)

> **Note:** Clipboard/data-transfer infrastructure has no meaningful cross-platform Swift equivalent and is **not ported**. See "Not in scope" section.
> 
> **AKTUELLER STATUS:** ⭕️ **KOMPLETT FEHLEND** (0/6 Klassen)
> 
> Das Paket existiert nicht. Enthält:
> - Clipboard, ClipboardOwner, DataFlavor, Transferable, StringSelection, UnsupportedFlavorException

### java.text — New package in 1.1 (partially implemented - 35% coverage)

> **AKTUELLER STATUS:** ⚠️ **TEILWEISE IMPLEMENTIERT** (4/12 Klassen vorhanden)
> 
> **Vorhanden:**
> - Format (base), NumberFormat, DateFormat, SimpleDateFormat
> - ParseException, ParsePosition, FieldPosition
> 
> **Fehlend (65%):**
> - DecimalFormat, MessageFormat, ChoiceFormat (KRITISCH für Formatierung)
> - Collator, RuleBasedCollator, CollationKey (KRITISCH für Internationalisierung)
> - AttributedString, AttributedCharacterIterator, Annotation

Core formatting classes are now ported and back `JFormattedTextField` as well as `String.format()` / `java.util.Formatter`.

##### java.text.Format (abstract base)

version | implemented | tested   | type          | name                                      | more informations
------- | ----------- | -------- | ------------- | ----------------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | format(Object, StringBuffer, FieldPosition) | abstract
1.1     | ✔️          | ⭕️       | method        | parseObject(String, ParsePosition)        | abstract
1.1     | ✔️          | ⭕️       | method        | format(Object)                            | convenience

##### java.text.FieldPosition

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | FieldPosition(int)  |
1.1     | ✔️          | ⭕️       | method        | getField()          |
1.1     | ✔️          | ⭕️       | method        | getBeginIndex()     |
1.1     | ✔️          | ⭕️       | method        | getEndIndex()       |

##### java.text.ParsePosition

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ParsePosition(int)  |
1.1     | ✔️          | ⭕️       | method        | getIndex()          |
1.1     | ✔️          | ⭕️       | method        | setIndex(int)       |
1.1     | ✔️          | ⭕️       | method        | getErrorIndex()     |
1.1     | ✔️          | ⭕️       | method        | setErrorIndex(int)  |

##### java.text.ParseException

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ParseException(String, int)      |
1.1     | ✔️          | ⭕️       | method        | getErrorOffset()                 |

##### java.text.NumberFormat (abstract)

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | format(double/long)              |
1.1     | ✔️          | ⭕️       | method        | parse(String)                    |
1.1     | ✔️          | ⭕️       | static        | getInstance()                    |
1.1     | ✔️          | ⭕️       | static        | getIntegerInstance()             |
1.1     | ✔️          | ⭕️       | static        | getCurrencyInstance()            |
1.1     | ✔️          | ⭕️       | static        | getPercentInstance()             |

##### java.text.DateFormat (abstract)

version | implemented | tested   | type          | name                                       | more informations
------- | ----------- | -------- | ------------- | ------------------------------------------ | -----------------
1.1     | ✔️          | ⭕️       | constant      | FULL / LONG / MEDIUM / SHORT / DEFAULT     |
1.1     | ✔️          | ⭕️       | method        | format(Date)                               |
1.1     | ✔️          | ⭕️       | method        | parse(String)                              |
1.1     | ✔️          | ⭕️       | static        | getDateInstance(int)                       |
1.1     | ✔️          | ⭕️       | static        | getTimeInstance(int)                       |
1.1     | ✔️          | ⭕️       | static        | getDateTimeInstance(int, int)              |

##### java.text.SimpleDateFormat

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | SimpleDateFormat(String)         |
1.1     | ✔️          | ⭕️       | constructor   | SimpleDateFormat(String, Locale) |
1.1     | ✔️          | ⭕️       | method        | toPattern()                      |
1.1     | ✔️          | ⭕️       | method        | applyPattern(String)             |
1.1     | ✔️          | ⭕️       | method        | format(Date) / parse(String)     | inherited from DateFormat

> **Not yet ported:** `DecimalFormat`, `MessageFormat`, `ChoiceFormat`, `Collator`, `BreakIterator`, `CollationKey`.

### java.util.zip — New in 1.1 (partially implemented - 20% coverage)

> **AKTUELLER STATUS:** ⚠️ **TEILWEISE IMPLEMENTIERT** (5/19 Klassen vorhanden)
> 
> **Vorhanden (nur Checksummen):**
> - Checksum (interface), CRC32, Adler32, CRC32C, DataFormatException
> 
> **FEHLEND - KRITISCH (80%):**
> 
> STREAM-KOMPRESSION (ESSENTIELL):
> - Deflater, Inflater (Kompression/Dekompression-Algorithmen)
> - DeflaterInputStream, DeflaterOutputStream
> - InflaterInputStream, InflaterOutputStream
> 
> ZIP-ARCHIVE (ESSENTIELL):
> - ZipFile, ZipEntry, ZipInputStream, ZipOutputStream
> - ZipConstants, ZipException
> 
> OPTIONAL:
> - GZIPInputStream, GZIPOutputStream

##### java.util.zip.Checksum (2/2/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | update()       | (int)
1.1     | ✔️          | 🪄       | method        | getValue()     | ()->long
1.1     | ✔️          | 🪄       | method        | reset()        | ()

##### java.util.zip.CRC32 (1/1/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | CRC32()        | ()

##### java.util.zip.Adler32 (1/1/✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | Adler32()      | ()

##### java.util.zip.DataFormatException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | DataFormatException() | (String)

## Implementation Status Summary

### Critical Gaps (Must Implement First)

| Package | Status | Impact | Classes |
|---------|--------|--------|---------|
| **java.lang.reflect** | ❌ 0% | 🔴 CRITICAL - No dynamic programming | 8 missing |
| **java.beans (Descriptors)** | ⚠️ 26% | 🔴 CRITICAL - No introspection | 13 missing |
| **java.util.zip (Streams/Archive)** | ⚠️ 20% | 🔴 HIGH - No compression/ZIP | 14 missing |

### Important Gaps (Should Implement Soon)

| Package | Status | Impact | Classes |
|---------|--------|--------|---------|
| **java.text** | ⚠️ 35% | 🟡 MEDIUM - Missing Collation/MessageFormat | 8 missing |
| **java.security** | ⚠️ 35% | 🟡 MEDIUM - No cryptography | 24+ missing |
| **java.awt.datatransfer** | ❌ 0% | 🟡 MEDIUM - No clipboard support | 6 missing |
| **java.security.acl** | ❌ 0% | 🟡 MEDIUM - No access control | 8 missing |

### Partially Implemented (Minor Work)

| Package | Status | Impact | Classes |
|---------|--------|--------|---------|
| **java.awt.image** | ✔️ 60% | 🟢 LOW - ImageObserver missing | 7 missing |
| **java.net** | ✔️ 70% | 🟢 LOW - Minor utilities missing | 4 missing |

---

## Not in scope for this implementation

The following Java 1.1 APIs are explicitly **not** ported because they have no meaningful Swift equivalent or are platform-infrastructure concerns:

- **java.rmi**, **java.rmi.dgc**, **java.rmi.registry**, **java.rmi.server** — Remote Method Invocation requires a JVM runtime; no Swift equivalent.
- **java.sql (JDBC)** — Database connectivity is handled natively in Swift/Apple platforms via other means.
- **java.beans (BeanDescriptor, Introspector, BeanInfo, etc.)** — Reflection-based introspection API has no Swift equivalent and is not ported. Bound-property and veto support (`PropertyChangeEvent`, `PropertyChangeSupport`, `VetoableChangeSupport`, etc.) **is** implemented — see java.beans section above.
- **java.awt.datatransfer** — Clipboard infrastructure (`Clipboard`, `ClipboardOwner`, `DataFlavor`, `StringSelection`, `Transferable`, `UnsupportedFlavorException`); platform-specific, not portable.
- **java.text** (partially) — `DecimalFormat`, `MessageFormat`, `ChoiceFormat`, `Collator`, `BreakIterator` are not ported. Core classes (`Format`, `NumberFormat`, `DateFormat`, `SimpleDateFormat`, `ParseException`, `ParsePosition`, `FieldPosition`) are implemented — see java.text section above.
- **java.security.acl**, **java.security.interfaces** — ACL and key-interface sub-packages; not relevant for current scope.
- **Inner classes** — Language feature of Java, not a library API to port.
- **java.applet** additions — Applet model is obsolete.
