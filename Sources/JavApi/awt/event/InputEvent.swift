/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Base class for keyboard and mouse events — carries modifier state.
  open class InputEvent: ComponentEvent, @unchecked Sendable {

    // Legacy modifier masks (Java 1.0 style, kept for compatibility)
    public static let SHIFT_MASK     = 1
    public static let CTRL_MASK      = 2
    public static let META_MASK      = 4
    public static let ALT_MASK       = 8
    public static let ALT_GRAPH_MASK = 32
    public static let BUTTON1_MASK   = 16
    public static let BUTTON2_MASK   = 8
    public static let BUTTON3_MASK   = 4

    // Extended modifier masks (Java 1.4+)
    public static let SHIFT_DOWN_MASK     = 1 << 6
    public static let CTRL_DOWN_MASK      = 1 << 7
    public static let META_DOWN_MASK      = 1 << 8
    public static let ALT_DOWN_MASK       = 1 << 9
    public static let BUTTON1_DOWN_MASK   = 1 << 10
    public static let BUTTON2_DOWN_MASK   = 1 << 11
    public static let BUTTON3_DOWN_MASK   = 1 << 12
    public static let ALT_GRAPH_DOWN_MASK = 1 << 13

    public let when: Int64
    public let modifiers: Int

    public init(_ source: java.awt.Component, _ id: Int,
                _ when: Int64, _ modifiers: Int) {
      self.when      = when
      self.modifiers = modifiers
      super.init(source, id)
    }

    public func getWhen()      -> Int64 { when      }
    public func getModifiers() -> Int   { modifiers }
    public func getModifiersEx() -> Int { modifiers }

    public func isShiftDown()    -> Bool { modifiers & InputEvent.SHIFT_DOWN_MASK  != 0 }
    public func isControlDown()  -> Bool { modifiers & InputEvent.CTRL_DOWN_MASK   != 0 }
    public func isMetaDown()     -> Bool { modifiers & InputEvent.META_DOWN_MASK   != 0 }
    public func isAltDown()      -> Bool { modifiers & InputEvent.ALT_DOWN_MASK    != 0 }
    public func isAltGraphDown() -> Bool { modifiers & InputEvent.ALT_GRAPH_DOWN_MASK != 0 }
  }
}
