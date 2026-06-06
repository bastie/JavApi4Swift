/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  public class ActionEvent: java.awt.AWTEvent, @unchecked Sendable {

    public static let SHIFT_MASK = 1
    public static let CTRL_MASK  = 2
    public static let META_MASK  = 4
    public static let ALT_MASK   = 8

    public static let ACTION_FIRST     = 1001
    public static let ACTION_LAST      = 1001
    public static let ACTION_PERFORMED = 1001

    public let actionCommand: String
    public let when: Int64
    public let modifiers: Int

    public init(_ source: AnyObject, _ id: Int,
                _ command: String, _ when: Int64, _ modifiers: Int) {
      self.actionCommand = command
      self.when          = when
      self.modifiers     = modifiers
      super.init(source, id)
    }

    public convenience init(_ source: AnyObject, _ id: Int, _ command: String) {
      self.init(source, id, command, 0, 0)
    }

    public func getActionCommand() -> String { actionCommand }
    public func getWhen()          -> Int64  { when          }
    public func getModifiers()     -> Int    { modifiers     }
  }
}
