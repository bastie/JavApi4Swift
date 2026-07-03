/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI


#if os(macOS)
@preconcurrency import AppKit


/// Natives NSView, das `component.paint(g)` in `draw(_:)` aufruft
/// und Mausereignisse als AWT-Events weiterleitet.
@MainActor
final class _SwiftUINativeCanvas: NSView {
  
  var component: java.awt.Component? {
    didSet {
      subscribeNotifications()
      _SwiftUIFocusManager.shared.rootComponent = component
    }
  }

  private var cursorObserver: NSObjectProtocol?

  /// Recognisers that were hit during the most recent mouseDown.
  /// Kept across mouseDragged calls so we don't re-hit-test during a drag
  /// (the cursor may have moved off the source component).
  var _activeAppKitRecognizers: [java.awt.dnd._AppKitMouseDragGestureRecognizer] = []

  private func subscribeNotifications() {
    if let obs = cursorObserver { NotificationCenter.default.removeObserver(obs) }

    cursorObserver = NotificationCenter.default.addObserver(
      forName: .awtCursorChanged, object: nil, queue: .main) { [weak self] _ in
      MainActor.assumeIsolated {
        guard let self else { return }
        self.window?.invalidateCursorRects(for: self)
      }
    }
    // Register drop types for NSDraggingDestination
    _registerForDnDTypes()
  }

  override var acceptsFirstResponder: Bool { true }

  // NSHostingView (the SwiftUI bridge) sets isFlipped=true, giving draw() a
  // coordinate system where Y=0 is at the top — exactly matching AWT.
  // We must mirror that here so our own draw() receives the same orientation;
  // otherwise the manual translate+scale flip below would double-flip and
  // invert directions (triangles, line segments, etc.) while leaving absolute
  // positions coincidentally correct.
  override var isFlipped: Bool { true }

  override func setFrameSize(_ newSize: NSSize) {
    super.setFrameSize(newSize)
    // Wenn das NSWindow/NSPanel seine Größe ändert, passen wir component.bounds an
    // und rufen validate() auf, damit alle LayoutManager neu rechnen.
    // Gilt für Frame UND Dialog (und generell jeden Container als Root-Komponente).
    if let container = component as? java.awt.Container {
      let newW = Int(newSize.width)
      let newH = Int(newSize.height)
      container.setBounds(0, 0, newW, newH)
      container.validate()
    }
    needsDisplay = true
  }
  
  override func draw(_ dirtyRect: NSRect) {
    guard let component,
          let cgContext = NSGraphicsContext.current?.cgContext else { return }
    cgContext.saveGState()
    // isFlipped=true → draw() already has Y=0 at top, matching AWT.
    // No manual flip needed.
    let g = java.awt.Graphics2D(cgContext)
    component.paint(g)
    // ── JComboBox popup overlay ──────────────────────────────────────────────
    // Drawn after the full component tree so it is never clipped by parent containers.
    if let found = _findOpenComboBox(in: component),
       let combo = found as? _AnyJComboBox {
      _paintComboBoxPopup(g, combo: combo, component: found)
    }
    // ── Tooltip overlay ──────────────────────────────────────────────────────
    if _tooltipVisible, let tipComp = _tooltipComponent,
       let text = tipComp.getToolTipText(), !text.isEmpty {
      _paintTooltip(g, text: text, at: _tooltipPoint)
    }
    cgContext.restoreGState()
  }

  /// Renders the open JComboBox popup at absolute canvas coordinates.
  private func _paintComboBoxPopup(_ g: java.awt.Graphics,
                                   combo: _AnyJComboBox,
                                   component comboComp: javax.swing.JComponent) {
    let origin = _SwingHitTest.absoluteOrigin(comboComp)
    let cw     = comboComp.bounds.width
    let ch     = comboComp.bounds.height
    let rowH   = combo._popupItemHeight()
    let count  = combo._itemCount()
    let selIdx  = combo._selectedIndex()
    let hoverIdx = combo._rolloverIndex()
    let px     = origin.x
    let py     = origin.y + ch   // directly below the combo box
    let pw     = cw
    let ph     = count * rowH
    let fm     = java.awt.FontMetrics.make(for: comboComp.font)

    g.save()
    // No clip — popup must overdraw any siblings
    g.setColor(java.awt.SystemColor.window)
    g.fillRect(px, py, pw, ph)

    for i in 0..<count {
      let iy = py + i * rowH
      if i == hoverIdx || (hoverIdx < 0 && i == selIdx) {
        g.setColor(java.awt.SystemColor.textHighlight)
        g.fillRect(px + 1, iy, pw - 2, rowH)
        g.setColor(java.awt.SystemColor.textHighlightText)
      } else {
        g.setColor(java.awt.SystemColor.windowText)
      }
      let label = combo._labelAt(i)
      let ty = iy + (rowH - fm.getHeight()) / 2 + fm.getAscent()
      g.drawString(label, px + 4, ty)
    }

    g.setColor(java.awt.SystemColor.controlShadow)
    g.drawLine(px,      py,      px+pw-1, py)
    g.drawLine(px,      py,      px,      py+ph-1)
    g.drawLine(px+pw-1, py,      px+pw-1, py+ph-1)
    g.drawLine(px,      py+ph-1, px+pw-1, py+ph-1)
    g.restore()
  }
  
  /// Renders the tooltip bubble at canvas coordinates `pt` (bottom-left of bubble).
  private func _paintTooltip(_ g: java.awt.Graphics, text: String, at pt: CGPoint) {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 11)
    // Set the font on the Graphics context so drawString uses the same font
    // as FontMetrics — otherwise size mismatch causes text to overflow the box.
    g.setFont(font)
    let fm   = java.awt.FontMetrics.make(for: font)
    let tw   = fm.stringWidth(text)
    let th   = fm.getHeight()
    let padH = 6   // horizontal padding (left + right each)
    let padV = 3   // vertical padding (top + bottom each)
    let w    = tw + padH * 2
    let h    = th + padV * 2
    // Keep tooltip inside canvas bounds
    var tx   = Int(pt.x) + 12
    var ty   = Int(pt.y) + 16
    let cw   = Int(bounds.width)
    let ch   = Int(bounds.height)
    if tx + w > cw { tx = max(0, cw - w - 2) }
    if ty + h > ch { ty = max(0, Int(pt.y) - h - 4) }

    g.save()
    // Shadow (subtle, 1px offset)
    g.setColor(java.awt.Color(0, 0, 0, 40))
    g.fillRect(tx + 1, ty + 1, w, h)
    // Background
    g.setColor(java.awt.SystemColor.info)
    g.fillRect(tx, ty, w, h)
    // Border
    g.setColor(java.awt.SystemColor.infoText)
    g.drawRect(tx, ty, w - 1, h - 1)
    // Text — baseline at ascent + top padding
    let textY = ty + padV + fm.getAscent()
    g.drawString(text, tx + padH, textY)
    g.restore()
  }

  // isFlipped=true → convert() already returns Y=0-at-top, matching AWT.
  // No manual Y-flip needed (it was needed before isFlipped=true; now it would double-flip).
  private func awtPoint(from event: NSEvent) -> CGPoint {
    let p = convert(event.locationInWindow, from: nil)
    return CGPoint(x: p.x, y: p.y)
  }
  
  private var pressedButton: java.awt.Button?
  private var pressedJButton: javax.swing.JButton?
  // Generic pressed component for components handled only in mouseUp
  // (JToggleButton, JCheckBox, JRadioButton, JTabbedPane, etc.)
  private weak var pressedComponent: java.awt.Component?
  
  // Scrollbar being dragged (for thumb drag)
  private var draggingScrollbar: java.awt.Scrollbar?
  // TextArea whose scrollbar thumb is being dragged
  private var draggingTextAreaScroll: java.awt.TextArea?
  // ScrollPane whose scrollbar thumb is being dragged
  private var draggingScrollPane: java.awt.ScrollPane?
  // List whose scrollbar is being dragged
  private var draggingList: java.awt.List?
  // javax.swing.JScrollBar being dragged
  private weak var draggingJScrollBar: javax.swing.JScrollBar?
  private var jScrollBarDragStartCoord: Int = 0
  private var jScrollBarDragStartValue: Int = 0
  // JSplitPane whose divider is being dragged
  private weak var draggingSplitPane: javax.swing.JSplitPane?
  private var splitPaneDragStartCoord: Int = 0
  private var splitPaneDragStartPos:   Int = 0
  // JInternalFrame being dragged by its title bar
  private weak var draggingInternalFrame: javax.swing.JInternalFrame?
  private var internalFrameDragStartX: Int = 0   // global
  private var internalFrameDragStartY: Int = 0
  private var internalFrameOriginX: Int = 0      // frame.bounds at drag start
  private var internalFrameOriginY: Int = 0
  // Currently open Choice popup (tracked so outside clicks close it)
  private weak var openChoice: java.awt.Choice?
  // Currently open JComboBox popup (tracked so outside clicks close it)
  private weak var openComboBox: javax.swing.JComponent?
  // Currently open Swing JMenu (tracked so outside clicks close the popup)
  private weak var openMenu: javax.swing.JMenu?
  // Currently open free-standing JPopupMenu (tracked so outside clicks close it)
  weak var openPopupMenu: javax.swing.JPopupMenu?
  // True when mouseDown handled a menu-bar or popup click — mouseUp must not
  // dispatch a second event for whatever lies under the menu.
  private var _menuDownConsumed: Bool = false

  // ── Tooltip state ───────────────────────────────────────────────────────────
  // The component currently under the mouse that has a tooltip text.
  private weak var _tooltipComponent: javax.swing.JComponent? = nil
  // Canvas-coordinates where the tooltip should appear (below mouse).
  private var _tooltipPoint: CGPoint = .zero
  // Timer that delays tooltip appearance or auto-dismiss.
  private var _tooltipTimer: Timer? = nil
  // Whether the tooltip popup is currently visible.
  private var _tooltipVisible: Bool = false
  // Delays are read from ToolTipManager.sharedInstance() at the moment a
  // timer fires, so changes to the manager take effect immediately.
  private var _tooltipManager: javax.swing.ToolTipManager { .sharedInstance() }
  
  // ── Swing menu helpers ──────────────────────────────────────────────────────

  /// Walks the AWT tree of `root` and returns the first `JMenuBar` found, or nil.
  private func _swingMenuBar(in root: java.awt.Component) -> javax.swing.JMenuBar? {
    if let bar = root as? javax.swing.JMenuBar { return bar }
    if let c = root as? java.awt.Container {
      for child in c.getComponents() {
        if let found = _swingMenuBar(in: child) { return found }
      }
    }
    return nil
  }

  /// Opens `menu`'s popup in the POPUP_LAYER of the root layered pane.
  private func _openSwingMenu(_ menu: javax.swing.JMenu, bar: javax.swing.JMenuBar) {
    // Locate the hit-rect for this menu from the bar's UI delegate
    guard let barUI = bar.ui as? javax.swing.plaf.basic.BasicMenuBarUI,
          let entry = barUI.menuRects.first(where: { $0.menu === menu })
    else { return }

    // Find the JLayeredPane via the bar's ancestor chain
    var node: java.awt.Component? = bar
    var layeredPane: javax.swing.JLayeredPane? = nil
    while let n = node {
      if let lp = n as? javax.swing.JLayeredPane { layeredPane = lp; break }
      node = n.parent
    }
    guard let lp = layeredPane else { return }

    menu.setSelected(true)
    openMenu = menu

    let popup = menu.swingPopupMenu
    // Position popup below the menu title in layered-pane coordinates
    let barY  = bar.bounds.y
    let popX  = bar.bounds.x + entry.rect.x
    let popY  = barY + javax.swing.JMenuBar.defaultHeight
    lp.add(popup, layer: javax.swing.JLayeredPane.POPUP_LAYER)
    popup.show(x: popX, y: popY)
  }

  /// Closes the currently open Swing menu popup, if any.
  private func _closeOpenSwingMenu(repaint: Bool) {
    guard let menu = openMenu else { return }
    menu.setSelected(false)
    let popup = menu.swingPopupMenu
    popup.parent?.remove(popup)   // remove from layeredPane
    popup.closePopup()
    openMenu = nil
    if repaint { needsDisplay = true }
  }

  /// Closes the currently tracked free-standing `JPopupMenu`, if any.
  func _closeOpenPopupMenu(repaint: Bool) {
    guard let popup = openPopupMenu else { return }
    popup.parent?.remove(popup)
    popup.closePopup()
    openPopupMenu = nil
    if repaint { needsDisplay = true }
  }

  // ────────────────────────────────────────────────────────────────────────────

  override func mouseDown(with event: NSEvent) {
    guard let component else { return }
    let pt  = awtPoint(from: event)
    _hideTooltip()   // any click immediately dismisses the tooltip

    // ── Swing JMenu popup handling (must come before normal hit-test) ────────
    if let menu = openMenu {
      let popup = menu.swingPopupMenu
      let pb    = popup.bounds
      if pb.contains(Int(pt.x), Int(pt.y)) {
        // Click inside open popup → dispatch item, close
        let localX = Int(pt.x) - pb.x
        let localY = Int(pt.y) - pb.y
        if let item = popup.itemAt(x: localX, y: localY) {
          // Close popup first (so ActionListener sees a clean state)
          _closeOpenSwingMenu(repaint: false)
          item.doClick()
        } else {
          _closeOpenSwingMenu(repaint: false)
        }
        needsDisplay = true
        _menuDownConsumed = true
        return
      } else {
        // Click outside open popup
        // Check if the click hit the JMenuBar — handled below; close first.
        _closeOpenSwingMenu(repaint: false)
        // Fall through to check if another menu title was clicked.
      }
    }

    // ── JMenuBar click handling ──────────────────────────────────────────────
    if let bar = _swingMenuBar(in: component) {
      let bb = bar.bounds
      if bb.contains(Int(pt.x), Int(pt.y)) {
        // Point is inside the menu bar — ask BasicMenuBarUI for the hit menu
        if let barUI = bar.ui as? javax.swing.plaf.basic.BasicMenuBarUI,
           let hitMenu = barUI.menu(at: Int(pt.x) - bb.x, y: Int(pt.y) - bb.y) {
          if hitMenu.isSelected() {
            // Click on already-open title → close
            _closeOpenSwingMenu(repaint: true)
          } else {
            // Open the clicked menu's popup
            _closeOpenSwingMenu(repaint: false)
            _openSwingMenu(hitMenu, bar: bar)
            needsDisplay = true
          }
        } else {
          // Click in bar gutter → close any open menu
          _closeOpenSwingMenu(repaint: true)
        }
        _menuDownConsumed = true
        return
      }
    }

    // ── Choice popup handling (must come before normal hit-test) ────────────
    if let choice = openChoice {
      // popupRect() uses parent-relative coords; convert to frame-absolute.
      let origin = _SwingHitTest.absoluteOrigin(choice)
      let absPopupY = origin.y + choice.bounds.height
      let absPopupX = origin.x
      let visRows = min(choice.getItemCount(), choice.maxVisiblePopupRows)
      let pw = choice.bounds.width
      let ph = visRows * choice.itemHeight
      let ptX = Int(pt.x), ptY = Int(pt.y)
      if ptX >= absPopupX && ptX < absPopupX + pw &&
         ptY >= absPopupY && ptY < absPopupY + ph {
        // Click inside popup → select item and close
        let idx = (ptY - absPopupY) / choice.itemHeight
        if idx >= 0 && idx < choice.getItemCount() {
          choice.select(idx)
          choice.fireItemEvent(index: idx)
        }
        choice.isOpen = false
        openChoice    = nil
        needsDisplay  = true
        return
      } else {
        // Click outside popup → close it.
        // If the click landed on the same Choice that owns the popup, stop here —
        // falling through would re-open it via the toggle below.
        choice.isOpen = false
        openChoice    = nil
        needsDisplay  = true
        let closeHit = _SwiftUIHitTest.find(at: pt, in: component)
        if closeHit === choice { return }
        // Otherwise fall through so the actual click target is dispatched normally.
      }
    }
    
    // ── Free-standing JPopupMenu handling ───────────────────────────────────
    if openPopupMenu == nil {
      openPopupMenu = _findOpenJPopupMenu(in: component)
    }
    if let popup = openPopupMenu {
      let pb = popup.bounds
      if pb.contains(Int(pt.x), Int(pt.y)) {
        // Click inside popup → dispatch item, then close
        let localX = Int(pt.x) - pb.x
        let localY = Int(pt.y) - pb.y
        if let item = popup.itemAt(x: localX, y: localY) {
          _closeOpenPopupMenu(repaint: false)
          item.doClick()
        } else {
          _closeOpenPopupMenu(repaint: false)
        }
        needsDisplay = true
        _menuDownConsumed = true
        return
      } else {
        // Click outside popup → close it, fall through to normal dispatch
        _closeOpenPopupMenu(repaint: false)
      }
    }

    // ── JComboBox popup handling ─────────────────────────────────────────────
    // Find any open JComboBox popup in the component tree.
    if openComboBox == nil {
      openComboBox = _findOpenComboBox(in: component)
    }
    if let combo = openComboBox as? _CanvasComboBox {
      let c       = combo as! java.awt.Component
      let origin  = _SwingHitTest.absoluteOrigin(c)
      let ch      = c.bounds.height
      let rowH    = combo._popupItemHeight()
      let count   = combo._itemCount()
      let popupY  = origin.y + ch
      let popupX  = origin.x
      let pw      = c.bounds.width
      let ph      = count * rowH
      let ptX     = Int(pt.x), ptY = Int(pt.y)
      if ptX >= popupX && ptX < popupX + pw &&
         ptY >= popupY && ptY < popupY + ph {
        let idx = (ptY - popupY) / max(1, rowH)
        if idx >= 0 && idx < count { combo._selectIndex(idx) }
      }
      combo._closePopup()
      openComboBox = nil
      needsDisplay = true
      return
    }

    // Use findWithLocal so we get both the hit component AND local coordinates.
    // All sub-rect checks (thumb, track, arrow buttons) use these local coords.
    guard let (hit, lx, ly) = _SwiftUIHitTest.findWithLocal(at: pt, in: component) else { return }

    // Transfer keyboard focus
    _SwiftUIFocusManager.shared.requestFocus(hit)

    if let btn = hit as? javax.swing.JButton {
      pressedJButton = btn
      btn.processMouseEvent(java.awt.event.MouseEvent(
        btn, java.awt.event.MouseEvent.MOUSE_PRESSED, 0, 0,
        lx, ly, 1, false))
      needsDisplay = true

    } else if let btn = hit as? java.awt.Button {
      pressedButton = btn
      btn.isPressed = true
      self.setNeedsDisplay(bounds)
      needsDisplay  = true

    } else if let jtf = hit as? javax.swing.JTextField {
      // Swing JTextField: simple left-to-right char index via font metrics
      let fm      = java.awt.FontMetrics.make(for: jtf.font)
      let text    = jtf.getText()
      let chars   = Array(text)
      let relX    = lx - 4   // 4px left padding (matches BasicTextFieldUI)
      var prev    = 0
      var clickIdx = chars.count
      for i in 0..<chars.count {
        let next = fm.stringWidth(String(chars.prefix(i + 1)))
        if relX <= (prev + next) / 2 { clickIdx = i; break }
        prev = next
      }
      if event.modifierFlags.contains(.shift) {
        jtf.moveCaretPosition(clickIdx)
      } else {
        jtf.setCaretPosition(clickIdx)
      }
      needsDisplay = true

    } else if let jtp = hit as? javax.swing.JTextPane {
      // Swing JTextPane: use BasicTextPaneUI layout for variable line heights
      let clickIdx = _jtpCharIndex(jtp, localX: lx, localY: ly)
      if event.modifierFlags.contains(.shift) {
        jtp.moveCaretPosition(clickIdx)
      } else {
        jtp.setCaretPosition(clickIdx)
      }
      needsDisplay = true

    } else if let jta = hit as? javax.swing.JTextArea {
      // Swing JTextArea: find line by y, then char by x
      let fm     = java.awt.FontMetrics.make(for: jta.font)
      let lineH  = fm.getHeight()
      let relY   = ly - 3   // 3px top padding (matches BasicTextAreaUI)
      let relX   = lx - 4
      let lines  = jta.getText().components(separatedBy: "\n")
      let lineIdx = max(0, min(lines.count - 1, relY / max(1, lineH)))
      var offset  = 0
      for i in 0..<lineIdx { offset += lines[i].count + 1 }
      let lineChars = Array(lines[lineIdx])
      var prev = 0
      var col  = lineChars.count
      for i in 0..<lineChars.count {
        let next = fm.stringWidth(String(lineChars.prefix(i + 1)))
        if relX <= (prev + next) / 2 { col = i; break }
        prev = next
      }
      let clickIdx = offset + col
      if event.modifierFlags.contains(.shift) {
        jta.moveCaretPosition(clickIdx)
      } else {
        jta.setCaretPosition(clickIdx)
      }
      needsDisplay = true

    } else if let tf = hit as? java.awt.TextField {
      // _charIndex uses absolute coords — reconstruct from component origin + local
      let clickIdx = tf._charIndex(at: tf.bounds.x + lx)
      if event.modifierFlags.contains(.shift) {
        tf.extendSelection(to: clickIdx)
      } else {
        tf.setCaretPosition(clickIdx)
      }
      needsDisplay = true

    } else if let ta = hit as? java.awt.TextArea {
      // verticalScrollbarThumbRect / _charIndex use absolute coords
      let absX = ta.bounds.x + lx, absY = ta.bounds.y + ly
      if let thumb = ta.verticalScrollbarThumbRect(),
         thumb.contains(absX, absY) {
        draggingTextAreaScroll = ta
        ta.isScrollbarDragging = true
        ta.scrollDragStartY    = absY
        ta.scrollDragStartOff  = ta.scrollOffsetY
      } else {
        let idx = ta._charIndex(atX: absX, atY: absY)
        if event.modifierFlags.contains(.shift) {
          ta.extendSelection(to: idx)
        } else {
          ta.setCaretPosition(idx)
        }
      }
      needsDisplay = true

    } else if let jsb = hit as? javax.swing.JScrollBar {
      // javax.swing.JScrollBar — geometry helpers return local coords (0,0 origin).
      // Use absolute pt for drag-delta tracking (consistent with mouseDragged).
      let isVert  = jsb.getOrientation() == javax.swing.JScrollBar.VERTICAL
      let absCoord = isVert ? Int(pt.y) : Int(pt.x)
      if jsb.decrementButtonRect().contains(lx, ly) {
        jsb.setValue(jsb.getValue() - jsb.getUnitIncrement())
      } else if jsb.incrementButtonRect().contains(lx, ly) {
        jsb.setValue(jsb.getValue() + jsb.getUnitIncrement())
      } else if jsb.thumbRect().contains(lx, ly) {
        draggingJScrollBar        = jsb
        jScrollBarDragStartCoord  = absCoord
        jScrollBarDragStartValue  = jsb.getValue()
      } else {
        // Click on track — jump to position
        let range  = jsb.getMaximum() - jsb.getMinimum()
        let bs     = jsb.buttonSize
        let track  = max(1, (isVert ? jsb.bounds.height : jsb.bounds.width) - 2 * bs)
        let localCoord = isVert ? ly : lx
        let newVal = jsb.getMinimum() + max(0, localCoord - bs) * range / track - jsb.getVisibleAmount() / 2
        jsb.setValue(newVal)
        draggingJScrollBar        = jsb
        jScrollBarDragStartCoord  = absCoord
        jScrollBarDragStartValue  = jsb.getValue()
      }
      needsDisplay = true

    } else if let sb = hit as? java.awt.Scrollbar {
      // All Scrollbar rects are now LOCAL — use lx/ly directly.
      let isVert = sb.orientation == java.awt.Scrollbar.VERTICAL
      let coord  = isVert ? ly : lx
      if sb.decrementButtonRect().contains(lx, ly) {
        sb.value = sb.value - sb.unitIncrement
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_DECREMENT, isAdjusting: false)
      } else if sb.incrementButtonRect().contains(lx, ly) {
        sb.value = sb.value + sb.unitIncrement
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_INCREMENT, isAdjusting: false)
      } else if sb.thumbRect().contains(lx, ly) {
        draggingScrollbar = sb
        sb.isDragging     = true
        sb.dragStartCoord = isVert ? Int(pt.y) : Int(pt.x)  // absolute for drag delta
        sb.dragStartValue = sb.value
      } else {
        let range  = sb.maximum - sb.minimum
        let track  = isVert ? sb.bounds.height : sb.bounds.width
        let newVal = sb.minimum + coord * range / max(1, track) - sb.visibleAmount / 2
        sb.value   = newVal
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: false)
        draggingScrollbar = sb
        sb.isDragging     = true
        sb.dragStartCoord = isVert ? Int(pt.y) : Int(pt.x)
        sb.dragStartValue = sb.value
      }
      needsDisplay = true

    } else if let sp = hit as? java.awt.ScrollPane {
      // All ScrollPane rects are now LOCAL — use lx/ly directly.
      let (maxX, maxY) = sp.maxScroll()
      if let btn = sp.vDecrementButtonRect(), btn.contains(lx, ly) {
        sp.setScrollPosition(sp.scrollX, max(0, sp.scrollY - sp.scrollbarSize))
      } else if let btn = sp.vIncrementButtonRect(), btn.contains(lx, ly) {
        sp.setScrollPosition(sp.scrollX, min(maxY, sp.scrollY + sp.scrollbarSize))
      } else if let btn = sp.hDecrementButtonRect(), btn.contains(lx, ly) {
        sp.setScrollPosition(max(0, sp.scrollX - sp.scrollbarSize), sp.scrollY)
      } else if let btn = sp.hIncrementButtonRect(), btn.contains(lx, ly) {
        sp.setScrollPosition(min(maxX, sp.scrollX + sp.scrollbarSize), sp.scrollY)
      } else if let thumb = sp.vThumbRect(), thumb.contains(lx, ly) {
        draggingScrollPane  = sp
        sp.isDraggingV      = true
        sp.dragStartY       = Int(pt.y)   // absolute for drag delta
        sp.dragStartScrollY = sp.scrollY
      } else if let track = sp.vScrollbarRect(), track.contains(lx, ly) {
        let relY   = ly - track.y
        sp.scrollY = max(0, min(maxY, relY * maxY / max(1, track.height)))
        draggingScrollPane  = sp
        sp.isDraggingV      = true
        sp.dragStartY       = Int(pt.y)
        sp.dragStartScrollY = sp.scrollY
      } else if let thumb = sp.hThumbRect(), thumb.contains(lx, ly) {
        draggingScrollPane  = sp
        sp.isDraggingH      = true
        sp.dragStartX       = Int(pt.x)
        sp.dragStartScrollX = sp.scrollX
      } else if let track = sp.hScrollbarRect(), track.contains(lx, ly) {
        let relX   = lx - track.x
        sp.scrollX = max(0, min(maxX, relX * maxX / max(1, track.width)))
        draggingScrollPane  = sp
        sp.isDraggingH      = true
        sp.dragStartX       = Int(pt.x)
        sp.dragStartScrollX = sp.scrollX
      }
      needsDisplay = true

    } else if let ch = hit as? java.awt.Choice {
      ch.isOpen   = !ch.isOpen
      openChoice  = ch.isOpen ? ch : nil
      needsDisplay = true

    } else if let list = hit as? java.awt.List {
      // scrollbarThumbRect/TrackRect return parent-relative coords; reconstruct.
      let absX = list.bounds.x + lx, absY = list.bounds.y + ly
      if let thumb = list.scrollbarThumbRect(), thumb.contains(absX, absY) {
        draggingList             = list
        list.isScrollbarDragging = true
        list.scrollDragStartY    = Int(pt.y)   // frame-absolute for drag delta
        list.scrollDragStartOff  = list.scrollOffset
      } else if let track = list.scrollbarTrackRect(), track.contains(absX, absY) {
        let maxOff = list.maxScrollOffset()
        let relY   = absY - track.y
        list.scrollOffset        = max(0, min(maxOff, relY * maxOff / max(1, track.height)))
        draggingList             = list
        list.isScrollbarDragging = true
        list.scrollDragStartY    = Int(pt.y)   // frame-absolute for drag delta
        list.scrollDragStartOff  = list.scrollOffset
      } else {
        // Use local coordinate directly — itemIndex(atLocalY:) needs no translation
        if let idx = list.itemIndex(ly) {
          list.select(idx)
          list.fireItemEvent(index: idx, stateChange: java.awt.event.ItemEvent.SELECTED)
          if event.clickCount >= 2 { list.fireActionEvent(index: idx) }
        }
      }
      needsDisplay = true

    } else if let sp = _nearestJSplitPane(from: hit, globalPt: pt) {
      // _nearestJSplitPane already verified the divider hit
      draggingSplitPane       = sp
      splitPaneDragStartCoord = sp.isHorizontal ? Int(pt.x) : Int(pt.y)
      splitPaneDragStartPos   = sp.effectiveDividerLocation()
    } else if let icon = hit as? javax.swing.JInternalFrame.JDesktopIcon {
      // Double-click on desktop icon → deiconify
      if event.clickCount >= 2, let frame = icon.getInternalFrame() {
        frame.setIcon(false)   // resets _isIcon and calls deiconifyFrame
        needsDisplay = true
      }
    } else if let iFrame = _nearestJInternalFrame(from: hit) {
      // Activate the frame on every click
      if let desktop = iFrame.getParent() as? javax.swing.JDesktopPane {
        desktop.getDesktopManager().activateFrame(iFrame)
      }
      needsDisplay = true
      // Convert global point to frame-local coordinates
      let (fox, foy) = _SwingHitTest.absoluteOrigin(iFrame)
      let flx = Int(pt.x) - fox
      let fly = Int(pt.y) - foy
      let tbH = javax.swing.plaf.basic.BasicInternalFrameUI.TITLE_BAR_HEIGHT
      // Only title-bar interactions below; clicks in content area just activate
      guard fly >= 0 && fly <= tbH else { return }
      // Button hit?
      if let btnHit = javax.swing.plaf.basic.BasicInternalFrameUI.hitButton(x: flx, y: fly, frame: iFrame) {
        switch btnHit {
        case .close:    iFrame.dispose()
        case .maximize: iFrame.setMaximum(!iFrame.isMaximum())
        case .iconify:  iFrame.setIcon(true)
        }
        setNeedsDisplay(self.bounds)
        needsDisplay = true
      } else {
        // Start drag
        draggingInternalFrame  = iFrame
        internalFrameDragStartX = Int(pt.x)
        internalFrameDragStartY = Int(pt.y)
        internalFrameOriginX   = iFrame.bounds.x
        internalFrameOriginY   = iFrame.bounds.y
        if let desktop = iFrame.getParent() as? javax.swing.JDesktopPane {
          desktop.getDesktopManager().beginDraggingFrame(iFrame)
        }
      }
    } else {
      // All other components (JToggleButton, JCheckBox, JRadioButton,
      // JTabbedPane, panels, etc.) are dispatched on mouseUp — record which
      // component was pressed so mouseUp can confirm the hit still matches.
      pressedComponent = hit

      // Forward MOUSE_PRESSED to registered MouseListeners immediately so that
      // components like JSlider (whose BasicSliderUI installs a MouseListener
      // for drag-start) receive the event without waiting for mouseUp.
      if !hit.getMouseListeners().isEmpty {
        hit.processMouseEvent(java.awt.event.MouseEvent(
          hit, java.awt.event.MouseEvent.MOUSE_PRESSED, 0, 0, lx, ly, 1, false))
      }
    }
    // ── DnD gesture recognisers ───────────────────────────────────────────────
    _dndMouseDown(event: event, pt: pt)
  }

  override func mouseDragged(with event: NSEvent) {
    let pt = awtPoint(from: event)

    // JInternalFrame title bar drag
    if let iFrame = draggingInternalFrame {
      let newX = internalFrameOriginX + Int(pt.x) - internalFrameDragStartX
      let newY = internalFrameOriginY + Int(pt.y) - internalFrameDragStartY
      if let desktop = iFrame.getParent() as? javax.swing.JDesktopPane {
        desktop.getDesktopManager().dragFrame(iFrame, newX, newY)
      }
      needsDisplay = true
      return
    }

    // JSplitPane divider drag
    if let sp = draggingSplitPane {
      let coord = sp.isHorizontal ? Int(pt.x) : Int(pt.y)
      let delta = coord - splitPaneDragStartCoord
      let newPos = max(0, splitPaneDragStartPos + delta)
      let total  = sp.isHorizontal ? sp.bounds.width : sp.bounds.height
      sp.setDividerLocation(min(newPos, max(0, total - sp.getDividerSize())))
      needsDisplay = true
      return
    }

    // ScrollPane scrollbar drag
    if let sp = draggingScrollPane {
      if sp.isDraggingV, let track = sp.vScrollbarRect() {
        let (_, maxY) = sp.maxScroll()
        guard maxY > 0 else { return }
        let dy = Int(pt.y) - sp.dragStartY
        let newY = sp.dragStartScrollY + dy * maxY / max(1, track.height)
        sp.setScrollPosition(sp.scrollX, newY)
      } else if sp.isDraggingH, let track = sp.hScrollbarRect() {
        let (maxX, _) = sp.maxScroll()
        guard maxX > 0 else { return }
        let dx = Int(pt.x) - sp.dragStartX
        let newX = sp.dragStartScrollX + dx * maxX / max(1, track.width)
        sp.setScrollPosition(newX, sp.scrollY)
      }
      needsDisplay = true
      return
    }
    
    // TextArea internal scrollbar
    if let ta = draggingTextAreaScroll {
      let fm      = ta.getFontMetrics(ta.font)
      let lineH   = max(1, fm.getHeight())
      let lines   = ta.computeLines()
      let totalH  = lines.count * lineH
      let visibleH = ta.bounds.height - 2 * ta.padY
      guard totalH > visibleH else { return }
      let trackH   = ta.bounds.height
      let dy       = Int(pt.y) - ta.scrollDragStartY
      let newOff   = ta.scrollDragStartOff + dy * totalH / max(1, trackH)
      ta.scrollOffsetY = max(0, min(totalH - visibleH, newOff))
      needsDisplay = true
      return
    }
    
    // javax.swing.JScrollBar drag
    if let jsb = draggingJScrollBar {
      let isVert   = jsb.getOrientation() == javax.swing.JScrollBar.VERTICAL
      let absCoord = isVert ? Int(pt.y) : Int(pt.x)
      let range    = max(1, jsb.getMaximum() - jsb.getMinimum() - jsb.getVisibleAmount())
      let bs       = jsb.buttonSize
      let track    = max(1, (isVert ? jsb.bounds.height : jsb.bounds.width) - 2 * bs)
      let delta    = absCoord - jScrollBarDragStartCoord
      let newVal   = jScrollBarDragStartValue + delta * range / track
      jsb.setValue(newVal)
      needsDisplay = true
      return
    }

    // Standalone Scrollbar thumb drag
    if let sb = draggingScrollbar {
      let range  = sb.maximum - sb.minimum
      let isVert = sb.orientation == java.awt.Scrollbar.VERTICAL
      let track  = isVert ? sb.bounds.height : sb.bounds.width
      let coord  = isVert ? Int(pt.y) : Int(pt.x)
      let delta  = coord - sb.dragStartCoord
      let newVal = sb.dragStartValue + delta * range / max(1, track)
      let old    = sb.value
      sb.value   = newVal
      if sb.value != old {
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: true)
      }
      needsDisplay = true
      return
    }
    
    // Swing JTextField selection drag
    if let jtf = _SwiftUIFocusManager.shared.focusOwner as? javax.swing.JTextField {
      let fm    = java.awt.FontMetrics.make(for: jtf.font)
      let chars = Array(jtf.getText())
      let relX  = Int(pt.x) - jtf.bounds.x - 4
      var prev  = 0
      var idx   = chars.count
      for i in 0..<chars.count {
        let next = fm.stringWidth(String(chars.prefix(i + 1)))
        if relX <= (prev + next) / 2 { idx = i; break }
        prev = next
      }
      jtf.moveCaretPosition(idx)
      needsDisplay = true
      return
    }

    // Swing JTextPane selection drag
    if let jtp = _SwiftUIFocusManager.shared.focusOwner as? javax.swing.JTextPane {
      let origin = _SwingHitTest.absoluteOrigin(jtp)
      let lx = Int(pt.x) - origin.x
      let ly = Int(pt.y) - origin.y
      jtp.moveCaretPosition(_jtpCharIndex(jtp, localX: lx, localY: ly))
      needsDisplay = true
      return
    }

    // Swing JTextArea selection drag
    if let jta = _SwiftUIFocusManager.shared.focusOwner as? javax.swing.JTextArea {
      let fm     = java.awt.FontMetrics.make(for: jta.font)
      let lineH  = fm.getHeight()
      let relY   = Int(pt.y) - jta.bounds.y - 3
      let relX   = Int(pt.x) - jta.bounds.x - 4
      let lines  = jta.getText().components(separatedBy: "\n")
      let lineIdx = max(0, min(lines.count - 1, relY / max(1, lineH)))
      var offset  = 0
      for i in 0..<lineIdx { offset += lines[i].count + 1 }
      let lineChars = Array(lines[lineIdx])
      var prev = 0
      var col  = lineChars.count
      for i in 0..<lineChars.count {
        let next = fm.stringWidth(String(lineChars.prefix(i + 1)))
        if relX <= (prev + next) / 2 { col = i; break }
        prev = next
      }
      jta.moveCaretPosition(offset + col)
      needsDisplay = true
      return
    }

    // TextField selection drag
    if let tf = _SwiftUIFocusManager.shared.focusOwner as? java.awt.TextField {
      let idx = tf._charIndex(at: Int(pt.x))
      tf.extendSelection(to: idx)
      needsDisplay = true
      return
    }

    // TextArea selection drag
    if let ta = _SwiftUIFocusManager.shared.focusOwner as? java.awt.TextArea {
      let idx = ta._charIndex(atX: Int(pt.x), atY: Int(pt.y))
      ta.extendSelection(to: idx)
      needsDisplay = true
      return
    }
    
    // List scrollbar drag
    if let list = draggingList {
      guard list.needsScrollbar() else { return }
      let trackH  = list.bounds.height
      let maxOff  = list.maxScrollOffset()
      let dy      = Int(pt.y) - list.scrollDragStartY
      let newOff  = list.scrollDragStartOff + dy * maxOff / max(1, trackH)
      list.scrollOffset = max(0, min(maxOff, newOff))
      needsDisplay = true
      return
    }

    // Generic fallback: dispatch mouseDragged to MouseMotionListeners of the
    // component under the cursor (e.g. JSlider with BasicSliderUI._DragHandler).
    if let root = component,
       let hit = _SwiftUIHitTest.find(at: pt, in: root),
       !hit.getMouseMotionListeners().isEmpty {
      let origin = _SwingHitTest.absoluteOrigin(hit)
      let lx = Int(pt.x) - origin.x
      let ly = Int(pt.y) - origin.y
      let e = java.awt.event.MouseEvent(
        hit, java.awt.event.MouseEvent.MOUSE_DRAGGED, 0, 0, lx, ly, 0, false)
      for l in hit.getMouseMotionListeners() { l.mouseDragged(e) }
      needsDisplay = true
    }
    // ── DnD gesture recognisers ───────────────────────────────────────────────
    _dndMouseDragged(event: event, pt: pt)
  }

  override func mouseUp(with event: NSEvent) {
    // ── DnD gesture recognisers ───────────────────────────────────────────────
    _dndMouseUp(event: event)

    // If mouseDown was fully handled by menu-bar or popup logic, do nothing here.
    if _menuDownConsumed {
      _menuDownConsumed = false
      return
    }

    // End JInternalFrame drag
    if let iFrame = draggingInternalFrame {
      draggingInternalFrame = nil
      if let desktop = iFrame.getParent() as? javax.swing.JDesktopPane {
        desktop.getDesktopManager().endDraggingFrame(iFrame)
      }
      needsDisplay = true
      return
    }

    // End JSplitPane divider drag
    if draggingSplitPane != nil {
      draggingSplitPane = nil
      needsDisplay = true
      return
    }

    // End ScrollPane drag
    if let sp = draggingScrollPane {
      sp.isDraggingV    = false
      sp.isDraggingH    = false
      draggingScrollPane = nil
      needsDisplay = true
      return
    }
    
    // End scrollbar drags
    if let ta = draggingTextAreaScroll {
      ta.isScrollbarDragging = false
      draggingTextAreaScroll = nil
      needsDisplay = true
      return
    }
    if draggingJScrollBar != nil {
      draggingJScrollBar = nil
      needsDisplay = true
      return
    }
    if let sb = draggingScrollbar {
      sb.isDragging     = false
      draggingScrollbar = nil
      sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: false)
      needsDisplay = true
      return
    }
    
    // End List scrollbar drag
    if let list = draggingList {
      list.isScrollbarDragging = false
      draggingList = nil
      needsDisplay = true
      return
    }
    
    // Release button press
    if let btn = pressedButton {
      btn.isPressed  = false
      pressedButton  = nil
      self.setNeedsDisplay(bounds)
      let pt = awtPoint(from: event)
      if let hit = _SwiftUIHitTest.find(at: pt, in: component ?? btn),
         hit === btn {
        btn.doClick()
      }
      needsDisplay = true
      return
    }

    // Swing JButton release
    if let btn = pressedJButton {
      pressedJButton = nil
      let upPt = awtPoint(from: event)
      btn.processMouseEvent(java.awt.event.MouseEvent(
        btn, java.awt.event.MouseEvent.MOUSE_RELEASED, 0, 0,
        Int(upPt.x), Int(upPt.y), 1, false))
      // Only fire action if mouse released over the same button
      if let hit = _SwiftUIHitTest.find(at: upPt, in: component ?? btn),
         hit === btn {
        btn.doClick()
      }
      needsDisplay = true
      return
    }
    
    // Generic component release — dispatch only if mouseDown recorded a press
    // on this component and the pointer is still over it on release.
    // This prevents spurious clicks on whatever happens to be under the cursor
    // after a menu, scrollbar, Choice, or List interaction.
    if let pressed = pressedComponent {
      pressedComponent = nil
      guard let component else { return }
      let upPt = awtPoint(from: event)
      if let (hit, lx, ly) = _SwiftUIHitTest.findWithLocal(at: upPt, in: component),
         hit === pressed {
        // Forward MOUSE_RELEASED to registered MouseListeners (e.g. JSlider drag-end).
        if !hit.getMouseListeners().isEmpty {
          hit.processMouseEvent(java.awt.event.MouseEvent(
            hit, java.awt.event.MouseEvent.MOUSE_RELEASED, 0, 0, lx, ly, 1, false))
        }
        _SwiftUIHitTest.dispatch(click: hit, localX: lx, localY: ly)
        needsDisplay = true
      }
    }
  }
  
  override func scrollWheel(with event: NSEvent) {
    guard let component else { return }
    let pt  = awtPoint(from: event)
    guard let hit = _SwiftUIHitTest.find(at: pt, in: component) else { return }

    if let jsp = _SwingHitTest.nearestJScrollPane(hit) {
      // javax.swing.JScrollPane — scroll the viewport's view position
      let dy = Int(event.scrollingDeltaY * -3)
      let dx = Int(event.scrollingDeltaX * -3)
      let vp  = jsp.getViewport()
      let pos = vp.getViewPosition()
      let view = vp.getView()
      let viewSize = view?.getPreferredSize() ?? java.awt.Dimension(0, 0)
      let maxY = Swift.max(0, viewSize.height - vp.bounds.height)
      let maxX = Swift.max(0, viewSize.width  - vp.bounds.width)
      let newY = Swift.max(0, Swift.min(maxY, pos.y + dy))
      let newX = Swift.max(0, Swift.min(maxX, pos.x + dx))
      vp.setViewPosition(java.awt.Point(newX, newY))
      needsDisplay = true
    } else if let sp = _SwingHitTest.nearestScrollPane(hit) {
      let dy = Int(event.scrollingDeltaY * -3)
      let dx = Int(event.scrollingDeltaX * -3)
      sp.setScrollPosition(sp.scrollX + dx, sp.scrollY + dy)
      needsDisplay = true
    } else if let ta = hit as? java.awt.TextArea {
      let delta = Int(event.scrollingDeltaY * -3)
      let fm      = ta.getFontMetrics(ta.font)
      let lineH   = max(1, fm.getHeight())
      let lines   = ta.computeLines()
      let totalH  = lines.count * lineH
      let visibleH = ta.bounds.height - 2 * ta.padY
      let maxOff  = max(0, totalH - visibleH)
      ta.scrollOffsetY = max(0, min(maxOff, ta.scrollOffsetY + delta))
      needsDisplay = true
    } else if let sb = hit as? java.awt.Scrollbar {
      let delta = Int(event.scrollingDeltaY)
      let old   = sb.value
      sb.value  = sb.value + (sb.orientation == java.awt.Scrollbar.VERTICAL ? delta : -delta)
      if sb.value != old {
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_INCREMENT)
      }
      needsDisplay = true
    } else if let list = hit as? java.awt.List {
      let delta = Int(event.scrollingDeltaY)
      let maxOff = list.maxScrollOffset()
      list.scrollOffset = max(0, min(maxOff, list.scrollOffset + delta))
      needsDisplay = true
    }
  }
  
  // MARK: - Cursor support

  override func resetCursorRects() {
    discardCursorRects()
    guard let component else { return }
    // Walk the component tree and add cursor rects for any component with a cursor set
    addCursorRects(for: component)
  }

  private func addCursorRects(for comp: java.awt.Component) {
    // Explicit cursor takes priority; TextComponents implicitly get iBeam.
    let effectiveCur: NSCursor?
    if let cur = comp.cursor {
      effectiveCur = nsCursor(for: cur)
    } else if comp is java.awt.TextComponent || comp is javax.swing.text.JTextComponent {
      effectiveCur = .iBeam
    } else {
      effectiveCur = nil
    }
    if let cur = effectiveCur {
      let r = comp.bounds
      let ns = NSRect(x: r.x, y: Int(bounds.height) - r.y - r.height,
                      width: r.width, height: r.height)
      addCursorRect(ns, cursor: cur)
    }
    if let container = comp as? java.awt.Container {
      for child in container.getComponents() {
        addCursorRects(for: child)
      }
    }
  }

  private func nsCursor(for cursor: java.awt.Cursor) -> NSCursor {
    switch cursor.type {
    case java.awt.Cursor.CROSSHAIR_CURSOR:  return .crosshair
    case java.awt.Cursor.TEXT_CURSOR:       return .iBeam
    case java.awt.Cursor.WAIT_CURSOR:       return .operationNotAllowed
    case java.awt.Cursor.HAND_CURSOR:       return .pointingHand
    case java.awt.Cursor.MOVE_CURSOR:       return .openHand
    case java.awt.Cursor.N_RESIZE_CURSOR,
         java.awt.Cursor.S_RESIZE_CURSOR:   return .resizeUpDown
    case java.awt.Cursor.E_RESIZE_CURSOR,
         java.awt.Cursor.W_RESIZE_CURSOR:   return .resizeLeftRight
    case java.awt.Cursor.NE_RESIZE_CURSOR,
         java.awt.Cursor.SW_RESIZE_CURSOR:  return _SwiftUIDiagonalCursor.neSwCursor
    case java.awt.Cursor.NW_RESIZE_CURSOR,
         java.awt.Cursor.SE_RESIZE_CURSOR:  return _SwiftUIDiagonalCursor.nwSeCursor
    default:                                return .arrow
    }
  }

  override func mouseMoved(with event: NSEvent) {
    guard let component else { super.mouseMoved(with: event); return }
    let pt = awtPoint(from: event)

    // If a menu is open and mouse is over the menubar → switch to hovered menu
    if openMenu != nil,
       let bar = _swingMenuBar(in: component) {
      let bb = bar.bounds
      if bb.contains(Int(pt.x), Int(pt.y)),
         let barUI = bar.ui as? javax.swing.plaf.basic.BasicMenuBarUI,
         let hitMenu = barUI.menu(at: Int(pt.x) - bb.x, y: Int(pt.y) - bb.y),
         hitMenu !== openMenu {
        _closeOpenSwingMenu(repaint: false)
        _openSwingMenu(hitMenu, bar: bar)
        needsDisplay = true
        return
      }
    }

    // Hover highlight inside an open Swing popup
    if let menu = openMenu {
      let popup = menu.swingPopupMenu
      let pb    = popup.bounds
      if pb.contains(Int(pt.x), Int(pt.y)),
         let popupUI = popup.ui as? javax.swing.plaf.basic.BasicPopupMenuUI {
        let localX = Int(pt.x) - pb.x
        let localY = Int(pt.y) - pb.y
        if popupUI.updateArmed(at: localX, y: localY) {
          needsDisplay = true
        }
        return
      } else {
        // Cursor left the popup — clear armed state
        if let popupUI = popup.ui as? javax.swing.plaf.basic.BasicPopupMenuUI {
          if popupUI.updateArmed(at: -1, y: -1) { needsDisplay = true }
        }
        // Check if cursor moved onto another menu title → switch popup
        if let bar = _swingMenuBar(in: component) {
          let bb = bar.bounds
          if bb.contains(Int(pt.x), Int(pt.y)),
             let barUI = bar.ui as? javax.swing.plaf.basic.BasicMenuBarUI,
             let hitMenu = barUI.menu(at: Int(pt.x) - bb.x, y: Int(pt.y) - bb.y),
             hitMenu !== openMenu {
            _closeOpenSwingMenu(repaint: false)
            _openSwingMenu(hitMenu, bar: bar)
            needsDisplay = true
          }
        }
      }
    }

    let hit = _SwiftUIHitTest.find(at: pt, in: component)
    effectiveCursor(for: hit).set()

    // Dispatch mouseMoved to MouseMotionListeners of the hit component
    if let hit {
      let origin = _SwingHitTest.absoluteOrigin(hit)
      let lx = Int(pt.x) - origin.x
      let ly = Int(pt.y) - origin.y
      let e = java.awt.event.MouseEvent(
        hit, java.awt.event.MouseEvent.MOUSE_MOVED, 0, 0, lx, ly, 0, false)
      for l in hit.getMouseMotionListeners() { l.mouseMoved(e) }
    }

    // ── Tooltip handling ─────────────────────────────────────────────────────
    let tipComp = hit as? javax.swing.JComponent
    let tipText = tipComp?.getToolTipText()
    if _tooltipManager.isEnabled(), let tipText, !tipText.isEmpty {
      if tipComp !== _tooltipComponent {
        // Mouse moved to a different tooltip component — reset
        _hideTooltip()
        _tooltipComponent = tipComp
        _tooltipPoint     = pt
        _startTooltipTimer()
      } else {
        // Same component — update position but keep timer running
        _tooltipPoint = pt
      }
    } else {
      // No tooltip under cursor, or tooltips globally disabled
      _hideTooltip()
    }

    // Hover highlight inside an open JComboBox popup (canvas overlay)
    if let found = _findOpenComboBox(in: component),
       let combo = found as? _AnyJComboBox {
      let origin = _SwingHitTest.absoluteOrigin(found)
      let ch   = found.bounds.height
      let rowH = combo._popupItemHeight()
      let ptX  = Int(pt.x), ptY = Int(pt.y)
      let popX = origin.x, popY = origin.y + ch
      let pw   = found.bounds.width
      let ph   = combo._itemCount() * rowH
      if ptX >= popX && ptX < popX + pw && ptY >= popY && ptY < popY + ph {
        let idx = (ptY - popY) / max(1, rowH)
        combo._setRolloverIndex(idx)
      } else {
        combo._setRolloverIndex(-1)
      }
      needsDisplay = true
    }
  }

  /// Returns the effective NSCursor for a hit component:
  /// walks up the AWT parent chain for an explicit cursor, falls back to
  /// implicit cursors for text components, then arrow.
  private func effectiveCursor(for comp: java.awt.Component?) -> NSCursor {
    // Implicit cursor for text-editing components
    if comp is java.awt.TextField || comp is java.awt.TextArea
        || comp is javax.swing.text.JTextComponent {
      return .iBeam
    }
    // Walk up parent chain for explicit cursor
    var current: java.awt.Component? = comp
    while let c = current {
      if let cur = c.cursor {
        return nsCursor(for: cur)
      }
      current = c.getParent()
    }
    return .arrow
  }

  override func mouseEntered(with event: NSEvent) {
    // Trigger cursor update on entry
    mouseMoved(with: event)
  }

  override func mouseExited(with event: NSEvent) {
    NSCursor.arrow.set()
    _hideTooltip()
  }

  // ── Tooltip helpers ─────────────────────────────────────────────────────────

  /// Starts the initial-delay timer before showing the tooltip.
  /// Delays are read from `ToolTipManager.sharedInstance()` at fire time.
  private func _startTooltipTimer() {
    _tooltipTimer?.invalidate()
    let initialDelay = _tooltipManager.initialDelaySeconds
    _tooltipTimer = Timer.scheduledTimer(withTimeInterval: initialDelay, repeats: false) { [weak self] _ in
      Task { @MainActor [weak self] in
        guard let self, self._tooltipManager.isEnabled() else { return }
        self._tooltipVisible = true
        self.needsDisplay = true
        // Auto-dismiss after dismissDelay
        let dismissDelay = self._tooltipManager.dismissDelaySeconds
        self._tooltipTimer = Timer.scheduledTimer(withTimeInterval: dismissDelay, repeats: false) { [weak self] _ in
          Task { @MainActor [weak self] in
            self?._hideTooltip()
          }
        }
      }
    }
  }

  /// Hides any visible tooltip and cancels the pending timer.
  private func _hideTooltip() {
    _tooltipTimer?.invalidate()
    _tooltipTimer = nil
    if _tooltipVisible || _tooltipComponent != nil {
      _tooltipVisible   = false
      _tooltipComponent = nil
      needsDisplay = true
    }
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    for area in trackingAreas { removeTrackingArea(area) }
    let opts: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow]
    addTrackingArea(NSTrackingArea(rect: bounds, options: opts, owner: self, userInfo: nil))
  }

  override func rightMouseDown(with event: NSEvent) {
    guard let component else { return }
    let pt  = awtPoint(from: event)
    guard let hit = _SwiftUIHitTest.find(at: pt, in: component) else { return }
    guard let popup = hit.popupMenu else { return }
    popup._showAtEvent(event, in: self)
  }
  
  override func keyDown(with event: NSEvent) {
    let fm   = _SwiftUIFocusManager.shared
    let mods = event.modifierFlags
    let hasCmd   = mods.contains(.command)
    let hasShift = mods.contains(.shift)
    
    switch event.keyCode {
      
      // Backspace
    case 51:
      fm.handleBackspace()
      needsDisplay = true
      
      // Forward Delete
    case 117:
      fm.handleDelete()
      needsDisplay = true
      
      // Return / Enter
    case 36, 76:
      fm.handleEnter()
      needsDisplay = true
      
      // Left arrow
    case 123:
      if hasCmd {
        fm.moveCaretToEnd(end: false, extending: hasShift)  // Cmd+Left → line start
      } else {
        fm.moveCaret(by: -1, extending: hasShift)
      }
      needsDisplay = true
      
      // Right arrow
    case 124:
      if hasCmd {
        fm.moveCaretToEnd(end: true, extending: hasShift)   // Cmd+Right → line end
      } else {
        fm.moveCaret(by: 1, extending: hasShift)
      }
      needsDisplay = true
      
      // Up arrow
    case 126:
      fm.moveCaretUp(extending: hasShift)
      needsDisplay = true
      
      // Down arrow
    case 125:
      fm.moveCaretDown(extending: hasShift)
      needsDisplay = true

      // Tab / Shift+Tab — focus traversal
    case 48:
      fm.transferFocus(forward: !hasShift)
      needsDisplay = true

    default:
      if hasCmd {
        switch event.keyCode {
        case 0:  // Cmd+A — Select All
          fm.selectAll()
          needsDisplay = true
        case 8:  // Cmd+C — Copy
          fm.copySelection()
        case 9:  // Cmd+V — Paste
          fm.pasteText()
          needsDisplay = true
        case 7:  // Cmd+X — Cut
          fm.cutSelection()
          needsDisplay = true
        default:
          super.keyDown(with: event)
        }
      } else if let chars = event.characters, !chars.isEmpty {
        var typed = false
        for ch in chars {
          let v = ch.unicodeScalars.first?.value ?? 0
          if v >= 32 && v != 127 {
            fm.typeCharacter(ch)
            typed = true
          }
        }
        if typed { needsDisplay = true }
        else     { super.keyDown(with: event) }
      } else {
        super.keyDown(with: event)
      }
    }
  }

  // macOS intercepts Tab before keyDown to do NSView focus traversal.
  // Override performKeyEquivalent to catch Tab/Shift+Tab ourselves first.
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    guard event.keyCode == 48 else { return super.performKeyEquivalent(with: event) }
    let hasShift = event.modifierFlags.contains(.shift)
    _SwiftUIFocusManager.shared.transferFocus(forward: !hasShift)
    needsDisplay = true
    return true  // consumed — don't pass to NSWindow's key-view loop
  }

  // Recursively find a JComboBox with an open popup in the component tree.
  /// Walk up from `hit` and return the nearest enclosing `JSplitPane`
  /// whose divider contains `(globalX, globalY)`, or nil.
  /// Walks up the component hierarchy from `hit` and returns the first
  /// `JInternalFrame` ancestor, or `nil` if none exists.
  private func _nearestJInternalFrame(from hit: java.awt.Component) -> javax.swing.JInternalFrame? {
    var node: java.awt.Component? = hit
    while let n = node {
      if let f = n as? javax.swing.JInternalFrame { return f }
      node = n.parent
    }
    return nil
  }

  private func _nearestJSplitPane(from hit: java.awt.Component, globalPt: CGPoint) -> javax.swing.JSplitPane? {
    var node: java.awt.Component? = hit
    while let n = node {
      if let sp = n as? javax.swing.JSplitPane {
        var ox = 0, oy = 0
        var walk: java.awt.Component? = sp
        while let w = walk { ox += w.bounds.x; oy += w.bounds.y; walk = w.parent }
        let localCoord = sp.isHorizontal ? (Int(globalPt.x) - ox) : (Int(globalPt.y) - oy)
        let pos = sp.effectiveDividerLocation()
        if localCoord >= pos && localCoord < pos + sp.getDividerSize() { return sp }
      }
      node = n.parent
    }
    return nil
  }

  /// Convert a local (component-relative) point to a document character offset
  /// in a `JTextPane`, using `BasicTextPaneUI`'s variable-line-height layout.
  private func _jtpCharIndex(_ jtp: javax.swing.JTextPane, localX lx: Int, localY ly: Int) -> Int {
    guard let ui = jtp.ui as? javax.swing.plaf.basic.BasicTextPaneUI,
          let sd = jtp.getStyledDocument() else {
      // Fallback: treat as fixed-height (base font)
      let fm     = java.awt.FontMetrics.make(for: jtp.font)
      let lineH  = fm.getHeight()
      let relY   = ly - 3
      let relX   = lx - 4
      let lines  = jtp.getText().components(separatedBy: "\n")
      let lineIdx = max(0, min(lines.count - 1, relY / max(1, lineH)))
      var offset  = 0
      for i in 0..<lineIdx { offset += lines[i].count + 1 }
      let lineChars = Array(lines[lineIdx])
      var prev = 0
      var col  = lineChars.count
      for i in 0..<lineChars.count {
        let next = fm.stringWidth(String(lineChars.prefix(i + 1)))
        if relX <= (prev + next) / 2 { col = i; break }
        prev = next
      }
      return offset + col
    }

    let lines  = jtp.getText().components(separatedBy: "\n")
    let layout = ui._lineLayout(lines: lines, sd: sd, baseFont: jtp.font)

    // Find which line the click is in
    let relY = ly   // layout yTop already includes padY
    var lineIdx = lines.count - 1
    for i in 0..<layout.count {
      let (yTop, lineH, _) = layout[i]
      if relY < yTop + lineH {
        lineIdx = i
        break
      }
    }

    // Character offset to start of this line
    var lineStart = 0
    for i in 0..<lineIdx { lineStart += lines[i].count + 1 }

    // Find column within the line.
    // Use the same stringWidth-of-prefix approach as _xForCol in BasicTextPaneUI
    // so that pixel positions match exactly (avoids cumulative kerning drift).
    let relX      = lx - ui.padX
    let line      = lines[lineIdx]
    let lineChars = Array(line)
    var col       = lineChars.count   // default: end of line

    // Walk run by run, then within each run compare prefix widths
    var runOffset = 0   // index into lineChars of the current run's start
    var xRunStart = 0   // pixel X at the start of this run

    while runOffset < lineChars.count {
      let absIdx = lineStart + runOffset
      let attrs  = sd.getCharacterElement(absIdx)
      let (runFont, _, _, _) = ui._resolveAttrs(attrs, baseFont: jtp.font)
      let runFm  = java.awt.FontMetrics.make(for: runFont)

      // Find run end
      var runEnd = runOffset + 1
      while runEnd < lineChars.count {
        if !ui._sameAttrs(attrs, sd.getCharacterElement(lineStart + runEnd)) { break }
        runEnd += 1
      }

      let runChars  = Array(lineChars[runOffset..<runEnd])
      let runWidth  = runFm.stringWidth(String(runChars))

      if relX <= xRunStart + runWidth {
        // Click is inside this run — find exact column via prefix widths.
        // Default: after the last char in the run (click on right half of last char)
        col = runOffset + runChars.count
        for k in 0..<runChars.count {
          let wBefore = runFm.stringWidth(String(runChars[0..<k]))
          let wAfter  = runFm.stringWidth(String(runChars[0...k]))
          let mid     = xRunStart + (wBefore + wAfter) / 2
          if relX <= mid {
            col = runOffset + k
            break
          }
        }
        break
      }

      xRunStart += runWidth
      runOffset  = runEnd
    }

    return lineStart + col
  }

  private func _findOpenComboBox(in comp: java.awt.Component) -> javax.swing.JComponent? {
    if let combo = comp as? _CanvasComboBoxVisible, combo._isPopupVisible() {
      return comp as? javax.swing.JComponent
    }
    if let container = comp as? java.awt.Container {
      for child in container.getComponents() {
        if let found = _findOpenComboBox(in: child) { return found }
      }
    }
    return nil
  }

  /// Walks the component tree and returns the first visible `JPopupMenu`, or `nil`.
  private func _findOpenJPopupMenu(in comp: java.awt.Component) -> javax.swing.JPopupMenu? {
    if let popup = comp as? javax.swing.JPopupMenu, popup.isVisible() {
      return popup
    }
    if let container = comp as? java.awt.Container {
      for child in container.getComponents() {
        if let found = _findOpenJPopupMenu(in: child) { return found }
      }
    }
    return nil
  }
}

// ── JComboBox popup protocols (Canvas ↔ BasicComboBoxUI bridge) ─────────────
/// Allows _SwiftUINativeCanvas to interact with open JComboBox popups without
/// depending on the generic type parameter of JComboBox<E>.
@MainActor
protocol _CanvasComboBox: AnyObject {
  func _popupItemHeight() -> Int
  func _itemCount()       -> Int
  func _selectIndex(_ i: Int)
  func _closePopup()
}

@MainActor
protocol _CanvasComboBoxVisible: AnyObject {
  func _isPopupVisible() -> Bool
}

// _CanvasComboBox requirements are already satisfied by the _AnyJComboBox
// extension in BasicComboBoxUI.swift (_popupItemHeight, _itemCount,
// _selectIndex, _closePopup).  _isPopupVisible maps to isPopupVisible().
extension javax.swing.JComboBox: _CanvasComboBox, _CanvasComboBoxVisible {
  func _isPopupVisible() -> Bool { isPopupVisible() }
}

#elseif os(iOS) || os(tvOS)
import UIKit

/// Natives UIView, das `component.paint(g)` in `draw(_:)` aufruft
/// und Touch-Events als AWT-Events weiterleitet.
@MainActor
final class _SwiftUINativeCanvas: UIView {
  
  var component: java.awt.Component?
  
  override func draw(_ rect: CGRect) {
    guard let component,
          let cgContext = UIGraphicsGetCurrentContext() else { return }
    let g = java.awt.Graphics2D(cgContext)
    component.paint(g)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let component, let touch = touches.first else { return }
    let p = touch.location(in: self)
    // UIKit: Y already goes down — same as AWT, no conversion needed
    if let (hit, lx, ly) = _SwiftUIHitTest.findWithLocal(at: p, in: component) {
      _SwiftUIHitTest.dispatch(click: hit, localX: lx, localY: ly)
      setNeedsDisplay()
    }
  }
}


#endif   // os(macOS) / os(iOS) / else
#endif
