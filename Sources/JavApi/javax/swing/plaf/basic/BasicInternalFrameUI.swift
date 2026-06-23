/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JInternalFrame`.
  ///
  /// Paints a titled, bordered internal frame window.  The title bar shows the
  /// frame title and – when the frame is selected – uses an active highlight
  /// colour.  All drawing is done through the `java.awt.Graphics` API so it
  /// works with any backend.
  ///
  /// `installUI` registers a mouse handler that provides:
  /// - Click on title bar → activate frame
  /// - Drag on title bar → move frame via `DesktopManager`
  /// - Click on close / maximise / iconify buttons
  ///
  /// ## Visual layout
  ///
  /// ```
  /// ┌──────────────────────────────────┐  ← outer border (1 px, controlDkShadow)
  /// │ [Title text]              [─][□][✕] │  ← title bar (titleBarHeight)
  /// ├──────────────────────────────────┤
  /// │                                  │
  /// │          content pane            │
  /// │                                  │
  /// └──────────────────────────────────┘
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicInternalFrameUI: javax.swing.plaf.ComponentUI {

    // MARK: - Constants

    /// Height of the title bar in pixels.
    public static let TITLE_BAR_HEIGHT: Int = 22

    // MARK: - Mouse handler

    private var _handler: _TitleBarHandler?

    // MARK: - Install / uninstall

    override open func installUI(_ component: javax.swing.JComponent) {
      guard let frame = component as? javax.swing.JInternalFrame else { return }
      let h = _TitleBarHandler(frame: frame)
      _handler = h
      component.addMouseListener(h)
      component.addMouseMotionListener(h)
      if component.getBorder() == nil {
        component.setBorder(javax.swing.BorderFactory.createLineBorder(
          java.awt.SystemColor.controlDkShadow))
      }
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      if let h = _handler {
        component.removeMouseListener(h)
        component.removeMouseMotionListener(h)
      }
      _handler = nil
      if component.getBorder() is javax.swing.border.LineBorder {
        component.setBorder(nil)
      }
    }

    // MARK: - Preferred size

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let frame = component as? javax.swing.JInternalFrame else { return nil }
      let contentPref = frame.getContentPane().getPreferredSize()
      let w = (contentPref.width) + 2   // 1px border each side
      let h = (contentPref.height) + BasicInternalFrameUI.TITLE_BAR_HEIGHT + 2
      return java.awt.Dimension(w, h)
    }

    // MARK: - Painting

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let frame = component as? javax.swing.JInternalFrame else { return }

      let w = component.bounds.width
      let h = component.bounds.height
      let tbH = BasicInternalFrameUI.TITLE_BAR_HEIGHT

      // ── Outer border is painted by JComponent.paint() via getBorder().paintBorder(...) ──

      // ── Title bar background ──────────────────────────────────────────────
      let isSelected = frame.isSelected()
      let titleBg: java.awt.Color = isSelected
        ? java.awt.SystemColor.activeCaption
        : java.awt.SystemColor.inactiveCaption
      g.setColor(titleBg)
      g.fillRect(1, 1, w - 2, tbH)

      // ── Title text ────────────────────────────────────────────────────────
      let titleFg: java.awt.Color = isSelected
        ? java.awt.SystemColor.activeCaptionText
        : java.awt.SystemColor.inactiveCaptionText
      g.setColor(titleFg)
      let fm = java.awt.FontMetrics.make(for: component.font)
      let title = frame.getTitle()
      let textY = (tbH - fm.getHeight()) / 2 + fm.getAscent()
      g.drawString(title, 6, textY)

      // ── Title bar separator ───────────────────────────────────────────────
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawLine(1, tbH, w - 2, tbH)

      // ── Content area background ───────────────────────────────────────────
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(1, tbH + 1, w - 2, h - tbH - 2)

      // ── Window buttons (right side of title bar) ──────────────────────────
      paintTitleButtons(g, frame, w, tbH)
    }

    /// Paints close / maximise / iconify buttons in the title bar.
    private func paintTitleButtons(
      _ g: java.awt.Graphics,
      _ frame: javax.swing.JInternalFrame,
      _ frameWidth: Int,
      _ tbH: Int
    ) {
      let btnSize  = tbH - 6
      let btnTop   = 3
      var rightEdge = frameWidth - 4

      if frame.isClosable() {
        let x = rightEdge - btnSize
        paintButton(g, x, btnTop, btnSize, "✕")
        rightEdge = x - 3
      }
      if frame.isMaximizable() {
        let x = rightEdge - btnSize
        paintButton(g, x, btnTop, btnSize, "□")
        rightEdge = x - 3
      }
      if frame.isIconifiable() {
        let x = rightEdge - btnSize
        paintButton(g, x, btnTop, btnSize, "─")
      }
    }

    private func paintButton(_ g: java.awt.Graphics, _ x: Int, _ y: Int, _ size: Int, _ symbol: String) {
      let base = java.awt.SystemColor.control
      g.setColor(base)
      g.fillRect(x, y, size, size)
      let dark = java.awt.Color(
        Swift.max(0, base.getRed()   - 50),
        Swift.max(0, base.getGreen() - 50),
        Swift.max(0, base.getBlue()  - 50))
      g.setColor(dark)
      g.drawRect(x, y, size - 1, size - 1)
      g.setColor(java.awt.Color.black)
      let fm = java.awt.FontMetrics.make(for: java.awt.Font("Dialog", java.awt.Font.PLAIN, 9))
      let sx = x + (size - fm.stringWidth(symbol)) / 2
      let sy = y + (size - fm.getHeight()) / 2 + fm.getAscent()
      g.drawString(symbol, sx, sy)
    }

    // MARK: - Button hit-testing (static helper, reused by handler)

    /// Returns which button was hit at `(x, y)` in frame coordinates, or `nil`.
    static func hitButton(x: Int, y: Int, frame: javax.swing.JInternalFrame) -> ButtonHit? {
      let tbH = TITLE_BAR_HEIGHT
      guard y >= 3 && y <= tbH - 3 else { return nil }
      let btnSize = tbH - 6
      let w = frame.bounds.width
      var rightEdge = w - 4
      if frame.isClosable() {
        let bx = rightEdge - btnSize
        if x >= bx && x <= bx + btnSize { return .close }
        rightEdge = bx - 3
      }
      if frame.isMaximizable() {
        let bx = rightEdge - btnSize
        if x >= bx && x <= bx + btnSize { return .maximize }
        rightEdge = bx - 3
      }
      if frame.isIconifiable() {
        let bx = rightEdge - btnSize
        if x >= bx && x <= bx + btnSize { return .iconify }
      }
      return nil
    }

    enum ButtonHit { case close, maximize, iconify }
  }
}

// MARK: - Title bar mouse handler

/// Handles mouse events on the title bar: activate, drag-to-move, button clicks.
@MainActor
private class _TitleBarHandler: java.awt.event.MouseAdapter, java.awt.event.MouseMotionListener, @unchecked Sendable {

  private weak var frame: javax.swing.JInternalFrame?

  /// Point (in frame coordinates) where the drag started.
  private var dragOrigin: java.awt.Point? = nil

  init(frame: javax.swing.JInternalFrame) {
    self.frame = frame
  }

  // MARK: MouseListener

  override func mousePressed(_ e: java.awt.event.MouseEvent) {
    guard let frame else { return }
    // Activate on any press
    if let desktop = frame.getParent() as? javax.swing.JDesktopPane {
      desktop.getDesktopManager().activateFrame(frame)
    }
    let tbH = javax.swing.plaf.basic.BasicInternalFrameUI.TITLE_BAR_HEIGHT
    guard e.getY() <= tbH else { return }

    // Button hit?
    if let hit = javax.swing.plaf.basic.BasicInternalFrameUI.hitButton(
        x: e.getX(), y: e.getY(), frame: frame) {
      switch hit {
      case .close:    frame.dispose()
      case .maximize: frame.setMaximum(!frame.isMaximum())
      case .iconify:  frame.setIcon(true)
      }
      return
    }
    // Start drag
    dragOrigin = java.awt.Point(e.getX(), e.getY())
    if let desktop = frame.getParent() as? javax.swing.JDesktopPane {
      desktop.getDesktopManager().beginDraggingFrame(frame)
    }
  }

  override func mouseReleased(_ e: java.awt.event.MouseEvent) {
    guard let frame, dragOrigin != nil else { return }
    dragOrigin = nil
    if let desktop = frame.getParent() as? javax.swing.JDesktopPane {
      desktop.getDesktopManager().endDraggingFrame(frame)
    }
  }

  // MARK: MouseMotionListener

  func mouseDragged(_ e: java.awt.event.MouseEvent) {
    guard let frame, let origin = dragOrigin else { return }
    guard let desktop = frame.getParent() as? javax.swing.JDesktopPane else { return }
    let newX = frame.bounds.x + e.getX() - origin.x
    let newY = frame.bounds.y + e.getY() - origin.y
    desktop.getDesktopManager().dragFrame(frame, newX, newY)
  }

  func mouseMoved(_ e: java.awt.event.MouseEvent) {}
}
