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
1.2     | ✔️          | ⭕️       | method        | paintChildren()         | translates g to each child's origin
1.2     | ✔️          | ⭕️       | method        | updateUI()              | no-op; subclasses override
1.2     | ✔️          | ⭕️       | method        | setUI()                 | installs ComponentUI delegate
1.2     | ✔️          | ⭕️       | method        | isOpaque() / setOpaque()| controls background fill
1.2     | ✔️          | ⭕️       | method        | getBackground() / setBackground() |
1.2     | ✔️          | ⭕️       | method        | getForeground() / setForeground() |
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | delegates to UI then LayoutManager
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
1.2     | ✔️          | ⭕️       | method        | processWindowEvent()    | handles WINDOW_CLOSING

### javax.swing.JDialog (✔️/⭕️)

version | implemented | tested   | type          | name                    | more informations
------- | ----------- | -------- | ------------- | ----------------------- | -----------------
1.2     | ✔️          | ⭕️       | class         | JDialog                 | extends java.awt.Dialog
1.2     | ✔️          | ⭕️       | constructor   | JDialog()               | (owner:title:modal:)
1.2     | ✔️          | ⭕️       | method        | setDefaultCloseOperation()| HIDE_ON_CLOSE (default), DISPOSE_ON_CLOSE
1.2     | ✔️          | ⭕️       | method        | getContentPane()        |
1.2     | ✔️          | ⭕️       | method        | add()                   | delegates to content pane

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
1.2     | ✔️          | ⭕️       | method        | getPreferredSize()      | 16×100 (V) or 100×16 (H)

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
> Both are **fully implemented** in JavApi4Swift (2026).

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

- ✅ **`JSplitPane`** — container with resizable divider; implemented
- **`JOptionPane`** — message/option dialogs; not yet implemented
- **`JInternalFrame`** — MDI frame container; not yet implemented
- **`JFileChooser`** — file selection dialog; not yet implemented
- **java.awt.color** (`ColorSpace`, `ICC_Profile`) — planned for Java 2D Phase 2
- **java.awt.font** (`GlyphVector`) — stub only (no platform glyph outlines)
- **java.awt.print** (`Printable`, `PageFormat`, `PrinterJob`) — low priority
- **java.awt.image.renderable** — not in scope
- **java.util.Collections framework** (`ArrayList`, `HashMap`, `LinkedList`, etc.) — tracked separately
- **java.lang.ref** (weak/soft/phantom references) — not in scope
- **java.security** additions — not in scope
