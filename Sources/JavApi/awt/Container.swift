/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  open class Container: Component {

    internal var children: [Component] = []
    private var layoutManager: LayoutManager? = FlowLayout()

    /// Set the LayoutManager for this Container
    /// - Parameter mgr: LayoutManager instance
    public func setLayout(_ mgr: LayoutManager?) {
      layoutManager = mgr
    }
    public func getLayout() -> LayoutManager?    { layoutManager       }

    public func doLayout() { layoutManager?.layoutContainer(self) }

    /// Recursively lay out this container and all Container children.
    /// Mirrors `java.awt.Container.validate()`.
    public func validate() {
      doLayout()
      for child in children {
        (child as? Container)?.validate()
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Children
    // -------------------------------------------------------------------------

    public func add(_ comp: Component) {
      comp.parent = self
      children.append(comp)
      layoutManager?.addLayoutComponent("", comp)
      invalidate()
    }

    /// Add with BorderLayout-style string constraint.
    public func add(_ comp: Component, _ constraint: String) {
      comp.parent = self
      children.append(comp)
      if let mgr2 = layoutManager as? LayoutManager2 {
        mgr2.addLayoutComponent(comp, constraint as AnyObject)
      } else {
        layoutManager?.addLayoutComponent(constraint, comp)
      }
      invalidate()
    }

    /// Add with arbitrary constraint object (LayoutManager2).
    public func add(_ comp: Component, _ constraints: AnyObject?) {
      comp.parent = self
      children.append(comp)
      if let mgr2 = layoutManager as? LayoutManager2 {
        mgr2.addLayoutComponent(comp, constraints)
      }
      invalidate()
    }

    public func remove(_ comp: Component) {
      comp.parent = nil
      children.removeAll { $0 === comp }
      layoutManager?.removeLayoutComponent(comp)
      invalidate()
    }

    public func removeAll() {
      for comp in children {
        comp.parent = nil
        layoutManager?.removeLayoutComponent(comp)
      }
      children.removeAll()
      invalidate()
    }

    /// Mark this container as needing layout recalculation.
    public func invalidate() {
      // Propagate up — parent may also need re-layout
      parent?.invalidate()
    }

    public func getComponents() -> [Component] { children }
    public func getComponentCount() -> Int      { children.count }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      for child in children where child.visible { child.paint(g) }
    }
  }
}
