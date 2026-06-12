/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Extended layout manager for constraint-based layouts.
  /// - Since: Java 1.2
  @MainActor
  public protocol LayoutManager2: LayoutManager {
    func addLayoutComponent(_ comp: java.awt.Component, _ constraints: AnyObject?)
    func maximumLayoutSize(_ target: java.awt.Container) -> java.awt.Dimension
    func getLayoutAlignmentX(_ target: java.awt.Container) -> Double
    func getLayoutAlignmentY(_ target: java.awt.Container) -> Double
    func invalidateLayout(_ target: java.awt.Container)
  }
}
