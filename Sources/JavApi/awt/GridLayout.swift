/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - GridLayout
  // ---------------------------------------------------------------------------

  /// Lays components out in a rectangular grid — mirrors `java.awt.GridLayout`.
  ///
  /// Components are placed left-to-right, top-to-bottom. All cells have the
  /// same size. Either `rows` or `cols` (but not both) may be zero to indicate
  /// "as many as needed":
  ///
  /// - `GridLayout(0, 3)` — unlimited rows, exactly 3 columns.
  /// - `GridLayout(2, 0)` — exactly 2 rows, as many columns as needed.
  /// - `GridLayout(2, 3)` — fixed 2×3 grid; `cols` wins when both are nonzero.
  ///
  /// ```swift
  /// let panel = java.awt.Panel(java.awt.GridLayout(2, 3, 4, 4))
  /// for i in 1...6 { panel.add(java.awt.Button("B\(i)")) }
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.0)
  public final class GridLayout: LayoutManager {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    private var rows: Int
    private var cols: Int
    private var hgap: Int
    private var vgap: Int

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a `GridLayout` with the specified number of rows and columns.
    ///
    /// - Parameters:
    ///   - rows: Number of rows (0 = unlimited).
    ///   - cols: Number of columns (0 = unlimited).
    ///   - hgap: Horizontal gap between cells in pixels.
    ///   - vgap: Vertical gap between cells in pixels.
    public init(_ rows: Int = 1, _ cols: Int = 0,
                _ hgap: Int = 0, _ vgap: Int = 0) {
      precondition(rows >= 0 && cols >= 0,
                   "GridLayout: rows and cols must be >= 0")
      precondition(rows != 0 || cols != 0,
                   "GridLayout: rows and cols cannot both be 0")
      self.rows = rows
      self.cols = cols
      self.hgap = max(0, hgap)
      self.vgap = max(0, vgap)
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getRows() -> Int { rows }
    public func getCols() -> Int { cols }
    public func getHgap() -> Int { hgap }
    public func getVgap() -> Int { vgap }

    public func setRows(_ r: Int) { precondition(r >= 0); rows = r }
    public func setCols(_ c: Int) { precondition(c >= 0); cols = c }
    public func setHgap(_ h: Int) { hgap = max(0, h) }
    public func setVgap(_ v: Int) { vgap = max(0, v) }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ name: String, _ comp: java.awt.Component) {}
    public func removeLayoutComponent(_ comp: java.awt.Component) {}

    public func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      let (r, c) = effectiveRowsCols(count: parent.children.count)
      guard r > 0, c > 0 else { return java.awt.Dimension(0, 0) }
      var maxW = 0, maxH = 0
      for child in parent.children {
        let ps = child.getPreferredSize()
        maxW = max(maxW, ps.width  > 0 ? ps.width  : child.bounds.width)
        maxH = max(maxH, ps.height > 0 ? ps.height : child.bounds.height)
      }
      let w = c * maxW + (c - 1) * hgap
      let h = r * maxH + (r - 1) * vgap
      return java.awt.Dimension(w, h)
    }

    public func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(0, 0)
    }

    public func layoutContainer(_ parent: java.awt.Container) {
      let children = parent.children
      guard !children.isEmpty else { return }

      let (r, c) = effectiveRowsCols(count: children.count)
      guard r > 0, c > 0 else { return }

      let availW = parent.bounds.width  - (c - 1) * hgap
      let availH = parent.bounds.height - (r - 1) * vgap
      let cellW  = availW / c
      let cellH  = availH / r

      for (i, child) in children.enumerated() {
        let row = i / c
        let col = i % c
        let x = parent.bounds.x + col * (cellW + hgap)
        let y = parent.bounds.y + row * (cellH + vgap)
        child.bounds = java.awt.Rectangle(x, y, cellW, cellH)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Helpers
    // -------------------------------------------------------------------------

    /// Resolves the effective (rows, cols) pair from the count of children.
    private func effectiveRowsCols(count: Int) -> (Int, Int) {
      guard count > 0 else { return (0, 0) }
      if cols != 0 {
        // columns fixed → compute rows
        let r = (count + cols - 1) / cols
        return (r, cols)
      } else {
        // rows fixed → compute columns
        let c = (count + rows - 1) / rows
        return (rows, c)
      }
    }
  }
}
