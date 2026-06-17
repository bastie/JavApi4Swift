/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// - Since: Java 1.1
  open class ContainerEvent: ComponentEvent, @unchecked Sendable {
    
    private var child : java.awt.Component

    public static let COMPONENT_ADDED   = 300
    public static let COMPONENT_REMOVED = 301
    public static let CONTAINER_FIRST   = 300
    public static let CONTAINER_LAST    = 301

    public init(_ source: java.awt.Component, _ id: Int, _ child : java.awt.Component) {
      self.child = child
      super.init(source, id)
    }

    open func getContainer() -> java.awt.Container {
      getComponent() as! java.awt.Container
    }
    
    open func getChild() -> java.awt.Component {
      return self.child
    }
    
    
  }
}
