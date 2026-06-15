/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - GridBagLayout
  // ---------------------------------------------------------------------------

  /// A flexible grid layout manager — mirrors `java.awt.GridBagLayout`.
  ///
  /// Matches Java's behaviour: extra container space is distributed proportionally
  /// to column/row weights; RELATIVE places a component after the previous one;
  /// REMAINDER makes a component consume all remaining columns/rows in its line.
  ///
  /// ```swift
  /// let layout = java.awt.GridBagLayout()
  /// let c = java.awt.GridBagConstraints()
  /// c.gridx = 0; c.gridy = 0; c.fill = java.awt.GridBagConstraints.HORIZONTAL
  /// layout.setConstraints(button, c)
  /// panel.setLayout(layout)
  /// panel.add(button)
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.0 / 1.1)
  @MainActor
  public class GridBagLayout: LayoutManager2 {

    // -------------------------------------------------------------------------
    // MARK: Constants
    // -------------------------------------------------------------------------

    public static let MAXGRIDSIZE    = 512
    public static let MINSIZE        = 1
    public static let PREFERREDSIZE  = 2

    // -------------------------------------------------------------------------
    // MARK: Internal state
    // -------------------------------------------------------------------------

    /// Maps each component to its constraints (defensive copies stored).
    private var constraintsMap: [ObjectWrapper: GridBagConstraints] = [:]

    /// Thin wrapper so Component (a class) can be used as Dictionary key.
    private struct ObjectWrapper: Hashable {
      let component: Component
      func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(component)) }
      static func == (l: Self, r: Self) -> Bool { l.component === r.component }
    }

    // -------------------------------------------------------------------------
    // MARK: Constructor
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Constraint management
    // -------------------------------------------------------------------------

    /// Associates constraints with a component.
    ///
    /// A defensive copy is stored so later mutations of `constraints` have no
    /// effect.
    public func setConstraints(_ comp: Component, _ constraints: GridBagConstraints) {
      constraintsMap[ObjectWrapper(component: comp)] = constraints.clone()
    }

    /// Returns a copy of the constraints for the given component.
    ///
    /// If no constraints have been set, default constraints are returned.
    public func getConstraints(_ comp: Component) -> GridBagConstraints {
      constraintsMap[ObjectWrapper(component: comp)]?.clone() ?? GridBagConstraints()
    }

    /// Returns the internal (live) constraints — Java API compatibility.
    /// Modifying the returned object directly affects future layouts.
    public func lookupConstraints(_ comp: Component) -> GridBagConstraints {
      if let c = constraintsMap[ObjectWrapper(component: comp)] { return c }
      let c = GridBagConstraints()
      constraintsMap[ObjectWrapper(component: comp)] = c
      return c
    }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ name: String, _ comp: Component) {}

    public func addLayoutComponent(_ comp: Component, _ constraints: AnyObject?) {
      if let gbc = constraints as? GridBagConstraints {
        setConstraints(comp, gbc)
      }
    }

    public func removeLayoutComponent(_ comp: Component) {
      constraintsMap.removeValue(forKey: ObjectWrapper(component: comp))
    }

    public func preferredLayoutSize(_ parent: Container) -> Dimension {
      let info = computeGridInfo(for: parent)
      let w = info.colWidths.reduce(0, +)
      let h = info.rowHeights.reduce(0, +)
      return Dimension(w, h)
    }

    public func minimumLayoutSize(_ parent: Container) -> Dimension {
      Dimension(0, 0)
    }

    public func maximumLayoutSize(_ parent: Container) -> Dimension {
      Dimension(Int.max, Int.max)
    }

    public func getLayoutAlignmentX(_ parent: Container) -> Double { 0.5 }
    public func getLayoutAlignmentY(_ parent: Container) -> Double { 0.5 }
    public func invalidateLayout(_ parent: Container) {}

    public func layoutContainer(_ parent: Container) {
      var info = computeGridInfo(for: parent)
      guard info.cols > 0, info.rows > 0 else { return }

      // Distribute extra container space proportionally to weights.
      let usedW = info.colWidths.reduce(0, +)
      let usedH = info.rowHeights.reduce(0, +)
      let extraW = max(0, parent.bounds.width  - usedW)
      let extraH = max(0, parent.bounds.height - usedH)
      distributeExtra(extraW, sizes: &info.colWidths, weights: info.colWeights)
      distributeExtra(extraH, sizes: &info.rowHeights, weights: info.rowWeights)

      // Build cumulative x/y offsets for each column/row origin.
      var colX = [Int](repeating: 0, count: info.cols)
      var rowY = [Int](repeating: 0, count: info.rows)
      for i in 1 ..< info.cols { colX[i] = colX[i-1] + info.colWidths[i-1] }
      for i in 1 ..< info.rows { rowY[i] = rowY[i-1] + info.rowHeights[i-1] }

      // Child bounds are in the parent's LOCAL coordinate space (origin = 0,0).
      let originX = 0
      let originY = 0

      let positions = resolvePositions(for: parent)

      for (i, comp) in parent.children.enumerated() {
        let c   = lookupConstraints(comp)
        let p   = positions[i]
        // resolvePositions already produced real spans; clamp to actual grid bounds.
        let gx  = max(0, min(p.gx, info.cols - 1))
        let gy  = max(0, min(p.gy, info.rows - 1))
        let gw  = max(1, min(p.gw, info.cols - gx))
        let gh  = max(1, min(p.gh, info.rows - gy))

        // Cell rectangle (spanning gridwidth × gridheight cells).
        let cellX = originX + colX[gx] + c.insets.left
        let cellY = originY + rowY[gy] + c.insets.top
        let endCol = min(gx + gw - 1, info.cols - 1)
        let endRow = min(gy + gh - 1, info.rows - 1)
        let cellW = (colX[endCol] + info.colWidths[endCol]) - colX[gx]
                    - c.insets.left - c.insets.right
        let cellH = (rowY[endRow] + info.rowHeights[endRow]) - rowY[gy]
                    - c.insets.top - c.insets.bottom

        let ps = comp.getPreferredSize()

        // Apply ipadx / ipady (internal padding added to preferred size).
        var compW = ps.width  + c.ipadx
        var compH = ps.height + c.ipady

        // Apply fill.
        switch c.fill {
        case GridBagConstraints.BOTH:
          compW = cellW; compH = cellH
        case GridBagConstraints.HORIZONTAL:
          compW = cellW
        case GridBagConstraints.VERTICAL:
          compH = cellH
        default:
          break
        }
        compW = max(1, compW)
        compH = max(1, compH)

        // Apply anchor.
        var x = cellX
        var y = cellY
        switch c.anchor {
        case GridBagConstraints.NORTH:
          x = cellX + (cellW - compW) / 2
        case GridBagConstraints.NORTHEAST:
          x = cellX + cellW - compW
        case GridBagConstraints.EAST:
          x = cellX + cellW - compW
          y = cellY + (cellH - compH) / 2
        case GridBagConstraints.SOUTHEAST:
          x = cellX + cellW - compW
          y = cellY + cellH - compH
        case GridBagConstraints.SOUTH:
          x = cellX + (cellW - compW) / 2
          y = cellY + cellH - compH
        case GridBagConstraints.SOUTHWEST:
          y = cellY + cellH - compH
        case GridBagConstraints.WEST:
          y = cellY + (cellH - compH) / 2
        case GridBagConstraints.NORTHWEST:
          break   // x = cellX, y = cellY already
        default:  // CENTER
          x = cellX + (cellW - compW) / 2
          y = cellY + (cellH - compH) / 2
        }

        comp.bounds = Rectangle(x, y, compW, compH)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Private — grid analysis
    // -------------------------------------------------------------------------

    private struct GridInfo {
      var cols:       Int
      var rows:       Int
      var colWidths:  [Int]
      var rowHeights: [Int]
      var colWeights: [Double]   // sum of weightx per column
      var rowWeights: [Double]   // sum of weighty per row
    }

    // -------------------------------------------------------------------------
    // MARK: Private — RELATIVE / REMAINDER resolution
    // -------------------------------------------------------------------------

    /// Resolves RELATIVE / REMAINDER gridx/gridy/gridwidth/gridheight values into
    /// concrete cell coordinates, returning an array parallel to `parent.children`.
    ///
    /// The returned `gw`/`gh` for REMAINDER components is the *actual* number of
    /// cells they span (clamped to the grid extent computed in a first pass),
    /// NOT the sentinel MAXGRIDSIZE value.  This keeps `layoutContainer` and
    /// `computeGridInfo` consistent — both see the same effective span.
    private func resolvePositions(for parent: Container) -> [(gx: Int, gy: Int, gw: Int, gh: Int)] {

      // ── Pass 1: resolve gx/gy and raw gw/gh (REMAINDER stored as sentinel) ──
      struct Raw { var gx, gy, gw, gh: Int; var gwIsRemainder, ghIsRemainder: Bool }
      var raws: [Raw] = []
      var cursorX = 0
      var cursorY = 0

      for comp in parent.children {
        let c = lookupConstraints(comp)

        // resolve gridx
        var gx: Int
        if c.gridx == GridBagConstraints.RELATIVE {
          gx = cursorX
        } else {
          gx = max(0, c.gridx)
          cursorX = gx
        }

        // resolve gridy — only use c.gridy to update cursorY when it is explicit
        var gy: Int
        if c.gridy == GridBagConstraints.RELATIVE {
          gy = cursorY
        } else {
          gy = max(0, c.gridy)
          cursorY = gy
        }

        // resolve gridwidth (raw)
        let gwRemainder = (c.gridwidth == GridBagConstraints.REMAINDER)
        let gw: Int
        if gwRemainder {
          gw = GridBagLayout.MAXGRIDSIZE   // sentinel — fixed in pass 2
        } else if c.gridwidth == GridBagConstraints.RELATIVE {
          gw = 1
        } else {
          gw = max(1, c.gridwidth)
        }

        // resolve gridheight (raw)
        let ghRemainder = (c.gridheight == GridBagConstraints.REMAINDER)
        let gh: Int
        if ghRemainder {
          gh = GridBagLayout.MAXGRIDSIZE   // sentinel — fixed in pass 2
        } else if c.gridheight == GridBagConstraints.RELATIVE {
          gh = 1
        } else {
          gh = max(1, c.gridheight)
        }

        raws.append(Raw(gx: gx, gy: gy, gw: gw, gh: gh,
                        gwIsRemainder: gwRemainder, ghIsRemainder: ghRemainder))

        // Advance cursor.
        // gridwidth=REMAINDER → this component ends the row; next starts at (0, gy+1).
        if gwRemainder {
          cursorX = 0
          cursorY = gy + 1
        } else {
          cursorX = gx + gw
        }
      }

      // ── Pass 2: compute grid extent, then fix up REMAINDER spans ──
      // Find the maximum explicit column/row to cap REMAINDER.
      var maxExplicitCol = 0
      var maxExplicitRow = 0
      for r in raws {
        if !r.gwIsRemainder { maxExplicitCol = max(maxExplicitCol, r.gx + r.gw) }
        if !r.ghIsRemainder { maxExplicitRow = max(maxExplicitRow, r.gy + r.gh) }
      }
      // If everything is REMAINDER, fall back to 1-cell grid.
      let gridCols = max(1, maxExplicitCol)
      let gridRows = max(1, maxExplicitRow)

      var result: [(gx: Int, gy: Int, gw: Int, gh: Int)] = []
      for r in raws {
        let gw = r.gwIsRemainder ? max(1, gridCols - r.gx) : r.gw
        let gh = r.ghIsRemainder ? max(1, gridRows - r.gy) : r.gh
        result.append((r.gx, r.gy, gw, gh))
      }
      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Private — grid analysis
    // -------------------------------------------------------------------------

    /// Analyses all constrained components to determine the grid dimensions,
    /// preferred column/row sizes, and weight vectors.
    private func computeGridInfo(for parent: Container) -> GridInfo {
      let positions = resolvePositions(for: parent)
      guard !positions.isEmpty else {
        return GridInfo(cols: 0, rows: 0, colWidths: [], rowHeights: [],
                        colWeights: [], rowWeights: [])
      }

      // resolvePositions already fixed up REMAINDER → p.gw/gh are real spans.
      var maxCol = 0
      var maxRow = 0
      for p in positions {
        maxCol = max(maxCol, p.gx + p.gw)
        maxRow = max(maxRow, p.gy + p.gh)
      }

      guard maxCol > 0, maxRow > 0 else {
        return GridInfo(cols: 0, rows: 0, colWidths: [], rowHeights: [],
                        colWeights: [], rowWeights: [])
      }

      var colWidths  = [Int](repeating: 0, count: maxCol)
      var rowHeights = [Int](repeating: 0, count: maxRow)
      var colWeights = [Double](repeating: 0.0, count: maxCol)
      var rowWeights = [Double](repeating: 0.0, count: maxRow)

      // Distribute preferred sizes and weights across spanned cells.
      for (i, comp) in parent.children.enumerated() {
        let c   = lookupConstraints(comp)
        let ps  = comp.getPreferredSize()
        let p   = positions[i]
        let gx  = p.gx
        let gy  = p.gy
        let effectiveGW = min(p.gw, maxCol - gx)
        let effectiveGH = min(p.gh, maxRow - gy)
        guard effectiveGW > 0, effectiveGH > 0 else { continue }

        // Width with ipadx
        let totalInsetH = c.insets.left + c.insets.right
        let neededW     = ps.width + c.ipadx + totalInsetH
        let perCol      = max(0, (neededW + effectiveGW - 1) / effectiveGW)
        for col in gx ..< gx + effectiveGW {
          colWidths[col] = max(colWidths[col], perCol)
        }

        // Height with ipady
        let totalInsetV = c.insets.top + c.insets.bottom
        let neededH     = ps.height + c.ipady + totalInsetV
        let perRow      = max(0, (neededH + effectiveGH - 1) / effectiveGH)
        for row in gy ..< gy + effectiveGH {
          rowHeights[row] = max(rowHeights[row], perRow)
        }

        // Weights — distribute evenly across spanned cells (Java behaviour)
        let wxPerCol = c.weightx / Double(effectiveGW)
        for col in gx ..< gx + effectiveGW {
          colWeights[col] = max(colWeights[col], wxPerCol)
        }
        let wyPerRow = c.weighty / Double(effectiveGH)
        for row in gy ..< gy + effectiveGH {
          rowWeights[row] = max(rowWeights[row], wyPerRow)
        }
      }

      return GridInfo(cols: maxCol, rows: maxRow,
                      colWidths: colWidths, rowHeights: rowHeights,
                      colWeights: colWeights, rowWeights: rowWeights)
    }

    // -------------------------------------------------------------------------
    // MARK: Private — extra-space distribution
    // -------------------------------------------------------------------------

    /// Distributes `extra` pixels proportionally among `sizes` according to
    /// `weights`. Columns/rows with weight 0 receive no extra space.
    private func distributeExtra(_ extra: Int,
                                 sizes: inout [Int],
                                 weights: [Double]) {
      guard extra > 0 else { return }
      let totalWeight = weights.reduce(0.0, +)
      guard totalWeight > 0.0 else { return }
      var remainder = extra
      for i in 0 ..< sizes.count {
        let share = Int((Double(extra) * weights[i] / totalWeight).rounded(.down))
        sizes[i]  += share
        remainder -= share
      }
      // Give leftover pixel to the highest-weight column/row.
      if remainder > 0,
         let idx = weights.indices.max(by: { weights[$0] < weights[$1] }) {
        sizes[idx] += remainder
      }
    }
  }
}

