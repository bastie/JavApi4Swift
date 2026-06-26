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

    private let actionCommand: String?
    private let when: Int64
    private let modifiers: Int

    /// Create Action Event
    ///
    /// - Parameters:
    ///   - source: source type that fire the action event
    ///   - id: id of action event
    ///   - command: a command
    ///   - when: time stamp. A value zero or less are not recommended
    ///   - modifier: the mask key modifiert. Zero means no control, option, shift, command key is pressed. Negative values are not recommended.
    /// - Note: in Java it throw an `IllegalArgumentException` if source is `null`, but we do not provide a optional value in Swift
    /// - Since: Java 1.4
    public init(_ source: AnyObject, _ id: Int,
                _ command: String?, _ when: Int64, _ modifiers: Int) {
      self.actionCommand = command
      self.when          = when
      self.modifiers     = modifiers
      super.init(source, id)
      #if DEBUG // not recommended logging
      if when <= 0 {
        java.util.logging.Logger.getAnonymousLogger().log (java.util.logging.LogRecord(.WARNING, "Timestamp : \(when) <= 0 not recommended."))
      }
      if modifiers < 0 {
        java.util.logging.Logger.getAnonymousLogger().log (java.util.logging.LogRecord(.WARNING, "Action event modifiers : \(modifiers) <= 0 not recommended."))
      }
      #endif
    }

    public convenience init(_ source: AnyObject, _ id: Int, _ command: String, _ modifiers : Int) {
      self.init(source, id, command, java.util.Date().getTime(), 0)
    }

    public convenience init(_ source: AnyObject, _ id: Int, _ command: String) {
      self.init(source, id, command, java.util.Date().getTime(), 0)
    }
    
    /// - Returns the action command
    public func getActionCommand() -> String? { actionCommand }
    /// - Returns: the timestamp of event
    public func getWhen()          -> Int64  { when          }
    /// - Returns: modifier keys when event fired
    public func getModifiers()     -> Int    { modifiers     }
  }
}
