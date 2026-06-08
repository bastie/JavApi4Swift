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

      let containerX = parent.bounds.x
      let containerW = parent.bounds.width
      var y = parent.bounds.y + vgap

      // Collect components into rows, then apply alignment offset per row.
      // A "row" is the sequence of components that fit on one line.
      struct RowEntry { var comp: java.awt.Component; var w, h: Int }
      var rowEntries: [RowEntry] = []
      var rowW = 0   // accumulated width of current row (including hgaps)

      func flushRow(_ entries: [RowEntry], rowHeight: Int) {
        guard !entries.isEmpty else { return }
        let totalW = entries.reduce(0) { $0 + $1.w } + hgap * (entries.count - 1)
        let effectiveAlignment = (alignment == FlowLayout.LEADING)  ? FlowLayout.LEFT
                               : (alignment == FlowLayout.TRAILING) ? FlowLayout.RIGHT
                               : alignment
        let startX: Int
        switch effectiveAlignment {
        case FlowLayout.LEFT:
          startX = containerX + hgap
        case FlowLayout.RIGHT:
          startX = containerX + containerW - totalW - hgap
        default: // CENTER
          startX = containerX + (containerW - totalW) / 2
        }
        var cx = startX
        for entry in entries {
          // Vertically centre within the row height
          let cy = y + (rowHeight - entry.h) / 2
          entry.comp.bounds = java.awt.Rectangle(cx, cy, entry.w, entry.h)
          cx += entry.w + hgap
        }
        y += rowHeight + vgap
      }

      var rowHeight = 0
      for comp in parent.children {
        let ps = comp.getPreferredSize()
        let w  = ps.width  > 0 ? ps.width  : max(1, comp.bounds.width)
        let h  = ps.height > 0 ? ps.height : max(1, comp.bounds.height)

        // Would adding this component exceed the container width?
        let addedW = rowEntries.isEmpty ? w : rowW + hgap + w
        if !rowEntries.isEmpty && containerX + hgap + addedW + hgap > containerX + containerW {
          flushRow(rowEntries, rowHeight: rowHeight)
          rowEntries  = []
          rowW        = 0
          rowHeight   = 0
        }
        rowEntries.append(RowEntry(comp: comp, w: w, h: h))
        rowW      = rowEntries.isEmpty ? w : rowW + (rowEntries.count > 1 ? hgap : 0) + w
        rowHeight = max(rowHeight, h)
      }
      flushRow(rowEntries, rowHeight: rowHeight)
    }
  }
}
