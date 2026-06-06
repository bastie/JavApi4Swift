/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Base class for all AWT components — mirrors `java.awt.Component`.
  @MainActor
  open class Component {

    // -------------------------------------------------------------------------
    // MARK: Visual properties
    // -------------------------------------------------------------------------

    public var background: java.awt.Color = java.awt.SystemColor.window
    public var foreground: java.awt.Color = java.awt.SystemColor.windowText
    public var bounds: java.awt.Rectangle = .zero
    public var font: java.awt.Font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    public var visible: Bool = true
    public var enabled: Bool = true

    /// The container this component was added to, or `nil` if not yet added.
    public weak var parent: java.awt.Container?

    /// Optionales PopupMenu — wird bei Rechtsklick / Context-Klick eingeblendet.
    public var popupMenu: java.awt.PopupMenu? = nil

    // -------------------------------------------------------------------------
    // MARK: Size hints (used by LayoutManagers)
    // -------------------------------------------------------------------------

    private var _preferredSize: java.awt.Dimension? = nil
    private var _minimumSize:   java.awt.Dimension? = nil
    private var _maximumSize:   java.awt.Dimension? = nil

    /// Hint für LayoutManager; `nil` bedeutet „komponenteneigener Standardwert".
    public func setPreferredSize(_ d: java.awt.Dimension?) { _preferredSize = d }
    public func getPreferredSize() -> java.awt.Dimension {
      _preferredSize ?? java.awt.Dimension(bounds.width, bounds.height)
    }

    public func setMinimumSize(_ d: java.awt.Dimension?) { _minimumSize = d }
    public func getMinimumSize() -> java.awt.Dimension {
      _minimumSize ?? java.awt.Dimension(0, 0)
    }

    public func setMaximumSize(_ d: java.awt.Dimension?) { _maximumSize = d }
    public func getMaximumSize() -> java.awt.Dimension {
      _maximumSize ?? java.awt.Dimension(Int.max, Int.max)
    }

    // -------------------------------------------------------------------------
    // MARK: Position & size
    // -------------------------------------------------------------------------

    // -------------------------------------------------------------------------
    // MARK: Visibility
    // -------------------------------------------------------------------------

    open func setVisible(_ v: Bool) { visible = v }
    open func isVisible() -> Bool   { visible     }

    // -------------------------------------------------------------------------
    // MARK: Position & size
    // -------------------------------------------------------------------------

    /// Setzt die Position ohne die Größe zu ändern.
    public func setLocation(_ x: Int, _ y: Int) {
      bounds = java.awt.Rectangle(x, y, bounds.width, bounds.height)
    }

    public func setLocation(_ p: java.awt.Point) {
      setLocation(p.x, p.y)
    }

    /// Liefert die aktuelle Position als `Point`.
    public func getLocation() -> java.awt.Point {
      java.awt.Point(bounds.x, bounds.y)
    }

    /// Setzt Breite und Höhe ohne die Position zu ändern.
    public func setSize(_ width: Int, _ height: Int) {
      bounds = java.awt.Rectangle(bounds.x, bounds.y, width, height)
    }

    public func setSize(_ d: java.awt.Dimension) {
      setSize(d.width, d.height)
    }

    /// Liefert die aktuelle Größe als `Dimension`.
    public func getSize() -> java.awt.Dimension {
      java.awt.Dimension(bounds.width, bounds.height)
    }

    /// Liefert den übergeordneten Container, oder `nil`.
    public func getParent() -> java.awt.Container? { parent }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var mouseListeners:       [java.awt.event.MouseListener]       = []
    private var mouseMotionListeners: [java.awt.event.MouseMotionListener] = []
    private var keyListeners:         [java.awt.event.KeyListener]         = []
    private var focusListeners:       [java.awt.event.FocusListener]       = []
    private var componentListeners:   [java.awt.event.ComponentListener]   = []
    private var windowListeners:      [java.awt.event.WindowListener]      = []

    public func addMouseListener       (_ l: java.awt.event.MouseListener)       { mouseListeners.append(l) }
    public func removeMouseListener    (_ l: java.awt.event.MouseListener)       { mouseListeners.removeAll { $0 === l } }
    public func getMouseListeners()    -> [java.awt.event.MouseListener]         { mouseListeners }

    public func addMouseMotionListener    (_ l: java.awt.event.MouseMotionListener) { mouseMotionListeners.append(l) }
    public func removeMouseMotionListener (_ l: java.awt.event.MouseMotionListener) { mouseMotionListeners.removeAll { $0 === l } }
    public func getMouseMotionListeners() -> [java.awt.event.MouseMotionListener]   { mouseMotionListeners }

    public func addKeyListener    (_ l: java.awt.event.KeyListener) { keyListeners.append(l) }
    public func removeKeyListener (_ l: java.awt.event.KeyListener) { keyListeners.removeAll { $0 === l } }
    public func getKeyListeners() -> [java.awt.event.KeyListener]   { keyListeners }

    public func addFocusListener    (_ l: java.awt.event.FocusListener) { focusListeners.append(l) }
    public func removeFocusListener (_ l: java.awt.event.FocusListener) { focusListeners.removeAll { $0 === l } }
    public func getFocusListeners() -> [java.awt.event.FocusListener]   { focusListeners }

    public func addComponentListener    (_ l: java.awt.event.ComponentListener) { componentListeners.append(l) }
    public func removeComponentListener (_ l: java.awt.event.ComponentListener) { componentListeners.removeAll { $0 === l } }
    public func getComponentListeners() -> [java.awt.event.ComponentListener]   { componentListeners }

    public func addWindowListener    (_ l: java.awt.event.WindowListener) { windowListeners.append(l) }
    public func removeWindowListener (_ l: java.awt.event.WindowListener) { windowListeners.removeAll { $0 === l } }
    public func getWindowListeners() -> [java.awt.event.WindowListener]   { windowListeners }

    // -------------------------------------------------------------------------
    // MARK: Event dispatch (called by platform bridge)
    // -------------------------------------------------------------------------

    open func processMouseEvent(_ e: java.awt.event.MouseEvent) {
      switch e.id {
      case java.awt.event.MouseEvent.MOUSE_CLICKED:  mouseListeners.forEach { $0.mouseClicked(e)  }
      case java.awt.event.MouseEvent.MOUSE_PRESSED:  mouseListeners.forEach { $0.mousePressed(e)  }
      case java.awt.event.MouseEvent.MOUSE_RELEASED: mouseListeners.forEach { $0.mouseReleased(e) }
      case java.awt.event.MouseEvent.MOUSE_ENTERED:  mouseListeners.forEach { $0.mouseEntered(e)  }
      case java.awt.event.MouseEvent.MOUSE_EXITED:   mouseListeners.forEach { $0.mouseExited(e)   }
      default: break
      }
    }

    open func processMouseMotionEvent(_ e: java.awt.event.MouseEvent) {
      switch e.id {
      case java.awt.event.MouseEvent.MOUSE_MOVED:   mouseMotionListeners.forEach { $0.mouseMoved(e)   }
      case java.awt.event.MouseEvent.MOUSE_DRAGGED: mouseMotionListeners.forEach { $0.mouseDragged(e) }
      default: break
      }
    }

    open func processKeyEvent(_ e: java.awt.event.KeyEvent) {
      switch e.id {
      case java.awt.event.KeyEvent.KEY_TYPED:    keyListeners.forEach { $0.keyTyped(e)    }
      case java.awt.event.KeyEvent.KEY_PRESSED:  keyListeners.forEach { $0.keyPressed(e)  }
      case java.awt.event.KeyEvent.KEY_RELEASED: keyListeners.forEach { $0.keyReleased(e) }
      default: break
      }
    }

    open func processFocusEvent(_ e: java.awt.event.FocusEvent) {
      switch e.id {
      case java.awt.event.FocusEvent.FOCUS_GAINED: focusListeners.forEach { $0.focusGained(e) }
      case java.awt.event.FocusEvent.FOCUS_LOST:   focusListeners.forEach { $0.focusLost(e)   }
      default: break
      }
    }

    open func processWindowEvent(_ e: java.awt.event.WindowEvent) {
      switch e.id {
      case java.awt.event.WindowEvent.WINDOW_OPENED:      windowListeners.forEach { $0.windowOpened(e)      }
      case java.awt.event.WindowEvent.WINDOW_CLOSING:     windowListeners.forEach { $0.windowClosing(e)     }
      case java.awt.event.WindowEvent.WINDOW_CLOSED:      windowListeners.forEach { $0.windowClosed(e)      }
      case java.awt.event.WindowEvent.WINDOW_ICONIFIED:   windowListeners.forEach { $0.windowIconified(e)   }
      case java.awt.event.WindowEvent.WINDOW_DEICONIFIED: windowListeners.forEach { $0.windowDeiconified(e) }
      case java.awt.event.WindowEvent.WINDOW_ACTIVATED:   windowListeners.forEach { $0.windowActivated(e)   }
      case java.awt.event.WindowEvent.WINDOW_DEACTIVATED: windowListeners.forEach { $0.windowDeactivated(e) }
      default: break
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Focus query
    // -------------------------------------------------------------------------

    /// Returns `true` when this component currently holds keyboard focus.
    ///
    /// Using a computed property (rather than `let hasFocus = false`) prevents
    /// the Swift compiler from constant-folding focus-guarded blocks as dead code
    /// on platforms where `AWTFocusManager` is unavailable.
    public var isFocusOwner: Bool {
      #if canImport(SwiftUI)
      return AWTFocusManager.shared.focusOwner === self
      #else
      return false
      #endif
    }

    // -------------------------------------------------------------------------
    // MARK: Paint & layout
    // -------------------------------------------------------------------------

    open func paint(_ g: java.awt.Graphics) {}

    open func repaint() {}

    public func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: f)
    }
  }
}
