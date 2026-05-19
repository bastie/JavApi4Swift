/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  
  open class Container: Component {
    internal var children: [Component] = []
    
    public func add(_ comp: Component) {
      children.append(comp)
    }
    
    public func add(_ comp: Component, _ constraints: AnyObject?) {
      children.append(comp)
    }
    
    override open func paint(_ g: java.awt.Graphics) {
      for child in children { child.paint(g) }
    }
  }
  
}
