/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Java 1.0 event model.
  ///
  /// Deprecated since Java 1.1 — use `java.awt.event.*` listeners instead.
  /// Retained for source-level compatibility when porting Java 1.0 code.
  @available(*, deprecated, message: "Use java.awt.event listeners (Java 1.1+) instead.")
  public final class Event {

    // -------------------------------------------------------------------------
    // MARK: Modifier masks
    // -------------------------------------------------------------------------

    public static let SHIFT_MASK = 1
    public static let CTRL_MASK  = 2
    public static let META_MASK  = 4
    public static let ALT_MASK   = 8

    // -------------------------------------------------------------------------
    // MARK: Event id constants
    // -------------------------------------------------------------------------

    // Window
    public static let WINDOW_DESTROY   = 201
    public static let WINDOW_EXPOSE    = 202
    public static let WINDOW_ICONIFY   = 203
    public static let WINDOW_DEICONIFY = 204
    public static let WINDOW_MOVED     = 205

    // Keyboard
    public static let KEY_PRESS          = 401
    public static let KEY_RELEASE        = 402
    public static let KEY_ACTION         = 403
    public static let KEY_ACTION_RELEASE = 404

    // Mouse
    public static let MOUSE_DOWN  = 501
    public static let MOUSE_UP    = 502
    public static let MOUSE_MOVE  = 503
    public static let MOUSE_ENTER = 504
    public static let MOUSE_EXIT  = 505
    public static let MOUSE_DRAG  = 506

    // Scrollbar
    public static let SCROLL_LINE_UP   = 601
    public static let SCROLL_LINE_DOWN = 602
    public static let SCROLL_PAGE_UP   = 603
    public static let SCROLL_PAGE_DOWN = 604
    public static let SCROLL_ABSOLUTE  = 605
    public static let SCROLL_BEGIN     = 606
    public static let SCROLL_END       = 607

    // List
    public static let LIST_SELECT   = 701
    public static let LIST_DESELECT = 702

    // Misc
    public static let ACTION_EVENT = 1001
    public static let LOAD_FILE    = 1002
    public static let SAVE_FILE    = 1003
    public static let GOT_FOCUS    = 1004
    public static let LOST_FOCUS   = 1005

    // -------------------------------------------------------------------------
    // MARK: Special key codes
    // -------------------------------------------------------------------------

    public static let HOME  = 1000
    public static let END   = 1001
    public static let PGUP  = 1002
    public static let PGDN  = 1003
    public static let UP    = 1004
    public static let DOWN  = 1005
    public static let LEFT  = 1006
    public static let RIGHT = 1007
    public static let F1    = 1008
    public static let F2    = 1009
    public static let F3    = 1010
    public static let F4    = 1011
    public static let F5    = 1012
    public static let F6    = 1013
    public static let F7    = 1014
    public static let F8    = 1015
    public static let F9    = 1016
    public static let F10   = 1017
    public static let F11   = 1018
    public static let F12   = 1019

    // -------------------------------------------------------------------------
    // MARK: Instance fields
    // -------------------------------------------------------------------------

    /// The component that originated the event.
    public var target: AnyObject?

    /// Timestamp in milliseconds.
    public var when: Int64

    /// Event type identifier (one of the constants above).
    public var id: Int

    /// X coordinate (mouse events).
    public var x: Int

    /// Y coordinate (mouse events).
    public var y: Int

    /// Key code (keyboard events).
    public var key: Int

    /// Modifier mask (SHIFT_MASK, CTRL_MASK, …).
    public var modifiers: Int

    /// Click count (mouse events).
    public var clickCount: Int

    /// Additional argument (e.g. label for ACTION_EVENT).
    public var arg: AnyObject?

    /// Next event in a linked chain (Java 1.0 event queue).
    public var evt: java.awt.Event?

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public init(
      _ target: AnyObject?,
      _ when: Int64,
      _ id: Int,
      _ x: Int,
      _ y: Int,
      _ key: Int,
      _ modifiers: Int,
      _ arg: AnyObject? = nil
    ) {
      self.target     = target
      self.when       = when
      self.id         = id
      self.x          = x
      self.y          = y
      self.key        = key
      self.modifiers  = modifiers
      self.clickCount = 0
      self.arg        = arg
    }

    /// Convenience init for action-style events.
    public convenience init(_ target: AnyObject?, _ id: Int, _ arg: AnyObject?) {
      self.init(target, java.util.Date().getTime(), id, 0, 0, 0, 0, arg)
    }

    // -------------------------------------------------------------------------
    // MARK: Modifier helpers
    // -------------------------------------------------------------------------

    public func shiftDown()   -> Bool { modifiers & Event.SHIFT_MASK != 0 }
    public func controlDown() -> Bool { modifiers & Event.CTRL_MASK  != 0 }
    public func metaDown()    -> Bool { modifiers & Event.META_MASK  != 0 }

    // -------------------------------------------------------------------------
    // MARK: Translate
    // -------------------------------------------------------------------------

    /// Translates event coordinates by (dx, dy).
    public func translate(_ dx: Int, _ dy: Int) {
      x += dx
      y += dy
    }
  }
}
