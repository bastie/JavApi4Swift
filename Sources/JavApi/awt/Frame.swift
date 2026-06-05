/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  
  @MainActor
  open class Frame: Container {
    public var title: String
    
    public init(_ title: String = "") {
      self.title = title
    }
    
    /// Macht das Fenster sichtbar
    open func setVisible(_ visible: Bool) {
      let toolkit = java.awt.Toolkit.getDefaultToolkit()
      if visible {
        toolkit.show(self)
      } else {
        toolkit.hide(self)
      }
    }
    
    open func setSize(_ width: Int, _ height: Int) {
      bounds = java.awt.Rectangle(0, 0, width, height)
    }
  }
}
