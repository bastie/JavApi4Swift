/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  ///
  /// - Since: Java 1.1
  public class ActionEvent: java.awt.AWTEvent, @unchecked Sendable {

    public static let SHIFT_MASK = 1
    public static let CTRL_MASK  = 2
    public static let META_MASK  = 4
    public static let ALT_MASK   = 8

    public static let ACTION_FIRST     = 1001
    public static let ACTION_LAST      = 1001
    public static let ACTION_PERFORMED = 1001

    private let actionCommand: String
    private let when: Int64
    private let modifiers: Int

    public init(_ source: AnyObject, _ id: Int,
                _ command: String, _ when: Int64, _ modifiers: Int) {
      self.actionCommand = command
      self.when          = when
      self.modifiers     = modifiers
      super.init(source, id)
      if when <= 0 {
        java.util.logging.Logger.getAnonymousLogger().log (java.util.logging.LogRecord(.WARNING, "Timestamp : \(when) <= 0 not recommeded."))
      }
    }

    public convenience init(_ source: AnyObject, _ id: Int, _ command: String) {
      self.init(source, id, command, java.util.Date().getTime(), 0)
    }

    /// - Returns the action command
    public func getActionCommand() -> String { actionCommand }
    /// - Returns: the timestamp of event
    public func getWhen()          -> Int64  { when          }
    /// - Returns: modifier keys when event fired
    public func getModifiers()     -> Int    { modifiers     }
  }
}
