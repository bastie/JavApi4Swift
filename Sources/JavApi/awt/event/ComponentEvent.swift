/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Base for component-level events (moved, resized, shown, hidden).
  open class ComponentEvent: java.awt.AWTEvent, @unchecked Sendable {

    public static let COMPONENT_FIRST   = 100
    public static let COMPONENT_LAST    = 103
    public static let COMPONENT_MOVED   = 100
    public static let COMPONENT_RESIZED = 101
    public static let COMPONENT_SHOWN   = 102
    public static let COMPONENT_HIDDEN  = 103

    public init(_ source: java.awt.Component, _ id: Int) {
      super.init(source, id)
    }

    public func getComponent() -> java.awt.Component {
      source as! java.awt.Component
    }
  }
}
