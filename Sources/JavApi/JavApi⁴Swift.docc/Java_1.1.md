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
