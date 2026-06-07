/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Java 1.0 layout manager interface.
  @MainActor
  public protocol LayoutManager: AnyObject {
    
    /// Called when a component is added with a name constraint.
    func addLayoutComponent(_ name: String, _ comp: java.awt.Component)

    /// Called when a component is removed from the container.
    /// - Parameter comp: component to remove
    func removeLayoutComponent(_ comp: java.awt.Component)
    
    /// The preferred size of the container.
    /// - Parameter parent: the parent container
    /// - Returns: the dimension of prefered size
    func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension
    
    /// The minimum acceptable size of the container.
    /// - Parameter parent: the parent container
    /// - Returns: the dimension of minimum size
    func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension
    /// Lay out the container's children.
    func layoutContainer(_ parent: java.awt.Container)
  }
}
