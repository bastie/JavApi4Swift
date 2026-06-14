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
    didSet { subscribeNotifications() }
  }

  private var cursorObserver: NSObjectProtocol?

  private func subscribeNotifications() {
    if let obs = cursorObserver { NotificationCenter.default.removeObserver(obs) }

    cursorObserver = NotificationCenter.default.addObserver(
      forName: .awtCursorChanged, object: nil, queue: .main) { [weak self] _ in
      MainActor.assumeIsolated {
        guard let self else { return }
        self.window?.invalidateCursorRects(for: self)
      }
    }
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
      guard container.bounds.width != newW || container.bounds.height != newH else {
        needsDisplay = true
        return
      }
      container.bounds = java.awt.Rectangle(0, 0, newW, newH)
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
    cgContext.restoreGState()
  }
  
  // isFlipped=true → convert() already returns Y=0-at-top, matching AWT.
  // No manual Y-flip needed (it was needed before isFlipped=true; now it would double-flip).
  private func awtPoint(from event: NSEvent) -> CGPoint {
    let p = convert(event.locationInWindow, from: nil)
    return CGPoint(x: p.x, y: p.y)
  }
  
  private var pressedButton: java.awt.Button?
  
  // Scrollbar being dragged (for thumb drag)
  private var draggingScrollbar: java.awt.Scrollbar?
  // TextArea whose scrollbar thumb is being dragged
  private var draggingTextAreaScroll: java.awt.TextArea?
  // ScrollPane whose scrollbar thumb is being dragged
  private var draggingScrollPane: java.awt.ScrollPane?
  // List whose scrollbar is being dragged
  private var draggingList: java.awt.List?
  // Currently open Choice popup (tracked so outside clicks close it)
  private weak var openChoice: java.awt.Choice?
  // Currently open Swing JMenu (tracked so outside clicks close the popup)
  private weak var openMenu: javax.swing.JMenu?
  
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

    menu.isSelected = true
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
    menu.isSelected = false
    let popup = menu.swingPopupMenu
    popup.parent?.remove(popup)   // remove from layeredPane
    popup.closePopup()
    openMenu = nil
    if repaint { needsDisplay = true }
  }

  // ────────────────────────────────────────────────────────────────────────────

  override func mouseDown(with event: NSEvent) {
    guard let component else { return }
    let pt  = awtPoint(from: event)
    
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
          if hitMenu.isSelected {
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
        return
      }
    }

    // ── Choice popup handling (must come before normal hit-test) ────────────
    if let choice = openChoice {
      let pr = choice.popupRect()
      if pr.contains(Int(pt.x), Int(pt.y)) {
        // Click inside popup → select item and close
        if let idx = choice.popupItemIndex(atY: Int(pt.y)) {
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
    
    let hit = _SwiftUIHitTest.find(at: pt, in: component)
    
    // Transfer keyboard focus
    _SwiftUIFocusManager.shared.requestFocus(hit)
    
    if let btn = hit as? java.awt.Button {
      pressedButton = btn
      btn.isPressed = true
      self.setNeedsDisplay(bounds)
      needsDisplay  = true
      
    } else if let tf = hit as? java.awt.TextField {
      let clickIdx = tf._charIndex(at: Int(pt.x))
      if event.modifierFlags.contains(.shift) {
        tf.extendSelection(to: clickIdx)
      } else {
        tf.setCaretPosition(clickIdx)
      }
      needsDisplay = true
      
    } else if let ta = hit as? java.awt.TextArea {
      // Check if click hit the internal vertical scrollbar thumb
      if let thumb = ta.verticalScrollbarThumbRect(),
         thumb.contains(Int(pt.x), Int(pt.y)) {
        draggingTextAreaScroll = ta
        ta.isScrollbarDragging = true
        ta.scrollDragStartY    = Int(pt.y)
        ta.scrollDragStartOff  = ta.scrollOffsetY
      } else {
        // Position caret in text area
        let idx = ta._charIndex(atX: Int(pt.x), atY: Int(pt.y))
        if event.modifierFlags.contains(.shift) {
          ta.extendSelection(to: idx)
        } else {
          ta.setCaretPosition(idx)
        }
      }
      needsDisplay = true
      
    } else if let sb = hit as? java.awt.Scrollbar {
      let isVert = sb.orientation == java.awt.Scrollbar.VERTICAL
      let coord  = isVert ? Int(pt.y) : Int(pt.x)
      let ptI    = (x: Int(pt.x), y: Int(pt.y))
      if sb.decrementButtonRect().contains(ptI.x, ptI.y) {
        // Decrement arrow — step by unitIncrement
        sb.value = sb.value - sb.unitIncrement
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_DECREMENT, isAdjusting: false)
      } else if sb.incrementButtonRect().contains(ptI.x, ptI.y) {
        // Increment arrow — step by unitIncrement
        sb.value = sb.value + sb.unitIncrement
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_INCREMENT, isAdjusting: false)
      } else if sb.thumbRect().contains(ptI.x, ptI.y) {
        // Thumb drag
        draggingScrollbar = sb
        sb.isDragging     = true
        sb.dragStartCoord = coord
        sb.dragStartValue = sb.value
      } else {
        // Track click — jump to position, then allow drag
        let range  = sb.maximum - sb.minimum
        let track  = isVert ? sb.bounds.height : sb.bounds.width
        let origin = isVert ? sb.bounds.y      : sb.bounds.x
        let newVal = sb.minimum + (coord - origin) * range / max(1, track) - sb.visibleAmount / 2
        sb.value   = newVal
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: false)
        draggingScrollbar = sb
        sb.isDragging     = true
        sb.dragStartCoord = coord
        sb.dragStartValue = sb.value
      }
      needsDisplay = true
      
    } else if let sp = hit as? java.awt.ScrollPane {
      let ptI = (x: Int(pt.x), y: Int(pt.y))
      let (maxX, maxY) = sp.maxScroll()
      if let btn = sp.vDecrementButtonRect(), btn.contains(ptI.x, ptI.y) {
        // V-Pfeil aufwärts — unitIncrement
        sp.setScrollPosition(sp.scrollX, max(0, sp.scrollY - sp.scrollbarSize))
      } else if let btn = sp.vIncrementButtonRect(), btn.contains(ptI.x, ptI.y) {
        // V-Pfeil abwärts — unitIncrement
        sp.setScrollPosition(sp.scrollX, min(maxY, sp.scrollY + sp.scrollbarSize))
      } else if let btn = sp.hDecrementButtonRect(), btn.contains(ptI.x, ptI.y) {
        // H-Pfeil links — unitIncrement
        sp.setScrollPosition(max(0, sp.scrollX - sp.scrollbarSize), sp.scrollY)
      } else if let btn = sp.hIncrementButtonRect(), btn.contains(ptI.x, ptI.y) {
        // H-Pfeil rechts — unitIncrement
        sp.setScrollPosition(min(maxX, sp.scrollX + sp.scrollbarSize), sp.scrollY)
      } else if let thumb = sp.vThumbRect(), thumb.contains(ptI.x, ptI.y) {
        // Klick auf V-Thumb — Drag starten
        draggingScrollPane      = sp
        sp.isDraggingV          = true
        sp.dragStartY           = ptI.y
        sp.dragStartScrollY     = sp.scrollY
      } else if let track = sp.vScrollbarRect(), track.contains(ptI.x, ptI.y) {
        // Klick in V-Track — Sprung zur Position
        let relY      = ptI.y - track.y
        sp.scrollY    = max(0, min(maxY, relY * maxY / max(1, track.height)))
        draggingScrollPane      = sp
        sp.isDraggingV          = true
        sp.dragStartY           = ptI.y
        sp.dragStartScrollY     = sp.scrollY
      } else if let thumb = sp.hThumbRect(), thumb.contains(ptI.x, ptI.y) {
        // Klick auf H-Thumb — Drag starten
        draggingScrollPane      = sp
        sp.isDraggingH          = true
        sp.dragStartX           = ptI.x
        sp.dragStartScrollX     = sp.scrollX
      } else if let track = sp.hScrollbarRect(), track.contains(ptI.x, ptI.y) {
        // Klick in H-Track — Sprung zur Position
        let relX      = ptI.x - track.x
        sp.scrollX    = max(0, min(maxX, relX * maxX / max(1, track.width)))
        draggingScrollPane      = sp
        sp.isDraggingH          = true
        sp.dragStartX           = ptI.x
        sp.dragStartScrollX     = sp.scrollX
      }
      needsDisplay = true
      
    } else if let ch = hit as? java.awt.Choice {
      // Toggle popup
      ch.isOpen   = !ch.isOpen
      openChoice  = ch.isOpen ? ch : nil
      needsDisplay = true
      
    } else if let list = hit as? java.awt.List {
      let ptI = (x: Int(pt.x), y: Int(pt.y))
      if let thumb = list.scrollbarThumbRect(), thumb.contains(ptI.x, ptI.y) {
        // Thumb drag
        draggingList             = list
        list.isScrollbarDragging = true
        list.scrollDragStartY   = ptI.y
        list.scrollDragStartOff = list.scrollOffset
      } else if let track = list.scrollbarTrackRect(), track.contains(ptI.x, ptI.y) {
        // Track click — jump to position, then allow drag
        let maxOff = list.maxScrollOffset()
        let relY   = ptI.y - track.y
        list.scrollOffset       = max(0, min(maxOff, relY * maxOff / max(1, track.height)))
        draggingList             = list
        list.isScrollbarDragging = true
        list.scrollDragStartY   = ptI.y
        list.scrollDragStartOff = list.scrollOffset
      } else {
        // Item selection
        if let idx = list.itemIndex(atY: ptI.y) {
          list.select(idx)
          list.fireItemEvent(index: idx,
                             stateChange: java.awt.event.ItemEvent.SELECTED)
          if event.clickCount >= 2 {
            list.fireActionEvent(index: idx)
          }
        }
      }
      needsDisplay = true
    }
  }
  
  override func mouseDragged(with event: NSEvent) {
    let pt = awtPoint(from: event)
    
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
    }
  }
  
  override func mouseUp(with event: NSEvent) {
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
    
    // Other components — TextComponent handled in mouseDown/mouseDragged
    guard let component else { return }
    let pt = awtPoint(from: event)
    if let hit = _SwiftUIHitTest.find(at: pt, in: component),
       !(hit is java.awt.TextComponent) {
      _SwiftUIHitTest.dispatch(click: hit)
      needsDisplay = true
    }
  }
  
  override func scrollWheel(with event: NSEvent) {
    guard let component else { return }
    let pt  = awtPoint(from: event)
    guard let hit = _SwiftUIHitTest.find(at: pt, in: component) else { return }
    
    if let sp = _AWTHitTest.nearestScrollPane(hit) {
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
    } else if comp is java.awt.TextComponent {
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
  }

  /// Returns the effective NSCursor for a hit component:
  /// walks up the AWT parent chain for an explicit cursor, falls back to
  /// implicit cursors for text components, then arrow.
  private func effectiveCursor(for comp: java.awt.Component?) -> NSCursor {
    // Implicit cursor for text-editing components
    if comp is java.awt.TextField || comp is java.awt.TextArea {
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
    if let hit = _SwiftUIHitTest.find(at: p, in: component) {
      _SwiftUIHitTest.dispatch(click: hit)
      setNeedsDisplay()
    }
  }
}


#endif   // os(macOS) / os(iOS) / else
#endif
