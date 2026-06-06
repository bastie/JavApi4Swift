/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Arranges components in five regions — mirrors `java.awt.BorderLayout`.
  public final class BorderLayout: LayoutManager2 {

    public static let NORTH  = "North"
    public static let SOUTH  = "South"
    public static let EAST   = "East"
    public static let WEST   = "West"
    public static let CENTER = "Center"
    // Java 1.4 aliases
    public static let PAGE_START = "First"
    public static let PAGE_END   = "Last"
    public static let LINE_START = "Before"
    public static let LINE_END   = "After"

    public var hgap: Int
    public var vgap: Int

    private var north:  java.awt.Component?
    private var south:  java.awt.Component?
    private var east:   java.awt.Component?
    private var west:   java.awt.Component?
    private var center: java.awt.Component?

    public init(_ hgap: Int = 0, _ vgap: Int = 0) {
      self.hgap = hgap
      self.vgap = vgap
    }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ name: String, _ comp: java.awt.Component) {
      switch name {
      case BorderLayout.NORTH,  BorderLayout.PAGE_START: north  = comp
      case BorderLayout.SOUTH,  BorderLayout.PAGE_END:   south  = comp
      case BorderLayout.EAST,   BorderLayout.LINE_END:   east   = comp
      case BorderLayout.WEST,   BorderLayout.LINE_START:  west   = comp
      default:                                            center = comp
      }
    }

    public func removeLayoutComponent(_ comp: java.awt.Component) {
      if north  === comp { north  = nil }
      if south  === comp { south  = nil }
      if east   === comp { east   = nil }
      if west   === comp { west   = nil }
      if center === comp { center = nil }
    }

    public func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      // Ermittle die bevorzugte Größe aus den fünf Regionen.
      // NORTH/SOUTH bestimmen die Höhe; EAST/WEST bestimmen die Breite;
      // CENTER füllt den Rest — wir nehmen hier seine preferredSize als Minimum.
      func ps(_ c: java.awt.Component?) -> java.awt.Dimension {
        guard let c else { return java.awt.Dimension(0, 0) }
        let p = c.getPreferredSize()
        return java.awt.Dimension(
          p.width  > 0 ? p.width  : c.bounds.width,
          p.height > 0 ? p.height : c.bounds.height)
      }
      let n = ps(north), s = ps(south), e = ps(east), w = ps(west), ctr = ps(center)
      let totalH = n.height + s.height + vgap * (north != nil && south != nil ? 2 : north != nil || south != nil ? 1 : 0)
                 + Swift.max(e.height, w.height, ctr.height)
      let totalW = w.width + e.width + hgap * (west != nil && east != nil ? 2 : west != nil || east != nil ? 1 : 0)
                 + ctr.width
      return java.awt.Dimension(totalW, totalH)
    }

    public func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(0, 0)
    }

    public func layoutContainer(_ parent: java.awt.Container) {
      let b = parent.bounds
      var top    = b.y
      var bottom = b.y + b.height
      var left   = b.x
      var right  = b.x + b.width

      if let c = north {
        let ps = c.getPreferredSize()
        let h  = ps.height > 0 ? ps.height : c.bounds.height
        c.bounds = java.awt.Rectangle(left, top, right - left, h)
        top += h + vgap
      }
      if let c = south {
        let ps = c.getPreferredSize()
        let h  = ps.height > 0 ? ps.height : c.bounds.height
        c.bounds = java.awt.Rectangle(left, bottom - h, right - left, h)
        bottom -= h + vgap
      }
      if let c = east {
        let ps = c.getPreferredSize()
        let w  = ps.width > 0 ? ps.width : c.bounds.width
        c.bounds = java.awt.Rectangle(right - w, top, w, bottom - top)
        right -= w + hgap
      }
      if let c = west {
        let ps = c.getPreferredSize()
        let w  = ps.width > 0 ? ps.width : c.bounds.width
        c.bounds = java.awt.Rectangle(left, top, w, bottom - top)
        left += w + hgap
      }
      center?.bounds = java.awt.Rectangle(left, top, right - left, bottom - top)
    }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager2
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ comp: java.awt.Component, _ constraints: AnyObject?) {
      addLayoutComponent((constraints as? String) ?? BorderLayout.CENTER, comp)
    }

    public func maximumLayoutSize(_ target: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(Int.max, Int.max)
    }

    public func getLayoutAlignmentX(_ target: java.awt.Container) -> Double { 0.5 }
    public func getLayoutAlignmentY(_ target: java.awt.Container) -> Double { 0.5 }
    public func invalidateLayout(_ target: java.awt.Container) {}
  }
}
