/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  public class MouseEvent: InputEvent, @unchecked Sendable {

    public static let MOUSE_FIRST    = 500
    public static let MOUSE_LAST     = 507
    public static let MOUSE_CLICKED  = 500
    public static let MOUSE_PRESSED  = 501
    public static let MOUSE_RELEASED = 502
    public static let MOUSE_MOVED    = 503
    public static let MOUSE_ENTERED  = 504
    public static let MOUSE_EXITED   = 505
    public static let MOUSE_DRAGGED  = 506
    public static let MOUSE_WHEEL    = 507

    public static let NOBUTTON = 0
    public static let BUTTON1  = 1
    public static let BUTTON2  = 2
    public static let BUTTON3  = 3

    public let x: Int
    public let y: Int
    public let clickCount: Int
    public let button: Int
    public let popupTrigger: Bool

    public init(_ source: java.awt.Component, _ id: Int,
                _ when: Int64, _ modifiers: Int,
                _ x: Int, _ y: Int,
                _ clickCount: Int, _ popupTrigger: Bool,
                _ button: Int = NOBUTTON) {
      self.x            = x
      self.y            = y
      self.clickCount   = clickCount
      self.button       = button
      self.popupTrigger = popupTrigger
      super.init(source, id, when, modifiers)
    }

    public func getX()            -> Int  { x            }
    public func getY()            -> Int  { y            }
    public func getClickCount()   -> Int  { clickCount   }
    public func getButton()       -> Int  { button       }
    public func isPopupTrigger()  -> Bool { popupTrigger }
    public func getPoint()        -> java.awt.Point { java.awt.Point(x, y) }
  }
}
