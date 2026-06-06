/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Base class for all Java 1.1+ AWT events — mirrors `java.awt.AWTEvent`.
  open class AWTEvent: java.util.EventObject, @unchecked Sendable {

    // Reserved id ranges per subsystem
    public static let COMPONENT_EVENT_MASK  : Int64 = 0x01
    public static let FOCUS_EVENT_MASK      : Int64 = 0x04
    public static let KEY_EVENT_MASK        : Int64 = 0x08
    public static let MOUSE_EVENT_MASK      : Int64 = 0x10
    public static let MOUSE_MOTION_EVENT_MASK: Int64 = 0x20
    public static let WINDOW_EVENT_MASK     : Int64 = 0x40
    public static let ACTION_EVENT_MASK     : Int64 = 0x80
    public static let ITEM_EVENT_MASK       : Int64 = 0x200
    public static let TEXT_EVENT_MASK       : Int64 = 0x400

    public private(set) var id: Int
    internal var consumed: Bool = false

    public init(_ source: AnyObject, _ id: Int) {
      self.id = id
      super.init(source)
    }

    public func getID() -> Int { id }

    public func consume()    { consumed = true  }
    public func isConsumed() -> Bool { consumed }
  }
}
