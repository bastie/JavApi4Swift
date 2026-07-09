/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JToolBar`.
  ///
  /// Handles preferred-size calculation, child layout, painting, and
  /// floatable drag-out behaviour.
  ///
  /// ## Floatable drag-out
  ///
  /// When `JToolBar.isFloatable()` is `true` (the default), dragging the
  /// toolbar body detaches it from its parent container and shows it in a
  /// borderless `JDialog`.  Releasing the mouse leaves the toolbar floating.
  /// Re-docking (dropping onto a `BorderLayout` docking zone) is not yet
  /// implemented.
  ///
  @MainActor
  open class BasicToolBarUI: javax.swing.plaf.ComponentUI {

    private let pad = 4

    // -------------------------------------------------------------------------
    // MARK: Drag handler
    // -------------------------------------------------------------------------

    private var _dragHandler: _ToolBarDragHandler?

    // -------------------------------------------------------------------------
    // MARK: Install / uninstall
    // -------------------------------------------------------------------------

    override open func installUI(_ c: javax.swing.JComponent) {
      guard let tb = c as? javax.swing.JToolBar else { return }
      let h = _ToolBarDragHandler(toolbar: tb)
      _dragHandler = h
      tb.addMouseListener(h)
      tb.addMouseMotionListener(h)
    }

    override open func uninstallUI(_ c: javax.swing.JComponent) {
      if let h = _dragHandler {
        c.removeMouseListener(h)
        c.removeMouseMotionListener(h)
      }
      _dragHandler = nil
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let toolbar = component as? javax.swing.JToolBar else { return nil }
      let items = toolbar.getItems()
      let isHorizontal = toolbar.getOrientation() == javax.swing.JToolBar.HORIZONTAL

      var totalW = pad, totalH = pad, maxH = 0, maxW = 0
      for item in items {
        let ps = item.getPreferredSize()
        if isHorizontal {
          totalW += ps.width + pad
          maxH = Swift.max(maxH, ps.height)
        } else {
          totalH += ps.height + pad
          maxW = Swift.max(maxW, ps.width)
        }
      }
      if isHorizontal {
        return java.awt.Dimension(totalW, maxH + pad * 2)
      } else {
        return java.awt.Dimension(maxW + pad * 2, totalH)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Layout
    // -------------------------------------------------------------------------

    /// Positions all toolbar children within the toolbar's current bounds.
    private func layoutItems(of toolbar: javax.swing.JToolBar) {
      let items = toolbar.getItems()
      let b = toolbar.getBounds()
      let isHorizontal = toolbar.getOrientation() == javax.swing.JToolBar.HORIZONTAL

      if isHorizontal {
        var x = pad
        let y = pad
        let h = Swift.max(b.height - pad * 2, 1)
        for item in items {
          let w = item.getPreferredSize().width
          item.bounds = java.awt.Rectangle(x, y, w, h)
          x += w + pad
        }
      } else {
        let x = pad
        var y = pad
        let w = Swift.max(b.width - pad * 2, 1)
        for item in items {
          let h = item.getPreferredSize().height
          item.bounds = java.awt.Rectangle(x, y, w, h)
          y += h + pad
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let toolbar = component as? javax.swing.JToolBar else { return }
      let b = toolbar.getBounds()
      let w = b.width
      let h = b.height

      // Background
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(0, 0, w, h)

      // Bottom border line (horizontal) / right border line (vertical)
      g.setColor(java.awt.SystemColor.controlShadow)
      if toolbar.getOrientation() == javax.swing.JToolBar.HORIZONTAL {
        g.drawLine(0, h - 1, w - 1, h - 1)
      } else {
        g.drawLine(w - 1, 0, w - 1, h - 1)
      }

      // Layout children, then paint them
      layoutItems(of: toolbar)

      for item in toolbar.getItems() {
        guard item.isVisible() else { continue }
        let dx = item.bounds.x
        let dy = item.bounds.y
        g.translate(dx, dy)
        item.paint(g)
        g.translate(-dx, -dy)
      }
    }
  }
}

// MARK: - Toolbar drag handler

/// Handles floatable drag-out for `JToolBar`.
///
/// On a drag exceeding 10 px the toolbar is detached from its parent
/// container and shown in an undecorated `JDialog`.  The dialog remains open
/// when the mouse is released (re-docking to `BorderLayout` zones is not yet
/// implemented).
///
/// Registered by `BasicToolBarUI.installUI(_:)` as both a `MouseListener`
/// and a `MouseMotionListener`.
@MainActor
private final class _ToolBarDragHandler:
  java.awt.event.MouseAdapter,
  java.awt.event.MouseMotionListener,
  @unchecked Sendable
{

  private weak var toolbar: javax.swing.JToolBar?

  /// Component-coordinate point where the drag started.
  private var dragOrigin: java.awt.Point? = nil

  /// Container the toolbar was removed from when it floated out.
  private weak var savedParent: java.awt.Container?

  /// BorderLayout constraint under which the toolbar will be re-docked
  /// (derived from orientation at drag time).
  private var savedConstraint: String = java.awt.BorderLayout.NORTH

  /// The floating dialog shown while the toolbar is detached, if any.
  private var floatingDialog: javax.swing.JDialog? = nil

  init(toolbar: javax.swing.JToolBar) {
    self.toolbar = toolbar
  }

  // MARK: MouseListener

  override func mousePressed(_ e: java.awt.event.MouseEvent) {
    guard let tb = toolbar, tb.isFloatable() else { return }
    dragOrigin    = java.awt.Point(e.getX(), e.getY())
    savedParent   = tb.getParent()
    // Default docking constraint derived from current orientation
    savedConstraint = tb.getOrientation() == javax.swing.JToolBar.HORIZONTAL
      ? java.awt.BorderLayout.NORTH
      : java.awt.BorderLayout.WEST
  }

  override func mouseReleased(_ e: java.awt.event.MouseEvent) {
    dragOrigin = nil
    guard let dialog = floatingDialog, let tb = toolbar else { return }

    // Compute approximate screen position of the mouse when released.
    // dialog.bounds.x/y holds the screen position set via setLocation().
    // e.getX()/getY() are in toolbar coordinates (the toolbar fills the dialog).
    let mouseScreenX = dialog.bounds.x + e.getX()
    let mouseScreenY = dialog.bounds.y + e.getY()

    if let parent = savedParent, isNearDockingZone(mouseScreenX, mouseScreenY, parent: parent) {
      // Re-dock: move toolbar back into its original parent container
      dialog.remove(tb)
      floatingDialog = nil
      dialog.dispose()
      parent.add(tb, savedConstraint)
      parent.validate()
      parent.repaint()
    }
    // Otherwise the floating dialog stays open (toolbar remains detached)
  }

  /// Returns `true` when the given screen point is within the parent
  /// container's screen bounds (+ a 30-px docking margin on every side).
  private func isNearDockingZone(_ screenX: Int, _ screenY: Int,
                                  parent: java.awt.Container) -> Bool {
    // Compute parent's approximate screen position
    var px = 0, py = 0
    var walk: java.awt.Component? = parent
    while let c = walk {
      px   += c.getX()
      py   += c.getY()
      walk  = (c is java.awt.Window) ? nil : c.getParent()
    }
    let margin = 30
    return screenX >= px - margin && screenX <= px + parent.getWidth()  + margin
        && screenY >= py - margin && screenY <= py + parent.getHeight() + margin
  }

  // MARK: MouseMotionListener

  func mouseDragged(_ e: java.awt.event.MouseEvent) {
    guard let tb = toolbar,
          tb.isFloatable(),
          let origin = dragOrigin,
          floatingDialog == nil else { return }
    let dx = e.getX() - origin.x
    let dy = e.getY() - origin.y
    // Float out once the drag exceeds 10 px
    guard dx * dx + dy * dy > 100 else { return }
    floatOut(toolbar: tb, dragOffsetX: origin.x, dragOffsetY: origin.y)
  }

  func mouseMoved(_ e: java.awt.event.MouseEvent) {}

  // MARK: Float out

  private func floatOut(toolbar tb: javax.swing.JToolBar,
                        dragOffsetX: Int, dragOffsetY: Int) {
    guard let parent = savedParent else { return }

    // Compute approximate screen position by walking up the component hierarchy.
    // Each component's x/y is relative to its parent; a Window's x/y is the
    // screen position (the toolkit stores it that way).
    var screenX = 0, screenY = 0
    var walkComp: java.awt.Component? = tb
    while let c = walkComp {
      screenX  += c.getX()
      screenY  += c.getY()
      walkComp  = (c is java.awt.Window) ? nil : c.getParent()
    }

    // Detach toolbar from its current parent
    parent.remove(tb)
    parent.validate()
    parent.repaint()

    // Find nearest Frame ancestor to use as dialog owner (may be nil)
    var ownerFrame: java.awt.Frame? = nil
    var walkOwner: java.awt.Component? = parent
    while let c = walkOwner {
      if let f = c as? java.awt.Frame { ownerFrame = f; break }
      walkOwner = c.getParent()
    }

    // Create undecorated floating dialog
    let dialog = javax.swing.JDialog(ownerFrame)
    dialog.setUndecorated(true)
    dialog.setDefaultCloseOperation(javax.swing.JDialog.DISPOSE_ON_CLOSE)
    dialog.add(tb)
    dialog.pack()
    dialog.setLocation(screenX - dragOffsetX, screenY - dragOffsetY)
    dialog.setVisible(true)
    floatingDialog = dialog
  }
}
