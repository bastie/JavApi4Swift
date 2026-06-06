/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Arranges components left-to-right, wrapping to next row — mirrors `java.awt.FlowLayout`.
  public final class FlowLayout: LayoutManager {

    public static let LEFT    = 0
    public static let CENTER  = 1
    public static let RIGHT   = 2
    public static let LEADING = 3
    public static let TRAILING = 4

    private var alignment: Int = FlowLayout.CENTER
    private var hgap: Int = 5
    private var vgap: Int = 5

    /// Constructs new ``FlowLayout``. The default alignment is center and horizontal and vertical gap of five.
    ///
    /// - Parameters:
    ///   - alignment FlowLayout.CENTER (default) or LEFT, RIGHT, LEADING, TRAILING
    ///   - hgap horizontal gap with default value 5
    ///   - vgap vertical gap with default value 5
    public init(_ alignment: Int = FlowLayout.CENTER, _ hgap: Int = 5, _ vgap: Int = 5) {
      var _alignment = alignment
      if _alignment < 0 || _alignment > 4 {
        _alignment = java.awt.FlowLayout.CENTER
      }
      let _hgap = hgap >= 0 ? hgap : 5
      let _vgap = vgap >= 0 ? vgap : 5
      self.alignment = _alignment
      self.hgap      = _hgap
      self.vgap      = _vgap
    }

    public func addLayoutComponent(_ name: String, _ comp: java.awt.Component) {}
    
    public func removeLayoutComponent(_ comp: java.awt.Component) {}

    public func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(parent.bounds.width, parent.bounds.height)
    }

    public func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(0, 0)
    }
    
    public func getAlignment () -> Int {
      return self.alignment
    }
    public func setAlignment (_ alignment: Int) {
      var _alignment = alignment
      if _alignment < 0 || _alignment > 4 {
        _alignment = java.awt.FlowLayout.CENTER
      }
      self.alignment = _alignment
    }
    public func getHgap () -> Int {
      return self.hgap
    }
    public func getVgap () -> Int {
      return self.vgap
    }
    public func setVgap (_ vgap: Int) {
      guard vgap >= 0 else { return }
      self.vgap = vgap
    }
    public func setHgap (_ hgap: Int) {
      guard hgap >= 0 else { return }
      self.hgap = hgap
    }

    public func layoutContainer(_ parent: java.awt.Container) {
      guard !parent.children.isEmpty else { return }
      var x = parent.bounds.x + hgap
      var y = parent.bounds.y + vgap
      var rowHeight = 0

      for comp in parent.children {
        let ps = comp.getPreferredSize()
        let w  = ps.width  > 0 ? ps.width  : comp.bounds.width
        let h  = ps.height > 0 ? ps.height : comp.bounds.height
        if x + w > parent.bounds.x + parent.bounds.width && x > parent.bounds.x + hgap {
          x = parent.bounds.x + hgap
          y += rowHeight + vgap
          rowHeight = 0
        }
        comp.bounds = java.awt.Rectangle(x, y, w, h)
        x += w + hgap
        rowHeight = max(rowHeight, h)
      }
    }
  }
}
