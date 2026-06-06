/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Java 1.0 layout manager interface — mirrors `java.awt.LayoutManager`.
  @MainActor
  public protocol LayoutManager: AnyObject {
    /// Called when a component is added with a name constraint.
    func addLayoutComponent(_ name: String, _ comp: java.awt.Component)
    /// Called when a component is removed from the container.
    func removeLayoutComponent(_ comp: java.awt.Component)
    /// The preferred size of the container.
    func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension
    /// The minimum acceptable size of the container.
    func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension
    /// Lay out the container's children.
    func layoutContainer(_ parent: java.awt.Container)
  }

  /// Extended layout manager for constraint-based layouts — mirrors `java.awt.LayoutManager2`.
  @MainActor
  public protocol LayoutManager2: LayoutManager {
    func addLayoutComponent(_ comp: java.awt.Component, _ constraints: AnyObject?)
    func maximumLayoutSize(_ target: java.awt.Container) -> java.awt.Dimension
    func getLayoutAlignmentX(_ target: java.awt.Container) -> Double
    func getLayoutAlignmentY(_ target: java.awt.Container) -> Double
    func invalidateLayout(_ target: java.awt.Container)
  }
}
