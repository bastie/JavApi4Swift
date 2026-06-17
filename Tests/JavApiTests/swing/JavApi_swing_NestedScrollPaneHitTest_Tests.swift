/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

/// Regression tests for the horizontal scrollbar of a `JTable` that lives inside
/// a `JScrollPane` nested in a `JSplitPane` inside a `JTabbedPane`.
///
/// Bug: the hit-test lost its Swing awareness while descending through the plain
/// AWT container recursion, so a click on the (correctly painted) horizontal
/// scrollbar never reached the Swing-specific handling — the bar was visible but
/// non-functional.  The fix re-enters `_SwingHitTest` for nested children via a
/// recursion hook installed into `_AWTHitTest`.
@MainActor
@Suite("javax.swing nested JScrollPane horizontal scrollbar")
struct JavApi_swing_NestedScrollPaneHitTest_Tests {

  /// Builds the master/detail tree used by the showcase, with explicit bounds
  /// that mirror a real layout: the table (380px wide) is wider than its
  /// viewport, so a horizontal scrollbar is required.
  private func makeTree() -> (
    tabbed: javax.swing.JTabbedPane,
    split:  javax.swing.JSplitPane,
    scroll: javax.swing.JScrollPane,
    table:  javax.swing.JTable
  ) {
    // ── Detail table — total column width 150+60+70+100 = 380 ────────────────
    let model = javax.swing.table.DefaultTableModel(
      [
        ["Main.swift", "Swift", "2.1 KB", "2026-06-01"],
        ["Info.plist", "XML",   "800 B",  "2026-04-10"],
      ],
      columnNames: ["Name", "Type", "Size", "Modified"])
    let table = javax.swing.JTable(model)
    table.setAutoResizeMode(javax.swing.JTable.AUTO_RESIZE_OFF)
    table.setColumnWidth(0, 150)
    table.setColumnWidth(1, 60)
    table.setColumnWidth(2, 70)
    table.setColumnWidth(3, 100)

    let scroll = javax.swing.JScrollPane(
      table,
      javax.swing.JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,
      javax.swing.JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED)

    let left  = javax.swing.JScrollPane(javax.swing.JTree(
      javax.swing.tree.DefaultMutableTreeNode("Projekt")))

    let split = javax.swing.JSplitPane(
      javax.swing.JSplitPane.HORIZONTAL_SPLIT, left, scroll)

    let tabbed = javax.swing.JTabbedPane()
    tabbed.addTab("Split", split)
    tabbed.setSelectedIndex(0)

    // ── Lay everything out so the viewport is narrower than the table ────────
    // Tab content area occupies the lower part of the tabbed pane.
    let contentY = 30
    tabbed.setBounds(0, 0, 400, 230)
    split.setBounds(0, contentY, 400, 200)   // triggers JSplitPane.doLayout()
    // After the split lays out, the right scroll pane is ~ (208, 0, 192, 200)
    // inside the split.  Force a narrow viewport so 380 > viewport width.
    scroll.setBounds(208, 0, 192, 200)       // triggers JScrollPane.doLayout()

    return (tabbed, split, scroll, table)
  }

  // ---------------------------------------------------------------------------

  @Test("JTable reports its own preferred width from the column widths")
  func tablePreferredWidth() {
    let t = makeTree()
    #expect(t.table.getPreferredSize().width == 380)
    #expect(t.table.getTotalColumnWidth() == 380)
  }

  @Test("Horizontal scrollbar becomes visible when the table is too wide")
  func horizontalBarVisible() {
    let t = makeTree()
    // Viewport (192) minus a possible vertical bar is < 380 → bar required.
    #expect(t.scroll.showHBarPublic)
    let hbar = t.scroll.getHorizontalScrollBar()
    #expect(hbar.visible)
    // Range must cover the full table width so dragging can reveal column 4.
    #expect(hbar.getMaximum() >= 380)
  }

  @Test("Click on the nested horizontal scrollbar resolves to the JScrollBar")
  func clickReachesScrollBar() {
    let t = makeTree()
    let hbar = t.scroll.getHorizontalScrollBar()
    #expect(hbar.visible)

    // hbar bounds are relative to the JScrollPane; compute its frame-absolute
    // centre and hit-test from the top of the tree.
    let origin = _SwingHitTest.absoluteOrigin(hbar)
    let cx = origin.x + hbar.bounds.width  / 2
    let cy = origin.y + hbar.bounds.height / 2

    let hit = _SwingHitTest.find(x: cx, y: cy, in: t.tabbed)
    #expect(hit === hbar,
            "Expected the nested horizontal JScrollBar to be hit, got \(String(describing: hit))")
  }

  @Test("Adjusting the horizontal scrollbar scrolls the viewport")
  func scrollbarScrollsViewport() {
    let t = makeTree()
    let hbar = t.scroll.getHorizontalScrollBar()
    let viewport = t.scroll.getViewport()

    #expect(viewport.getViewPosition().x == 0)
    // Simulate the user dragging the thumb to the far right.
    hbar.setValue(hbar.getMaximum())
    #expect(viewport.getViewPosition().x > 0,
            "Viewport did not scroll horizontally after the scrollbar value changed")
  }

  // ---------------------------------------------------------------------------
  // MARK: Orientation constants (self-reference regression)
  // ---------------------------------------------------------------------------

  @Test("JScrollBar orientation constants are distinct (HORIZONTAL=0, VERTICAL=1)")
  func scrollBarConstants() {
    #expect(javax.swing.JScrollBar.HORIZONTAL == 0)
    #expect(javax.swing.JScrollBar.VERTICAL   == 1)
    #expect(javax.swing.JScrollBar.HORIZONTAL != javax.swing.JScrollBar.VERTICAL)
  }

  @Test("JSeparator orientation constants are distinct (HORIZONTAL=0, VERTICAL=1)")
  func separatorConstants() {
    #expect(javax.swing.JSeparator.HORIZONTAL == 0)
    #expect(javax.swing.JSeparator.VERTICAL   == 1)
    #expect(javax.swing.JSeparator.HORIZONTAL != javax.swing.JSeparator.VERTICAL)
  }

  @Test("A horizontal JScrollBar reports horizontal orientation and geometry")
  func horizontalScrollBarGeometryIsHorizontal() {
    let bar = javax.swing.JScrollBar(javax.swing.JScrollBar.HORIZONTAL)
    #expect(bar.getOrientation() == javax.swing.JScrollBar.HORIZONTAL)

    // Wide-and-short bounds, as a horizontal scrollbar gets from JScrollPane.
    bar.setBounds(0, 0, 200, 16)
    bar.setMinimum(0)
    bar.setMaximum(400)
    bar.setVisibleAmount(200)
    bar.setValue(0)

    // For a horizontal bar the thumb must be wider than it is tall — if the
    // orientation were wrong (vertical geometry) the thumb would fill the width
    // and be only a few pixels tall, i.e. height >= width.
    let thumb = bar.thumbRect()
    #expect(thumb.width > thumb.height,
            "Horizontal scrollbar thumb has vertical geometry: \(thumb)")

    // The increment button must sit on the right edge, not the bottom.
    let inc = bar.incrementButtonRect()
    #expect(inc.x > 0, "Increment button is not on the right edge: \(inc)")
    #expect(inc.y == 0, "Increment button has vertical placement: \(inc)")
  }
}
