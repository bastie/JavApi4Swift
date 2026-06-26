/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// - Since: Java 1.4
  open class MouseWheelEvent: MouseEvent, @unchecked Sendable {

    public static let WHEEL_UNIT_SCROLL: Int = 0
    public static let WHEEL_BLOCK_SCROLL: Int = 1
    
    private let scrollType: Int
    private let scrollAmount: Int
    private let wheelRotation: Int
    
    public init(_ source: java.awt.Component, _ id: Int, _ when: Int64, _ modifiers: Int, _ x: Int, _ y: Int, _ clickCount: Int, _ popupTrigger: Bool, _ scrollType: Int, _ scrollAmount: Int, _ wheelRotation: Int) {
      self.scrollType = scrollType
      self.scrollAmount = scrollAmount
      self.wheelRotation = wheelRotation
      
      super.init(source, id, when, modifiers, x, y, clickCount, popupTrigger)
    }
    
    public func getScrollType() -> Int {
      scrollType
    }
    public func getScrollAmount() -> Int {
      scrollAmount
    }
    public func getWheelRotation() -> Int {
      wheelRotation
    }
  }
}
