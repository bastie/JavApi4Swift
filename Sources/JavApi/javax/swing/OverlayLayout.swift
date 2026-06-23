/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  // ---------------------------------------------------------------------------
  // MARK: - OverlayLayout
  // ---------------------------------------------------------------------------

  /// Stacks all components on top of each other, aligned via each component's
  /// `alignmentX` / `alignmentY` — mirrors `javax.swing.OverlayLayout`.
  ///
  /// Every child is given its preferred size and positioned so that its
  /// alignment point coincides with the shared alignment point of the container.
  /// The container's own preferred size is the smallest rectangle that can
  /// accommodate all children at their preferred sizes given their alignments.
  ///
  /// ### Alignment arithmetic
  ///
  /// For each axis separately:
  /// - `lead`  = max over all children of `preferredSize * alignmentFraction`
  /// - `trail` = max over all children of `preferredSize * (1 - alignmentFraction)`
  /// - container preferred extent = `lead + trail`
  /// - child origin = `lead - preferredSize * alignmentFraction`
  ///
  /// With the default `alignmentX = alignmentY = 0.5` (center) every child is
  /// simply centred in the container, which is the most common use-case.
  ///
  /// ```swift
  /// let overlay = javax.swing.JPanel()
  /// overlay.setLayout(javax.swing.OverlayLayout(overlay))
  /// overlay.add(background)   // painted first (bottom)
  /// overlay.add(foreground)   // painted on top
  /// ```
  ///
  /// > **AI hint:** `OverlayLayout` holds a *weak* reference to its target
  /// > container — the same pattern as `BoxLayout` — to avoid retain cycles.
  ///
  /// - Since: JavApi > 0.x (Java 1.2 / Swing 1.0)
  @MainActor
  public final class OverlayLayout: java.awt.LayoutManager {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private weak var target: java.awt.Container?

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates an `OverlayLayout` for the given container.
    ///
    /// - Parameter target: The container whose children will be overlaid.
    public init(_ target: java.awt.Container) {
      self.target = target
    }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ name: String, _ comp: java.awt.Component) {}
    public func removeLayoutComponent(_ comp: java.awt.Component) {}

    public func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      let children = parent.getComponents()
      guard !children.isEmpty else { return java.awt.Dimension(0, 0) }

      var leadX: Float = 0, trailX: Float = 0
      var leadY: Float = 0, trailY: Float = 0

      for child in children {
        let ps  = child.getPreferredSize()
        let ax  = child.getAlignmentX()
        let ay  = child.getAlignmentY()
        let pw  = Float(ps.width)
        let ph  = Float(ps.height)

        leadX  = max(leadX,  pw * ax)
        trailX = max(trailX, pw * (1.0 - ax))
        leadY  = max(leadY,  ph * ay)
        trailY = max(trailY, ph * (1.0 - ay))
      }

      return java.awt.Dimension(Int(leadX + trailX), Int(leadY + trailY))
    }

    public func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(0, 0)
    }

    public func layoutContainer(_ parent: java.awt.Container) {
      let children = parent.getComponents()
      guard !children.isEmpty else { return }

      // Determine the shared alignment anchor relative to container origin.
      var leadX: Float = 0, leadY: Float = 0
      for child in children {
        let ps = child.getPreferredSize()
        leadX = max(leadX, Float(ps.width)  * child.getAlignmentX())
        leadY = max(leadY, Float(ps.height) * child.getAlignmentY())
      }

      for child in children {
        let ps = child.getPreferredSize()
        let w  = ps.width  > 0 ? ps.width  : max(1, child.bounds.width)
        let h  = ps.height > 0 ? ps.height : max(1, child.bounds.height)
        let x  = Int(leadX - Float(w) * child.getAlignmentX())
        let y  = Int(leadY - Float(h) * child.getAlignmentY())
        child.bounds = java.awt.Rectangle(x, y, w, h)
      }
    }
  }
}
