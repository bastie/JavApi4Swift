/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.BorderLayout {

  /// Type-safe `addLayoutComponent` accepting a `BorderLayoutConstraint` enum.
  public func addLayoutComponent(_ comp: java.awt.Component,
                                 constraint: java.awt.BorderLayoutConstraint) {
    addLayoutComponent(constraint.rawValue, comp)
  }
}

extension java.awt.Container {

  /// Add `comp` to this container using a type-safe `BorderLayoutConstraint`.
  ///
  /// Requires the container's layout manager to be a `BorderLayout`.
  /// ```swift
  /// frame.add(toolbar, constraint: .north)
  /// frame.add(canvas,  constraint: .center)
  /// ```
  public func add(_ comp: java.awt.Component, constraint: java.awt.BorderLayoutConstraint) {
    add(comp, constraint.rawValue)
  }
}
