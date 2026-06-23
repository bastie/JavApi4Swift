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

##### java.io.Reader (9/9/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | read()         | ()->int
1.1     | ✔️          | 🪄       | method        | read()         | (char[])->int
1.1     | ✔️          | 🪄       | method        | read()         | (char[],int,int)->int — abstract
1.1     | ✔️          | 🪄       | method        | skip()         | (long)->long
1.1     | ✔️          | 🪄       | method        | ready()        | ()->boolean
1.1     | ✔️          | 🪄       | method        | markSupported()| ()->boolean
1.1     | ✔️          | 🪄       | method        | mark()         | (int)
1.1     | ✔️          | 🪄       | method        | reset()        | ()
1.1     | ✔️          | 🪄       | method        | close()        | () — abstract

##### java.io.Writer (7/7/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | write()        | (int)
1.1     | ✔️          | 🪄       | method        | write()        | (char[])
1.1     | ✔️          | 🪄       | method        | write()        | (char[],int,int) — abstract
1.1     | ✔️          | 🪄       | method        | write()        | (String)
1.1     | ✔️          | 🪄       | method        | write()        | (String,int,int)
1.1     | ✔️          | 🪄       | method        | flush()        | () — abstract
1.1     | ✔️          | 🪄       | method        | close()        | () — abstract

##### java.io.UnsupportedEncodingException (1/1/0)

version | implemented | tested   | type          | name                          | more informations
------- | ----------- | -------- | ------------- | ----------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | UnsupportedEncodingException()| () and (String)

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

##### java.awt.event.ActionEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | ActionEvent    | with ACTION_PERFORMED, getActionCommand(), getModifiers()

##### java.awt.event.ActionListener (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | actionPerformed() | (ActionEvent)

##### java.awt.event.AdjustmentEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | AdjustmentEvent | with UNIT_INCREMENT, UNIT_DECREMENT, BLOCK_INCREMENT, BLOCK_DECREMENT, TRACK

##### java.awt.event.AdjustmentListener (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | adjustmentValueChanged() | (AdjustmentEvent)

##### java.awt.event.ComponentEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | ComponentEvent | with COMPONENT_MOVED, COMPONENT_RESIZED, COMPONENT_SHOWN, COMPONENT_HIDDEN

##### java.awt.event.ComponentListener (4/4/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | componentMoved()   | (ComponentEvent)
1.1     | ✔️          | 🪄       | method        | componentResized() | (ComponentEvent)
1.1     | ✔️          | 🪄       | method        | componentShown()   | (ComponentEvent)
1.1     | ✔️          | 🪄       | method        | componentHidden()  | (ComponentEvent)

##### java.awt.event.FocusEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | FocusEvent     | with FOCUS_GAINED, FOCUS_LOST

##### java.awt.event.FocusListener (2/2/0)  — see ComponentListener

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | focusGained()  | (FocusEvent)
1.1     | ✔️          | 🪄       | method        | focusLost()    | (FocusEvent)

##### java.awt.event.InputEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | class         | InputEvent     | base for KeyEvent and MouseEvent; SHIFT_MASK, CTRL_MASK, META_MASK, ALT_MASK

##### java.awt.event.ItemEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | ItemEvent      | with SELECTED, DESELECTED, getItem(), getStateChange()

##### java.awt.event.ItemListener (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | itemStateChanged() | (ItemEvent)

##### java.awt.event.KeyEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | KeyEvent       | with KEY_PRESSED, KEY_RELEASED, KEY_TYPED; VK_* constants; getKeyCode(), getKeyChar()

##### java.awt.event.KeyListener (3/3/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | keyPressed()   | (KeyEvent)
1.1     | ✔️          | 🪄       | method        | keyReleased()  | (KeyEvent)
1.1     | ✔️          | 🪄       | method        | keyTyped()     | (KeyEvent)

##### java.awt.event.MouseEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | MouseEvent     | with MOUSE_CLICKED, MOUSE_PRESSED, MOUSE_RELEASED, MOUSE_ENTERED, MOUSE_EXITED, MOUSE_MOVED, MOUSE_DRAGGED; getX(), getY(), getClickCount()

##### java.awt.event.MouseListener (5/5/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | mouseClicked() | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mouseEntered() | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mouseExited()  | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mousePressed() | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mouseReleased()| (MouseEvent)

##### java.awt.event.MouseMotionListener (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | mouseDragged() | (MouseEvent)
1.1     | ✔️          | 🪄       | method        | mouseMoved()   | (MouseEvent)

##### java.awt.event.TextEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | TextEvent      | with TEXT_VALUE_CHANGED

##### java.awt.event.TextListener (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | textValueChanged() | (TextEvent)

##### java.awt.event.WindowEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | WindowEvent    | with WINDOW_OPENED, WINDOW_CLOSING, WINDOW_CLOSED, WINDOW_ICONIFIED, WINDOW_DEICONIFIED, WINDOW_ACTIVATED, WINDOW_DEACTIVATED

##### java.awt.event.WindowListener (7/7/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | windowOpened()      | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowClosing()     | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowClosed()      | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowIconified()   | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowDeiconified() | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowActivated()   | (WindowEvent)
1.1     | ✔️          | 🪄       | method        | windowDeactivated() | (WindowEvent)

##### java.awt.event.ContainerEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | ContainerEvent | extends ComponentEvent; COMPONENT_ADDED, COMPONENT_REMOVED, getChild(), getContainer()

##### java.awt.event.ContainerListener (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | componentAdded()   | (ContainerEvent)
1.1     | ✔️          | 🪄       | method        | componentRemoved() | (ContainerEvent)

##### java.awt.event.PaintEvent (3/3/2)

> **Note:** Implemented in `awt/event/PaintEvent.swift`. Carries the dirty
> rectangle (`updateRect`) that identifies which region of the component needs
> repainting. `PAINT_FIRST = 800`, `PAINT_LAST = 801`, `PAINT = 800`,
> `UPDATE = 801`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | class         | PaintEvent     | extends ComponentEvent
1.1     | ✔️          | 🪄       | final field   | PAINT / UPDATE / PAINT_FIRST / PAINT_LAST | int constants
1.1     | ✔️          | ✔️       | method        | getUpdateRect() / setUpdateRect() | ()->Rectangle / (Rectangle)

##### java.awt.event — Adapter classes (7/7/0)

> **Note:** The 1.1 delegation event model also ships abstract no-op *adapter*
> classes so listeners can override only the methods they need. All are
> implemented in `awt/event/`. `MouseAdapter` conforms to `MouseListener` only;
> `MouseMotionAdapter` is a separate class conforming to `MouseMotionListener` only —
> matching the Java 1.1 class hierarchy exactly.

version | implemented | tested   | type          | name               | more informations
------- | ----------- | -------- | ------------- | ------------------ | -----------------
1.1     | ✔️          | ⭕️       | class         | ComponentAdapter   | empty default impl of ComponentListener
1.1     | ✔️          | ⭕️       | class         | ContainerAdapter   | empty default impl of ContainerListener
1.1     | ✔️          | ⭕️       | class         | FocusAdapter       | empty default impl of FocusListener
1.1     | ✔️          | ⭕️       | class         | KeyAdapter         | empty default impl of KeyListener
1.1     | ✔️          | ⭕️       | class         | MouseAdapter       | empty default impl of MouseListener (`awt/event/MouseAdapter.swift`)
1.1     | ✔️          | ⭕️       | class         | MouseMotionAdapter | empty default impl of MouseMotionListener (`awt/event/MouseMotionAdapter.swift`)
1.1     | ✔️          | ⭕️       | class         | WindowAdapter      | empty default impl of WindowListener (file `WindowsAdapter.swift`)

##### java.awt.AWTEventMulticaster (2/2/0)

> **Note:** Implemented in `awt/AWTEventMulticaster.swift`. Uses a binary-tree
> chain of listener references. The static `add(_:_:)` / `remove(_:_:)` methods
> are the primary public API; all `XxxListener` dispatch methods delegate to
> both arms of the chain.

version | implemented | tested   | type          | name             | more informations
------- | ----------- | -------- | ------------- | ---------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | add()            | (XxxListener?, XxxListener?) -> XxxListener?
1.1     | ✔️          | ⭕️       | static method | remove()         | (XxxListener?, XxxListener?) -> XxxListener?

##### java.awt.EventQueue (3/3/0)

> **Note:** Implemented in `awt/EventQueue.swift`. The "Event Dispatch Thread"
> is mapped to `@MainActor`. `invokeLater` / `invokeAndWait` execute on the
> main actor, matching Java's EDT guarantee.

version | implemented | tested   | type          | name               | more informations
------- | ----------- | -------- | ------------- | ------------------ | -----------------
1.1     | ✔️          | ⭕️       | static method | invokeLater()      | (Runnable)
1.1     | ✔️          | ⭕️       | static method | invokeAndWait()    | (Runnable) throws
1.1     | ✔️          | ⭕️       | static method | isDispatchThread() | ()->boolean

#### Printing (new in 1.1)

##### java.awt.PrintJob (5/5/0)

> **Note:** Implemented as an `open class` in `awt/PrintJob.swift` (the abstract
> base) plus a concrete `_SwiftUIPrintJob` backend. The base methods return safe
> default values (stub behaviour) and are meant to be overridden by the platform
> backend, mirroring Java's abstract `PrintJob`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | getGraphics()  | ()->Graphics — returns a Graphics for the next page
1.1     | ✔️          | ⭕️       | method        | getPageDimension() | ()->Dimension
1.1     | ✔️          | ⭕️       | method        | getPageResolution() | ()->int — DPI
1.1     | ✔️          | ⭕️       | method        | lastPageFirst() | ()->boolean
1.1     | ✔️          | ⭕️       | method        | end()          | () — finishes the print job

> **Note:** `PrintJob` instances are obtained from `Toolkit.getPrintJob(frame, jobTitle, properties)`. The printing API introduced in Java 1.1 was superseded by `java.awt.print` (Java 1.2) and `javax.print` (Java 1.4).

##### java.awt.Toolkit — getPrintJob() (1.1 addition)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | getPrintJob()  | (Frame,String,Properties)->PrintJob — implemented in `awt/Toolkit.swift`

#### New / extended AWT classes

##### java.awt.AWTEvent (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | AWTEvent       | base for all 1.1 events; getID(), getSource(), consume()

##### java.awt.Cursor (0/0/✔️)

Already tracked in Java_1.0.md (version column `1.1`). All constants and methods implemented ✔️.

##### java.awt.SystemColor (1/1/0)

> **Note:** Implemented in `awt/SystemColor.swift` as a `final` subclass of `java.awt.Color`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | SystemColor    | symbolic desktop colors (window, text, control, …); subclass of Color

##### java.awt.Adjustable (9/9/0)

> **Note:** Implemented as a `protocol` in `awt/Adjustable.swift`. Constants are
> provided via a protocol extension and must be accessed through a concrete
> conforming type (e.g. `Scrollbar.HORIZONTAL`). `NO_ORIENTATION` is a Java 1.4
> addition included for API completeness.

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | final field   | HORIZONTAL / VERTICAL | Int orientation constants
1.1     | ✔️          | 🪄       | method        | getOrientation()      | ()->int
1.1     | ✔️          | 🪄       | method        | setMinimum() / getMinimum() | (int) / ()->int
1.1     | ✔️          | 🪄       | method        | setMaximum() / getMaximum() | (int) / ()->int
1.1     | ✔️          | 🪄       | method        | setUnitIncrement() / getUnitIncrement() | (int) / ()->int
1.1     | ✔️          | 🪄       | method        | setBlockIncrement() / getBlockIncrement() | (int) / ()->int
1.1     | ✔️          | 🪄       | method        | setVisibleAmount() / getVisibleAmount() | (int) / ()->int
1.1     | ✔️          | 🪄       | method        | setValue() / getValue() | (int) / ()->int
1.1     | ✔️          | 🪄       | method        | addAdjustmentListener() / removeAdjustmentListener() | (AdjustmentListener)

##### java.awt.ItemSelectable (3/3/0)

> **Note:** Implemented as a `protocol` in `awt/ItemSelectable.swift`.

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getSelectedObjects()  | ()->[AnyObject]?
1.1     | ✔️          | 🪄       | method        | addItemListener()     | (ItemListener)
1.1     | ✔️          | 🪄       | method        | removeItemListener()  | (ItemListener)

##### java.awt.IllegalComponentStateException (1/1/1)

> **Note:** Implemented in `awt/IllegalComponentStateException.swift` as a
> subclass of `IllegalStateException`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | class         | IllegalComponentStateException | extends IllegalStateException

##### java.awt.Shape (1/1/0)

> **Note:** Implemented as a `protocol` in `awt/Shape.swift`. `Rectangle` and `Polygon` conform via `Rectangle+Shape.swift`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | interface     | Shape          | contains(double,double), intersects(Rectangle2D), getBounds()

##### java.awt.MenuShortcut (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | MenuShortcut   | with key, usesShift, getKey(), usesShiftModifier(), equals()

##### java.awt.PopupMenu (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | PopupMenu      | extends Menu; show(Component,int,int); AppKit native on macOS

##### java.awt.ScrollPane (8/8/0)

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

##### java.awt.LayoutManager2 (5/5/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | addLayoutComponent() | (Component,Object)
1.1     | ✔️          | 🪄       | method        | maximumLayoutSize()  | (Container)->Dimension
1.1     | ✔️          | 🪄       | method        | getLayoutAlignmentX()| (Container)->float
1.1     | ✔️          | 🪄       | method        | getLayoutAlignmentY()| (Container)->float
1.1     | ✔️          | 🪄       | method        | invalidateLayout()   | (Container)

##### java.awt.GridBagLayout (14/14/0)

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

##### java.awt.GridBagConstraints (34/34/0)

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

##### java.awt.FontMetrics (no 1.1 additions)

> **Note:** `FontMetrics` was fully defined in Java 1.0. See Java_1.0.md for complete documentation. It is an abstract class. On Apple platforms the concrete implementation is `CoreTextFontMetrics` (backed by `CTFont`). On all other platforms a proportional-approximation fallback is used. Instances are obtained via `Graphics.getFontMetrics()` or `Graphics.getFontMetrics(Font)`.

## Java Core Packages — Continued

### java.io — Character-Stream Hierarchy (new in 1.1)

#### Concrete Reader implementations

##### java.io.BufferedReader (3/3/3)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | BufferedReader()     | (Reader)
1.1     | ✔️          | ✔️       | constructor   | BufferedReader()     | (Reader,int)
1.1     | ✔️          | ✔️       | method        | readLine()           | ()->String?

##### java.io.CharArrayReader (2/2/2)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | CharArrayReader()    | (char[])
1.1     | ✔️          | ✔️       | constructor   | CharArrayReader()    | (char[],int,int)

##### java.io.FileReader (2/2/2)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | FileReader()         | (File)
1.1     | ✔️          | ✔️       | constructor   | FileReader()         | (String)

##### java.io.FilterReader (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | FilterReader()       | (Reader)

##### java.io.InputStreamReader (2/2/2)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | InputStreamReader()  | (InputStream)
1.1     | ✔️          | ✔️       | constructor   | InputStreamReader()  | (InputStream,String) — charset name

##### java.io.LineNumberReader (2/2/2)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | LineNumberReader()   | (Reader)
1.1     | ✔️          | ✔️       | method        | getLineNumber()      | ()->int

##### java.io.PipedReader (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | PipedReader()        | ()
1.1     | ✔️          | ⭕️       | constructor   | PipedReader()        | (PipedWriter)

##### java.io.PushbackReader (2/2/2)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PushbackReader()     | (Reader)
1.1     | ✔️          | ✔️       | constructor   | PushbackReader()     | (Reader,int)

##### java.io.StringReader (1/1/1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | StringReader()       | (String)

#### Concrete Writer implementations

##### java.io.BufferedWriter (3/3/3)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | BufferedWriter()     | (Writer)
1.1     | ✔️          | ✔️       | constructor   | BufferedWriter()     | (Writer,int)
1.1     | ✔️          | ✔️       | method        | newLine()            | ()

##### java.io.CharArrayWriter (5/5/5)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | CharArrayWriter()    | ()
1.1     | ✔️          | ✔️       | constructor   | CharArrayWriter()    | (int)
1.1     | ✔️          | ✔️       | method        | toCharArray()        | ()->char[]
1.1     | ✔️          | ✔️       | method        | reset()              | ()
1.1     | ✔️          | ✔️       | method        | size()               | ()->int

##### java.io.FileWriter (3/3/3)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | FileWriter()         | (File)
1.1     | ✔️          | ✔️       | constructor   | FileWriter()         | (String)
1.1     | ✔️          | ✔️       | constructor   | FileWriter()         | (String,boolean) — append mode

##### java.io.FilterWriter (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | FilterWriter()       | (Writer)

##### java.io.OutputStreamWriter (2/2/2)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | OutputStreamWriter() | (OutputStream)
1.1     | ✔️          | ✔️       | constructor   | OutputStreamWriter() | (OutputStream,String) — charset name

##### java.io.PipedWriter (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | PipedWriter()        | ()
1.1     | ✔️          | ⭕️       | constructor   | PipedWriter()        | (PipedReader)

##### java.io.PrintWriter (5/5/5)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PrintWriter()        | (OutputStream)
1.1     | ✔️          | ✔️       | constructor   | PrintWriter()        | (OutputStream,boolean)
1.1     | ✔️          | ✔️       | method        | println()            | (String)
1.1     | ✔️          | ✔️       | constructor   | PrintWriter()        | (Writer)
1.1     | ✔️          | ✔️       | constructor   | PrintWriter()        | (Writer,boolean)

##### java.io.StringWriter (4/4/4)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | StringWriter()       | ()
1.1     | ✔️          | ✔️       | constructor   | StringWriter()       | (int)
1.1     | ✔️          | ✔️       | method        | getBuffer()          | ()->StringBuffer
1.1     | ✔️          | ✔️       | method        | toString()           | ()->String

##### java.io.ObjectStreamClass (3/3/0)

> **Note:** Implemented in `io/ObjectStreamClass.swift`. `lookup(_:)` accepts
> any Swift `Any.Type` and always returns a descriptor. `getSerialVersionUID()`
> returns `0` because Swift has no compile-time `serialVersionUID` equivalent.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | lookup()       | (Any.Type)->ObjectStreamClass?
1.1     | ✔️          | ⭕️       | method        | getName()      | ()->String
1.1     | ✔️          | ⭕️       | method        | getSerialVersionUID() | ()->Int64 (always 0)

##### java.io.ObjectInputValidation (1/1/0)

> **Note:** Implemented as a `protocol` in `io/ObjectInputValidation.swift`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | validateObject() | () throws — callback interface for serialization validation

### java.io — Object Serialization (new in 1.1)

> **Design decision:** The object serialization mechanism (`ObjectInputStream.readObject()` / `ObjectOutputStream.writeObject()`) is deliberately not implemented beyond stub level. For the full rationale see <doc:NotImplemented>.

##### java.io.Serializable (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | interface     | Serializable   | marker protocol — no methods

##### java.io.Externalizable (2/2/0)

> **Note:** Implemented as a `protocol` in `io/Externalization.swift`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | writeExternal() | (ObjectOutput) throws
1.1     | ✔️          | ⭕️       | method        | readExternal()  | (ObjectInput) throws

##### java.io.ObjectOutput (5/5/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | writeObject()   | (Object)
1.1     | ✔️          | 🪄       | method        | write()         | (int)
1.1     | ✔️          | 🪄       | method        | write()         | (byte[])
1.1     | ✔️          | 🪄       | method        | flush()         | ()
1.1     | ✔️          | 🪄       | method        | close()         | ()

##### java.io.ObjectInput (4/4/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | readObject()    | ()->Object
1.1     | ✔️          | 🪄       | method        | read()          | ()->int
1.1     | ✔️          | 🪄       | method        | skip()          | (long)->long
1.1     | ✔️          | 🪄       | method        | close()         | ()

##### java.io.ObjectOutputStream (3/3/0)

> **Note:** Implemented in `io/ObjectOutputStream.swift`. Delegates `write`,
> `flush`, and `close` to the wrapped `OutputStream`. `writeObject(_:)` throws
> ``NotActiveException`` — full object serialization is not yet implemented.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ObjectOutputStream() | (OutputStream) — stub; delegates to wrapped stream
1.1     | ✔️          | ⭕️       | method        | writeObject()  | (AnyObject?) throws — throws NotActiveException (not implemented)
1.1     | ✔️          | ⭕️       | method        | write/flush/close | delegated to underlying OutputStream

##### java.io.ObjectInputStream (3/3/0)

> **Note:** Implemented in `io/ObjectInputStream.swift`. Delegates `read` and
> `close` to the wrapped `InputStream`. `readObject()` throws
> ``NotActiveException`` — full object deserialization is not yet implemented.
> `registerValidation(_:priority:)` is accepted but callbacks are never called.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ObjectInputStream()  | (InputStream) — stub; delegates to wrapped stream
1.1     | ✔️          | ⭕️       | method        | readObject()   | ()->AnyObject? throws — throws NotActiveException (not implemented)
1.1     | ✔️          | ⭕️       | method        | registerValidation() | (ObjectInputValidation,Int) — accepted, not invoked

##### java.io.ObjectStreamException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ObjectStreamException() |

##### java.io.InvalidClassException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | InvalidClassException() | (String)

##### java.io.InvalidObjectException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | InvalidObjectException() | (String)

##### java.io.NotActiveException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | NotActiveException() | (String)

##### java.io.NotSerializableException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | NotSerializableException() | (String)

##### java.io.OptionalDataException (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | field         | eof            | boolean
1.1     | ✔️          | ⭕️       | field         | length         | int

##### java.io.StreamCorruptedException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | StreamCorruptedException() | (String)

##### java.io.WriteAbortedException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | WriteAbortedException() | (String,Exception)

### java.util — New in 1.1

##### java.util.EventObject (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | EventObject()  | (Object source)
1.1     | ✔️          | ⭕️       | method        | getSource()    | ()->Object

##### java.util.EventListener (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | interface     | EventListener  | marker protocol — no methods

##### java.util.Calendar (10/10/8)

> **Note:** Calendar is an abstract class. `getInstance()` returns a `GregorianCalendar`.
> All Java 1.1 field constants are implemented with the correct integer values from the spec.
> Java months are 0-based (JANUARY=0 … DECEMBER=11); Foundation months are 1-based — the conversion is handled internally.
>
> **Bugs fixed (June 2026):**
> - `DAY_OF_MONTH` was wrongly set to `8` (should be `5`); `DAY_OF_WEEK_IN_MONTH = 8` as per spec.
> - `get(SECOND)` in the Swiftify extension was returning `dateComponents.minute` due to a copy-paste error.
> - `GregorianCalendar.get(DAY_OF_MONTH)` was returning `dateComponents.month` instead of `dateComponents.day`.
> - `GregorianCalendar` constructors were not applying the 0→1-based month conversion.
> - `getInstance()` and `set(Int,Int)` were missing entirely.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | static method | getInstance()  | ()->Calendar
1.1     | ✔️          | ✔️       | static method | getInstance()  | (Locale)->Calendar
1.1     | ✔️          | ✔️       | method        | get()          | (int)->int — all 17 fields supported
1.1     | ✔️          | ✔️       | method        | set()          | (int,int)
1.1     | ✔️          | ⭕️       | method        | getTime()      | ()->Date
1.1     | ✔️          | ⭕️       | method        | setTime()      | (Date)
1.1     | ✔️          | ✔️       | final field   | ERA=0, YEAR=1, MONTH=2, WEEK_OF_YEAR=3, WEEK_OF_MONTH=4, DATE/DAY_OF_MONTH=5, DAY_OF_YEAR=6, DAY_OF_WEEK=7, DAY_OF_WEEK_IN_MONTH=8, AM_PM=9, HOUR=10, HOUR_OF_DAY=11, MINUTE=12, SECOND=13, MILLISECOND=14, ZONE_OFFSET=15, DST_OFFSET=16, FIELD_COUNT=17 | int field constants
1.1     | ✔️          | ✔️       | final field   | SUNDAY=1 … SATURDAY=7 | day-of-week constants
1.1     | ✔️          | ✔️       | final field   | JANUARY=0 … DECEMBER=11, UNDECIMBER=12 | month constants
1.1     | ✔️          | ✔️       | final field   | AM=0, PM=1, BC=0, AD=1 | era/AM-PM constants

##### java.util.GregorianCalendar (6/6/6)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | GregorianCalendar()  | ()
1.1     | ✔️          | ✔️       | constructor   | GregorianCalendar()  | (int year, int month, int day) — month 0-based as per Java spec
1.1     | ✔️          | ✔️       | constructor   | GregorianCalendar()  | (int,int,int,int,int) — with hour+minute
1.1     | ✔️          | ✔️       | constructor   | GregorianCalendar()  | (int,int,int,int,int,int) — with hour+minute+second
1.1     | ✔️          | ✔️       | method        | isLeapYear()         | (int)->boolean
1.1     | ✔️          | ✔️       | method        | get()                | (int)->int — overrides Calendar; all fields supported

##### java.util.Locale (7/7/7)

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

##### java.util.TimeZone (6/6/6)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | static method | getDefault()    | ()->TimeZone — returns SimpleTimeZone backed by Foundation.TimeZone.current
1.1     | ✔️          | ✔️       | static method | getTimeZone()   | (String)->TimeZone — looks up by identifier or abbreviation; falls back to GMT
1.1     | ✔️          | ✔️       | static method | getAvailableIDs() | ()->[String] — delegates to Foundation.TimeZone.knownTimeZoneIdentifiers
1.1     | ✔️          | ✔️       | static method | getAvailableIDs() | (int rawOffset)->[String]
1.1     | ✔️          | ✔️       | method        | getID()         | ()->String
1.1     | ✔️          | ✔️       | method        | getRawOffset()  | ()->int — raw offset in ms (total minus DST)

### java.lang.reflect — New package in 1.1

> **Note:** Java reflection cannot be fully mapped to Swift's type system. Field introspection is backed by Swift Mirror. Method/Constructor reflection is not portable.

##### java.lang.reflect.AnnotatedElement (4/4/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getAnnotation()          | (Type)->Any?
1.1     | ✔️          | 🪄       | method        | getAnnotations()         | ()->[Any]
1.1     | ✔️          | 🪄       | method        | getDeclaredAnnotations() | ()->[Any]
1.1     | ✔️          | 🪄       | method        | isAnnotationPresent()    | (Type)->Bool

##### java.lang.reflect.Member (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | protocol      | Member         | getDeclaringClass(), getName(), getModifiers(), isSynthetic()

##### java.lang.reflect.AccessibleObject (4/4/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | setAccessible()          | (boolean)
1.1     | ✔️          | ⭕️       | method        | isAccessible()           | ()->boolean
1.1     | ✔️          | ⭕️       | static method | setAccessible()          | ([AccessibleObject],boolean)
1.1     | ✔️          | ⭕️       | method        | toString()               | ()->String

##### java.lang.reflect.Modifier (3/3/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | static field  | PUBLIC, PRIVATE, PROTECTED | int constants
1.1     | ✔️          | ⭕️       | static field  | STATIC, FINAL, SYNCHRONIZED | int constants
1.1     | ✔️          | ⭕️       | static field  | VOLATILE, TRANSIENT, NATIVE | int constants

##### java.lang.reflect.Field (10/8/0)

> **Note:** Backed by Swift Mirror. `get()` / `set()` use Mirror-based introspection; write access is limited.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | getName()            | ()->String
1.1     | ✔️          | ⭕️       | method        | getModifiers()       | ()->int
1.1     | ✔️          | ⭕️       | method        | get()                | (Any?)->Any?
1.1     | ✔️          | ⭕️       | method        | set()                | (inout Any, Any?)
1.1     | ✔️          | ⭕️       | method        | getDeclaringClass()  | ()->Class
1.1     | ✔️          | ⭕️       | method        | getGenericType()     | (Any)->Any.Type?

#### java.lang.Class — Reflection additions (1.1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | getDeclaredFields()      | (Any)->[Field] — via Swift Mirror
1.1     | ✔️          | ⭕️       | method        | getFields()              | (Any)->[Field] — via Swift Mirror
1.1     | ⭕️          | ⭕️       | method        | getDeclaredMethods()     | ()->Method[] — not portable in Swift
1.1     | ⭕️          | ⭕️       | method        | getConstructors()        | ()->Constructor[] — not portable in Swift

> **Not ported:** `java.lang.reflect.Method`, `Constructor`, `Array`, `InvocationTargetException` — Swift has no equivalent runtime method/constructor introspection API.

### java.lang — New wrapper classes in 1.1

##### java.lang.Byte (17/17/17)

> **Note:** `byte` in this project is `UInt8` for Swift compatibility. Therefore `Byte` wraps `UInt8`.
> `MIN_VALUE` / `MAX_VALUE` alias `UMIN_VALUE` (0) / `UMAX_VALUE` (255).
> Signed Java constants `SMIN_VALUE` (-128) / `SMAX_VALUE` (127) and `parseSignedByte()` / `signedByteValue()` are in `Byte+Java.swift`.
>
> **Swift/Java incompatibility:** In Java, `Byte extends Number`. In this project `Number` is a `typealias` for Swift's `Numeric` protocol (a value-type protocol), which a wrapper class cannot conform to. The numeric conversion methods (`intValue()`, `longValue()`, `floatValue()`, `doubleValue()`, `shortValue()`) are therefore added directly to `Byte` rather than inherited.

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
1.1     | ✔️          | ✔️       | method        | intValue()          | ()->Int (unsigned, 0–255)
1.1     | ✔️          | ✔️       | method        | longValue()         | ()->Int64
1.1     | ✔️          | ✔️       | method        | floatValue()        | ()->Float
1.1     | ✔️          | ✔️       | method        | doubleValue()       | ()->Double
1.1     | ✔️          | ✔️       | method        | shortValue()        | ()->Int16
1.1     | ✔️          | ✔️       | method        | equals()            | via Equatable
1.1     | ✔️          | ✔️       | method        | toString()          | ()->String

##### java.lang.Short (8/8/8)

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

##### java.lang.Void (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | class         | Void           | uninstantiable placeholder; used as type argument for void return types

### java.net — 1.1 additions

##### java.net.BindException / ConnectException / NoRouteToHostException (3/3/0)

> **Note:** All three are new `IOException` subclasses added in Java 1.1.
> Implemented in `net/BindException.swift`, `net/ConnectException.swift`,
> `net/NoRouteToHostException.swift`. Each provides the standard two-constructor
> pattern (no-arg + message).

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | BindException           | extends SocketException; address already in use
1.1     | ✔️          | ⭕️       | class         | ConnectException        | extends SocketException; connection refused
1.1     | ✔️          | ⭕️       | class         | NoRouteToHostException  | extends SocketException; no route to host

##### java.net.DatagramPacket — 1.1 additions (4/4/0)

> **Note:** Java 1.1 added setter methods to `DatagramPacket` (previously read-only).
> All implemented in `net/DatagramPacket.swift`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | setAddress()   | (InetAddress)
1.1     | ✔️          | ⭕️       | method        | setData()      | (byte[])
1.1     | ✔️          | ⭕️       | method        | setLength()    | (int)
1.1     | ✔️          | ⭕️       | method        | setPort()      | (int)

##### java.net.DatagramSocket — 1.1 additions (4/4/4)

> **Note:** Java 1.1 added a new constructor, socket-option accessors, and
> `getLocalAddress()`. All four are implemented in `net/DatagramSocket.swift`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | DatagramSocket()        | (int port, InetAddress laddr)
1.1     | ✔️          | ✔️       | method        | getSoTimeout()          | ()->int
1.1     | ✔️          | ✔️       | method        | setSoTimeout()          | (int)
1.1     | ✔️          | ✔️       | method        | getLocalAddress()       | ()->InetAddress?

##### java.net.URLConnection — 1.1 additions (2/2/2)

> **Note:** `getFileNameMap()` and `setFileNameMap()` are implemented as static
> methods in `net/URLConnection.swift`. A built-in `DefaultFileNameMap` provides
> common extension-to-MIME mappings; callers may replace it via `setFileNameMap()`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.1     | ✔️          | ✔️       | static method | getFileNameMap()        | ()->FileNameMap
1.1     | ✔️          | ✔️       | static method | setFileNameMap()        | (FileNameMap)

##### java.net.DatagramSocketImpl (10/10/0)

> **Note:** Implemented in `net/DatagramSocketImpl.swift` as an `open class`
> following the same pattern as `SocketImpl`. All methods throw
> ``java.io.IOException`` by default; subclasses must override them.
> Platform-independent — pure Swift, no POSIX imports.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | field         | fd / localPort | Int32 / Int
1.1     | ✔️          | ⭕️       | method        | create()       | () throws
1.1     | ✔️          | ⭕️       | method        | bind()         | (Int,InetAddress) throws
1.1     | ✔️          | ⭕️       | method        | send()         | (DatagramPacket) throws
1.1     | ✔️          | ⭕️       | method        | receive()      | (DatagramPacket) throws
1.1     | ✔️          | ⭕️       | method        | connect()      | (InetAddress,Int) throws — no-op default
1.1     | ✔️          | ⭕️       | method        | disconnect()   | () — no-op default
1.1     | ✔️          | ⭕️       | method        | setTTL()/getTTL() | (UInt8)/()->UInt8 throws
1.1     | ✔️          | ⭕️       | method        | join()/leave() | (InetAddress) throws
1.1     | ✔️          | ⭕️       | method        | getLocalPort() | ()->Int

##### java.net.HttpURLConnection (10/10/10)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | method        | getResponseCode()    | ()->int
1.1     | ✔️          | ✔️       | method        | getResponseMessage() | ()->String?
1.1     | ✔️          | ✔️       | method        | getRequestMethod()   | ()->String
1.1     | ✔️          | ✔️       | method        | setRequestMethod()   | (String)
1.1     | ✔️          | ✔️       | method        | disconnect()         | ()
1.1     | ✔️          | ✔️       | static field  | followRedirects      | Bool
1.1     | ✔️          | ✔️       | final field   | HTTP_OK, HTTP_CREATED, HTTP_ACCEPTED, HTTP_NO_CONTENT | int constants
1.1     | ✔️          | ✔️       | final field   | HTTP_MOVED_PERM, HTTP_MOVED_TEMP, HTTP_NOT_MODIFIED | int constants
1.1     | ✔️          | ✔️       | final field   | HTTP_BAD_REQUEST, HTTP_UNAUTHORIZED, HTTP_FORBIDDEN, HTTP_NOT_FOUND | int constants
1.1     | ✔️          | ✔️       | final field   | HTTP_INTERNAL_ERROR, HTTP_NOT_IMPLEMENTED, HTTP_BAD_GATEWAY, HTTP_UNAVAILABLE | int constants

##### java.net.MulticastSocket (4/4/0)

> **Note:** Implemented in `net/MulticastSocket.swift` as a subclass of
> ``DatagramSocket``. `joinGroup`/`leaveGroup` use POSIX `IP_ADD_MEMBERSHIP` /
> `IP_DROP_MEMBERSHIP` on Darwin and Linux; on Windows the same Winsock2 options
> are called via ``platformSetsockopt``. On WASI only, these methods throw
> ``SocketException``.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | MulticastSocket() | ()
1.1     | ✔️          | ⭕️       | constructor   | MulticastSocket() | (int port)
1.1     | ✔️          | ⭕️       | method        | joinGroup()    | (InetAddress) — Darwin/Linux/Windows; throws on WASI
1.1     | ✔️          | ⭕️       | method        | leaveGroup()   | (InetAddress) — Darwin/Linux/Windows; throws on WASI

##### java.net.FileNameMap (1/1/0)

> **Note:** Implemented as a `protocol` in `net/FileNameMap.swift`.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getContentTypeFor() | (String)->String? — interface

### java.awt.image — no 1.1 additions (see Java_1.0.md)

> **Note:** java.awt.image was fully defined in Java 1.0. See Java_1.0.md for complete documentation of all classes and interfaces, including:
> - ColorModel, DirectColorModel, IndexColorModel (color models)
> - ImageFilter, RGBImageFilter, CropImageFilter, FilteredImageSource (filters)
> - ImageProducer, ImageConsumer, ImageObserver (producer/consumer pipeline)
> - MemoryImageSource, PixelGrabber (sources)
>
> **1.1 extensions** to existing classes are documented below only.

##### java.awt.image.MemoryImageSource — 1.1 additions (7/7/0)

> **Note:** Java 1.1 animation support is now implemented in
> `awt/image/MemoryImageSource.swift`. `setAnimated(true)` keeps consumers
> registered after each frame (sends `SINGLEFRAMEDONE` instead of
> `STATICIMAGEDONE`). `setFullBufferUpdates(true)` forces full-buffer sends even
> for partial `newPixels(x,y,w,h)` calls. The consumer dict uses
> `[ObjectIdentifier: any ImageConsumer]` (strong refs) so the producer keeps
> consumers alive during animation.

version | implemented | tested   | type          | name                       | more informations
------- | ----------- | -------- | ------------- | -------------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | setAnimated()              | (boolean) — enables animation mode
1.1     | ✔️          | ⭕️       | method        | setFullBufferUpdates()     | (boolean)
1.1     | ✔️          | ⭕️       | method        | newPixels()                | () — push full frame to consumers
1.1     | ✔️          | ⭕️       | method        | newPixels()                | (int,int,int,int) — push sub-region
1.1     | ✔️          | ⭕️       | method        | newPixels()                | (int,int,int,int,boolean)
1.1     | ✔️          | ⭕️       | method        | newPixels()                | (byte[],ColorModel,int,int)
1.1     | ✔️          | ⭕️       | method        | newPixels()                | (int[],ColorModel,int,int)

##### java.awt.image.PixelGrabber — 1.1 additions (6/6/0)

version | implemented | tested   | type          | name                       | more informations
------- | ----------- | -------- | ------------- | -------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | PixelGrabber()             | (Image,int,int,int,int,boolean) — allocates pixel array internally
1.1     | ✔️          | ⭕️       | method        | abortGrabbing()            | ()
1.1     | ✔️          | ⭕️       | method        | startGrabbing()            | ()
1.1     | ✔️          | ⭕️       | method        | getColorModel()            | ()->ColorModel?
1.1     | ✔️          | ⭕️       | method        | getHeight()                | ()->int
1.1     | ✔️          | ⭕️       | method        | getWidth()                 | ()->int

### java.util — Internationalization additions in 1.1 (continued)

##### java.util.ResourceBundle (4/4/4)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | static method | getBundle()    | (String)->ResourceBundle
1.1     | ✔️          | ✔️       | static method | getBundle()    | (String,Locale)->ResourceBundle
1.1     | ✔️          | ✔️       | method        | getString()    | (String)->String
1.1     | ✔️          | ✔️       | method        | getObject()    | (String)->Object

##### java.util.ListResourceBundle (1/1/1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | class         | ListResourceBundle | abstract subclass of ResourceBundle backed by a list of key/value pairs

##### java.util.PropertyResourceBundle (2/2/2)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PropertyResourceBundle() | ()
1.1     | ✔️          | ✔️       | constructor   | PropertyResourceBundle() | (InputStream)

##### java.util.SimpleTimeZone (5/5/5)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | SimpleTimeZone() | (int rawOffset, String ID)
1.1     | ✔️          | ✔️       | constructor   | SimpleTimeZone() | (int,String,int,int,int,int,int,int,int,int) — with DST rules
1.1     | ✔️          | ✔️       | method        | getID()          | ()->String
1.1     | ✔️          | ✔️       | method        | getRawOffset()   | ()->int — milliseconds
1.1     | ✔️          | ✔️       | method        | inDaylightTime() | (Date)->boolean

### java.math — New package in 1.1

##### java.math.BigInteger (14/14/14)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | BigInteger()   | (String)
1.1     | ✔️          | ✔️       | constructor   | BigInteger()   | (String,int radix)
1.1     | ✔️          | ✔️       | static field  | ZERO, ONE, TEN | BigInteger constants
1.1     | ✔️          | ✔️       | method        | add()          | (BigInteger)->BigInteger
1.1     | ✔️          | ✔️       | method        | subtract()     | (BigInteger)->BigInteger
1.1     | ✔️          | ✔️       | method        | multiply()     | (BigInteger)->BigInteger
1.1     | ✔️          | ✔️       | method        | divide()       | (BigInteger)->BigInteger
1.1     | ✔️          | ✔️       | method        | mod()          | (BigInteger)->BigInteger
1.1     | ✔️          | ✔️       | method        | abs()          | ()->BigInteger
1.1     | ✔️          | ✔️       | method        | negate()       | ()->BigInteger
1.1     | ✔️          | ✔️       | method        | compareTo()    | (BigInteger)->int
1.1     | ✔️          | ✔️       | method        | toString()     | ()->String
1.1     | ✔️          | ✔️       | method        | intValue()     | ()->int
1.1     | ✔️          | ✔️       | method        | longValue()    | ()->long

##### java.math.BigDecimal (9/9/9)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | BigDecimal()   | (String)
1.1     | ✔️          | ✔️       | constructor   | BigDecimal()   | (double)
1.1     | ✔️          | ✔️       | method        | add()          | (BigDecimal)->BigDecimal
1.1     | ✔️          | ✔️       | method        | subtract()     | (BigDecimal)->BigDecimal
1.1     | ✔️          | ✔️       | method        | multiply()     | (BigDecimal)->BigDecimal
1.1     | ✔️          | ✔️       | method        | divide()       | (BigDecimal,int,int)->BigDecimal
1.1     | ✔️          | ✔️       | method        | compareTo()    | (BigDecimal)->int
1.1     | ✔️          | ✔️       | method        | toString()     | ()->String
1.1     | ✔️          | ✔️       | method        | doubleValue()  | ()->double

### java.security — New package in 1.1

> **Note:** Only the subset relevant for JavApi is implemented. `java.security.acl` is implemented and marked deprecated (removed in Java 24). `java.security.interfaces` is fully implemented — see below.

##### java.security.DigestInputStream / DigestOutputStream (2/2/2)


version | implemented | tested   | type          | name                 | more informations
------- | ----------- | -------- | ------------- | -------------------- | -----------------
1.1     | ✔️          | ✔️       | class         | DigestInputStream    | extends FilterInputStream; on()/off() toggle digesting
1.1     | ✔️          | ✔️       | class         | DigestOutputStream   | extends FilterOutputStream; on()/off() toggle digesting

##### java.security.KeyPair / KeyPairGenerator (2/2/2)


version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | ✔️       | class         | KeyPair             | immutable pair of PublicKey + PrivateKey
1.1     | ✔️          | ✔️       | class         | KeyPairGenerator    | getInstance(String)->KeyPairGenerator; initialize(int); generateKeyPair()->KeyPair

##### java.security.Signature (1/1/1)


version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | class         | Signature      | getInstance(String); initSign(PrivateKey); update(byte[]); sign()->byte[]; initVerify(PublicKey); verify(byte[])->boolean

##### java.security.Security (1/1/1)


version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | class         | Security       | addProvider(), getProvider(), getProviders(), getProperty(), setProperty()

##### java.security.MessageDigest (4/4/4)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | static method | getInstance()  | (String)->MessageDigest
1.1     | ✔️          | ✔️       | method        | update()       | (byte[])
1.1     | ✔️          | ✔️       | method        | digest()       | ()->byte[]
1.1     | ✔️          | ✔️       | method        | reset()        | ()

##### java.security.SecureRandom (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | SecureRandom() | ()
1.1     | ✔️          | ⭕️       | method        | nextBytes()    | (byte[])

##### java.security.Provider (2/2/2)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | method        | getName()      | ()->String
1.1     | ✔️          | ✔️       | method        | getVersion()   | ()->double

##### java.security.GeneralSecurityException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | GeneralSecurityException() | (String)

##### java.security.NoSuchAlgorithmException (1/1/1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | NoSuchAlgorithmException() | (String)

##### java.security.Principal (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getName()      | ()->String

### java.security.interfaces — New package in 1.1 (complete)

##### java.security.Key (3/3/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getAlgorithm() | ()->String
1.1     | ✔️          | 🪄       | method        | getFormat()    | ()->String?
1.1     | ✔️          | 🪄       | method        | getEncoded()   | ()->[UInt8]?

##### java.security.PublicKey (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | protocol      | PublicKey      | extends Key — marker

##### java.security.PrivateKey (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | protocol      | PrivateKey     | extends Key — marker

##### java.security.interfaces.DSAParams (3/3/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getP()         | ()->BigInteger
1.1     | ✔️          | 🪄       | method        | getQ()         | ()->BigInteger
1.1     | ✔️          | 🪄       | method        | getG()         | ()->BigInteger

##### java.security.interfaces.DSAKey (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getParams()    | ()->(any DSAParams)?

##### java.security.interfaces.DSAPublicKey (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | protocol      | DSAPublicKey   | extends DSAKey + PublicKey
1.1     | ✔️          | 🪄       | method        | getY()         | ()->BigInteger — public value y

##### java.security.interfaces.DSAPrivateKey (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | protocol      | DSAPrivateKey  | extends DSAKey + PrivateKey
1.1     | ✔️          | 🪄       | method        | getX()         | ()->BigInteger — private value x

##### java.security.interfaces.DSAKeyPairGenerator (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | initialize()   | (DSAParams, SecureRandom) throws
1.1     | ✔️          | 🪄       | method        | initialize()   | (Int, Bool, SecureRandom) throws

### java.security.acl — New package in 1.1 (deprecated)

> **Warning:** The entire `java.security.acl` package was **deprecated in Java 17**
> for removal and **removed in Java 24**. It is provided here for Java 1.1–16
> compatibility. All types carry `@available(*, deprecated, ...)`.
> Set the system property `java.expected.version` to a value < 17 to suppress
> Swift compiler deprecation warnings in legacy code.

##### java.security.Principal — see java.security above ✔️

##### java.security.acl.Permission (2/2/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | equals()       | (Any?)->Bool
1.1     | ✔️          | ⭕️       | method        | toString()     | ()->String

##### java.security.acl.Owner (3/3/0)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | addOwner()          | (Principal,Principal)->Bool throws NotOwnerException
1.1     | ✔️          | ⭕️       | method        | deleteOwner()       | (Principal,Principal)->Bool throws NotOwnerException, LastOwnerException
1.1     | ✔️          | ⭕️       | method        | isOwner()           | (Principal)->Bool

##### java.security.acl.Group (4/4/0)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | addMember()         | (Principal)->Bool
1.1     | ✔️          | ⭕️       | method        | removeMember()      | (Principal)->Bool
1.1     | ✔️          | ⭕️       | method        | isMember()          | (Principal)->Bool
1.1     | ✔️          | ⭕️       | method        | members()           | ()->Enumeration<Principal>

##### java.security.acl.AclEntry (10/10/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | setPrincipal()        | (Principal)->Bool
1.1     | ✔️          | ⭕️       | method        | getPrincipal()        | ()->Principal?
1.1     | ✔️          | ⭕️       | method        | setNegativePermissions() | ()
1.1     | ✔️          | ⭕️       | method        | isNegative()          | ()->Bool
1.1     | ✔️          | ⭕️       | method        | addPermission()       | (Permission)->Bool
1.1     | ✔️          | ⭕️       | method        | removePermission()    | (Permission)->Bool
1.1     | ✔️          | ⭕️       | method        | checkPermission()     | (Permission)->Bool
1.1     | ✔️          | ⭕️       | method        | permissions()         | ()->Enumeration<Permission>
1.1     | ✔️          | ⭕️       | method        | clone()               | ()->AclEntry
1.1     | ✔️          | ⭕️       | method        | toString()            | ()->String

##### java.security.acl.Acl (8/8/0)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | setName()           | (Principal,String) throws NotOwnerException
1.1     | ✔️          | ⭕️       | method        | getName()           | ()->String
1.1     | ✔️          | ⭕️       | method        | addEntry()          | (Principal,AclEntry)->Bool throws NotOwnerException
1.1     | ✔️          | ⭕️       | method        | removeEntry()       | (Principal,AclEntry)->Bool throws NotOwnerException
1.1     | ✔️          | ⭕️       | method        | getPermissions()    | (Principal)->Enumeration<Permission>
1.1     | ✔️          | ⭕️       | method        | entries()           | ()->Enumeration<AclEntry>
1.1     | ✔️          | ⭕️       | method        | checkPermission()   | (Principal,Permission)->Bool
1.1     | ✔️          | ⭕️       | method        | toString()          | ()->String

##### java.security.acl.AclNotFoundException (2/2/0)

version | implemented | tested   | type          | name                   | more informations
------- | ----------- | -------- | ------------- | ---------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | AclNotFoundException() | ()
1.1     | ✔️          | ⭕️       | constructor   | AclNotFoundException() | (String)

##### java.security.acl.LastOwnerException (2/2/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | LastOwnerException()  | ()
1.1     | ✔️          | ⭕️       | constructor   | LastOwnerException()  | (String)

##### java.security.acl.NotOwnerException (2/2/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | NotOwnerException()   | ()
1.1     | ✔️          | ⭕️       | constructor   | NotOwnerException()   | (String)

### java.beans — New package in 1.1 (partial)

Only the bound-property and veto-change subset needed for JFC 1.0 / Swing is implemented.
Reflection-based introspection (`BeanDescriptor`, `BeanInfo`, `Introspector`, `MethodDescriptor`, …) is not in scope.

##### java.beans.PropertyChangeEvent (6/6/6)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PropertyChangeEvent() | (Object,String,Object,Object)
1.1     | ✔️          | ✔️       | method        | getPropertyName()     | ()->String?
1.1     | ✔️          | ✔️       | method        | getOldValue()         | ()->Object?
1.1     | ✔️          | ✔️       | method        | getNewValue()         | ()->Object?
1.1     | ✔️          | ✔️       | method        | setPropagationId()    | (Object?)
1.1     | ✔️          | ✔️       | method        | getPropagationId()    | ()->Object?

##### java.beans.PropertyChangeListener (1/1/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | propertyChange()      | (PropertyChangeEvent)

##### java.beans.PropertyChangeSupport (12/12/12)

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

##### java.beans.IntrospectionException (1/1/0)

version | implemented | tested   | type          | name                        | more informations
------- | ----------- | -------- | ------------- | --------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | IntrospectionException()    | (String)

##### java.beans.Visibility (4/4/0)

> **Note:** Implemented as a `protocol` in `beans/Visibility.swift`.

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.1     | ✔️          | 🪄       | method        | needsGui()        | ()->boolean
1.1     | ✔️          | 🪄       | method        | dontUseGui()      | ()
1.1     | ✔️          | 🪄       | method        | okToUseGui()      | ()
1.1     | ✔️          | 🪄       | method        | isGuiAvailable()  | ()->boolean

##### java.beans.FeatureDescriptor (10/10/0)

> **Note:** Implemented in `beans/FeatureDescriptor.swift`. Carries name,
> display name, short description, and flag attributes. Does **not** carry
> `java.lang.reflect` data — reflection-based subclasses are not ported.
> `isPreferred()`/`setPreferred()` are a Java 1.2 addition included for
> API completeness.

version | implemented | tested   | type          | name                   | more informations
------- | ----------- | -------- | ------------- | ---------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | getName()              | ()->String
1.1     | ✔️          | ⭕️       | method        | setName()              | (String)
1.1     | ✔️          | ⭕️       | method        | getDisplayName()       | ()->String
1.1     | ✔️          | ⭕️       | method        | setDisplayName()       | (String)
1.1     | ✔️          | ⭕️       | method        | getShortDescription()  | ()->String
1.1     | ✔️          | ⭕️       | method        | setShortDescription()  | (String)
1.1     | ✔️          | ⭕️       | method        | isExpert()             | ()->boolean
1.1     | ✔️          | ⭕️       | method        | setExpert()            | (boolean)
1.1     | ✔️          | ⭕️       | method        | isHidden()             | ()->boolean
1.1     | ✔️          | ⭕️       | method        | setHidden()            | (boolean)

##### java.beans.Beans (5/4/0)

> **Note:** Only the environment-query methods are implemented
> (`beans/Beans.swift`). `instantiate(ClassLoader, String)` requires
> `java.lang.Class` reflection and is **not ported** — see `NotImplemented.md`.

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | isDesignTime()        | ()->boolean
1.1     | ✔️          | ⭕️       | static method | setDesignTime()       | (boolean)
1.1     | ✔️          | ⭕️       | static method | isGuiAvailable()      | ()->boolean
1.1     | ✔️          | ⭕️       | static method | setGuiAvailable()     | (boolean)
1.1     | ⭕️          | ⭕️       | static method | instantiate()         | (ClassLoader,String) — not portable

##### java.beans.Customizer (3/3/0)

> **Note:** Implemented as a `protocol` in `beans/Customizer.swift`. In Java,
> `Customizer` extends `java.awt.Component`; here it is a plain protocol —
> conforming types should wrap a UI component independently.

version | implemented | tested   | type          | name                          | more informations
------- | ----------- | -------- | ------------- | ----------------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | setObject()                   | (Object)
1.1     | ✔️          | 🪄       | method        | addPropertyChangeListener()   | (PropertyChangeListener)
1.1     | ✔️          | 🪄       | method        | removePropertyChangeListener()| (PropertyChangeListener)

##### java.beans.PropertyEditor (11/10/0)

> **Note:** Implemented as a `protocol` in `beans/PropertyEditor.swift`.
> `getCustomEditor()` is **not included** — it returns `java.awt.Component`
> and has no portable Swift equivalent outside an AWT context.

version | implemented | tested   | type          | name                          | more informations
------- | ----------- | -------- | ------------- | ----------------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | setValue()                    | (Object?)
1.1     | ✔️          | 🪄       | method        | getValue()                    | ()->Object?
1.1     | ✔️          | 🪄       | method        | isPaintable()                 | ()->boolean
1.1     | ✔️          | 🪄       | method        | getAsText()                   | ()->String?
1.1     | ✔️          | 🪄       | method        | setAsText()                   | (String) throws
1.1     | ✔️          | 🪄       | method        | getTags()                     | ()->[String]?
1.1     | ✔️          | 🪄       | method        | supportsCustomEditor()        | ()->boolean
1.1     | ✔️          | 🪄       | method        | getJavaInitializationString() | ()->String?
1.1     | ✔️          | 🪄       | method        | addPropertyChangeListener()   | (PropertyChangeListener)
1.1     | ✔️          | 🪄       | method        | removePropertyChangeListener()| (PropertyChangeListener)
1.1     | ⭕️          | ⭕️       | method        | getCustomEditor()             | ()->Component — not portable (AWT dependency)

##### java.beans.PropertyEditorSupport (11/11/0)

> **Note:** Implemented in `beans/PropertyEditorSupport.swift`. Provides
> default implementations of all `PropertyEditor` methods and delegates
> listener management to an internal `PropertyChangeSupport`.

version | implemented | tested   | type          | name                          | more informations
------- | ----------- | -------- | ------------- | ----------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | PropertyEditorSupport()       | ()
1.1     | ✔️          | ⭕️       | constructor   | PropertyEditorSupport()       | (Object source)
1.1     | ✔️          | ⭕️       | method        | getValue() / setValue()       | AnyObject?
1.1     | ✔️          | ⭕️       | method        | getAsText() / setAsText()     | String?
1.1     | ✔️          | ⭕️       | method        | getTags()                     | ()->[String]?
1.1     | ✔️          | ⭕️       | method        | isPaintable()                 | ()->boolean (returns false)
1.1     | ✔️          | ⭕️       | method        | supportsCustomEditor()        | ()->boolean (returns false)
1.1     | ✔️          | ⭕️       | method        | getJavaInitializationString() | ()->String? (returns nil)
1.1     | ✔️          | ⭕️       | method        | firePropertyChange()          | ()
1.1     | ✔️          | ⭕️       | method        | addPropertyChangeListener()   | (PropertyChangeListener)
1.1     | ✔️          | ⭕️       | method        | removePropertyChangeListener()| (PropertyChangeListener)

##### java.beans.PropertyVetoException (2/2/2)

version | implemented | tested   | type          | name                      | more informations
------- | ----------- | -------- | ------------- | ------------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | PropertyVetoException()   | (String,PropertyChangeEvent)
1.1     | ✔️          | ✔️       | method        | getPropertyChangeEvent()  | ()->PropertyChangeEvent

##### java.beans.VetoableChangeListener (1/1/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | vetoableChange()      | (PropertyChangeEvent) throws

##### java.beans.VetoableChangeSupport (27/27/12)

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

### java.rmi — New package in 1.1 (exception stubs only)

> **Note:** The RMI networking stack is **not implemented** — see
> `NotImplemented.md` for the full rationale. However, the exception hierarchy
> and the `Remote` marker protocol are provided as compile-time stubs so that
> ported Java code that references these types compiles without modification.
>
> **Filename collisions:** Two classes share their simple name with types in
> `java.net`, forcing non-canonical Swift filenames:
> - `java.rmi.ConnectException` → `rmi/RMIConnectException.swift`
>   (conflicts with `net/ConnectException.swift`)
> - `java.rmi.UnknownHostException` → `rmi/RMIUnknownHostException.swift`
>   (conflicts with `net/UnknownHostException.swift`)

version | implemented | tested   | type          | name                   | more informations
------- | ----------- | -------- | ------------- | ---------------------- | -----------------
1.1     | ✔️          | 🪄       | protocol      | Remote                 | marker; `rmi/Remote.swift`
1.1     | ✔️          | ⭕️       | class         | RemoteException        | extends IOException; `rmi/RemoteException.swift`
1.1     | ✔️          | ⭕️       | class         | AccessException        | extends RemoteException
1.1     | ✔️          | ⭕️       | class         | AlreadyBoundException  | extends Exception
1.1     | ✔️          | ⭕️       | class         | ConnectException       | extends RemoteException; **file:** `RMIConnectException.swift`
1.1     | ✔️          | ⭕️       | class         | ConnectIOException     | extends RemoteException
1.1     | ✔️          | ⭕️       | class         | MarshalException       | extends RemoteException
1.1     | ✔️          | ⭕️       | class         | NoSuchObjectException  | extends RemoteException
1.1     | ✔️          | ⭕️       | class         | NotBoundException      | extends Exception
1.1     | ✔️          | ⭕️       | class         | ServerError            | extends RemoteException
1.1     | ✔️          | ⭕️       | class         | ServerException        | extends RemoteException
1.1     | ✔️          | ⭕️       | class         | StubNotFoundException  | extends RemoteException
1.1     | ✔️          | ⭕️       | class         | UnexpectedException    | extends RemoteException
1.1     | ✔️          | ⭕️       | class         | UnknownHostException   | extends RemoteException; **file:** `RMIUnknownHostException.swift`
1.1     | ✔️          | ⭕️       | class         | UnmarshalException     | extends RemoteException

### java.awt.datatransfer — New package in 1.1

> **Platform support:**
> - **macOS** — `NSPasteboard.general` via `_AppKitClipboardProvider`
> - **iOS / tvOS** — `UIPasteboard.general` via `_UIKitClipboardProvider`
> - **Linux / FreeBSD (X11)** — in-memory fallback; TODO: `XSetSelectionOwner` / `xclip` / `wl-clipboard`
> - **Windows (Win32)** — in-memory fallback; TODO: refactor existing `OpenClipboard`/`SetClipboardData` from `_Win32FocusManager` into `_Win32ClipboardProvider`
> - **WASI / Headless** — in-memory buffer (`_HeadlessClipboardProvider`): copy → paste works within the process even without OS clipboard access
>
> Entry point: `java.awt.Toolkit.getDefaultToolkit().getSystemClipboard()`

##### java.awt.datatransfer.Transferable (3/3/0)

version | implemented | tested   | type          | name                       | more informations
------- | ----------- | -------- | ------------- | -------------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getTransferDataFlavors()   | ()->[DataFlavor]
1.1     | ✔️          | 🪄       | method        | isDataFlavorSupported()    | (DataFlavor)->boolean
1.1     | ✔️          | 🪄       | method        | getTransferData()          | (DataFlavor)->Any throws

##### java.awt.datatransfer.ClipboardOwner (1/1/0)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | lostOwnership()     | (Clipboard, Transferable)

##### java.awt.datatransfer.DataFlavor (8/8/6)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.1     | ✔️          | ✔️       | static field  | stringFlavor            | DataFlavor for Unicode String
1.1     | ✔️          | ✔️       | static field  | plainTextFlavor         | deprecated since Java 1.3, kept for API compat
1.1     | ✔️          | 🪄       | constructor   | DataFlavor()            | (String mimeType)
1.1     | ✔️          | 🪄       | constructor   | DataFlavor()            | (String mimeType, String humanPresentableName)
1.1     | ✔️          | ✔️       | method        | getMimeType()           | ()->String
1.1     | ✔️          | ✔️       | method        | getHumanPresentableName() | ()->String
1.1     | ✔️          | ✔️       | method        | isMimeTypeEqual()       | (String)->boolean
1.1     | ✔️          | ✔️       | method        | equals()                | (DataFlavor)->boolean

##### java.awt.datatransfer.UnsupportedFlavorException (1/1/1)

version | implemented | tested   | type          | name                          | more informations
------- | ----------- | -------- | ------------- | ----------------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | UnsupportedFlavorException()  | (DataFlavor)

##### java.awt.datatransfer.StringSelection (5/5/4)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | StringSelection()   | (String)
1.1     | ✔️          | ✔️       | method        | getTransferDataFlavors() | ()->[DataFlavor]
1.1     | ✔️          | ✔️       | method        | isDataFlavorSupported() | (DataFlavor)->boolean
1.1     | ✔️          | ✔️       | method        | getTransferData()   | (DataFlavor)->Any throws
1.1     | ✔️          | ⭕️       | method        | lostOwnership()     | (Clipboard,Transferable)

##### java.awt.datatransfer.Clipboard (6/6/6)

version | implemented | tested   | type          | name                     | more informations
------- | ----------- | -------- | ------------- | ------------------------ | -----------------
1.1     | ✔️          | ✔️       | constructor   | Clipboard()              | (String name, ClipboardProvider) — internal
1.1     | ✔️          | ✔️       | method        | getName()                | ()->String
1.1     | ✔️          | ✔️       | method        | setContents()            | (Transferable, ClipboardOwner?)
1.1     | ✔️          | ✔️       | method        | getContents()            | (AnyObject?)->Transferable?
1.1     | ✔️          | ✔️       | method        | isDataFlavorAvailable()  | (DataFlavor)->boolean
1.1     | ✔️          | ✔️       | method        | getData()                | (DataFlavor)->Any throws

### java.text — New package in 1.1 (mostly complete)

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

##### java.text.DecimalFormat

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | DecimalFormat()                  | ()
1.1     | ✔️          | ⭕️       | constructor   | DecimalFormat()                  | (String pattern)
1.1     | ✔️          | ⭕️       | method        | toPattern()                      | ()->String
1.1     | ✔️          | ⭕️       | method        | applyPattern()                   | (String)
1.1     | ✔️          | ⭕️       | method        | getDecimalFormatSymbols()        | ()->DecimalFormatSymbols
1.1     | ✔️          | ⭕️       | method        | setDecimalFormatSymbols()        | (DecimalFormatSymbols)
1.1     | ✔️          | ⭕️       | method        | getRoundingMode()/setRoundingMode() | RoundingMode
1.1     | ✔️          | ⭕️       | method        | isParseBigDecimal()/setParseBigDecimal() | boolean

##### java.text.DecimalFormatSymbols

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | DecimalFormatSymbols()           | ()
1.1     | ✔️          | ⭕️       | constructor   | DecimalFormatSymbols()           | (Locale)
1.1     | ✔️          | ⭕️       | method        | getDecimalSeparator()/setDecimalSeparator() | char
1.1     | ✔️          | ⭕️       | method        | getGroupingSeparator()/setGroupingSeparator() | char
1.1     | ✔️          | ⭕️       | method        | getMinusSign()/setMinusSign()    | char
1.1     | ✔️          | ⭕️       | method        | getPercent()/setPercent()        | char
1.1     | ✔️          | ⭕️       | method        | getZeroDigit()/setZeroDigit()    | char
1.1     | ✔️          | ⭕️       | method        | getInfinity()/setInfinity()      | String
1.1     | ✔️          | ⭕️       | method        | getNaN()/setNaN()                | String

##### java.text.MessageFormat

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | MessageFormat()                  | (String pattern)
1.1     | ✔️          | ⭕️       | static method | format()                         | (String pattern, Object...)->String
1.1     | ✔️          | ⭕️       | method        | applyPattern()                   | (String)
1.1     | ✔️          | ⭕️       | method        | toPattern()                      | ()->String

##### java.text.ChoiceFormat

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ChoiceFormat()                   | (String pattern)
1.1     | ✔️          | ⭕️       | method        | applyPattern()                   | (String)
1.1     | ✔️          | ⭕️       | method        | toPattern()                      | ()->String
1.1     | ✔️          | ⭕️       | method        | getLimits()                      | ()->[double]
1.1     | ✔️          | ⭕️       | method        | getFormats()                     | ()->[String]

##### java.text.CharacterIterator

> **Note:** Implemented as a `protocol` in `text/CharacterIterator.swift`. Constants `DONE` (= `￿`) match Java spec.

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | 🪄       | final field   | DONE                             | char = '￿'
1.1     | ✔️          | 🪄       | method        | first() / last()                 | ()->char
1.1     | ✔️          | 🪄       | method        | current()                        | ()->char
1.1     | ✔️          | 🪄       | method        | next() / previous()              | ()->char
1.1     | ✔️          | 🪄       | method        | setIndex()                       | (int)->char
1.1     | ✔️          | 🪄       | method        | getBeginIndex() / getEndIndex()  | ()->int
1.1     | ✔️          | 🪄       | method        | getIndex()                       | ()->int
1.1     | ✔️          | 🪄       | method        | clone()                          | ()->CharacterIterator

##### java.text.StringCharacterIterator

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | StringCharacterIterator()        | (String)
1.1     | ✔️          | ⭕️       | method        | setText()                        | (String)
1.1     | ✔️          | ⭕️       | method        | getText()                        | ()->String
1.1     | ✔️          | ⭕️       | method        | first()/last()/current()/next()/previous() | ()->char
1.1     | ✔️          | ⭕️       | method        | getBeginIndex()/getEndIndex()/getIndex() | ()->int
1.1     | ✔️          | ⭕️       | method        | clone()                          | ()->CharacterIterator

##### java.text.Collator

> **Note:** Implemented in `text/Collator.swift`. Backed by Foundation's `NSString` comparison with locale-sensitive `CompareOptions`. `getAvailableLocales()` is a Java 1.2 addition, tracked in ``Java_1.2``.

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | getInstance()                    | ()->Collator
1.1     | ✔️          | ⭕️       | static method | getInstance()                    | (Locale)->Collator
1.1     | ✔️          | ⭕️       | final field   | PRIMARY / SECONDARY / TERTIARY / IDENTICAL | int strength constants
1.1     | ✔️          | ⭕️       | method        | getStrength() / setStrength()    | int
1.1     | ✔️          | ⭕️       | method        | getDecomposition() / setDecomposition() | int
1.1     | ✔️          | ⭕️       | method        | compare()                        | (String,String)->int
1.1     | ✔️          | ⭕️       | method        | equals()                         | (String,String)->boolean
1.1     | ✔️          | ⭕️       | method        | getCollationKey()                | (String)->CollationKey

##### java.text.RuleBasedCollator

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | RuleBasedCollator()              | (String rules)
1.1     | ✔️          | ⭕️       | method        | getRules()                       | ()->String
1.1     | ✔️          | ⭕️       | method        | getCollationElementIterator()    | (String)->CollationElementIterator
1.1     | ✔️          | ⭕️       | method        | getCollationElementIterator()    | (StringCharacterIterator)->CollationElementIterator

##### java.text.CollationKey

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | compareTo()                      | (CollationKey)->int
1.1     | ✔️          | ⭕️       | method        | getSourceString()                | ()->String

##### java.text.CollationElementIterator

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | method        | next() / previous()              | ()->int
1.1     | ✔️          | ⭕️       | method        | reset()                          | ()
1.1     | ✔️          | ⭕️       | method        | getOffset() / setOffset()        | int
1.1     | ✔️          | ⭕️       | method        | setText()                        | (String) or (CharacterIterator)

##### java.text.BreakIterator

> **Note:** Implemented in `text/BreakIterator.swift`. Backed by `StringBreakingIterator` using Foundation `NSString.enumerateSubstrings`.

version | implemented | tested   | type          | name                             | more informations
------- | ----------- | -------- | ------------- | -------------------------------- | -----------------
1.1     | ✔️          | ⭕️       | final field   | DONE                             | int = -1
1.1     | ✔️          | ⭕️       | static method | getCharacterInstance()           | ()->BreakIterator
1.1     | ✔️          | ⭕️       | static method | getCharacterInstance()           | (Locale)->BreakIterator
1.1     | ✔️          | ⭕️       | static method | getWordInstance()                | ()->BreakIterator
1.1     | ✔️          | ⭕️       | static method | getWordInstance()                | (Locale)->BreakIterator
1.1     | ✔️          | ⭕️       | static method | getSentenceInstance()            | ()->BreakIterator
1.1     | ✔️          | ⭕️       | static method | getSentenceInstance()            | (Locale)->BreakIterator
1.1     | ✔️          | ⭕️       | static method | getLineInstance()                | ()->BreakIterator
1.1     | ✔️          | ⭕️       | static method | getLineInstance()                | (Locale)->BreakIterator
1.1     | ✔️          | ⭕️       | method        | setText()                        | (String)
1.1     | ✔️          | ⭕️       | method        | first() / last()                 | ()->int
1.1     | ✔️          | ⭕️       | method        | next() / previous()              | ()->int
1.1     | ✔️          | ⭕️       | method        | current()                        | ()->int
1.1     | ✔️          | ⭕️       | method        | following()                      | (int)->int
1.1     | ✔️          | ⭕️       | method        | isBoundary()                     | (int)->boolean

> **Missing from implementation:** `java.text.DateFormatSymbols` — provides locale-sensitive names for months, weekdays, AM/PM strings etc. Not yet implemented; `SimpleDateFormat` delegates formatting to Foundation instead of using a `DateFormatSymbols` instance. Tracked as ⭕️ (not ported).

>   High effort. Deferred; consider bridging to `CoreText` on Apple platforms or an ICU wrapper.

### java.util.zip — New in 1.1

##### java.util.zip.CheckedInputStream / CheckedOutputStream (2/2/2)

> **Note:** Implemented in `util/zip/CheckedInputStream.swift` and
> `util/zip/CheckedOutputStream.swift`. Both wrap any
> `FilterInputStream`/`FilterOutputStream` and update a `Checksum` protocol
> instance on every byte transferred. `CheckedInputStream` also provides a
> `skip(_:)` that reads-and-updates so the checksum stays accurate over skipped
> bytes.

version | implemented | tested   | type          | name                 | more informations
------- | ----------- | -------- | ------------- | -------------------- | -----------------
1.1     | ✔️          | ✔️       | class         | CheckedInputStream   | extends FilterInputStream; updates a Checksum as bytes are read
1.1     | ✔️          | ✔️       | class         | CheckedOutputStream  | extends FilterOutputStream; updates a Checksum as bytes are written

##### java.util.zip.Checksum (3/3/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | 🪄       | method        | update()       | (int)
1.1     | ✔️          | 🪄       | method        | getValue()     | ()->long
1.1     | ✔️          | 🪄       | method        | reset()        | ()

##### java.util.zip.CRC32 (1/1/1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | CRC32()        | ()

##### java.util.zip.Adler32 (1/1/1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | Adler32()      | ()

##### java.util.zip.DataFormatException (1/1/0)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | DataFormatException() | (String)

##### java.util.zip.Inflater (✔️)

> **Note:** Implemented in `util/zip/Inflater.swift` (the decompression counterpart of `Deflater`).

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | Inflater()     | ()
1.1     | ✔️          | ⭕️       | constructor   | Inflater(_ nowrap:) | (Bool)
1.1     | ✔️          | ⭕️       | method        | setInput(_:)   | ([UInt8])
1.1     | ✔️          | ⭕️       | method        | setDictionary(_:) | ([UInt8])
1.1     | ✔️          | ⭕️       | method        | needsInput()   | ()->Bool
1.1     | ✔️          | ⭕️       | method        | needsDictionary() | ()->Bool
1.1     | ✔️          | ⭕️       | method        | finished()     | ()->Bool
1.1     | ✔️          | ⭕️       | method        | inflate(_:)    | (inout [UInt8])->Int
1.1     | ✔️          | ⭕️       | method        | reset()        | ()
1.1     | ✔️          | ⭕️       | method        | end()          | ()

##### java.util.zip.Deflater (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constant      | NO_COMPRESSION | Int = 0
1.1     | ✔️          | ⭕️       | constant      | BEST_SPEED     | Int = 1
1.1     | ✔️          | ⭕️       | constant      | BEST_COMPRESSION | Int = 9
1.1     | ✔️          | ⭕️       | constant      | DEFAULT_COMPRESSION | Int = -1
1.1     | ✔️          | ⭕️       | constant      | DEFAULT_STRATEGY | Int = 0
1.1     | ✔️          | ⭕️       | constant      | FILTERED       | Int = 1
1.1     | ✔️          | ⭕️       | constant      | HUFFMAN_ONLY   | Int = 2
1.1     | ✔️          | ⭕️       | constructor   | Deflater()     | ()
1.1     | ✔️          | ⭕️       | constructor   | Deflater(_ level:) | (Int)
1.1     | ✔️          | ⭕️       | constructor   | Deflater(_ level:_ nowrap:) | (Int, Bool)
1.1     | ✔️          | ⭕️       | method        | setInput(_:)   | ([UInt8])
1.1     | ✔️          | ⭕️       | method        | setInput(_:_:_:) | ([UInt8],Int,Int)
1.1     | ✔️          | ⭕️       | method        | setDictionary(_:) | ([UInt8])
1.1     | ✔️          | ⭕️       | method        | setDictionary(_:_:_:) | ([UInt8],Int,Int)
1.1     | ✔️          | ⭕️       | method        | setLevel(_:)   | (Int)
1.1     | ✔️          | ⭕️       | method        | setStrategy(_:) | (Int)
1.1     | ✔️          | ⭕️       | method        | needsInput()   | ()->Bool
1.1     | ✔️          | ⭕️       | method        | finish()       | ()
1.1     | ✔️          | ⭕️       | method        | finished()     | ()->Bool
1.1     | ✔️          | ⭕️       | method        | deflate(_:)    | (inout [UInt8])->Int
1.1     | ✔️          | ⭕️       | method        | deflate(_:_:_:) | (inout [UInt8],Int,Int)->Int
1.1     | ✔️          | ⭕️       | method        | reset()        | ()
1.1     | ✔️          | ⭕️       | method        | end()          | ()
1.1     | ✔️          | ⭕️       | method        | getBytesRead() | ()->Int64
1.1     | ✔️          | ⭕️       | method        | getBytesWritten() | ()->Int64

##### java.util.zip.DeflaterOutputStream (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | DeflaterOutputStream(_ out:) | (OutputStream)
1.1     | ✔️          | ✔️       | constructor   | DeflaterOutputStream(_ out:_ def:) | (OutputStream, Deflater)
1.1     | ✔️          | ✔️       | constructor   | DeflaterOutputStream(_ out:_ def:_ size:) | (OutputStream, Deflater, Int)
1.1     | ✔️          | ✔️       | method        | write(_ b:_ off:_ len:) | ([UInt8],Int,Int)
1.1     | ✔️          | ✔️       | method        | finish()       | ()
1.1     | ✔️          | ✔️       | method        | close()        | ()

##### java.util.zip.InflaterInputStream (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | InflaterInputStream(_ in:) | (InputStream)
1.1     | ✔️          | ✔️       | constructor   | InflaterInputStream(_ in:_ inf:) | (InputStream, Inflater)
1.1     | ✔️          | ✔️       | constructor   | InflaterInputStream(_ in:_ inf:_ size:) | (InputStream, Inflater, Int)
1.1     | ✔️          | ✔️       | method        | read(_ array:_ offset:_ length:) | ([UInt8],Int,Int)->Int
1.1     | ✔️          | ✔️       | method        | available()    | ()->Int
1.1     | ✔️          | ✔️       | method        | close()        | ()

##### java.util.zip.DeflaterInputStream (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | DeflaterInputStream(_ in:) | (InputStream)
1.1     | ✔️          | ✔️       | constructor   | DeflaterInputStream(_ in:_ def:) | (InputStream, Deflater)
1.1     | ✔️          | ✔️       | constructor   | DeflaterInputStream(_ in:_ def:_ size:) | (InputStream, Deflater, Int)
1.1     | ✔️          | ✔️       | method        | read(_ array:_ offset:_ length:) | ([UInt8],Int,Int)->Int
1.1     | ✔️          | ✔️       | method        | close()        | ()

##### java.util.zip.InflaterOutputStream (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | InflaterOutputStream(_ out:) | (OutputStream)
1.1     | ✔️          | ✔️       | constructor   | InflaterOutputStream(_ out:_ inf:) | (OutputStream, Inflater)
1.1     | ✔️          | ✔️       | constructor   | InflaterOutputStream(_ out:_ inf:_ size:) | (OutputStream, Inflater, Int)
1.1     | ✔️          | ✔️       | method        | write(_ b:_ off:_ len:) | ([UInt8],Int,Int)
1.1     | ✔️          | ✔️       | method        | finish()       | ()
1.1     | ✔️          | ✔️       | method        | close()        | ()

##### java.util.zip.GZIPOutputStream (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constant      | GZIP_MAGIC     | Int = 0x8b1f
1.1     | ✔️          | ✔️       | constructor   | GZIPOutputStream(_ out:) | (OutputStream) throws
1.1     | ✔️          | ✔️       | constructor   | GZIPOutputStream(_ out:_ size:) | (OutputStream, Int) throws
1.1     | ✔️          | ✔️       | method        | write(_ b:_ off:_ len:) | ([UInt8],Int,Int)
1.1     | ✔️          | ✔️       | method        | finish()       | ()
1.1     | ✔️          | ✔️       | method        | close()        | ()

##### java.util.zip.GZIPInputStream (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constant      | GZIP_MAGIC     | Int = 0x8b1f
1.1     | ✔️          | ✔️       | constructor   | GZIPInputStream(_ in:) | (InputStream) throws
1.1     | ✔️          | ✔️       | constructor   | GZIPInputStream(_ in:_ size:) | (InputStream, Int) throws
1.1     | ✔️          | ✔️       | method        | read(_ array:_ offset:_ length:) | ([UInt8],Int,Int)->Int
1.1     | ✔️          | ✔️       | method        | close()        | ()

##### java.util.zip.ZipInputStream (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constructor   | ZipInputStream(_ in:) | (InputStream)
1.1     | ✔️          | ✔️       | method        | getNextEntry() | ()->ZipEntry?
1.1     | ✔️          | ✔️       | method        | closeEntry()   | ()
1.1     | ✔️          | ✔️       | method        | read(_ array:_ offset:_ length:) | ([UInt8],Int,Int)->Int
1.1     | ✔️          | ✔️       | method        | available()    | ()->Int
1.1     | ✔️          | ✔️       | method        | close()        | ()

##### java.util.zip.ZipOutputStream (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constant      | STORED         | Int = 0
1.1     | ✔️          | ✔️       | constant      | DEFLATED       | Int = 8
1.1     | ✔️          | ✔️       | constructor   | ZipOutputStream(_ out:) | (OutputStream)
1.1     | ✔️          | ✔️       | method        | putNextEntry(_ entry:) | (ZipEntry)
1.1     | ✔️          | ✔️       | method        | write(_ b:_ off:_ len:) | ([UInt8],Int,Int)
1.1     | ✔️          | ✔️       | method        | closeEntry()   | ()
1.1     | ✔️          | ✔️       | method        | finish()       | ()
1.1     | ✔️          | ✔️       | method        | close()        | ()

##### java.util.zip.ZipConstants (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ✔️       | constant      | LOCSIG         | Int64
1.1     | ✔️          | ✔️       | constant      | EXTSIG         | Int64
1.1     | ✔️          | ✔️       | constant      | CENSIG         | Int64
1.1     | ✔️          | ✔️       | constant      | ENDSIG         | Int64
1.1     | ✔️          | ✔️       | constant      | LOCHDR/EXTHDR/CENHDR/ENDHDR | sizes
1.1     | ✔️          | ✔️       | constant      | LOC*/EXT*/CEN*/END* | field offsets
1.1     | ✔️          | ⭕️       | constant      | STORED         | Int = 0
1.1     | ✔️          | ⭕️       | constant      | DEFLATED       | Int = 8

##### java.util.zip.ZipException (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ZipException() | ()
1.1     | ✔️          | ⭕️       | constructor   | ZipException(_ message: String) | (String)

##### java.util.zip.ZipEntry (✔️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constant      | STORED         | Int = 0
1.1     | ✔️          | ⭕️       | constant      | DEFLATED       | Int = 8
1.1     | ✔️          | ⭕️       | constructor   | ZipEntry(_ name: String) | (String)
1.1     | ✔️          | ⭕️       | constructor   | ZipEntry(_ entry: ZipEntry) | (ZipEntry)
1.1     | ✔️          | ⭕️       | method        | getName()      | ()->String
1.1     | ✔️          | ⭕️       | method        | setTime(_:)    | (Int64)
1.1     | ✔️          | ⭕️       | method        | getTime()      | ()->Int64
1.1     | ✔️          | ⭕️       | method        | setSize(_:)    | (Int64)
1.1     | ✔️          | ⭕️       | method        | getSize()      | ()->Int64
1.1     | ✔️          | ⭕️       | method        | getCompressedSize() | ()->Int64
1.1     | ✔️          | ⭕️       | method        | setCompressedSize(_:) | (Int64)
1.1     | ✔️          | ⭕️       | method        | setCrc(_:)     | (Int64)
1.1     | ✔️          | ⭕️       | method        | getCrc()       | ()->Int64
1.1     | ✔️          | ⭕️       | method        | setMethod(_:)  | (Int)
1.1     | ✔️          | ⭕️       | method        | getMethod()    | ()->Int
1.1     | ✔️          | ⭕️       | method        | setExtra(_:)   | ([UInt8]?)
1.1     | ✔️          | ⭕️       | method        | getExtra()     | ()->[UInt8]?
1.1     | ✔️          | ⭕️       | method        | setComment(_:) | (String?)
1.1     | ✔️          | ⭕️       | method        | getComment()   | ()->String?
1.1     | ✔️          | ⭕️       | method        | isDirectory()  | ()->Bool
1.1     | ✔️          | ⭕️       | method        | toString()     | ()->String
1.1     | ✔️          | ⭕️       | method        | clone()        | ()->ZipEntry

##### java.util.zip.ZipFile (✔️)

> **Note:** Implemented in `util/zip/ZipFile.swift`. Parses the central directory
> for random-access lookup (unlike the sequential `ZipInputStream`). The archive
> is read into memory on construction; `getInputStream(_:)` returns a
> `ByteArrayInputStream` over the eagerly decompressed bytes. Conforms to
> `java.io.Closeable`. ZIP64 is a future (Java 6) TODO.

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | constructor   | ZipFile(_ name:) | (String) throws
1.1     | ✔️          | ⭕️       | constructor   | ZipFile(_ file:) | (File) throws
1.1     | ✔️          | ⭕️       | method        | getName()      | ()->String
1.1     | ✔️          | ⭕️       | method        | size()         | ()->Int
1.1     | ✔️          | ⭕️       | method        | entries()      | ()->Enumeration\<ZipEntry\>
1.1     | ✔️          | ⭕️       | method        | getEntry(_:)   | (String)->ZipEntry?
1.1     | ✔️          | ⭕️       | method        | getInputStream(_:) | (ZipEntry)->InputStream throws
1.1     | ✔️          | ⭕️       | method        | close()        | () throws
1.3     | ✔️          | ⭕️       | constant      | OPEN_READ / OPEN_DELETE | Int (1.3 additions, for completeness)

### java.sql — New package in 1.1 (JDBC 1.x)

> **Note:** JDBC 1.x defines the `java.sql` package. Concrete driver implementations
> live in separate library targets (e.g. `SQLiteJDBC`). Drivers are registered via
> the static SPI registry in ``java/sql/DriverManager`` — see ``Java2Swift`` for
> the SPI→Registry pattern. `CallableStatement` is provided for API completeness
> but no bundled driver implements it (SQLite has no stored procedures).

##### java.sql.DriverManager (6/6/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ⭕️       | static method | registerDriver()      | (Driver)
1.1     | ✔️          | ⭕️       | static method | deregisterDriver()    | (Driver)
1.1     | ✔️          | ⭕️       | static method | getConnection()       | (String)->Connection
1.1     | ✔️          | ⭕️       | static method | getConnection()       | (String,[String:String]?)->Connection
1.1     | ✔️          | ⭕️       | static method | getDriver()           | (String)->Driver
1.1     | ✔️          | ⭕️       | static method | getDrivers()          | ()->[Driver]

##### java.sql.Driver (6/6/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | acceptsURL()          | (String)->Bool
1.1     | ✔️          | 🪄       | method        | connect()             | (String,[String:String]?)->Connection?
1.1     | ✔️          | 🪄       | method        | getPropertyInfo()     | (String,[String:String]?)->[DriverPropertyInfo]
1.1     | ✔️          | 🪄       | property      | majorVersion          | Int
1.1     | ✔️          | 🪄       | property      | minorVersion          | Int
1.1     | ✔️          | 🪄       | property      | jdbcCompliant         | Bool

##### java.sql.Connection (11/11/0)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | createStatement()       | ()->Statement
1.1     | ✔️          | 🪄       | method        | prepareStatement()      | (String)->PreparedStatement
1.1     | ✔️          | 🪄       | method        | prepareCall()           | (String)->CallableStatement
1.1     | ✔️          | 🪄       | method        | getAutoCommit()         | ()->Bool
1.1     | ✔️          | 🪄       | method        | setAutoCommit()         | (Bool)
1.1     | ✔️          | 🪄       | method        | commit()                | ()
1.1     | ✔️          | 🪄       | method        | rollback()              | ()
1.1     | ✔️          | 🪄       | method        | close() / isClosed()    | ()
1.1     | ✔️          | 🪄       | method        | getMetaData()           | ()->DatabaseMetaData
1.1     | ✔️          | 🪄       | method        | getTransactionIsolation() / setTransactionIsolation() | ()
1.1     | ✔️          | 🪄       | final field   | TRANSACTION_* constants | Int

##### java.sql.Statement (8/8/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | executeQuery()        | (String)->ResultSet
1.1     | ✔️          | 🪄       | method        | executeUpdate()       | (String)->Int
1.1     | ✔️          | 🪄       | method        | execute()             | (String)->Bool
1.1     | ✔️          | 🪄       | method        | getResultSet()        | ()->ResultSet?
1.1     | ✔️          | 🪄       | method        | getUpdateCount()      | ()->Int
1.1     | ✔️          | 🪄       | method        | close()               | ()
1.1     | ✔️          | 🪄       | method        | setMaxRows()          | (Int)
1.1     | ✔️          | 🪄       | method        | setQueryTimeout()     | (Int)

##### java.sql.PreparedStatement (9/9/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | executeQuery()        | ()->ResultSet
1.1     | ✔️          | 🪄       | method        | executeUpdate()       | ()->Int
1.1     | ✔️          | 🪄       | method        | execute()             | ()->Bool
1.1     | ✔️          | 🪄       | method        | clearParameters()     | ()
1.1     | ✔️          | 🪄       | method        | setNull()             | (Int,Int)
1.1     | ✔️          | 🪄       | method        | setBoolean/setInt/setLong/setDouble() | (Int,T)
1.1     | ✔️          | 🪄       | method        | setString()           | (Int,String?)
1.1     | ✔️          | 🪄       | method        | setDate/setTime/setTimestamp() | (Int,java.sql.T?)
1.1     | ✔️          | 🪄       | method        | setBytes()            | (Int,[UInt8]?)

##### java.sql.CallableStatement (⭕️ stub only)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | registerOutParameter() | (Int,Int)
1.1     | ✔️          | 🪄       | method        | get*()                | result accessors

##### java.sql.ResultSet (7/7/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | next()                | ()->Bool
1.1     | ✔️          | 🪄       | method        | close() / wasNull()   | ()
1.1     | ✔️          | 🪄       | method        | getString()           | (Int/String)->String?
1.1     | ✔️          | 🪄       | method        | getBoolean/getInt/getLong/getDouble() | (Int/String)
1.1     | ✔️          | 🪄       | method        | getDate/getTime/getTimestamp() | (Int/String)->java.sql.T?
1.1     | ✔️          | 🪄       | method        | getMetaData()         | ()->ResultSetMetaData
1.1     | ✔️          | 🪄       | method        | findColumn()          | (String)->Int

##### java.sql.ResultSetMetaData (7/7/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getColumnCount()      | ()->Int
1.1     | ✔️          | 🪄       | method        | getColumnName()       | (Int)->String
1.1     | ✔️          | 🪄       | method        | getColumnLabel()      | (Int)->String
1.1     | ✔️          | 🪄       | method        | getColumnType()       | (Int)->Int
1.1     | ✔️          | 🪄       | method        | getColumnTypeName()   | (Int)->String
1.1     | ✔️          | 🪄       | method        | isNullable()          | (Int)->Int
1.1     | ✔️          | 🪄       | method        | getColumnDisplaySize()| (Int)->Int

##### java.sql.DatabaseMetaData (minimal/⭕️)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | method        | getDatabaseProductName/Version() | ()->String
1.1     | ✔️          | 🪄       | method        | getDriverName/Version() | ()->String
1.1     | ✔️          | 🪄       | method        | getTables()           | (String?,String?,String?,[String]?)->ResultSet
1.1     | ✔️          | 🪄       | method        | getColumns()          | (String?,String?,String?,String?)->ResultSet
1.1     | ✔️          | 🪄       | method        | supportsTransactions() | ()->Bool

##### java.sql.Types (6/6/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | final field   | BIT/TINYINT/SMALLINT/INTEGER/BIGINT | Int constants
1.1     | ✔️          | 🪄       | final field   | FLOAT/REAL/DOUBLE/NUMERIC/DECIMAL | Int constants
1.1     | ✔️          | 🪄       | final field   | CHAR/VARCHAR/LONGVARCHAR | Int constants
1.1     | ✔️          | 🪄       | final field   | DATE/TIME/TIMESTAMP  | Int constants
1.1     | ✔️          | 🪄       | final field   | BINARY/VARBINARY/LONGVARBINARY | Int constants
1.1     | ✔️          | 🪄       | final field   | NULL/OTHER           | Int constants

##### java.sql.Date / Time / Timestamp (3/3/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | Date                  | extends java.util.Date; toString() → `yyyy-MM-dd`
1.1     | ✔️          | ⭕️       | class         | Time                  | extends java.util.Date; toString() → `HH:mm:ss`
1.1     | ✔️          | ⭕️       | class         | Timestamp             | extends java.util.Date; getNanos()/setNanos(); toString() → `yyyy-MM-dd HH:mm:ss.nnnnnnnnn`

##### java.sql.SQLException / SQLWarning (2/2/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | ⭕️       | class         | SQLException          | extends Exception; getSQLState(), getErrorCode()
1.1     | ✔️          | ⭕️       | class         | SQLWarning            | extends SQLException; getNextWarning(), setNextWarning()

##### java.sql.DriverPropertyInfo (21/18/0)

version | implemented | tested   | type          | name                  | more informations
------- | ----------- | -------- | ------------- | --------------------- | -----------------
1.1     | ✔️          | 🪄       | class         | DriverPropertyInfo    | name, value, required, description, choices

## Implementation Status Summary

| Package | Status | Notes |
|---------|--------|-------|
| **java.io** (Reader/Writer hierarchy) | ✔️ implemented, ⭕️ tests | all classes present, tests sparse |
| **java.io** (Object Serialization) | ✔️ stub | `Externalizable`, `ObjectInputValidation`, `ObjectStreamClass` implemented; `ObjectInputStream`/`ObjectOutputStream` have constructors + stream delegation; `readObject`/`writeObject` throw `NotActiveException` |
| **java.lang.reflect** | ✔️ partial | Field + Mirror-based; Method/Constructor not portable |
| **java.text** | ✔️ mostly complete | Format, NumberFormat, DecimalFormat, DecimalFormatSymbols, DateFormat, SimpleDateFormat, MessageFormat, ChoiceFormat, Collator, RuleBasedCollator, CollationKey, CollationElementIterator, BreakIterator, CharacterIterator, StringCharacterIterator — all implemented; `DateFormatSymbols` not yet implemented (SimpleDateFormat delegates to Foundation); Normalizer/Bidi deferred (see TODO notes above) |
| **java.util.zip** | ✔️ complete | Checksum, CRC32, Adler32, Deflater, Inflater, GZIP, ZIP streams, `ZipFile` (random-access read), `CheckedInputStream`, `CheckedOutputStream` |
| **java.awt.event** | ✔️ complete | all listeners, events and adapter classes; `PaintEvent` added; `MouseAdapter` (MouseListener only) and `MouseMotionAdapter` (MouseMotionListener only) are separate classes — matching Java 1.1 exactly |
| **java.awt** (1.1 additions) | ✔️ complete | `AWTEventMulticaster`, `EventQueue`, `Shape`, `IllegalComponentStateException` implemented; all 1.1 types present |
| **java.awt.image** (1.1 additions) | ✔️ complete | `ReplicateScaleFilter`, `AreaAveragingScaleFilter`, `MemoryImageSource` animation API (`setAnimated`, `setFullBufferUpdates`, 5× `newPixels`), `PixelGrabber` 1.1 additions (`abortGrabbing`, `startGrabbing`, `getColorModel`, `getHeight`, `getWidth`, new constructor) — all implemented |
| **java.awt printing** | ✔️ stub | `PrintJob` + `Toolkit.getPrintJob()` present; base returns defaults, platform backend overrides |
| **java.util** (i18n) | ✔️ | Locale, TimeZone, SimpleTimeZone, ResourceBundle, Calendar |
| **java.net** | ✔️ complete | `BindException`, `ConnectException`, `NoRouteToHostException`, `DatagramPacket` setters, `DatagramSocket(int,InetAddress)`, `getSoTimeout`/`setSoTimeout`, `getLocalAddress()`, `URLConnection.getFileNameMap()`/`setFileNameMap()` — all implemented |
| **java.security** | ✔️ complete | MessageDigest, SecureRandom, Principal, Key/PublicKey/PrivateKey, Provider, DigestInputStream, DigestOutputStream, KeyPair, KeyPairGenerator, Signature, Security; `acl` fully implemented (deprecated since Java 17, removed Java 24) |
| **java.security.interfaces** | ✔️ complete | DSAParams, DSAKey, DSAPublicKey, DSAPrivateKey, DSAKeyPairGenerator — all pure protocols |
| **java.beans** | ✔️ | PropertyChange + VetoableChange fully implemented; `IntrospectionException`, `Visibility`, `FeatureDescriptor`, `Beans` (env queries), `Customizer`, `PropertyEditor`, `PropertyEditorSupport` added; reflection-based introspection not ported |
| **java.sql (JDBC 1.x)** | ✔️ protocols | All JDBC 1.x protocols + `DriverManager` registry; concrete driver in `SQLiteJDBC` target (macOS) |
| **java.rmi** | ✔️ stubs | `Remote` marker + 14 exception classes as compile-time stubs; RMI networking stack not implemented |
| **java.awt.datatransfer** | ✔️ implemented | `Transferable`, `ClipboardOwner`, `DataFlavor`, `StringSelection`, `UnsupportedFlavorException`, `Clipboard`; macOS/iOS native, X11/Win32 in-memory fallback (TODO: native) |
| **java.lang.reflect.Method/Constructor/Array** | ⭕️ not ported | Swift has no runtime method/constructor introspection API — not portable |

---

## What is still needed for full Java 1.1 compatibility

Verified against the actual source tree and javaalmanac.io (June 2026).
Almost all in-scope Java 1.1 public API items have been implemented.
The remaining open work is:

---

Everything else listed in the tables above is implemented (some with `⭕️`
tests still to be written; that column tracks test coverage, not implementation).

## Not in scope for this implementation

The following Java 1.1 APIs are explicitly a the moment **not** ported because they have no meaningful Swift equivalent concerns:

- **java.rmi networking stack**, **java.rmi.dgc**, **java.rmi.registry**, **java.rmi.server** — Remote Method Invocation requires a JVM runtime; no Swift equivalent. For the full rationale see <doc:NotImplemented>. The `java.rmi` exception hierarchy and `Remote` marker are present as compile-time stubs (see table above).
- **java.beans (BeanDescriptor, Introspector, BeanInfo, etc.)** — Reflection-based introspection API has no Swift equivalent and is not ported. For the full rationale see <doc:NotImplemented>. 
- **Inner classes** — Language feature of Java, not a library API to port.
