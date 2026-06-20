# Java 1.2

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

1998-12-08 release of Java 1.2 (also known as "Java 2").

## Overview

Java 1.2 introduced the Collections Framework, Java 2D API (JFC), `strictfp`,
`AccessController`, and the Swing toolkit (`javax.swing`). This file tracks the
Java 2D additions to `java.awt` and the new `java.awt.geom` / `java.awt.image`
sub-packages.

### How to read?

- Header type name (count of fields or methods / count of implemented / count of tests)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members are **not** part of the public API and are
> not ported. Only `public` and `protected` members are in scope.

---

## java.awt — Java 2D additions

### java.awt.Graphics2D (✔️/⭕️)

> Concrete implementation backed by `CGContext` on Apple platforms.
> Obtained via `Component.getGraphics()` or `BufferedImage.createGraphics()`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | method        | getStroke()             | ()->Stroke
1.2     | ✔️          | ⭕️       | method        | setStroke()             | (Stroke)
1.2     | ✔️          | ⭕️       | method        | getPaint()              | ()->Paint
1.2     | ✔️          | ⭕️       | method        | setPaint()              | (Paint)
1.2     | ✔️          | ⭕️       | method        | getComposite()          | ()->Composite
1.2     | ✔️          | ⭕️       | method        | setComposite()          | (Composite)
1.2     | ✔️          | ⭕️       | method        | getTransform()          | ()->AffineTransform
1.2     | ✔️          | ⭕️       | method        | setTransform()          | (AffineTransform)
1.2     | ✔️          | ⭕️       | method        | transform()             | (AffineTransform)
1.2     | ✔️          | ⭕️       | method        | translate()             | (double,double)
1.2     | ✔️          | ⭕️       | method        | rotate()                | (double)
1.2     | ✔️          | ⭕️       | method        | scale()                 | (double,double)
1.2     | ✔️          | ⭕️       | method        | shear()                 | (double,double)
1.2     | ✔️          | ⭕️       | method        | getRenderingHint()      | (RenderingHints.Key)->Object?
1.2     | ✔️          | ⭕️       | method        | setRenderingHint()      | (RenderingHints.Key,Object)
1.2     | ✔️          | ⭕️       | method        | getRenderingHints()     | ()->RenderingHints
1.2     | ✔️          | ⭕️       | method        | setRenderingHints()     | (RenderingHints)
1.2     | ✔️          | ⭕️       | method        | getBackground()         | ()->Color
1.2     | ✔️          | ⭕️       | method        | setBackground()         | (Color)
1.2     | ✔️          | ⭕️       | method        | getClip()               | ()->Shape?
1.2     | ✔️          | ⭕️       | method        | setClip()               | (Shape?)
1.2     | ✔️          | ⭕️       | method        | clip()                  | (Shape)
1.2     | ✔️          | ⭕️       | method        | draw()                  | (Shape)
1.2     | ✔️          | ⭕️       | method        | fill()                  | (Shape)
1.2     | ✔️          | ⭕️       | method        | drawString()            | (String,float,float)

### java.awt.BasicStroke (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | final field   | CAP_BUTT                | int = 0
1.2     | ✔️          | 🪄       | final field   | CAP_ROUND               | int = 1
1.2     | ✔️          | 🪄       | final field   | CAP_SQUARE              | int = 2
1.2     | ✔️          | 🪄       | final field   | JOIN_MITER              | int = 0
1.2     | ✔️          | 🪄       | final field   | JOIN_ROUND              | int = 1
1.2     | ✔️          | 🪄       | final field   | JOIN_BEVEL              | int = 2
1.2     | ✔️          | ⭕️       | constructor   | BasicStroke()           | ()
1.2     | ✔️          | ⭕️       | constructor   | BasicStroke()           | (float)
1.2     | ✔️          | ⭕️       | constructor   | BasicStroke()           | (float,int,int)
1.2     | ✔️          | ⭕️       | constructor   | BasicStroke()           | (float,int,int,float)
1.2     | ✔️          | ⭕️       | constructor   | BasicStroke()           | (float,int,int,float,float[],float)
1.2     | ✔️          | ⭕️       | method        | getLineWidth()          | ()->float
1.2     | ✔️          | ⭕️       | method        | getEndCap()             | ()->int
1.2     | ✔️          | ⭕️       | method        | getLineJoin()           | ()->int
1.2     | ✔️          | ⭕️       | method        | getMiterLimit()         | ()->float
1.2     | ✔️          | ⭕️       | method        | getDashArray()          | ()->[float]?
1.2     | ✔️          | ⭕️       | method        | getDashPhase()          | ()->float

### java.awt.Paint (protocol) (✔️/🪄)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | protocol      | Paint                   | marker protocol; Color conforms

### java.awt.Stroke (protocol) (✔️/🪄)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | protocol      | Stroke                  | createStrokedShape(Shape)->Shape

### java.awt.Composite / AlphaComposite (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | protocol      | Composite               | marker protocol
1.2     | ✔️          | ⭕️       | final field   | AlphaComposite.SRC_OVER | rule = 3
1.2     | ✔️          | ⭕️       | final field   | AlphaComposite.SRC      | rule = 1
1.2     | ✔️          | ⭕️       | final field   | AlphaComposite.CLEAR    | rule = 0
1.2     | ✔️          | ⭕️       | method        | AlphaComposite.getInstance() | (int)->AlphaComposite
1.2     | ✔️          | ⭕️       | method        | AlphaComposite.getInstance() | (int,float)->AlphaComposite
1.2     | ✔️          | ⭕️       | method        | getAlpha()              | ()->float
1.2     | ✔️          | ⭕️       | method        | getRule()               | ()->int

### java.awt.RenderingHints (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | constructor   | RenderingHints()        | ()
1.2     | ✔️          | ⭕️       | final field   | KEY_ANTIALIASING        |
1.2     | ✔️          | ⭕️       | final field   | VALUE_ANTIALIAS_ON      |
1.2     | ✔️          | ⭕️       | final field   | VALUE_ANTIALIAS_OFF     |
1.2     | ✔️          | ⭕️       | final field   | KEY_RENDERING           |
1.2     | ✔️          | ⭕️       | final field   | VALUE_RENDER_QUALITY    |
1.2     | ✔️          | ⭕️       | final field   | VALUE_RENDER_SPEED      |
1.2     | ✔️          | ⭕️       | method        | get()                   | (Key)->Object?
1.2     | ✔️          | ⭕️       | method        | put()                   | (Key,Object)

### java.awt.ComponentOrientation (✔️/🪄)

> Describes the language-sensitivity of component orientation (LTR/RTL).
> Static factory `getOrientation(Locale)` returns `RIGHT_TO_LEFT` for Arabic, Hebrew, Persian and Urdu locales.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | final class   | ComponentOrientation    | @unchecked Sendable
1.2     | ✔️          | 🪄       | final field   | LEFT_TO_RIGHT           | horizontal LTR
1.2     | ✔️          | 🪄       | final field   | RIGHT_TO_LEFT           | horizontal RTL
1.2     | ✔️          | 🪄       | final field   | UNKNOWN                 | alias for LEFT_TO_RIGHT (stub)
1.2     | ✔️          | ⭕️       | method        | isHorizontal()          | ()->Bool
1.2     | ✔️          | ⭕️       | method        | isLeftToRight()         | ()->Bool
1.2     | ✔️          | ⭕️       | static method | getOrientation()        | (Locale)->ComponentOrientation

### java.awt.FontFormatException (✔️/🪄)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | open class    | FontFormatException     | extends Exception; 4-init pattern; @unchecked Sendable

### java.awt.HeadlessException (✔️/🪄)

> Thrown when a display, keyboard or mouse is required but none is available.
> Extends `UnsupportedOperationException`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | open class    | HeadlessException       | extends UnsupportedOperationException; 4-init pattern; @unchecked Sendable

### java.awt.GraphicsConfiguration (✔️/⭕️)

> Abstract class representing a graphics destination (screen, printer, image buffer).
> Headless environments throw via `fatalError` from `getDevice()`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | open class    | GraphicsConfiguration   |
1.2     | ✔️          | ⭕️       | method        | getDevice()             | ()->GraphicsDevice (fatalError stub)
1.2     | ✔️          | ⭕️       | method        | getBounds()             | ()->Rectangle

### java.awt.GraphicsDevice (✔️/⭕️)

> Represents a graphics device such as a screen monitor, a printer or an image buffer.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | open class    | GraphicsDevice          |
1.2     | ✔️          | 🪄       | final field   | TYPE_RASTER_SCREEN      | int = 0
1.2     | ✔️          | 🪄       | final field   | TYPE_PRINTER            | int = 1
1.2     | ✔️          | 🪄       | final field   | TYPE_IMAGE_BUFFER       | int = 2
1.2     | ✔️          | ⭕️       | method        | getType()               | ()->Int
1.2     | ✔️          | ⭕️       | method        | getIDstring()           | ()->String
1.2     | ✔️          | ⭕️       | method        | getConfigurations()     | ()->[GraphicsConfiguration]
1.2     | ✔️          | ⭕️       | method        | getDefaultConfiguration() | ()->GraphicsConfiguration (fatalError stub)
1.2     | ✔️          | ⭕️       | method        | isFullScreenSupported() | ()->Bool
1.2     | ✔️          | ⭕️       | method        | getFullScreenWindow()   | ()->Window?
1.2     | ✔️          | ⭕️       | @MainActor method | setFullScreenWindow() | (Window?)

### java.awt.GraphicsEnvironment (✔️/⭕️)

> Abstract singleton describing the GraphicsDevice and Font objects available on the current
> platform. `getLocalGraphicsEnvironment()` returns `HeadlessGraphicsEnvironment` by default;
> platform subclasses override via the internal `_localEnvironment` hook.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | open class    | GraphicsEnvironment     |
1.2     | ✔️          | ⭕️       | static method | getLocalGraphicsEnvironment() | ()->GraphicsEnvironment
1.2     | ✔️          | ⭕️       | static method | isHeadless()            | ()->Bool
1.2     | ✔️          | ⭕️       | method        | isHeadlessInstance()    | ()->Bool
1.2     | ✔️          | ⭕️       | method        | getScreenDevices()      | ()->[GraphicsDevice] (fatalError in headless)
1.2     | ✔️          | ⭕️       | method        | getDefaultScreenDevice()| ()->GraphicsDevice (fatalError in headless)
1.2     | ✔️          | ⭕️       | method        | getAllFonts()            | ()->[Font]
1.2     | ✔️          | ⭕️       | method        | getAvailableFontFamilyNames() | ()->[String]

### java.awt.AWTEventMulticaster (✔️/⭕️)

> Binary-tree chaining of `EventListener` instances following the AWT multicaster pattern.
> `AWTEventMulticaster.add(existing, newListener)` builds the chain;
> `remove(existing, target)` prunes it. Thread safety: `@MainActor`.
>
> **Note:** `AWTEventMulticaster` was introduced in Java 1.1 but implemented here alongside
> the Java 1.2 JFC work.
>
> Supported listener protocols: `ActionListener`, `MouseListener`, `MouseMotionListener`,
> `KeyListener`, `WindowListener`, `FocusListener`, `ComponentListener`,
> `ContainerListener`, `AdjustmentListener`, `ItemListener`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.1     | ✔️          | ⭕️       | final class   | AWTEventMulticaster     | @MainActor; conforms to 10 listener protocols
1.1     | ✔️          | ⭕️       | static method | add()                   | overloads for each of 10 listener types
1.1     | ✔️          | ⭕️       | static method | remove()                | overloads for each of 10 listener types
1.1     | ✔️          | ⭕️       | method        | actionPerformed()       | ActionEvent dispatch
1.1     | ✔️          | ⭕️       | method        | mouseClicked/Pressed/Released/Entered/Exited() | MouseEvent dispatch
1.1     | ✔️          | ⭕️       | method        | mouseMoved/Dragged()    | MouseMotionEvent dispatch
1.1     | ✔️          | ⭕️       | method        | keyPressed/Released/Typed() | KeyEvent dispatch
1.1     | ✔️          | ⭕️       | method        | windowOpened/Closed/Activated/Deactivated/Iconified/Deiconified() | WindowEvent dispatch
1.1     | ✔️          | ⭕️       | method        | focusGained/Lost()      | FocusEvent dispatch
1.1     | ✔️          | ⭕️       | method        | componentResized/Moved/Shown/Hidden() | ComponentEvent dispatch
1.1     | ✔️          | ⭕️       | method        | componentAdded/Removed()| ContainerEvent dispatch
1.1     | ✔️          | ⭕️       | method        | adjustmentValueChanged()| AdjustmentEvent dispatch
1.1     | ✔️          | ⭕️       | method        | itemStateChanged()      | ItemEvent dispatch

---

## java.awt.geom — New package in 1.2

### java.awt.geom.AffineTransform (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | constructor   | AffineTransform()       | ()
1.2     | ✔️          | ⭕️       | constructor   | AffineTransform()       | (double,double,double,double,double,double)
1.2     | ✔️          | ⭕️       | method        | getScaleX/Y()           | ()->double
1.2     | ✔️          | ⭕️       | method        | getShearX/Y()           | ()->double
1.2     | ✔️          | ⭕️       | method        | getTranslateX/Y()       | ()->double
1.2     | ✔️          | ⭕️       | method        | translate()             | (double,double)
1.2     | ✔️          | ⭕️       | method        | rotate()                | (double)
1.2     | ✔️          | ⭕️       | method        | scale()                 | (double,double)
1.2     | ✔️          | ⭕️       | method        | shear()                 | (double,double)
1.2     | ✔️          | ⭕️       | method        | concatenate()           | (AffineTransform)
1.2     | ✔️          | ⭕️       | method        | createInverse()         | ()->AffineTransform throws
1.2     | ✔️          | ⭕️       | method        | transform()             | (Point2D,Point2D)->Point2D
1.2     | ✔️          | ⭕️       | method        | isIdentity()            | ()->bool
1.2     | ✔️          | ⭕️       | class (Bridge)| toCGAffineTransform()   | Apple-platform extension

### java.awt.geom.Point2D (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | abstract class| Point2D                 |
1.2     | ✔️          | ⭕️       | inner class   | Point2D.Double          |
1.2     | ✔️          | ⭕️       | inner class   | Point2D.Float           |
1.2     | ✔️          | ⭕️       | method        | getX() / getY()         | ()->double
1.2     | ✔️          | ⭕️       | method        | setLocation()           | (double,double)
1.2     | ✔️          | ⭕️       | method        | distance()              | static (double,double,double,double)->double

### java.awt.geom.RectangularShape (✔️/⭕️)

> Abstract base for `Rectangle2D`, `Ellipse2D`, `Arc2D`, `RoundRectangle2D`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | abstract class| RectangularShape        |
1.2     | ✔️          | 🪄       | method        | getMinX/Y()             | ()->double
1.2     | ✔️          | 🪄       | method        | getMaxX/Y()             | ()->double
1.2     | ✔️          | 🪄       | method        | getCenterX/Y()          | ()->double
1.2     | ✔️          | 🪄       | method        | setFrame()              | (double,double,double,double)
1.2     | ✔️          | 🪄       | method        | setFrameFromDiagonal()  | (double,double,double,double)
1.2     | ✔️          | 🪄       | method        | setFrameFromCenter()    | (double,double,double,double)
1.2     | ✔️          | 🪄       | method        | getBounds()             | ()->Rectangle

### java.awt.geom.Rectangle2D (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | inner class   | Rectangle2D.Double      |
1.2     | ✔️          | ⭕️       | inner class   | Rectangle2D.Float       |
1.2     | ✔️          | ⭕️       | final field   | OUT_LEFT/TOP/RIGHT/BOTTOM |
1.2     | ✔️          | ⭕️       | method        | contains()              | (double,double)
1.2     | ✔️          | ⭕️       | method        | intersects()            | (double,double,double,double)
1.2     | ✔️          | ⭕️       | method        | union()                 | (Rectangle2D,Rectangle2D,Rectangle2D)
1.2     | ✔️          | ⭕️       | method        | add()                   | (double,double)

### java.awt.geom.Ellipse2D (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | inner class   | Ellipse2D.Double        |
1.2     | ✔️          | ⭕️       | inner class   | Ellipse2D.Float         |
1.2     | ✔️          | ⭕️       | method        | contains()              | (double,double)
1.2     | ✔️          | ⭕️       | method        | intersects()            | (double,double,double,double)

### java.awt.geom.Line2D (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | inner class   | Line2D.Double           |
1.2     | ✔️          | ⭕️       | inner class   | Line2D.Float            |
1.2     | ✔️          | ⭕️       | method        | getP1() / getP2()       | ()->Point2D
1.2     | ✔️          | ⭕️       | method        | intersectsLine()        | (double,double,double,double)->bool
1.2     | ✔️          | ⭕️       | method        | ptSegDist()             | static

### java.awt.geom.Path2D (✔️/⭕️)

> Replaces the older `GeneralPath`. `GeneralPath` is kept as a legacy alias for `Path2D.Float`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2 (legacy) | ✔️   | ⭕️       | class         | GeneralPath             | alias for Path2D.Float
1.6     | ✔️          | ⭕️       | abstract class| Path2D                  |
1.6     | ✔️          | ⭕️       | inner class   | Path2D.Double           |
1.6     | ✔️          | ⭕️       | inner class   | Path2D.Float            |
1.6     | ✔️          | 🪄       | final field   | WIND_NON_ZERO           | int = 0
1.6     | ✔️          | 🪄       | final field   | WIND_EVEN_ODD           | int = 1
1.6     | ✔️          | ⭕️       | method        | moveTo()                | (double,double)
1.6     | ✔️          | ⭕️       | method        | lineTo()                | (double,double)
1.6     | ✔️          | ⭕️       | method        | quadTo()                | (double,double,double,double)
1.6     | ✔️          | ⭕️       | method        | curveTo()               | (double,double,double,double,double,double)
1.6     | ✔️          | ⭕️       | method        | closePath()             | ()
1.6     | ✔️          | ⭕️       | method        | append()                | (Shape,bool)
1.6     | ✔️          | ⭕️       | method        | reset()                 | ()
1.6     | ✔️          | ⭕️       | method        | contains()              | (double,double)
1.6     | ✔️          | ⭕️       | method        | intersects()            | (double,double,double,double)
1.6     | ✔️          | ⭕️       | method        | getBounds()             | ()->Rectangle

### java.awt.geom.Area (✔️/✔️)

> Constructive Area Geometry (CAG). Backed by `CGPath` boolean ops on Apple
> platforms (macOS 10.13+ / iOS 11+). Full bounding-box stub on Linux.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | constructor   | Area()                  | ()
1.2     | ✔️          | ✔️       | constructor   | Area()                  | (Shape)
1.2     | ✔️          | ✔️       | method        | add()                   | (Area) — union
1.2     | ✔️          | ✔️       | method        | subtract()              | (Area)
1.2     | ✔️          | ✔️       | method        | intersect()             | (Area)
1.2     | ✔️          | ✔️       | method        | exclusiveOr()           | (Area)
1.2     | ✔️          | ✔️       | method        | reset()                 | ()
1.2     | ✔️          | ✔️       | method        | isEmpty()               | ()->bool
1.2     | ✔️          | ✔️       | method        | isRectangular()         | ()->bool
1.2     | ✔️          | ✔️       | method        | isSingular()            | ()->bool
1.2     | ✔️          | ✔️       | method        | getBounds()             | ()->Rectangle
1.2     | ✔️          | ✔️       | method        | getBounds2D()           | ()->Rectangle2D
1.2     | ✔️          | ✔️       | method        | contains()              | (double,double)->bool
1.2     | ✔️          | ✔️       | method        | contains()              | (double,double,double,double)->bool
1.2     | ✔️          | ✔️       | method        | intersects()            | (double,double,double,double)->bool
1.2     | ✔️          | ⭕️       | method        | createTransformedArea() | (AffineTransform)->Area

### java.awt.geom.Arc2D (✔️/✔️)

> Arc segment defined by a bounding rectangle, start angle, angular extent and closure type (OPEN/CHORD/PIE).

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | final field   | OPEN / CHORD / PIE      | int 0/1/2
1.2     | ✔️          | ✔️       | inner class   | Arc2D.Double            | extends RectangularShape
1.2     | ✔️          | ✔️       | inner class   | Arc2D.Float             | extends RectangularShape
1.2     | ✔️          | ✔️       | method        | getAngleStart()         | ()->double
1.2     | ✔️          | ✔️       | method        | getAngleExtent()        | ()->double
1.2     | ✔️          | ✔️       | method        | containsAngle()         | (double)->bool
1.2     | ✔️          | ✔️       | method        | getStartPoint()         | ()->Point2D
1.2     | ✔️          | ✔️       | method        | getEndPoint()           | ()->Point2D
1.2     | ✔️          | ✔️       | method        | setArc()                | (double,double,double,double,double,double,int)
1.2     | ✔️          | ✔️       | method        | isEmpty()               | ()->bool
1.2     | ✔️          | ✔️       | method        | getBounds()             | ()->Rectangle
1.2     | ✔️          | ✔️       | method        | contains()              | (double,double)->bool
1.2     | ✔️          | ⭕️       | method        | intersects()            | (double,double,double,double)->bool

### java.awt.geom.QuadCurve2D (✔️/✔️)

> Quadratic Bézier curve defined by start, one control point, and end.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | inner class   | QuadCurve2D.Double      |
1.2     | ✔️          | ✔️       | inner class   | QuadCurve2D.Float       |
1.2     | ✔️          | ✔️       | method        | getX1/Y1/X2/Y2()        | ()->double
1.2     | ✔️          | ✔️       | method        | getCtrlX() / getCtrlY() | ()->double
1.2     | ✔️          | ✔️       | method        | setCurve()              | (double×6)
1.2     | ✔️          | ✔️       | method        | getFlatness()           | ()->double
1.2     | ✔️          | ✔️       | method        | getFlatnessSq()         | ()->double
1.2     | ✔️          | ✔️       | static method | solveQuadratic()        | ([double], inout [double])->int
1.2     | ✔️          | ✔️       | method        | getBounds()             | ()->Rectangle
1.2     | ✔️          | ⭕️       | method        | contains()              | (double,double)->bool
1.2     | ✔️          | ⭕️       | method        | intersects()            | (double,double,double,double)->bool

### java.awt.geom.CubicCurve2D (✔️/✔️)

> Cubic Bézier curve defined by start, two control points, and end.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | inner class   | CubicCurve2D.Double     |
1.2     | ✔️          | ✔️       | inner class   | CubicCurve2D.Float      |
1.2     | ✔️          | ✔️       | method        | getX1/Y1/X2/Y2()        | ()->double
1.2     | ✔️          | ✔️       | method        | getCtrlX1/Y1/X2/Y2()    | ()->double
1.2     | ✔️          | ✔️       | method        | setCurve()              | (double×8)
1.2     | ✔️          | ✔️       | static method | solveCubic()            | ([double], inout [double])->int — Cardano
1.2     | ✔️          | ✔️       | method        | getBounds()             | ()->Rectangle
1.2     | ✔️          | ⭕️       | method        | contains()              | (double,double)->bool
1.2     | ✔️          | ⭕️       | method        | intersects()            | (double,double,double,double)->bool

### java.awt.geom.NoninvertibleTransformException (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | constructor   | NoninvertibleTransformException() | (String)

---

## java.awt.font

### java.awt.font.FontRenderContext (✔️/⭕️)

> Encapsulates antialiasing and fractional-metrics hints for font measurement.
> Obtain via `Graphics2D.getFontRenderContext()`.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | FontRenderContext       |
1.2     | ✔️          | ⭕️       | constructor   | FontRenderContext()     | ()
1.2     | ✔️          | ⭕️       | constructor   | FontRenderContext()     | (antiAliasing:fractionalMetrics:)
1.2     | ✔️          | ⭕️       | method        | isAntiAliased()         | ()->bool
1.2     | ✔️          | ⭕️       | method        | usesFractionalMetrics() | ()->bool
1.2     | ✔️          | ⭕️       | method        | equals()                | (FontRenderContext)->bool

### java.awt.font.LineMetrics (✔️/⭕️)

> Per-string line metrics including strikethrough and underline geometry.
> On Apple platforms CoreText-backed; elsewhere proportional approximation.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | abstract class| LineMetrics             |
1.2     | ✔️          | ⭕️       | class         | DefaultLineMetrics      | concrete subclass
1.2     | ✔️          | ⭕️       | method        | getNumChars()           | ()->int
1.2     | ✔️          | ⭕️       | method        | getAscent()             | ()->float
1.2     | ✔️          | ⭕️       | method        | getDescent()            | ()->float
1.2     | ✔️          | ⭕️       | method        | getLeading()            | ()->float
1.2     | ✔️          | ⭕️       | method        | getHeight()             | ()->float (final)
1.2     | ✔️          | ⭕️       | method        | getStrikethroughOffset()    | ()->float
1.2     | ✔️          | ⭕️       | method        | getStrikethroughThickness() | ()->float
1.2     | ✔️          | ⭕️       | method        | getUnderlineOffset()    | ()->float
1.2     | ✔️          | ⭕️       | method        | getUnderlineThickness() | ()->float
1.2     | ✔️          | ⭕️       | method        | getBaselineIndex()      | ()->int
1.2     | ✔️          | ⭕️       | method        | getBaselineOffsets()    | ()->[float]

### java.awt.font.TextLayout (✔️/⭕️)

> Immutable, styled single-direction text layout. Supports measuring, hit-testing,
> caret positioning and drawing. Single font, LTR only in current implementation.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | TextLayout              |
1.2     | ✔️          | ⭕️       | constructor   | TextLayout()            | (String,Font,FontRenderContext)
1.2     | ✔️          | ⭕️       | method        | getAdvance()            | ()->float
1.2     | ✔️          | ⭕️       | method        | getVisibleAdvance()     | ()->float
1.2     | ✔️          | ⭕️       | method        | getAscent()             | ()->float
1.2     | ✔️          | ⭕️       | method        | getDescent()            | ()->float
1.2     | ✔️          | ⭕️       | method        | getLeading()            | ()->float
1.2     | ✔️          | ⭕️       | method        | getBounds()             | ()->Rectangle2D
1.2     | ✔️          | ⭕️       | method        | hitTestChar()           | (float,float)->TextHitInfo
1.2     | ✔️          | ⭕️       | method        | getCaretInfo()          | (TextHitInfo)->[float]
1.2     | ✔️          | ⭕️       | method        | draw()                  | (Graphics2D,float,float)

### java.awt.font.GlyphVector (stub/⭕️)

> Immutable collection of glyphs and positions. Glyph outlines return empty Path2D; advance positions use proportional approximation. Full CoreText backing planned.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | 🔧          | ⭕️       | abstract class| GlyphVector             | stub
1.2     | 🔧          | ⭕️       | method        | getNumGlyphs()          | ()->int
1.2     | 🔧          | ⭕️       | method        | getGlyphCode()          | (int)->int
1.2     | 🔧          | ⭕️       | method        | getGlyphCodes()         | (int,int)->[int]
1.2     | 🔧          | ⭕️       | method        | getLogicalBounds()      | ()->Rectangle2D
1.2     | 🔧          | ⭕️       | method        | getVisualBounds()       | ()->Rectangle2D
1.2     | 🔧          | ⭕️       | method        | getGlyphPosition()      | (int)->Point2D
1.2     | 🔧          | ⭕️       | method        | getGlyphOutline()       | (int)->Shape (empty)
1.2     | 🔧          | ⭕️       | method        | getOutline()            | ()->Shape (empty)

### java.awt.font.TextHitInfo (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | struct        | TextHitInfo             |
1.2     | ✔️          | ⭕️       | static method | leading()               | (int)->TextHitInfo
1.2     | ✔️          | ⭕️       | static method | trailing()              | (int)->TextHitInfo
1.2     | ✔️          | ⭕️       | method        | getInsertionIndex()     | ()->int

---

## java.awt.image — Java 2D additions

### java.awt.image.BufferedImage (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | final field   | TYPE_INT_RGB            | int = 1
1.2     | ✔️          | ⭕️       | final field   | TYPE_INT_ARGB           | int = 2
1.2     | ✔️          | ⭕️       | final field   | TYPE_INT_ARGB_PRE       | int = 3
1.2     | ✔️          | ⭕️       | final field   | TYPE_BYTE_GRAY          | int = 10
1.2     | ✔️          | ⭕️       | constructor   | BufferedImage()         | (int,int,int)
1.2     | ✔️          | ⭕️       | method        | getWidth()              | ()->int
1.2     | ✔️          | ⭕️       | method        | getHeight()             | ()->int
1.2     | ✔️          | ⭕️       | method        | getRGB()                | (int,int)->int
1.2     | ✔️          | ⭕️       | method        | setRGB()                | (int,int,int)
1.2     | ✔️          | ⭕️       | method        | createGraphics()        | ()->Graphics2D

### java.awt.image.ColorModel (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.0     | ✔️          | ⭕️       | abstract class| ColorModel              |
1.0     | ✔️          | ⭕️       | method        | getRed()                | (int)->int
1.0     | ✔️          | ⭕️       | method        | getGreen()              | (int)->int
1.0     | ✔️          | ⭕️       | method        | getBlue()               | (int)->int
1.0     | ✔️          | ⭕️       | method        | getAlpha()              | (int)->int
1.0     | ✔️          | ⭕️       | method        | getRGB()                | (int)->int

### java.awt.image.DirectColorModel (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.0     | ✔️          | ⭕️       | constructor   | DirectColorModel()      | (int,int,int,int)
1.0     | ✔️          | ⭕️       | constructor   | DirectColorModel()      | (int,int,int,int,int)

### java.awt.image.IndexColorModel (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.0     | ✔️          | ⭕️       | constructor   | IndexColorModel()       | (int,int,byte[],byte[],byte[])
1.0     | ✔️          | ⭕️       | constructor   | IndexColorModel()       | (int,int,byte[],byte[],byte[],int)
1.0     | ✔️          | ⭕️       | method        | getMapSize()            | ()->int
1.0     | ✔️          | ⭕️       | method        | getTransparentPixel()   | ()->int

### java.awt.image.ImageFilter hierarchy (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.0     | ✔️          | ⭕️       | class         | ImageFilter             | base class
1.0     | ✔️          | ⭕️       | class         | CropImageFilter         | (int,int,int,int)
1.0     | ✔️          | ⭕️       | class         | RGBImageFilter          | abstract; filterRGB()
1.0     | ✔️          | ⭕️       | class         | FilteredImageSource     | (ImageProducer,ImageFilter)
1.0     | ✔️          | ⭕️       | class         | MemoryImageSource       | (int,int,int[],int,int)
1.0     | ✔️          | ⭕️       | class         | PixelGrabber            | (Image,int,int,int,int,int[],int,int)

---

---

## javax.swing

> **Note — historical context:** Swing was first included in the standard JDK
> with Java 1.2. Before that it shipped as the separate **Java Foundation
> Classes (JFC) 1.1** add-on. In JavApi4Swift, Swing is integrated directly
> into the library — no separate dependency or import is needed. See also
> ``Java_1.1`` for the JFC/1.1 background note.

### javax.swing.SwingConstants (✔️/🪄)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | interface     | SwingConstants          | alignment/orientation constants
1.2     | ✔️          | 🪄       | final field   | CENTER                  | int = 0
1.2     | ✔️          | 🪄       | final field   | TOP                     | int = 1
1.2     | ✔️          | 🪄       | final field   | LEFT                    | int = 2
1.2     | ✔️          | 🪄       | final field   | BOTTOM                  | int = 3
1.2     | ✔️          | 🪄       | final field   | RIGHT                   | int = 4
1.2     | ✔️          | 🪄       | final field   | HORIZONTAL              | int = 0
1.2     | ✔️          | 🪄       | final field   | VERTICAL                | int = 1

### javax.swing.JComponent (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | abstract class| JComponent              | extends java.awt.Container
1.2     | ✔️          | ⭕️       | method        | paint()                 | fills bg if opaque (no UI), then paintComponent + paintChildren
1.2     | ✔️          | ⭕️       | method        | paintComponent()        | hook for subclasses
1.2     | ✔️          | ⭕️       | method        | paintChildren()         | translates g to each child's origin; skips zero-size children (empty clip)
1.2     | ✔️          | ⭕️       | method        | updateUI()              | no-op; subclasses override
1.2     | ✔️          | ⭕️       | method        | setUI()                 | installs ComponentUI delegate
1.2     | ✔️          | ⭕️       | method        | isOpaque() / setOpaque()| controls background fill
1.2     | ✔️          | ⭕️       | method        | getBackground() / setBackground() |
1.2     | ✔️          | ⭕️       | method        | getForeground() / setForeground() |
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | explicit _preferredSize wins, then UI, then LayoutManager
1.2     | ✔️          | ⭕️       | method        | getMinimumSize()        | delegates to UI
1.2     | ✔️          | ⭕️       | method        | getMaximumSize()        | delegates to UI

### javax.swing.JPanel (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JPanel                  | opaque=true, default FlowLayout
1.2     | ✔️          | ⭕️       | constructor   | JPanel()                | FlowLayout default
1.2     | ✔️          | ⭕️       | constructor   | JPanel(LayoutManager?)  |

### javax.swing.JLabel (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JLabel                  |
1.2     | ✔️          | ⭕️       | constructor   | JLabel()                | ()
1.2     | ✔️          | ⭕️       | constructor   | JLabel()                | (String)
1.2     | ✔️          | ⭕️       | method        | getText() / setText()   |
1.2     | ✔️          | ⭕️       | method        | setHorizontalAlignment()| SwingConstants.LEFT/CENTER/RIGHT
1.2     | ✔️          | ⭕️       | method        | setVerticalAlignment()  | SwingConstants.TOP/CENTER/BOTTOM

### javax.swing.JButton (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JButton                 | extends AbstractButton (refactored)
1.2     | ✔️          | ⭕️       | constructor   | JButton()               | (String)
1.2     | ✔️          | ⭕️       | method        | getText() / setText()   |
1.2     | ✔️          | ⭕️       | method        | addActionListener()     | closure-based
1.2     | ✔️          | ⭕️       | method        | doClick()               | fires ACTION_PERFORMED
1.2     | ✔️          | ⭕️       | method        | processMouseEvent()     | tracks isPressed / isRollover

### javax.swing.JFrame (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JFrame                  | extends java.awt.Frame
1.2     | ✔️          | ⭕️       | constructor   | JFrame()                | (String)
1.2     | ✔️          | ⭕️       | method        | setDefaultCloseOperation()| EXIT_ON_CLOSE etc.
1.2     | ✔️          | ⭕️       | method        | setJMenuBar()           |
1.2     | ✔️          | ⭕️       | method        | getContentPane()        |
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | delegates to rootPane so pack() works
1.2     | ✔️          | ⭕️       | method        | processWindowEvent()    | handles WINDOW_CLOSING

### javax.swing.JDialog (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JDialog                 | extends java.awt.Dialog
1.2     | ✔️          | ⭕️       | constructor   | JDialog()               | (owner:title:modal:)
1.2     | ✔️          | ⭕️       | method        | setDefaultCloseOperation()| HIDE_ON_CLOSE (default), DISPOSE_ON_CLOSE
1.2     | ✔️          | ⭕️       | method        | getContentPane()        |
1.2     | ✔️          | ⭕️       | method        | add()                   | delegates to content pane
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | delegates to rootPane so pack() sizes correctly

### javax.swing.JMenuBar / JMenu / JMenuItem (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JMenuBar                |
1.2     | ✔️          | ⭕️       | class         | JMenu                   |
1.2     | ✔️          | ⭕️       | class         | JMenuItem               |
1.2     | ✔️          | ⭕️       | method        | addActionListener()     | closure-based
1.2     | ✔️          | ⭕️       | method        | addSeparator()          | JMenu only

### javax.swing.JRootPane / JLayeredPane (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JRootPane               | manages layeredPane + contentPane + glassPane
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | contentPane preferred size + menu bar height (layout=nil)
1.2     | ✔️          | ⭕️       | class         | JLayeredPane            | layer-ordered painting
1.2     | ✔️          | 🪄       | final field   | DEFAULT_LAYER           | 0
1.2     | ✔️          | 🪄       | final field   | POPUP_LAYER             | 300
1.2     | ✔️          | 🪄       | final field   | FRAME_CONTENT_LAYER     | -30000

### javax.swing.plaf.ComponentUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | abstract class| ComponentUI             |
1.2     | ✔️          | ⭕️       | method        | installUI() / uninstallUI() |
1.2     | ✔️          | ⭕️       | method        | paint()                 | (Graphics, JComponent)
1.2     | ✔️          | ⭕️       | method        | update()                | fills bg if opaque, then paint()
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | ()->Dimension?

### javax.swing.plaf.basic.BasicButtonUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicButtonUI           | 3D raised rectangle, centred text
1.2     | ✔️          | ⭕️       | method        | paint()                 | highlight/shadow border, pressed offset
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | text width+20, height+10

### javax.swing.plaf.basic.BasicLabelUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicLabelUI            |
1.2     | ✔️          | ⭕️       | method        | paint()                 | aligned text via SwingConstants

### javax.swing.plaf.basic.BasicMenuBarUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicMenuBarUI          |
1.2     | ✔️          | ⭕️       | method        | paint()                 | bg fill + menu titles; selected title highlighted
1.2     | ✔️          | ⭕️       | method        | layoutMenuTitles()      | sets menu.bounds for hit-testing

### javax.swing.plaf.basic.BasicPopupMenuUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicPopupMenuUI        |
1.2     | ✔️          | ⭕️       | method        | paint()                 | bg + items; armed item highlighted

### javax.swing.JCheckBoxMenuItem (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JCheckBoxMenuItem       | extends JMenuItem; toggles selected state on click
1.2     | ✔️          | ⭕️       | constructor   | JCheckBoxMenuItem()     | ()
1.2     | ✔️          | ⭕️       | constructor   | JCheckBoxMenuItem()     | (String)
1.2     | ✔️          | ⭕️       | constructor   | JCheckBoxMenuItem()     | (String, selected: Bool)
1.2     | ✔️          | ⭕️       | method        | isSelected()            | ()->Bool
1.2     | ✔️          | ⭕️       | method        | setSelected()           | (Bool)
1.2     | ✔️          | ⭕️       | method        | getState() / setState() | Bool — alias for isSelected/setSelected
1.2     | ✔️          | ⭕️       | method        | addItemListener()       | (ItemListener)

### javax.swing.JRadioButtonMenuItem (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JRadioButtonMenuItem    | extends JMenuItem; use with ButtonGroup
1.2     | ✔️          | ⭕️       | constructor   | JRadioButtonMenuItem()  | ()
1.2     | ✔️          | ⭕️       | constructor   | JRadioButtonMenuItem()  | (String)
1.2     | ✔️          | ⭕️       | constructor   | JRadioButtonMenuItem()  | (String, selected: Bool)
1.2     | ✔️          | ⭕️       | method        | isSelected()            | ()->Bool
1.2     | ✔️          | ⭕️       | method        | setSelected()           | (Bool)

### javax.swing.plaf.basic.BasicCheckBoxMenuItemUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicCheckBoxMenuItemUI | paints checkbox indicator + text
1.2     | ✔️          | ⭕️       | method        | paint()                 | checkbox box, checkmark if selected, then text
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | box + gap + text width

### javax.swing.plaf.basic.BasicRadioButtonMenuItemUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicRadioButtonMenuItemUI | paints radio indicator + text
1.2     | ✔️          | ⭕️       | method        | paint()                 | circle, filled dot if selected, then text
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | circle + gap + text width

### javax.swing.plaf.basic.BasicMenuItemUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicMenuItemUI         | base UI for JMenuItem
1.2     | ✔️          | ⭕️       | method        | paint()                 | bg highlight when armed, text + accelerator
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | text width + padding

### javax.swing.Action / AbstractAction (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | protocol      | Action                  | extends ActionListener; getValue/putValue, isEnabled/setEnabled, property change listeners
1.2     | ✔️          | ⭕️       | class         | AbstractAction          | base implementation; stores properties in [String:AnyObject] dict
1.2     | ✔️          | 🪄       | final field   | NAME                    | "Name"
1.2     | ✔️          | 🪄       | final field   | SMALL_ICON              | "SmallIcon"
1.2     | ✔️          | 🪄       | final field   | SHORT_DESCRIPTION       | "ShortDescription" — used as tooltip
1.2     | ✔️          | 🪄       | final field   | LONG_DESCRIPTION        | "LongDescription"
1.2     | ✔️          | 🪄       | final field   | MNEMONIC_KEY            | "MnemonicKey"
1.2     | ✔️          | 🪄       | final field   | ACTION_COMMAND_KEY      | "ActionCommandKey"

### javax.swing.AbstractButton (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | AbstractButton          | extends JComponent; base for JButton, JToggleButton, JMenuItem
1.2     | ✔️          | ⭕️       | method        | getText()               | ()->String
1.2     | ✔️          | ⭕️       | method        | setText()               | (String)
1.2     | ✔️          | ⭕️       | method        | getIcon()               | ()->Icon
1.2     | ✔️          | ⭕️       | method        | setIcon()               | (Icon)
1.2     | ✔️          | ⭕️       | method        | isSelected()            | ()->boolean
1.2     | ✔️          | ⭕️       | method        | setSelected()           | (boolean)
1.2     | ✔️          | ⭕️       | method        | isEnabled()             | ()->boolean
1.2     | ✔️          | ⭕️       | method        | getModel()              | ()->ButtonModel
1.2     | ✔️          | ⭕️       | method        | setModel()              | (ButtonModel)
1.2     | ✔️          | ⭕️       | method        | addActionListener()     | (ActionListener)
1.2     | ✔️          | ⭕️       | method        | removeActionListener()  | (ActionListener)
1.2     | ✔️          | ⭕️       | method        | addItemListener()       | (ItemListener)
1.2     | ✔️          | ⭕️       | method        | removeItemListener()    | (ItemListener)
1.2     | ✔️          | ⭕️       | method        | addChangeListener()     | (ChangeListener)
1.2     | ✔️          | ⭕️       | method        | removeChangeListener()  | (ChangeListener)
1.2     | ✔️          | ⭕️       | method        | doClick()               | ()

### javax.swing.JToggleButton (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JToggleButton           | extends AbstractButton
1.2     | ✔️          | ⭕️       | constructor   | JToggleButton()         |
1.2     | ✔️          | ⭕️       | constructor   | JToggleButton(String)   | (text)
1.2     | ✔️          | ⭕️       | constructor   | JToggleButton(String,boolean) | (text, selected)
1.2     | ✔️          | ⭕️       | constructor   | JToggleButton(Icon)     |
1.2     | ✔️          | ⭕️       | constructor   | JToggleButton(String,Icon,boolean) |

### javax.swing.JCheckBox (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JCheckBox               | extends JToggleButton
1.2     | ✔️          | ⭕️       | constructor   | JCheckBox()             |
1.2     | ✔️          | ⭕️       | constructor   | JCheckBox(String)       |
1.2     | ✔️          | ⭕️       | constructor   | JCheckBox(String,boolean) |
1.2     | ✔️          | ⭕️       | constructor   | JCheckBox(Icon)         |
1.2     | ✔️          | ⭕️       | constructor   | JCheckBox(String,Icon,boolean) |

### javax.swing.JRadioButton (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JRadioButton            | extends JToggleButton
1.2     | ✔️          | ⭕️       | constructor   | JRadioButton()          |
1.2     | ✔️          | ⭕️       | constructor   | JRadioButton(String)    |
1.2     | ✔️          | ⭕️       | constructor   | JRadioButton(String,boolean) |
1.2     | ✔️          | ⭕️       | constructor   | JRadioButton(Icon)      |
1.2     | ✔️          | ⭕️       | constructor   | JRadioButton(String,Icon,boolean) |

### javax.swing.ButtonGroup (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | ButtonGroup             |
1.2     | ✔️          | ⭕️       | constructor   | ButtonGroup()           |
1.2     | ✔️          | ⭕️       | method        | add()                   | (AbstractButton)
1.2     | ✔️          | ⭕️       | method        | remove()                | (AbstractButton)
1.2     | ✔️          | ⭕️       | method        | getElements()           | ()->[AbstractButton]
1.2     | ✔️          | ⭕️       | method        | getSelection()          | ()->ButtonModel?
1.2     | ✔️          | ⭕️       | method        | isSelected()            | (ButtonModel)->boolean
1.2     | ✔️          | ⭕️       | method        | setSelected()           | (ButtonModel,boolean)
1.2     | ✔️          | ⭕️       | method        | getButtonCount()        | ()->int
1.2     | ✔️          | ⭕️       | method        | clearSelection()        | ()

### javax.swing.plaf.basic.BasicToggleButtonUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | paint()                 | selected state shown as inner border

### javax.swing.plaf.basic.BasicCheckBoxUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | paint()                 | box + checkmark
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | box + gap + text width

### javax.swing.plaf.basic.BasicRadioButtonUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | paint()                 | circle + selection dot
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | circle + gap + text width

### javax.swing.JToolBar (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JToolBar                | extends JComponent
1.2     | ✔️          | ⭕️       | constructor   | JToolBar()              | ()
1.2     | ✔️          | ⭕️       | constructor   | JToolBar()              | (int orientation)
1.2     | ✔️          | ⭕️       | method        | add()                   | (JButton)->JButton
1.2     | ✔️          | ⭕️       | method        | add()                   | (Action)->JButton — icon-only, tooltip from SHORT_DESCRIPTION
1.2     | ✔️          | ⭕️       | method        | addSeparator()          | ()
1.2     | ✔️          | ⭕️       | method        | addSeparator()          | (Dimension)
1.2     | ✔️          | ⭕️       | method        | isFloatable/setFloatable()| stub; TODO: drag/dock
1.2     | ✔️          | ⭕️       | method        | isRollover/setRollover() |
1.2     | ✔️          | ⭕️       | method        | getOrientation/setOrientation() |

### javax.swing.JSeparator (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JSeparator              |
1.2     | ✔️          | ⭕️       | constructor   | JSeparator()            | horizontal by default
1.2     | ✔️          | ⭕️       | constructor   | JSeparator()            | (int orientation)
1.2     | ✔️          | 🪄       | final field   | HORIZONTAL              | int = 0
1.2     | ✔️          | 🪄       | final field   | VERTICAL                | int = 1

### javax.swing.plaf.basic.BasicToolBarUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicToolBarUI          |
1.2     | ✔️          | ⭕️       | method        | paint()                 | bg + border line, lays out and paints items
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | sums item preferred sizes

### javax.swing.plaf.basic.BasicSeparatorUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicSeparatorUI        |
1.2     | ✔️          | ⭕️       | method        | paint()                 | single center line
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | 2×0 (vertical) or 0×2 (horizontal)

### javax.swing.JTabbedPane (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JTabbedPane             |
1.2     | ✔️          | ⭕️       | constructor   | JTabbedPane()           | ()
1.2     | ✔️          | ⭕️       | constructor   | JTabbedPane()           | (int tabPlacement)
1.2     | ✔️          | 🪄       | final field   | TOP / BOTTOM / LEFT / RIGHT | 1/3/2/4
1.2     | ✔️          | ⭕️       | method        | addTab()                | (String,Component)
1.2     | ✔️          | ⭕️       | method        | addTab()                | (String,Icon?,Component)
1.2     | ✔️          | ⭕️       | method        | addTab()                | (String,Icon?,Component,String?)
1.2     | ✔️          | ⭕️       | method        | removeTabAt()           | (int)
1.2     | ✔️          | ⭕️       | method        | getSelectedIndex/setSelectedIndex() |
1.2     | ✔️          | ⭕️       | method        | getSelectedComponent()  |
1.2     | ✔️          | ⭕️       | method        | getTabCount()           |
1.2     | ✔️          | ⭕️       | method        | getTitleAt/setTitleAt() |
1.2     | ✔️          | ⭕️       | method        | isEnabledAt/setEnabledAt() |
1.2     | ✔️          | ⭕️       | method        | getToolTipTextAt()      |
1.2     | ✔️          | ⭕️       | method        | indexAtLocation()       | delegates to BasicTabbedPaneUI

### javax.swing.plaf.basic.BasicTabbedPaneUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicTabbedPaneUI       |
1.2     | ✔️          | ⭕️       | method        | paint()                 | tab strip (TOP), content area border, selected child
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | max content size + tabHeight
1.2     | ✔️          | ⭕️       | method        | tabIndexAt()            | hit-test for tab-strip clicks

### javax.swing.JButton — Action constructor (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | constructor   | JButton()               | (Action) — adopts NAME, SMALL_ICON, registers action as listener
1.2     | ✔️          | ⭕️       | method        | isHideActionText/setHideActionText() | hides label when true; toolbar default

### javax.swing.JComponent — tooltip stub (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | method        | setToolTipText()        | (String?) — stored; rendering not yet implemented
1.2     | ✔️          | ⭕️       | method        | getToolTipText()        | ()->String?

### javax.swing.ImageIcon (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | ImageIcon               | wraps java.awt.Image
1.2     | ✔️          | ⭕️       | constructor   | ImageIcon()             | (Image, width:Int, height:Int)
1.2     | ✔️          | ⭕️       | method        | getImage()              | ()->Image
1.2     | ✔️          | ⭕️       | method        | getIconWidth/Height()   | ()->int

### javax.swing.JScrollBar (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | final field   | HORIZONTAL              | = SwingConstants.HORIZONTAL
1.2     | ✔️          | 🪄       | final field   | VERTICAL                | = SwingConstants.VERTICAL
1.2     | ✔️          | ⭕️       | constructor   | JScrollBar()            |
1.2     | ✔️          | ⭕️       | constructor   | JScrollBar(int)         | orientation
1.2     | ✔️          | ⭕️       | constructor   | JScrollBar(int,int,int,int,int) | orientation,value,extent,min,max
1.2     | ✔️          | ⭕️       | method        | getModel()              | ()->BoundedRangeModel
1.2     | ✔️          | ⭕️       | method        | setModel()              | (BoundedRangeModel)
1.2     | ✔️          | ⭕️       | method        | getValue()              | ()->int
1.2     | ✔️          | ⭕️       | method        | setValue()              | (int)
1.2     | ✔️          | ⭕️       | method        | getMinimum()            | ()->int
1.2     | ✔️          | ⭕️       | method        | setMinimum()            | (int)
1.2     | ✔️          | ⭕️       | method        | getMaximum()            | ()->int
1.2     | ✔️          | ⭕️       | method        | setMaximum()            | (int)
1.2     | ✔️          | ⭕️       | method        | getVisibleAmount()      | ()->int
1.2     | ✔️          | ⭕️       | method        | setVisibleAmount()      | (int)
1.2     | ✔️          | ⭕️       | method        | getOrientation()        | ()->int
1.2     | ✔️          | ⭕️       | method        | setOrientation()        | (int)
1.2     | ✔️          | ⭕️       | method        | getUnitIncrement()      | ()->int
1.2     | ✔️          | ⭕️       | method        | setUnitIncrement()      | (int)
1.2     | ✔️          | ⭕️       | method        | getBlockIncrement()     | ()->int
1.2     | ✔️          | ⭕️       | method        | setBlockIncrement()     | (int)
1.2     | ✔️          | ⭕️       | method        | getValueIsAdjusting()   | ()->boolean
1.2     | ✔️          | ⭕️       | method        | setValueIsAdjusting()   | (boolean)
1.2     | ✔️          | ⭕️       | method        | addAdjustmentListener() | (AdjustmentListener)
1.2     | ✔️          | ⭕️       | method        | removeAdjustmentListener() | (AdjustmentListener)
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | font-relative thickness; length unconstrained (LayoutManager decides)

### javax.swing.JViewport (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | constructor   | JViewport()             |
1.2     | ✔️          | ⭕️       | method        | getView()               | ()->Component
1.2     | ✔️          | ⭕️       | method        | setView()               | (Component)
1.2     | ✔️          | ⭕️       | method        | getViewPosition()       | ()->Point
1.2     | ✔️          | ⭕️       | method        | setViewPosition()       | (Point)
1.2     | ✔️          | ⭕️       | method        | getViewSize()           | ()->Dimension
1.2     | ✔️          | ⭕️       | method        | getViewRect()           | ()->Rectangle
1.2     | ✔️          | ⭕️       | method        | scrollRectToVisible()   | (Rectangle)
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | delegates to view

### javax.swing.JScrollPane (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | final field   | VERTICAL_SCROLLBAR_AS_NEEDED  | 20
1.2     | ✔️          | 🪄       | final field   | VERTICAL_SCROLLBAR_NEVER      | 21
1.2     | ✔️          | 🪄       | final field   | VERTICAL_SCROLLBAR_ALWAYS     | 22
1.2     | ✔️          | 🪄       | final field   | HORIZONTAL_SCROLLBAR_AS_NEEDED | 30
1.2     | ✔️          | 🪄       | final field   | HORIZONTAL_SCROLLBAR_NEVER    | 31
1.2     | ✔️          | 🪄       | final field   | HORIZONTAL_SCROLLBAR_ALWAYS   | 32
1.2     | ✔️          | ⭕️       | constructor   | JScrollPane()           |
1.2     | ✔️          | ⭕️       | constructor   | JScrollPane(Component)  |
1.2     | ✔️          | ⭕️       | constructor   | JScrollPane(Component,int,int) |
1.2     | ✔️          | ⭕️       | method        | getViewport()           | ()->JViewport
1.2     | ✔️          | ⭕️       | method        | getVerticalScrollBar()  | ()->JScrollBar
1.2     | ✔️          | ⭕️       | method        | getHorizontalScrollBar() | ()->JScrollBar
1.2     | ✔️          | ⭕️       | method        | setViewportView()       | (Component)
1.2     | ✔️          | ⭕️       | method        | getView()               | ()->Component
1.2     | ✔️          | ⭕️       | method        | getVerticalScrollBarPolicy()   | ()->int
1.2     | ✔️          | ⭕️       | method        | setVerticalScrollBarPolicy()   | (int)
1.2     | ✔️          | ⭕️       | method        | getHorizontalScrollBarPolicy() | ()->int
1.2     | ✔️          | ⭕️       | method        | setHorizontalScrollBarPolicy() | (int)
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | view + scrollbar thickness

### javax.swing.plaf.basic.BasicScrollBarUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | paint()                 | (Graphics,JComponent)
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | (JComponent)->Dimension

### javax.swing.plaf.basic.BasicScrollPaneUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | paint()                 | (Graphics,JComponent) — no-op, JScrollPane.paint handles all
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | (JComponent)->Dimension

### javax.swing.JOptionPane (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JOptionPane             | extends JComponent
1.2     | ✔️          | 🪄       | final field   | ERROR_MESSAGE           | int = 0
1.2     | ✔️          | 🪄       | final field   | INFORMATION_MESSAGE     | int = 1
1.2     | ✔️          | 🪄       | final field   | WARNING_MESSAGE         | int = 2
1.2     | ✔️          | 🪄       | final field   | QUESTION_MESSAGE        | int = 3
1.2     | ✔️          | 🪄       | final field   | PLAIN_MESSAGE           | int = -1
1.2     | ✔️          | 🪄       | final field   | DEFAULT_OPTION          | int = -1
1.2     | ✔️          | 🪄       | final field   | YES_NO_OPTION           | int = 0
1.2     | ✔️          | 🪄       | final field   | YES_NO_CANCEL_OPTION    | int = 1
1.2     | ✔️          | 🪄       | final field   | OK_CANCEL_OPTION        | int = 2
1.2     | ✔️          | 🪄       | final field   | YES_OPTION / OK_OPTION  | int = 0
1.2     | ✔️          | 🪄       | final field   | NO_OPTION               | int = 1
1.2     | ✔️          | 🪄       | final field   | CANCEL_OPTION           | int = 2
1.2     | ✔️          | 🪄       | final field   | CLOSED_OPTION           | int = -1
1.2     | ✔️          | ⭕️       | static method | showMessageDialog()     | (Component?,Any?,String,Int)
1.2     | ✔️          | ⭕️       | static method | showConfirmDialog()     | (Component?,Any?,String,Int,Int)->Int
1.2     | ✔️          | ⭕️       | static method | showInputDialog()       | (Component?,Any?,String,Int)->String? — shows a JTextField for text entry
1.2     | ✔️          | ⭕️       | static method | showOptionDialog()      | (Component?,Any?,String,Int,Int,Icon?,[Any]?,Any?)->Int
1.2     | ✔️          | ⭕️       | method        | createDialog()          | (Component?,String)->JDialog
1.2     | ✔️          | ⭕️       | method        | getValue() / setValue() | selected option result
1.2     | ✔️          | ⭕️       | method        | getInitialValue() / setInitialValue() | String value triggers input field; setter rebuilds UI

### javax.swing.plaf.basic.BasicOptionPaneUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicOptionPaneUI       | lays out message + icon + input field + buttons
1.2     | ✔️          | ⭕️       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | installUI()             | idempotent (removeAll first); builds message panel, optional input field, button row
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | font-relative; measures message text, button row, icon and input field via FontMetrics
1.2     | ✔️          | ⭕️       | method        | paint()                 | fills background

### javax.swing.JFileChooser (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JFileChooser            | extends JComponent
1.2     | ✔️          | 🪄       | final field   | APPROVE_OPTION          | int = 0
1.2     | ✔️          | 🪄       | final field   | CANCEL_OPTION           | int = 1
1.2     | ✔️          | 🪄       | final field   | ERROR_OPTION            | int = -1
1.2     | ✔️          | 🪄       | final field   | FILES_ONLY              | int = 0
1.2     | ✔️          | 🪄       | final field   | DIRECTORIES_ONLY        | int = 1
1.2     | ✔️          | 🪄       | final field   | FILES_AND_DIRECTORIES   | int = 2
1.2     | ✔️          | ⭕️       | constructor   | JFileChooser()          | ()
1.2     | ✔️          | ⭕️       | constructor   | JFileChooser()          | (String path)
1.2     | ✔️          | ⭕️       | constructor   | JFileChooser()          | (File dir)
1.2     | ✔️          | ⭕️       | method        | showOpenDialog()        | (Component?)->Int
1.2     | ✔️          | ⭕️       | method        | showSaveDialog()        | (Component?)->Int
1.2     | ✔️          | ⭕️       | method        | showDialog()            | (Component?,String)->Int
1.2     | ✔️          | ⭕️       | method        | getSelectedFile()       | ()->File?
1.2     | ✔️          | ⭕️       | method        | setSelectedFile()       | (File?)
1.2     | ✔️          | ⭕️       | method        | getSelectedFiles()      | ()->[File]
1.2     | ✔️          | ⭕️       | method        | getCurrentDirectory()   | ()->File?
1.2     | ✔️          | ⭕️       | method        | setCurrentDirectory()   | (File?)
1.2     | ✔️          | ⭕️       | method        | getFileSelectionMode()  | ()->Int
1.2     | ✔️          | ⭕️       | method        | setFileSelectionMode()  | (Int)
1.2     | ✔️          | ⭕️       | method        | approveSelection()      | ()
1.2     | ✔️          | ⭕️       | method        | cancelSelection()       | ()

### javax.swing.plaf.basic.BasicFileChooserUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicFileChooserUI      | directory list + file name field + approve/cancel
1.2     | ✔️          | ⭕️       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | installUI()             | builds file browser layout
1.2     | ✔️          | ⭕️       | method        | paint()                 | fills background

### javax.swing.JColorChooser (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JColorChooser           | extends JComponent
1.2     | ✔️          | ⭕️       | constructor   | JColorChooser()         | (Color initial)
1.2     | ✔️          | ⭕️       | static method | showDialog()            | (Component?,String,Color?)->Color?
1.2     | ✔️          | ⭕️       | method        | getColor()              | ()->Color
1.2     | ✔️          | ⭕️       | method        | setColor()              | (Color)
1.2     | ✔️          | ⭕️       | method        | setColor()              | (Int,Int,Int)

### javax.swing.plaf.basic.BasicColorChooserUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicColorChooserUI     | preview strip + swatch grid + RGB sliders
1.2     | ✔️          | ⭕️       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | installUI()             | builds color picker layout
1.2     | ✔️          | ⭕️       | method        | paint()                 | fills background

### javax.swing.plaf.basic.BasicDesktopPaneUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicDesktopPaneUI      | fills desktop background with `SystemColor.desktop`
1.2     | ✔️          | ⭕️       | class method  | createUI()              | (JComponent)->ComponentUI
1.2     | ✔️          | ⭕️       | method        | installUI()             | sets opaque=true, default background colour
1.2     | ✔️          | ⭕️       | method        | paint()                 | fills bounds with background colour
1.2     | ✔️          | 🪄       | method        | getPreferredSize()      | returns nil (adapts to parent)

### javax.swing.AbstractListModel (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | abstract class| AbstractListModel       | base for ListModel implementations
1.2     | ✔️          | ⭕️       | method        | addListDataListener()   | (ListDataListener)
1.2     | ✔️          | ⭕️       | method        | removeListDataListener()| (ListDataListener)
1.2     | ✔️          | ⭕️       | method        | fireContentsChanged()   | (Object,Int,Int)
1.2     | ✔️          | ⭕️       | method        | fireIntervalAdded()     | (Object,Int,Int)
1.2     | ✔️          | ⭕️       | method        | fireIntervalRemoved()   | (Object,Int,Int)

### javax.swing.AbstractSpinnerModel (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.4     | ✔️          | ⭕️       | abstract class| AbstractSpinnerModel    | base for SpinnerModel implementations
1.4     | ✔️          | ⭕️       | method        | addChangeListener()     | (ChangeListener)
1.4     | ✔️          | ⭕️       | method        | removeChangeListener()  | (ChangeListener)
1.4     | ✔️          | ⭕️       | method        | fireStateChanged()      | ()

### javax.swing.FocusManager (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | abstract class| FocusManager            | manages keyboard focus traversal
1.2     | ✔️          | ⭕️       | static method | getCurrentManager()     | ()->FocusManager
1.2     | ✔️          | ⭕️       | static method | setCurrentManager()     | (FocusManager?)
1.2     | ✔️          | ⭕️       | method        | focusNextComponent()    | (Component)
1.2     | ✔️          | ⭕️       | method        | focusPreviousComponent()| (Component)

### javax.swing.ToolTipManager (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | ToolTipManager          | singleton; manages tooltip display timing
1.2     | ✔️          | ⭕️       | static method | sharedInstance()        | ()->ToolTipManager
1.2     | ✔️          | ⭕️       | method        | setEnabled()            | (Bool)
1.2     | ✔️          | ⭕️       | method        | isEnabled()             | ()->Bool
1.2     | ✔️          | ⭕️       | method        | setInitialDelay()       | (Int)
1.2     | ✔️          | ⭕️       | method        | setDismissDelay()       | (Int)
1.2     | ✔️          | ⭕️       | method        | setReshowDelay()        | (Int)

### javax.swing.JToolTip (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JToolTip                | extends JComponent; tooltip popup widget
1.2     | ✔️          | ⭕️       | constructor   | JToolTip()              | ()
1.2     | ✔️          | ⭕️       | method        | getTipText()            | ()->String?
1.2     | ✔️          | ⭕️       | method        | setTipText()            | (String?)
1.2     | ✔️          | ⭕️       | method        | getComponent()          | ()->JComponent?

### javax.swing.plaf.basic.BasicToolTipUI (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | BasicToolTipUI          | paints tooltip background and text
1.2     | ✔️          | ⭕️       | method        | paint()                 | yellow bg, border, tip text
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | text width + padding

### javax.swing.JApplet (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | 🪄       | class         | JApplet                 | extends java.applet.Applet; Swing root pane container
1.2     | ✔️          | ⭕️       | method        | getContentPane()        | ()->Container
1.2     | ✔️          | ⭕️       | method        | setJMenuBar()           | (JMenuBar?)

### javax.swing.text — Document and Element (✔️/⭕️)

> **Note — naming:** Due to a Swift compiler limitation where two files with
> the same name in different directories cause build failures even if they
> reside in different modules, `javax.swing.text.Document` is implemented in
> `TextDocument.swift` and `javax.swing.text.Element` is implemented in
> `TextElement.swift`. The Swift type names are `javax.swing.text.TextDocument`
> (protocol) and `javax.swing.text.TextElement` (protocol). Call sites that
> use `javax.swing.text.Document` or `javax.swing.text.Element` must use
> these names instead.

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | protocol      | TextDocument            | mirrors `javax.swing.text.Document`; in TextDocument.swift
1.2     | ✔️          | ⭕️       | protocol      | TextElement             | mirrors `javax.swing.text.Element`; in TextElement.swift
1.2     | ✔️          | ⭕️       | method        | getText()               | (Int,Int)->String throws
1.2     | ✔️          | ⭕️       | method        | insertString()          | (Int,String,AttributeSet?) throws
1.2     | ✔️          | ⭕️       | method        | remove()                | (Int,Int) throws
1.2     | ✔️          | ⭕️       | method        | getLength()             | ()->Int
1.2     | ✔️          | ⭕️       | method        | getRootElements()       | ()->[TextElement]
1.2     | ✔️          | ⭕️       | method        | addDocumentListener()   | (DocumentListener)
1.2     | ✔️          | ⭕️       | method        | removeDocumentListener()| (DocumentListener)

### javax.swing.text — Remaining text infrastructure (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | protocol      | AttributeSet            | read-only attribute collection
1.2     | ✔️          | ⭕️       | protocol      | MutableAttributeSet     | extends AttributeSet; add/removeAttribute
1.2     | ✔️          | ⭕️       | class         | SimpleAttributeSet      | mutable AttributeSet backed by [String:Any]
1.2     | ✔️          | ⭕️       | class         | StyleConstants          | standard attribute keys (Bold, Italic, FontSize, …)
1.2     | ✔️          | ⭕️       | protocol      | StyledDocument          | extends TextDocument; character/paragraph attributes
1.2     | ✔️          | ⭕️       | class         | DefaultStyledDocument   | concrete StyledDocument implementation
1.2     | ✔️          | ⭕️       | class         | AbstractDocument        | open base class for PlainDocument/DefaultStyledDocument
1.2     | ✔️          | ⭕️       | class         | PlainDocument           | plain-text Document (no attributes)
1.2     | ✔️          | ⭕️       | class         | GapContent              | gap-buffer AbstractDocumentContent
1.2     | ✔️          | ⭕️       | class         | StringContent           | simple array-based AbstractDocumentContent
1.2     | ✔️          | ⭕️       | protocol      | Highlighter             | selection/search highlight management
1.2     | ✔️          | ⭕️       | class         | DefaultHighlighter      | concrete Highlighter
1.2     | ✔️          | ⭕️       | class         | Position                | document position that tracks insertions
1.2     | ✔️          | ⭕️       | abstract class| View                    | visual representation of document model
1.2     | ✔️          | ⭕️       | class         | Style                   | named AttributeSet with change listeners
1.2     | ✔️          | ⭕️       | class         | StyledEditorKit         | EditorKit for styled text
1.2     | ✔️          | ⭕️       | class         | AbstractWriter          | base class for document serializers

---

## Comprehensive Swing Coverage (as of current implementation)

The following were historically marked "not in scope" but are now **fully implemented**:
- ✅ **`JTextField`**, **`JTextArea`**, **`JPasswordField`**, **`JFormattedTextField`** — complete with `JTextComponent` base and document model
- ✅ **`JList`** — with `DefaultListModel`, `ListModel`, `ListSelectionModel`
- ✅ **`JComboBox`** — with `ComboBoxModel`, `DefaultComboBoxModel`, `MutableComboBoxModel`
- ✅ **`JTree`** — with `DefaultTreeModel`, `TreeModel`, `TreeCellRenderer`, `DefaultTreeCellRenderer`, `TreePath`, `DefaultMutableTreeNode`
- ✅ **`JTable`** — with cell renderers and editors (Java 1.2)
- ✅ **`JSpinner`** — with `SpinnerModel`, `SpinnerNumberModel`, `SpinnerListModel`
- ✅ **`javax.swing.text`** — document hierarchy, formatting, and text components (Java 1.4+)

---

## java.text — Java 1.2 additions

> **Note:** `java.text.AttributedString` and `java.text.AttributedCharacterIterator`
> were introduced with Java 1.2 as part of the internationalization enhancements.
> In addition, Java 1.2 added `getAvailableLocales()` to `Collator`, `BreakIterator`,
> `NumberFormat` and `DateFormat`, a subrange constructor for `AttributedString`,
> and format-accessor methods (`getFormats`, `setFormat`, …) on `MessageFormat`.
> All of these are **fully implemented** in JavApi4Swift (2026).

### java.text.Collator — Java 1.2 addition (✔️/✔️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | static method | getAvailableLocales()   | ()->[Locale]

### java.text.BreakIterator — Java 1.2 addition (✔️/✔️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | static method | getAvailableLocales()   | ()->[Locale]

### java.text.NumberFormat — Java 1.2 addition (✔️/✔️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | static method | getAvailableLocales()   | ()->[Locale]

### java.text.DateFormat — Java 1.2 addition (✔️/✔️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | static method | getAvailableLocales()   | ()->[Locale]

### java.text.MessageFormat — Java 1.2 additions (✔️/✔️)

version | implemented | tested   | type          | name                         | more informations
------- | ----------- | -------- | ------------- | ---------------------------- | -----------------
1.2     | ✔️          | ✔️       | method        | getFormats()                 | ()->[Format?] — in pattern order
1.2     | ✔️          | ✔️       | method        | getFormatsByArgumentIndex()  | ()->[Format?] — indexed by argument index
1.2     | ✔️          | ✔️       | method        | setFormat(int,Format?)       | sets format for nth format element
1.2     | ✔️          | ✔️       | method        | setFormatByArgumentIndex(int,Format?) | sets format for argument index
1.2     | ✔️          | ✔️       | method        | setFormats([Format?])        | replaces all format overrides (pattern order)
1.2     | ✔️          | ✔️       | method        | setFormatsByArgumentIndex([Format?]) | replaces all format overrides (by index)

### java.text.AttributedCharacterIterator (✔️/✔️)

> Protocol mapping of the Java interface; `Attribute` inner class mapped as
> `AttributedCharacterIteratorAttribute` with nested constants (`LANGUAGE`,
> `READING`, `INPUT_METHOD_SEGMENT`).

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | protocol      | AttributedCharacterIterator | extends CharacterIterator
1.2     | ✔️          | ✔️       | class         | Attribute               | mapped as `AttributedCharacterIteratorAttribute`
1.2     | ✔️          | ✔️       | final field   | Attribute.LANGUAGE      | `AttributedCharacterIteratorAttribute.LANGUAGE`
1.2     | ✔️          | ✔️       | final field   | Attribute.READING       | `AttributedCharacterIteratorAttribute.READING`
1.2     | ✔️          | ✔️       | final field   | Attribute.INPUT_METHOD_SEGMENT | `AttributedCharacterIteratorAttribute.INPUT_METHOD_SEGMENT`
1.2     | ✔️          | ✔️       | method        | getRunStart()           | ()->int; getRunStart(Attribute)->int
1.2     | ✔️          | ✔️       | method        | getRunLimit()           | ()->int; getRunLimit(Attribute)->int
1.2     | ✔️          | ✔️       | method        | getAttributes()         | ()->[Attribute:Any]
1.2     | ✔️          | ✔️       | method        | getAttribute()          | (Attribute)->Any?
1.2     | ✔️          | ✔️       | method        | getAllAttributeKeys()    | ()->Set<Attribute>

### java.text.AttributedString (✔️/✔️)

> Per-character attribute storage backed by `[[Attribute: Any]]`.
> `getIterator()` overloads return `AttributedStringIterator` (`@unchecked Sendable`).

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ✔️       | class         | AttributedString        |
1.2     | ✔️          | ✔️       | constructor   | AttributedString()      | (String)
1.2     | ✔️          | ✔️       | constructor   | AttributedString()      | (String, [Attribute:Any])
1.2     | ✔️          | ✔️       | constructor   | AttributedString()      | (AttributedCharacterIterator)
1.2     | ✔️          | ✔️       | constructor   | AttributedString()      | (AttributedCharacterIterator, beginIndex:Int, endIndex:Int)
1.2     | ✔️          | ✔️       | method        | addAttribute()          | (Attribute, Any)
1.2     | ✔️          | ✔️       | method        | addAttribute()          | (Attribute, Any, beginIndex:Int, endIndex:Int)
1.2     | ✔️          | ✔️       | method        | addAttributes()         | ([Attribute:Any], beginIndex:Int, endIndex:Int)
1.2     | ✔️          | ✔️       | method        | getIterator()           | ()->AttributedCharacterIterator
1.2     | ✔️          | ✔️       | method        | getIterator()           | (attributes:[Attribute])->AttributedCharacterIterator
1.2     | ✔️          | ✔️       | method        | getIterator()           | (attributes:[Attribute], beginIndex:Int, endIndex:Int)->AttributedCharacterIterator

> - ``TODO:`` **Normalizer** (`java.text.Normalizer`) — Unicode normalization forms (NFC/NFD/NFKC/NFKD).
>   Medium effort. Recommended for a future java.text iteration.
> - ``TODO:`` **Bidi** (`java.text.Bidi`) — Unicode Bidirectional Algorithm for RTL/mixed-direction text.
>   High effort. Deferred; consider `CoreText` bridge on Apple platforms or an ICU wrapper.

---

## Not in scope for Java 1.2

- ✅ **`JSplitPane`** — implemented
- ✅ **`JInternalFrame`** — implemented
- ✅ **`JOptionPane`** — implemented (showMessageDialog, showConfirmDialog, showInputDialog with text field, showOptionDialog); UI sized font-relative via FontMetrics, no hardcoded dimensions
- ✅ **`JFileChooser`** — implemented (showOpenDialog, showSaveDialog, showDialog)
- ✅ **`JColorChooser`** — implemented (showDialog, getColor/setColor, RGB sliders + swatch grid)
- ✅ **`JCheckBoxMenuItem`** / **`JRadioButtonMenuItem`** — implemented
- ✅ **`JApplet`** — implemented
- ✅ **`JToolTip`** / **`ToolTipManager`** — implemented
- ✅ **`AbstractListModel`** / **`AbstractSpinnerModel`** / **`FocusManager`** — implemented
- ✅ **`javax.swing.text`** — full document model implemented; `Document` → `TextDocument.swift`, `Element` → `TextElement.swift` (Swift compiler filename restriction)
- ✅ **`BasicEditorPaneUI`** — covered by `BasicTextPaneUI` (registered for `"EditorPaneUI"`)
- ✅ **`BasicDesktopPaneUI`** — implemented, registered for `"DesktopPaneUI"`
- ✅ **`BasicOptionPaneUI`** — implemented, registered for `"OptionPaneUI"`
- ✅ **`BasicFileChooserUI`** — implemented, registered for `"FileChooserUI"`
- ✅ **`BasicColorChooserUI`** — implemented, registered for `"ColorChooserUI"`
- ✅ **`javax.swing.table.TableColumn`** / **`TableColumnModel`** / **`DefaultTableColumnModel`** — implemented
- ✅ **`javax.swing.tree.TreeSelectionModel`** / **`DefaultTreeSelectionModel`** — implemented
- ✅ **`javax.swing.event.TableColumnModelEvent`** / **`TableColumnModelListener`** — implemented
- ✅ **`javax.swing.event.UndoableEditEvent`** / **`UndoableEditListener`** — implemented (incl. `UndoableEdit` protocol)
- ✅ **`javax.swing.event.HyperlinkEvent`** / **`HyperlinkListener`** — implemented
- ✅ **`javax.swing.event.AncestorEvent`** / **`AncestorListener`** — implemented
- ✅ **`java.awt.GraphicsEnvironment`** / **`GraphicsDevice`** / **`GraphicsConfiguration`** — implemented (headless stubs; `fatalError` for screen queries; platform backends deferred)
- ✅ **`java.awt.ComponentOrientation`** — implemented; RTL locales (Arabic, Hebrew, Persian, Urdu) resolved by `getOrientation(Locale)`
- ✅ **`java.awt.AWTEventMulticaster`** — implemented; 10 listener types; `@MainActor` binary-tree chaining
- ✅ **`java.awt.FontFormatException`** / **`HeadlessException`** — implemented (4-init exception pattern)
- **java.awt.color** (`ColorSpace`, `ICC_Profile`) — planned for Java 2D Phase 2
- **java.awt.font** (`GlyphVector`) — stub only (no platform glyph outlines)
- **java.awt.print** (`Printable`, `PageFormat`, `PrinterJob`) — low priority
- **java.awt.image.renderable** — not in scope
- **java.util.Collections framework** (`ArrayList`, `HashMap`, `LinkedList`, etc.) — tracked separately
- **java.lang.ref** (weak/soft/phantom references) — not in scope
- **java.security** additions — not in scope
