/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  // ---------------------------------------------------------------------------
  // MARK: - SpringLayout
  // ---------------------------------------------------------------------------

  /// Constraint-based layout that positions each component's four edges using
  /// `Spring` values relative to another component's edges —
  /// mirrors `javax.swing.SpringLayout`.
  ///
  /// ### Concept
  ///
  /// Every edge of every component (including the container itself) can be
  /// anchored to any other edge via a spring.  The most common pattern is a
  /// simple form layout:
  ///
  /// ```swift
  /// let layout = javax.swing.SpringLayout()
  /// panel.setLayout(layout)
  ///
  /// panel.add(nameLabel)
  /// panel.add(nameField)
  ///
  /// // Pin nameLabel 8 px from the container's left/top edge
  /// layout.putConstraint(SpringLayout.WEST,  nameLabel, 8,  SpringLayout.WEST,  panel)
  /// layout.putConstraint(SpringLayout.NORTH, nameLabel, 8,  SpringLayout.NORTH, panel)
  ///
  /// // Pin nameField's left 8 px right of nameLabel; stretch to right margin
  /// layout.putConstraint(SpringLayout.WEST,  nameField, 8,  SpringLayout.EAST,  nameLabel)
  /// layout.putConstraint(SpringLayout.NORTH, nameField, 0,  SpringLayout.NORTH, nameLabel)
  /// layout.putConstraint(SpringLayout.EAST,  nameField, -8, SpringLayout.EAST,  panel)
  /// ```
  ///
  /// > **AI hint:** Constraints are stored lazily and resolved at layout time,
  /// > so `putConstraint` may be called before the container has a size.
  /// > Negative `pad` values are valid (e.g. `-8` from the right edge).
  ///
  /// - Since: JavApi > 0.x (Java 1.4)
  @MainActor
  public final class SpringLayout: java.awt.LayoutManager2 {

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Edge name constants
    // -------------------------------------------------------------------------

    public static let NORTH = "North"
    public static let SOUTH = "South"
    public static let EAST  = "East"
    public static let WEST  = "West"

    // -------------------------------------------------------------------------
    // MARK: Lazy anchor record
    // -------------------------------------------------------------------------

    /// A stored constraint: resolve `anchorEdge` of `anchorComp` at layout time,
    /// then add `pad`.
    private struct Anchor {
      let anchorComp: java.awt.Component
      let anchorEdge: String
      let pad:        Int
    }

    // -------------------------------------------------------------------------
    // MARK: Constraints inner class
    // -------------------------------------------------------------------------

    /// Holds the four edge anchors for one component.
    @MainActor
    public final class Constraints {

      public static let NORTH = SpringLayout.NORTH
      public static let SOUTH = SpringLayout.SOUTH
      public static let EAST  = SpringLayout.EAST
      public static let WEST  = SpringLayout.WEST

      // Springs for direct API (getConstraint / setConstraint)
      var north: Spring? = nil
      var south: Spring? = nil
      var east:  Spring? = nil
      var west:  Spring? = nil

      public init() {}

      public func setConstraint(_ edgeName: String, _ s: Spring) {
        switch edgeName {
        case Constraints.NORTH: north = s
        case Constraints.SOUTH: south = s
        case Constraints.EAST:  east  = s
        case Constraints.WEST:  west  = s
        default: break
        }
      }

      public func getConstraint(_ edgeName: String) -> Spring? {
        switch edgeName {
        case Constraints.NORTH: return north
        case Constraints.SOUTH: return south
        case Constraints.EAST:  return east
        case Constraints.WEST:  return west
        default: return nil
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var constraintMap: [ObjectIdentifier: Constraints] = [:]

    /// Lazy anchors: (constrained component id, edge) → Anchor
    private var anchorMap: [ObjectIdentifier: [String: Anchor]] = [:]

    // -------------------------------------------------------------------------
    // MARK: Public API
    // -------------------------------------------------------------------------

    public func getConstraints(_ comp: java.awt.Component) -> Constraints {
      let key = ObjectIdentifier(comp)
      if let c = constraintMap[key] { return c }
      let c = Constraints()
      constraintMap[key] = c
      return c
    }

    /// Pins `edge1` of `comp1` to `edge2` of `comp2` + `pad` pixels.
    /// The anchor is stored lazily and resolved when `layoutContainer` runs.
    public func putConstraint(
      _ edge1: String,
      _ comp1: java.awt.Component,
      _ pad:   Int,
      _ edge2: String,
      _ comp2: java.awt.Component
    ) {
      let key = ObjectIdentifier(comp1)
      if anchorMap[key] == nil { anchorMap[key] = [:] }
      anchorMap[key]![edge1] = Anchor(anchorComp: comp2, anchorEdge: edge2, pad: pad)
    }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ name: String, _ comp: java.awt.Component) {}
    public func removeLayoutComponent(_ comp: java.awt.Component) {
      let key = ObjectIdentifier(comp)
      constraintMap.removeValue(forKey: key)
      anchorMap.removeValue(forKey: key)
    }

    public func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      var maxX = 0, maxY = 0
      for child in parent.getComponents() {
        let ps = child.getPreferredSize()
        let x  = resolvedValue(of: SpringLayout.WEST,  for: child, in: parent) ?? 0
        let y  = resolvedValue(of: SpringLayout.NORTH, for: child, in: parent) ?? 0
        maxX = Swift.max(maxX, x + ps.width)
        maxY = Swift.max(maxY, y + ps.height)
      }
      return java.awt.Dimension(maxX, maxY)
    }

    public func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(0, 0)
    }

    public func layoutContainer(_ parent: java.awt.Container) {
      for child in parent.getComponents() {
        let ps = child.getPreferredSize()
        let w0 = ps.width  > 0 ? ps.width  : Swift.max(1, child.bounds.width)
        let h0 = ps.height > 0 ? ps.height : Swift.max(1, child.bounds.height)

        // ── Horizontal ───────────────────────────────────────────────────────
        let westVal = resolvedValue(of: SpringLayout.WEST, for: child, in: parent)
        let eastVal = resolvedValue(of: SpringLayout.EAST, for: child, in: parent)

        let x: Int
        let w: Int
        switch (westVal, eastVal) {
        case let (wv?, ev?):
          x = wv
          w = Swift.max(0, ev - wv)
        case let (wv?, nil):
          x = wv
          w = w0
        case let (nil, ev?):
          x = ev - w0
          w = w0
        default:
          x = 0
          w = w0
        }

        // ── Vertical ─────────────────────────────────────────────────────────
        let northVal = resolvedValue(of: SpringLayout.NORTH, for: child, in: parent)
        let southVal = resolvedValue(of: SpringLayout.SOUTH, for: child, in: parent)

        let y: Int
        let h: Int
        switch (northVal, southVal) {
        case let (nv?, sv?):
          y = nv
          h = Swift.max(0, sv - nv)
        case let (nv?, nil):
          y = nv
          h = h0
        case let (nil, sv?):
          y = sv - h0
          h = h0
        default:
          y = 0
          h = h0
        }

        child.bounds = java.awt.Rectangle(x, y, w, h)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager2
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ comp: java.awt.Component, _ constraints: AnyObject?) {
      if let c = constraints as? Constraints {
        constraintMap[ObjectIdentifier(comp)] = c
      }
    }

    public func maximumLayoutSize(_ target: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(Int.max, Int.max)
    }

    public func getLayoutAlignmentX(_ target: java.awt.Container) -> Double { 0.5 }
    public func getLayoutAlignmentY(_ target: java.awt.Container) -> Double { 0.5 }

    public func invalidateLayout(_ target: java.awt.Container) {}

    // -------------------------------------------------------------------------
    // MARK: Helpers
    // -------------------------------------------------------------------------

    /// Lazily resolve the pixel value of `edge` for `comp` inside `parent`.
    /// Returns nil if no constraint was registered for that edge.
    private func resolvedValue(
      of edge: String,
      for comp: java.awt.Component,
      in parent: java.awt.Container
    ) -> Int? {
      let key = ObjectIdentifier(comp)

      // 1. Lazy anchor takes precedence
      if let anchor = anchorMap[key]?[edge] {
        return resolveEdgeOf(anchor.anchorComp, edge: anchor.anchorEdge, parent: parent)
               + anchor.pad
      }

      // 2. Fall back to direct Spring on Constraints
      if let spring = constraintMap[key]?.getConstraint(edge) {
        return spring.getValue()
      }

      return nil
    }

    /// Returns the pixel position of `edge` on `comp`, using the container's
    /// current bounds for the parent and stored constraints for children.
    private func resolveEdgeOf(
      _ comp: java.awt.Component,
      edge: String,
      parent: java.awt.Container
    ) -> Int {
      // The parent container's edges are always 0 / containerW / containerH.
      if comp === parent {
        switch edge {
        case SpringLayout.NORTH: return 0
        case SpringLayout.WEST:  return 0
        case SpringLayout.SOUTH: return parent.bounds.height
        case SpringLayout.EAST:  return parent.bounds.width
        default:                  return 0
        }
      }
      // For other components use current bounds (set by a prior layout pass
      // or by the component itself).
      switch edge {
      case SpringLayout.NORTH: return comp.bounds.y
      case SpringLayout.SOUTH: return comp.bounds.y + comp.bounds.height
      case SpringLayout.WEST:  return comp.bounds.x
      case SpringLayout.EAST:  return comp.bounds.x + comp.bounds.width
      default:                  return 0
      }
    }
  }
}
