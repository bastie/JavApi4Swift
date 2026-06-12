/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Base class for all AWT components.
  @MainActor
  open class Component: MenuContainer {

    // -------------------------------------------------------------------------
    // MARK: Visual properties
    // -------------------------------------------------------------------------

    internal var background: java.awt.Color = java.awt.SystemColor.window
    internal var foreground: java.awt.Color = java.awt.SystemColor.windowText
    internal var bounds: java.awt.Rectangle = .zero
    public var font: java.awt.Font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    public func getFont() -> java.awt.Font { font }
    
    /// - Since: Java 1.0
    public func getBackgroundColor () -> java.awt.Color {
      return self.background
    }
    
    /// - Since: Java 1.0
    public func getForegroundColor () -> java.awt.Color {
      return self.foreground
    }
    
    /// - Since: Java 1.0
    public func setForegroundColor (_ color : java.awt.Color?) {
      if let color {
        self.foreground = color
        self.foregroundSetOnSelf = true
      }
      else {
        self.foreground = self.parent?.foreground ?? java.awt.SystemColor.windowText
        self.foregroundSetOnSelf = false
      }
    }
    
    /// contains state to detect of color set directly on this Component
    private var foregroundSetOnSelf : Bool = false
    
    /// - Since: Java 1.4
    public func isForegroundSet () -> Bool {
      return self.foregroundSetOnSelf
    }
    
    public var visible: Bool = true
    public var enabled: Bool = true

    /// The container this component was added to, or `nil` if not yet added.
    public weak var parent: java.awt.Container?

    /// Optionales PopupMenu — wird bei Rechtsklick / Context-Klick eingeblendet.
    public var popupMenu: java.awt.PopupMenu? = nil

    // -------------------------------------------------------------------------
    // MARK: Size hints (used by LayoutManagers)
    // -------------------------------------------------------------------------

    internal var _preferredSize: java.awt.Dimension? = nil
    private  var _minimumSize:   java.awt.Dimension? = nil
    private var _maximumSize:   java.awt.Dimension? = nil

    /// Hint für LayoutManager; `nil` bedeutet „komponenteneigener Standardwert".
    public func setPreferredSize(_ d: java.awt.Dimension?) {
      _preferredSize = d
    }
    
    public func getPreferredSize() -> java.awt.Dimension {
      _preferredSize ?? java.awt.Dimension(bounds.width, bounds.height)
    }

    public func setMinimumSize(_ d: java.awt.Dimension?) {
      _minimumSize = d
    }
    
    public func getMinimumSize() -> java.awt.Dimension {
      _minimumSize ?? java.awt.Dimension(0, 0)
    }

    public func setMaximumSize(_ d: java.awt.Dimension?) {
      _maximumSize = d
    }
    
    public func getMaximumSize() -> java.awt.Dimension {
      _maximumSize ?? java.awt.Dimension(Int.max, Int.max)
    }

    // -------------------------------------------------------------------------
    // MARK: Position & size
    // -------------------------------------------------------------------------

    // -------------------------------------------------------------------------
    // MARK: Visibility
    // -------------------------------------------------------------------------

    open func setVisible(_ v: Bool) {
      visible = v
    }
    open func isVisible() -> Bool   {
      return visible
    }

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

    // Java 1.1 convenience accessors (java.awt.Component)
    public func getX() -> Int {
      bounds.x
    }
    public func getY() -> Int {
      bounds.y
    }
    public func getWidth() -> Int {
      bounds.width
    }
    public func getHeight() -> Int {
      bounds.height
    }

    public func getBounds() -> java.awt.Rectangle { bounds }
    public func setBounds(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      bounds = java.awt.Rectangle(x, y, width, height)
    }
    public func setBounds(_ r: java.awt.Rectangle) {
      bounds = r
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
    /// Delegates to `Toolkit.getDefaultToolkit().isFocusOwner(_:)` so that
    /// platform-specific focus systems (SwiftUI, headless, …) can be queried
    /// without a direct dependency on `_SwiftUIFocusManager`.
    public var isFocusOwner: Bool {
      java.awt.Toolkit.getDefaultToolkit().isFocusOwner(self)
    }

    // -------------------------------------------------------------------------
    // MARK: Cursor (Java 1.1)
    // -------------------------------------------------------------------------

    /// The cursor currently set on this component.
    public var cursor: java.awt.Cursor? = nil

    /// Sets the cursor for this component.
    public func setCursor(_ cursor: java.awt.Cursor) {
      self.cursor = cursor
      #if canImport(AppKit)
      // Tell the native view to recompute cursor rects
      NotificationCenter.default.post(name: .awtCursorChanged, object: self)
      #endif
    }

    /// Returns the cursor set on this component, or nil if none.
    public func getCursor() -> java.awt.Cursor? {
      return cursor
    }

    // -------------------------------------------------------------------------
    // MARK: Paint & layout
    // -------------------------------------------------------------------------

    open func paint(_ g: java.awt.Graphics) {}

    open func repaint() {
      // Walk up the parent chain to find the containing Window, then ask the
      // toolkit to repaint it. This allows setText(), setState() etc. to trigger
      // a visual update without the call site knowing about the platform layer.
      var node: java.awt.Component? = self
      while let current = node {
        if let window = current as? java.awt.Window {
          java.awt.Toolkit.getDefaultToolkit().repaint(window)
          return
        }
        node = current.parent
      }
    }

    /// Releases resources held by this component. Subclasses (Window, Dialog) override this.
    open func dispose() {}

    /// Returns a graphics context for this component.
    /// Real graphics contexts are only available during `paint(_:)` — this stub
    /// satisfies the `java.awt.peer.ComponentPeer` protocol requirement.
    open func getGraphics() -> java.awt.Graphics {
      java.awt.Graphics.stub
    }

    public func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: f)
    }
  }
}

#if canImport(Foundation)
import Foundation
extension Notification.Name {
  /// Posted when a java.awt.Component's cursor changes, so native views can update cursor rects.
  public static let awtCursorChanged = Notification.Name("java.awt.Component.cursorChanged")
  /// Posted by the caret blink timer so the owning native view can redraw.
  public static let awtCaretBlink    = Notification.Name("java.awt.TextComponent.caretBlink")
}
#endif
