/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Base class for all Java 1.1+ AWT events — mirrors `java.awt.AWTEvent`.
  open class AWTEvent: java.util.EventObject, @unchecked Sendable {

    // Reserved id ranges per subsystem
    public static let ACTION_EVENT_MASK : Int64 = 128
    public static let ADJUSTMENT_EVENT_MASK : Int64 = 256
    public static let COMPONENT_EVENT_MASK : Int64 = 1
    public static let CONTAINER_EVENT_MASK : Int64 = 2
    public static let FOCUS_EVENT_MASK : Int64 = 4
    public static let HIERARCHY_BOUNDS_EVENT_MASK : Int64 = 65536
    public static let HIERARCHY_EVENT_MASK : Int64 = 32768
    public static let INPUT_METHOD_EVENT_MASK : Int64 = 2048
    public static let INVOCATION_EVENT_MASK : Int64 = 16384
    public static let ITEM_EVENT_MASK : Int64 = 512
    public static let KEY_EVENT_MASK : Int64 = 8
    public static let MOUSE_EVENT_MASK : Int64 = 16
    public static let MOUSE_MOTION_EVENT_MASK : Int64 = 32
    public static let MOUSE_WHEEL_EVENT_MASK : Int64 = 131072
    public static let PAINT_EVENT_MASK : Int64 = 8192
    public static let RESERVED_ID_MAX : Int = 1999
    public static let TEXT_EVENT_MASK : Int64 = 1024
    public static let WINDOW_EVENT_MASK : Int64 = 64
    public static let WINDOW_FOCUS_EVENT_MASK : Int64 = 524288
    public static let WINDOW_STATE_EVENT_MASK : Int64 = 262144
    

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
