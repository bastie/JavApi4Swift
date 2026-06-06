/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  public class FocusEvent: ComponentEvent, @unchecked Sendable {

    public static let FOCUS_FIRST    = 1004
    public static let FOCUS_LAST     = 1005
    public static let FOCUS_GAINED   = 1004
    public static let FOCUS_LOST     = 1005

    public let temporary: Bool

    public init(_ source: java.awt.Component, _ id: Int, _ temporary: Bool = false) {
      self.temporary = temporary
      super.init(source, id)
    }

    public func isTemporary() -> Bool { temporary }
  }
}
