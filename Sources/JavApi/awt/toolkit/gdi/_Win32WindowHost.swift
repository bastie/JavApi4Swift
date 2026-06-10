/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK
import Foundation

// =============================================================================
// MARK: Win32 macro replacements (Swift cannot call C function-like macros)
// =============================================================================

@inline(__always) private func _LOWORD(_ v: DWORD_PTR) -> WORD { WORD(v & 0xFFFF) }
@inline(__always) private func _HIWORD(_ v: DWORD_PTR) -> WORD { WORD((v >> 16) & 0xFFFF) }
@inline(__always) private func _GET_X_LPARAM(_ lp: LPARAM) -> Int { Int(Int16(bitPattern: UInt16(UInt64(bitPattern: lp) & 0xFFFF))) }
@inline(__always) private func _GET_Y_LPARAM(_ lp: LPARAM) -> Int { Int(Int16(bitPattern: UInt16((UInt64(bitPattern: lp) >> 16) & 0xFFFF))) }

// =============================================================================
// MARK: _Win32WindowHost  (Singleton)
// =============================================================================

/// Singleton bridge between `java.awt.Window` and the Win32 window system.
///
/// Mirrors `_SwiftUIWindowHost` for Windows.
///
/// ### Integration
/// ```swift
/// // Entry point — before any AWT code:
/// try? System.setProperty("awt.toolkit", "GDI")
///
/// let frame = java.awt.Frame("Hello Windows")
/// frame.setSize(640, 480)
/// frame.setVisible(true)
/// ```
@MainActor
public final class _Win32WindowHost {

  public static let shared = _Win32WindowHost()
  private init() {}

  private var registry: [ObjectIdentifier: _Win32Canvas] = [:]

  // ---------------------------------------------------------------------------
  // MARK: Window lifecycle
  // ---------------------------------------------------------------------------

  public func openWindow(for awtWindow: java.awt.Window) {
    let id = ObjectIdentifier(awtWindow)
    guard registry[id] == nil else { return }
    awtWindow.validate()
    let title  = (awtWindow as? java.awt.Frame)?.title ?? ""
    let b      = awtWindow.bounds
    let canvas = _Win32Canvas(
      awtWindow: awtWindow, title: title,
      x: b.x, y: b.y,
      width:  b.width  > 0 ? b.width  : 640,
      height: b.height > 0 ? b.height : 480)
    registry[id] = canvas
    canvas.show()
    // MenuBar may have been set before the window existed — attach now.
    // attachMenuBar already updates awtWindow.bounds and calls validate().
    if let frame = awtWindow as? java.awt.Frame, let mb = frame.getMenuBar() {
      canvas.attachMenuBar(mb)
    }
  }

  public func openDialog(_ dialog: java.awt.Dialog) {
    let id = ObjectIdentifier(dialog)
    guard registry[id] == nil else { return }
    dialog.validate()
    let canvas = _Win32Canvas(
      awtWindow: dialog, title: dialog.getTitle(),
      x: dialog.bounds.x, y: dialog.bounds.y,
      width:  max(dialog.bounds.width,  200),
      height: max(dialog.bounds.height, 100),
      isDialog: true, isModal: dialog.isModal())
    registry[id] = canvas
    canvas.show()
    if dialog.isModal() { canvas.runModalLoop() }
  }

  public func hide(_ window: java.awt.Window) {
    let id = ObjectIdentifier(window)
    registry[id]?.destroy()
    registry.removeValue(forKey: id)
  }

  public func closeDialog(_ dialog: java.awt.Dialog) {
    let id = ObjectIdentifier(dialog)
    if let canvas = registry[id] {
      canvas.modalDone = true
      canvas.destroy()
      registry.removeValue(forKey: id)
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: MenuBar
  // ---------------------------------------------------------------------------

  public func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
    registry[ObjectIdentifier(frame)]?.attachMenuBar(menuBar)
  }

  // ---------------------------------------------------------------------------
  // MARK: PopupMenu
  // ---------------------------------------------------------------------------

  public func showPopupMenu(_ menu: java.awt.PopupMenu,
                             origin: java.awt.Component,
                             x: Int, y: Int) {
    guard let canvas = registry.values.first(where: { c in
      var cur: java.awt.Component? = origin
      while let c2 = cur {
        if c2 === c.awtWindow { return true }
        cur = c2.getParent()
      }
      return false
    }) else { return }
    canvas.showPopupMenu(menu, x: origin.bounds.x + x, y: origin.bounds.y + y)
  }
}

// =============================================================================
// MARK: _Win32Canvas — owns one HWND + _D2DContext
// =============================================================================

@MainActor
public final class _Win32Canvas {

  internal let awtWindow: java.awt.Window
  private var hwnd: HWND?

  internal var modalDone:    Bool = false
  private  var didFireClosing = false

  internal let isDialog: Bool
  private  let isModal:  Bool

  // Menu item dispatch table
  private var menuItems:    [UINT: java.awt.MenuItem] = [:]
  private var nextMenuId:   UINT = 1000

  // ---------------------------------------------------------------------------
  // MARK: Init
  // ---------------------------------------------------------------------------

  init(awtWindow: java.awt.Window, title: String,
       x: Int, y: Int, width: Int, height: Int,
       isDialog: Bool = false, isModal: Bool = false) {
    self.awtWindow = awtWindow
    self.isDialog  = isDialog
    self.isModal   = isModal
    createHWND(title: title, x: x, y: y, width: width, height: height)
  }

  // ---------------------------------------------------------------------------
  // MARK: HWND creation
  // ---------------------------------------------------------------------------

  private func createHWND(title: String, x: Int, y: Int,
                           width: Int, height: Int) {
    let style: DWORD = isDialog
      ? DWORD(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME)
      : DWORD(WS_OVERLAPPEDWINDOW)

    var rect = RECT(left: LONG(x), top: LONG(y),
                    right: LONG(x + width), bottom: LONG(y + height))
    // Always pass false for bMenu — SetMenu will add the menu bar after creation
    // and resyncBounds() will re-validate with the actual client size then.
    AdjustWindowRect(&rect, style, false)
    // Ensure the window title bar is not clipped off the top of the screen.
    if rect.top < 0 {
      let shift = -rect.top
      rect.top = 0
      rect.bottom += shift
    }

    _Win32Canvas.registerWindowClass()

    let wTitle = Array(title.utf16) + [WCHAR(0)]
    hwnd = wTitle.withUnsafeBufferPointer { titleBuf in
      _Win32Canvas.windowClassName.withUnsafeBufferPointer { clsBuf in
        CreateWindowExW(
          0, clsBuf.baseAddress!, titleBuf.baseAddress!, style,
          rect.left, rect.top,
          rect.right - rect.left, rect.bottom - rect.top,
          nil, nil, GetModuleHandleW(nil), nil)
      }
    }

    guard let hwnd else { return }

    // Store self as GWLP_USERDATA so WndProc can retrieve it
    let ptr = Unmanaged.passRetained(self).toOpaque()
    SetWindowLongPtrW(hwnd, GWLP_USERDATA, LONG_PTR(Int(bitPattern: ptr)))

    // Diagnose: Prüfe ob RT_GROUP_ICON Ressource gefunden wird
    let hInst = GetModuleHandleW(nil)
    let iconName = UnsafePointer<WCHAR>(bitPattern: 1)   // MAKEINTRESOURCEW(1)
    let grpType  = UnsafePointer<WCHAR>(bitPattern: 14)  // RT_GROUP_ICON = 14
    let iconType = UnsafePointer<WCHAR>(bitPattern: 3)   // RT_ICON = 3

    let hResGrp = FindResourceW(hInst, iconName, grpType)
    let hResIco = FindResourceW(hInst, iconName, iconType)
    // Schreibe Diagnose in Debugger-Output (sichtbar in DebugView oder beim Debug-Build)
    let grpFound = hResGrp != nil
    let icoFound = hResIco != nil
    let grpErr = GetLastError()
    _ = grpFound; _ = icoFound; _ = grpErr  // Haltepunkt hier setzen

    let bigSize = GetSystemMetrics(SM_CXICON)
    let smSize  = GetSystemMetrics(SM_CXSMICON)

    // Versuche Icon zu laden - erst aus Ressource, dann aus PNG (RT_RCDATA 256)
    var hIconBig: HICON? = LoadImageW(hInst, iconName, UINT(IMAGE_ICON), bigSize, bigSize, 0) as HICON?
    if hIconBig == nil { hIconBig = LoadIconW(hInst, iconName) }
    if hIconBig == nil {
      // Fallback: PNG-Ressource → HICON via CreateIconIndirect
      hIconBig = _makeHIconFromPNG(size: bigSize)
    }
    if let hIconBig {
      SendMessageW(hwnd, UINT(WM_SETICON), WPARAM(ICON_BIG),
                   LPARAM(Int(bitPattern: hIconBig)))
    }

    var hIconSm: HICON? = LoadImageW(hInst, iconName, UINT(IMAGE_ICON), smSize, smSize, 0) as HICON?
    if hIconSm == nil { hIconSm = LoadIconW(hInst, iconName) }
    if hIconSm == nil {
      hIconSm = _makeHIconFromPNG(size: smSize)
    }
    if let hIconSm {
      SendMessageW(hwnd, UINT(WM_SETICON), WPARAM(ICON_SMALL),
                   LPARAM(Int(bitPattern: hIconSm)))
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Show / Destroy
  // ---------------------------------------------------------------------------

  func show() {
    guard let hwnd else { return }
    // Sync AWT bounds to the actual client area size BEFORE ShowWindow so that
    // the first WM_PAINT (which Win32 dispatches synchronously inside ShowWindow)
    // already sees the correct layout.
    var cr = RECT()
    GetClientRect(hwnd, &cr)
    let cw = Int(cr.right - cr.left), ch = Int(cr.bottom - cr.top)
    if cw > 0 && ch > 0 {
      awtWindow.bounds = java.awt.Rectangle(0, 0, cw, ch)
      awtWindow.validate()
    }
    ShowWindow(hwnd, SW_SHOWNORMAL)
    UpdateWindow(hwnd)
  }

  /// Re-reads the actual client size and re-validates the AWT layout.
  /// Call after attaching a menu bar or any operation that changes client area.
  func resyncBounds() {
    guard let hwnd else { return }
    var cr = RECT()
    GetClientRect(hwnd, &cr)
    let cw = Int(cr.right - cr.left), ch = Int(cr.bottom - cr.top)
    guard cw > 0 && ch > 0 else { return }
    awtWindow.bounds = java.awt.Rectangle(0, 0, cw, ch)
    awtWindow.validate()
    InvalidateRect(hwnd, nil, false)
  }

  func destroy() {
    if let hwnd { DestroyWindow(hwnd) }
    hwnd = nil
  }

  // ---------------------------------------------------------------------------
  // MARK: Modal loop
  // ---------------------------------------------------------------------------

  func runModalLoop() {
    var msg = MSG()
    while !modalDone {
      guard GetMessageW(&msg, nil, 0, 0) else { break }
      TranslateMessage(&msg)
      DispatchMessageW(&msg)
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Paint (WM_PAINT)
  // ---------------------------------------------------------------------------

  fileprivate func onPaint() {
    guard let hwnd else { return }
    var ps = PAINTSTRUCT()
    guard let hdc = BeginPaint(hwnd, &ps) else { return }
    defer { EndPaint(hwnd, &ps) }

    // Clear background
    let bg = awtWindow.background
    let colorRef = COLORREF(
      DWORD(bg.getRed()) |
      (DWORD(bg.getGreen()) << 8) |
      (DWORD(bg.getBlue())  << 16))
    let hBrush = CreateSolidBrush(colorRef)
    var clientRect = RECT()
    GetClientRect(hwnd, &clientRect)
    FillRect(hdc, &clientRect, hBrush)
    DeleteObject(hBrush)

    let g = java.awt.toolkit.gdi._GDIRenderTarget(hdc: hdc)
    awtWindow.paint(g)
  }

  // ---------------------------------------------------------------------------
  // MARK: Resize (WM_SIZE)
  // ---------------------------------------------------------------------------

  fileprivate func onResize(width: Int, height: Int) {
    guard width > 0, height > 0 else { return }
    awtWindow.bounds = java.awt.Rectangle(0, 0, width, height)
    awtWindow.validate()
    if let hwnd { InvalidateRect(hwnd, nil, false) }
  }

  // ---------------------------------------------------------------------------
  // MARK: Close (WM_CLOSE)
  // ---------------------------------------------------------------------------

  /// Fires `WINDOW_CLOSING` exactly once — mirrors `_SwiftUIWindowSizeDelegate`.
  fileprivate func onClose() {
    guard !didFireClosing else { return }
    didFireClosing = true
    MainActor.assumeIsolated {
      awtWindow.processWindowEvent(
        java.awt.event.WindowEvent(awtWindow,
          java.awt.event.WindowEvent.WINDOW_CLOSING))
      // For dialogs without a WindowListener, close the dialog explicitly.
      // For the main frame the WindowListener is responsible (e.g. terminate()).
      if let dialog = awtWindow as? java.awt.Dialog {
        java.awt.Toolkit.getDefaultToolkit().closeDialog(dialog)
      }
    }
    modalDone = true
  }

  // ---------------------------------------------------------------------------
  // MARK: Mouse input
  // ---------------------------------------------------------------------------

  // Currently open Choice popup — tracked so outside clicks close it.
  private weak var openChoice: java.awt.Choice?
  // Drag state
  private weak var draggingList:            java.awt.List?
  private weak var draggingScrollbar:       java.awt.Scrollbar?
  private weak var draggingScrollPane:      java.awt.ScrollPane?
  private weak var draggingTextAreaScroll:  java.awt.TextArea?
  // Button whose press started this mouse-down cycle
  private weak var pressedButton:           java.awt.Button?

  fileprivate func onMouseDown(x: Int, y: Int) {
    // ── Choice popup handling (must come before normal hit-test) ────────────
    if let choice = openChoice {
      let pr = choice.popupRect()
      if pr.contains(x, y) {
        // Click inside popup → select item and close
        if let idx = choice.popupItemIndex(atY: y) {
          choice.select(idx)
          choice.fireItemEvent(index: idx)
        }
        choice.isOpen = false
        openChoice    = nil
        invalidate()
        return
      } else {
        // Click outside popup → close it
        choice.isOpen = false
        openChoice    = nil
        invalidate()
        let closeHit = _AWTHitTest.find(x: x, y: y, in: awtWindow)
        if closeHit === choice { return }
        // Fall through so the actual click target is dispatched normally.
      }
    }

    let hit = _AWTHitTest.find(x: x, y: y, in: awtWindow)
    _Win32FocusManager.shared.requestFocus(hit)
    if let hwnd { SetCapture(hwnd) }
    // Track pressed button for drag-outside detection in onMouseUp
    if let btn = hit as? java.awt.Button {
      btn.isPressed = true
      pressedButton = btn
    }
    // Position caret / scrollbar in text components
    if let tf = hit as? java.awt.TextField {
      tf.setCaretPosition(tf.charIndex(at: x))
    } else if let ta = hit as? java.awt.TextArea {
      if let thumb = ta.verticalScrollbarThumbRect(), thumb.contains(x, y) {
        // TextArea internal scrollbar thumb drag
        draggingTextAreaScroll = ta
        ta.isScrollbarDragging = true
        ta.scrollDragStartY    = y
        ta.scrollDragStartOff  = ta.scrollOffsetY
      } else {
        // Caret placement; Shift extends selection
        let idx = ta.charIndex(atX: x, atY: y)
        let shiftDown = (GetKeyState(VK_SHIFT) & Int16(bitPattern: 0x8000)) != 0
        if shiftDown { ta.extendSelection(to: idx) } else { ta.setCaretPosition(idx) }
      }
    } else if let ch = hit as? java.awt.Choice {
      ch.isOpen  = !ch.isOpen
      openChoice = ch.isOpen ? ch : nil

    } else if let sb = hit as? java.awt.Scrollbar {
      let isVert = sb.orientation == java.awt.Scrollbar.VERTICAL
      let coord  = isVert ? y : x
      if sb.decrementButtonRect().contains(x, y) {
        // Decrement arrow — step by unitIncrement
        sb.value = sb.value - sb.unitIncrement
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_DECREMENT, isAdjusting: false)
      } else if sb.incrementButtonRect().contains(x, y) {
        // Increment arrow — step by unitIncrement
        sb.value = sb.value + sb.unitIncrement
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_INCREMENT, isAdjusting: false)
      } else if sb.thumbRect().contains(x, y) {
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

    } else if let sp = hit as? java.awt.ScrollPane {
      let (maxX, maxY) = sp.maxScroll()
      if let btn = sp.vDecrementButtonRect(), btn.contains(x, y) {
        // V-Pfeil aufwärts — unitIncrement
        sp.setScrollPosition(sp.scrollX, max(0, sp.scrollY - sp.scrollbarSize))
      } else if let btn = sp.vIncrementButtonRect(), btn.contains(x, y) {
        // V-Pfeil abwärts — unitIncrement
        sp.setScrollPosition(sp.scrollX, min(maxY, sp.scrollY + sp.scrollbarSize))
      } else if let btn = sp.hDecrementButtonRect(), btn.contains(x, y) {
        // H-Pfeil links — unitIncrement
        sp.setScrollPosition(max(0, sp.scrollX - sp.scrollbarSize), sp.scrollY)
      } else if let btn = sp.hIncrementButtonRect(), btn.contains(x, y) {
        // H-Pfeil rechts — unitIncrement
        sp.setScrollPosition(min(maxX, sp.scrollX + sp.scrollbarSize), sp.scrollY)
      } else if let thumb = sp.vThumbRect(), thumb.contains(x, y) {
        draggingScrollPane  = sp
        sp.isDraggingV      = true
        sp.dragStartY       = y
        sp.dragStartScrollY = sp.scrollY
      } else if let track = sp.vScrollbarRect(), track.contains(x, y) {
        sp.scrollY          = max(0, min(maxY, (y - track.y) * maxY / max(1, track.height)))
        draggingScrollPane  = sp
        sp.isDraggingV      = true
        sp.dragStartY       = y
        sp.dragStartScrollY = sp.scrollY
      } else if let thumb = sp.hThumbRect(), thumb.contains(x, y) {
        draggingScrollPane  = sp
        sp.isDraggingH      = true
        sp.dragStartX       = x
        sp.dragStartScrollX = sp.scrollX
      } else if let track = sp.hScrollbarRect(), track.contains(x, y) {
        sp.scrollX          = max(0, min(maxX, (x - track.x) * maxX / max(1, track.width)))
        draggingScrollPane  = sp
        sp.isDraggingH      = true
        sp.dragStartX       = x
        sp.dragStartScrollX = sp.scrollX
      }

    } else if let list = hit as? java.awt.List {
      if let thumb = list.scrollbarThumbRect(), thumb.contains(x, y) {
        // Thumb drag
        draggingList             = list
        list.isScrollbarDragging = true
        list.scrollDragStartY    = y
        list.scrollDragStartOff  = list.scrollOffset
      } else if let track = list.scrollbarTrackRect(), track.contains(x, y) {
        // Track click — jump to position, then allow drag
        let maxOff = list.maxScrollOffset()
        let relY   = y - track.y
        list.scrollOffset        = max(0, min(maxOff, relY * maxOff / max(1, track.height)))
        draggingList             = list
        list.isScrollbarDragging = true
        list.scrollDragStartY    = y
        list.scrollDragStartOff  = list.scrollOffset
      } else {
        if let idx = list.itemIndex(atY: y) {
          list.select(idx)
          list.fireItemEvent(index: idx,
                             stateChange: java.awt.event.ItemEvent.SELECTED)
        }
      }
    }
    invalidate()
  }

  fileprivate func onMouseUp(x: Int, y: Int) {
    // End ScrollPane drag
    if let sp = draggingScrollPane {
      sp.isDraggingV     = false
      sp.isDraggingH     = false
      draggingScrollPane = nil
      ReleaseCapture(); invalidate(); return
    }
    // End Scrollbar drag
    if let sb = draggingScrollbar {
      sb.isDragging     = false
      draggingScrollbar = nil
      sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: false)
      ReleaseCapture(); invalidate(); return
    }
    // End TextArea scrollbar drag
    if let ta = draggingTextAreaScroll {
      ta.isScrollbarDragging = false
      draggingTextAreaScroll = nil
      ReleaseCapture(); invalidate(); return
    }
    // End List scrollbar drag
    if let list = draggingList {
      list.isScrollbarDragging = false
      draggingList = nil
      ReleaseCapture(); invalidate(); return
    }
    // Button: only fire click if mouse released over same button (drag-outside = no click)
    if let btn = pressedButton {
      btn.isPressed = false
      pressedButton = nil
      ReleaseCapture()
      let hit = _AWTHitTest.find(x: x, y: y, in: awtWindow)
      if hit === btn { btn.doClick() }
      invalidate()
      return
    }
    // Other components — dispatch click (Choice/List/Scrollbar/ScrollPane already handled)
    let hit = _AWTHitTest.find(x: x, y: y, in: awtWindow)
    ReleaseCapture()
    if !(hit is java.awt.Choice), !(hit is java.awt.List),
       !(hit is java.awt.Scrollbar), !(hit is java.awt.ScrollPane) {
      _AWTHitTest.dispatch(click: hit ?? awtWindow)
    }
    invalidate()
  }

  fileprivate func onDoubleClick(x: Int, y: Int) {
    let hit = _AWTHitTest.find(x: x, y: y, in: awtWindow)
    if let list = hit as? java.awt.List {
      if let idx = list.itemIndex(atY: y) {
        list.fireActionEvent(index: idx)
      }
    }
    invalidate()
  }

  fileprivate func onMouseDrag(x: Int, y: Int) {
    // ScrollPane thumb drag
    if let sp = draggingScrollPane {
      if sp.isDraggingV, let track = sp.vScrollbarRect() {
        let (_, maxY) = sp.maxScroll()
        let dy    = y - sp.dragStartY
        let newY  = sp.dragStartScrollY + dy * maxY / max(1, track.height)
        sp.setScrollPosition(sp.scrollX, newY)
      } else if sp.isDraggingH, let track = sp.hScrollbarRect() {
        let (maxX, _) = sp.maxScroll()
        let dx    = x - sp.dragStartX
        let newX  = sp.dragStartScrollX + dx * maxX / max(1, track.width)
        sp.setScrollPosition(newX, sp.scrollY)
      }
      invalidate()
      return
    }
    // Standalone Scrollbar thumb drag
    if let sb = draggingScrollbar {
      let isVert = sb.orientation == java.awt.Scrollbar.VERTICAL
      let range  = sb.maximum - sb.minimum
      let track  = isVert ? sb.bounds.height : sb.bounds.width
      let coord  = isVert ? y : x
      let delta  = coord - sb.dragStartCoord
      let old    = sb.value
      sb.value   = sb.dragStartValue + delta * range / max(1, track)
      if sb.value != old {
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: true)
      }
      invalidate()
      return
    }
    // TextArea internal scrollbar drag
    if let ta = draggingTextAreaScroll {
      let fm       = ta.getFontMetrics(ta.font)
      let lineH    = max(1, fm.getHeight())
      let totalH   = ta.computeLines().count * lineH
      let visibleH = ta.bounds.height - 2 * ta.padY
      guard totalH > visibleH else { return }
      let trackH = ta.bounds.height
      let dy     = y - ta.scrollDragStartY
      let newOff = ta.scrollDragStartOff + dy * totalH / max(1, trackH)
      ta.scrollOffsetY = max(0, min(totalH - visibleH, newOff))
      invalidate()
      return
    }
    // List scrollbar thumb drag
    if let list = draggingList {
      guard list.needsScrollbar() else { return }
      let trackH = list.bounds.height
      let maxOff = list.maxScrollOffset()
      let dy     = y - list.scrollDragStartY
      let newOff = list.scrollDragStartOff + dy * maxOff / max(1, trackH)
      list.scrollOffset = max(0, min(maxOff, newOff))
      invalidate()
      return
    }
    // TextField selection drag
    if let tf = _Win32FocusManager.shared.focusOwner as? java.awt.TextField {
      tf.extendSelection(to: tf.charIndex(at: x))
      invalidate()
      return
    }
    // TextArea selection drag
    if let ta = _Win32FocusManager.shared.focusOwner as? java.awt.TextArea {
      ta.extendSelection(to: ta.charIndex(atX: x, atY: y))
      invalidate()
      return
    }
  }

  fileprivate func onMouseWheel(x: Int, y: Int, delta: Int) {
    guard let hit = _AWTHitTest.find(x: x, y: y, in: awtWindow) else { return }
    let lines = delta / 40

    if let sp = hit as? java.awt.ScrollPane {
      sp.setScrollPosition(sp.scrollX, sp.scrollY - lines)
    } else if let ta = hit as? java.awt.TextArea {
      let lineH    = max(1, ta.getFontMetrics(ta.font).getHeight())
      let totalH   = ta.computeLines().count * lineH
      let visibleH = ta.bounds.height - 2 * ta.padY
      ta.scrollOffsetY = max(0, min(max(0, totalH - visibleH),
                                    ta.scrollOffsetY - lines))
    } else if let sb = hit as? java.awt.Scrollbar {
      let old  = sb.value
      sb.value = sb.value - (sb.orientation == java.awt.Scrollbar.VERTICAL
                              ? lines : -lines)
      if sb.value != old {
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_INCREMENT)
      }
    } else if let list = hit as? java.awt.List {
      list.scrollOffset = max(0, min(list.maxScrollOffset(),
                                      list.scrollOffset - lines))
    }
    invalidate()
  }

  // ---------------------------------------------------------------------------
  // MARK: Cursor
  // ---------------------------------------------------------------------------

  /// Returns the Win32 IDC resource ID for the AWT component under (x,y).
  /// Returns a plain UInt so it can cross the MainActor boundary without Sendable issues.
  fileprivate func cursorIDC(x: Int, y: Int) -> UInt {
    let comp = _AWTHitTest.find(x: x, y: y, in: awtWindow)
    // Walk up the parent chain for an explicit cursor, then infer from type.
    let awtType: Int
    var found: Int? = nil
    var c: java.awt.Component? = comp
    while let current = c {
      if let t = current.cursor?.type { found = t; break }
      c = current.parent
    }
    if let explicit = found {
      awtType = explicit
    } else if comp is java.awt.TextComponent {
      awtType = java.awt.Cursor.TEXT_CURSOR
    } else {
      awtType = java.awt.Cursor.DEFAULT_CURSOR
    }
    switch awtType {
    case java.awt.Cursor.CROSSHAIR_CURSOR:                    return 32515 // IDC_CROSS
    case java.awt.Cursor.TEXT_CURSOR:                         return 32513 // IDC_IBEAM
    case java.awt.Cursor.WAIT_CURSOR:                         return 32514 // IDC_WAIT
    case java.awt.Cursor.HAND_CURSOR:                         return 32649 // IDC_HAND
    case java.awt.Cursor.MOVE_CURSOR:                         return 32646 // IDC_SIZEALL
    case java.awt.Cursor.N_RESIZE_CURSOR,
         java.awt.Cursor.S_RESIZE_CURSOR:                     return 32645 // IDC_SIZENS
    case java.awt.Cursor.E_RESIZE_CURSOR,
         java.awt.Cursor.W_RESIZE_CURSOR:                     return 32644 // IDC_SIZEWE
    case java.awt.Cursor.NE_RESIZE_CURSOR,
         java.awt.Cursor.SW_RESIZE_CURSOR:                    return 32643 // IDC_SIZENESW
    case java.awt.Cursor.NW_RESIZE_CURSOR,
         java.awt.Cursor.SE_RESIZE_CURSOR:                    return 32642 // IDC_SIZENWSE
    default:                                                  return 32512 // IDC_ARROW
    }
  }

  fileprivate func onRightMouseDown(x: Int, y: Int) {
    guard let hit   = _AWTHitTest.find(x: x, y: y, in: awtWindow),
          let popup = hit.popupMenu else { return }
    showPopupMenu(popup, x: x, y: y)
  }

  // ---------------------------------------------------------------------------
  // MARK: Keyboard input
  // ---------------------------------------------------------------------------

  fileprivate func onChar(_ ch: Character) {
    let v = ch.unicodeScalars.first?.value ?? 0
    guard v >= 32 && v != 127 else { return }
    _Win32FocusManager.shared.typeCharacter(ch)
    invalidate()
  }

  fileprivate func onKeyDown(vk: UINT, ctrl: Bool, shift: Bool) {
    let fm = _Win32FocusManager.shared
    switch Int32(vk) {
    case VK_BACK:    fm.handleBackspace();                         invalidate()
    case VK_DELETE:  fm.handleDelete();                            invalidate()
    case VK_RETURN:  fm.handleEnter();                             invalidate()
    case VK_LEFT:
      ctrl ? fm.moveCaretToEnd(end: false, extending: shift)
           : fm.moveCaret(by: -1, extending: shift);               invalidate()
    case VK_RIGHT:
      ctrl ? fm.moveCaretToEnd(end: true, extending: shift)
           : fm.moveCaret(by: 1, extending: shift);                invalidate()
    case VK_UP:      fm.moveCaretUp(extending: shift);             invalidate()
    case VK_DOWN:    fm.moveCaretDown(extending: shift);           invalidate()
    case 0x41 where ctrl: fm.selectAll();                          invalidate()
    case 0x43 where ctrl: fm.copySelection()
    case 0x56 where ctrl: fm.pasteText();                          invalidate()
    case 0x58 where ctrl: fm.cutSelection();                       invalidate()
    default: break
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: WM_COMMAND — menu dispatch
  // ---------------------------------------------------------------------------

  fileprivate func onCommand(itemId: UINT) {
    menuItems[itemId]?.doAction()
  }

  // ---------------------------------------------------------------------------
  // MARK: MenuBar
  // ---------------------------------------------------------------------------

  func attachMenuBar(_ menuBar: java.awt.MenuBar?) {
    guard let hwnd else { return }
    menuItems.removeAll()
    nextMenuId = 1000
    guard let menuBar else { SetMenu(hwnd, nil); return }
    let hBar = CreateMenu()!
    for menu in menuBar.getMenus() {
      let hSub = buildPopup(menu)
      appendWide(hBar, flags: UINT(MF_POPUP),
                 id: UINT_PTR(UInt(bitPattern: OpaquePointer(hSub))), label: menu.getLabel())
    }
    SetMenu(hwnd, hBar)
    DrawMenuBar(hwnd)
    // SetMenu reduces the client area by the menu-bar height but does NOT send
    // WM_SIZE synchronously.  We need the layout to reflect the smaller client
    // area right now (before the first WM_PAINT arrives), so compute the new
    // height ourselves: current AWT height minus the system menu-bar row height.
    let menuH = Int(GetSystemMetrics(SM_CYMENU))
    let oldH  = awtWindow.bounds.height
    let newH  = max(1, oldH - menuH)
    let newW  = awtWindow.bounds.width
    awtWindow.bounds = java.awt.Rectangle(0, 0, newW, newH)
    awtWindow.validate()
  }

  private func buildPopup(_ menu: java.awt.Menu) -> HMENU {
    let hMenu = CreatePopupMenu()!
    for item in menu.getItems() {
      if item.isSeparator {
        AppendMenuW(hMenu, UINT(MF_SEPARATOR), 0, nil)
      } else if let sub = item as? java.awt.Menu {
        appendWide(hMenu, flags: UINT(MF_POPUP),
                   id: UINT_PTR(UInt(bitPattern: OpaquePointer(buildPopup(sub)))), label: sub.getLabel())
      } else {
        let mid = nextMenuId; nextMenuId += 1
        menuItems[mid] = item
        var flags = UINT(MF_STRING)
        if !item.isEnabled() { flags |= UINT(MF_GRAYED) }
        if let cb = item as? java.awt.CheckboxMenuItem,
           cb.getState() { flags |= UINT(MF_CHECKED) }
        appendWide(hMenu, flags: flags, id: UINT_PTR(mid), label: item.getLabel())
      }
    }
    return hMenu
  }

  private func appendWide(_ hMenu: HMENU, flags: UINT, id: UINT_PTR, label: String) {
    let wide = Array(label.utf16) + [WCHAR(0)]
    _ = wide.withUnsafeBufferPointer { buf in
      AppendMenuW(hMenu, flags, id, buf.baseAddress!)
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: PopupMenu
  // ---------------------------------------------------------------------------

  func showPopupMenu(_ menu: java.awt.PopupMenu, x: Int, y: Int) {
    guard let hwnd else { return }
    menuItems.removeAll(); nextMenuId = 1000
    let hMenu = buildPopup(menu)
    var pt    = POINT(x: LONG(x), y: LONG(y))
    ClientToScreen(hwnd, &pt)
    TrackPopupMenu(hMenu, UINT(TPM_LEFTALIGN | TPM_TOPALIGN),
                   pt.x, pt.y, 0, hwnd, nil)
    DestroyMenu(hMenu)
  }

  // ---------------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------------

  private func invalidate() {
    if let hwnd { InvalidateRect(hwnd, nil, false) }
  }

  // ---------------------------------------------------------------------------
  // MARK: Window class registration
  // ---------------------------------------------------------------------------

  fileprivate static let windowClassName: [WCHAR] =
    Array("JavApiGDIWindow".utf16) + [WCHAR(0)]

  private static var classRegistered = false

  static func registerWindowClass() {
    guard !classRegistered else { return }
    classRegistered = true
    windowClassName.withUnsafeBufferPointer { clsBuf in
      // Load the application icon from the embedded RT_GROUP_ICON resource
      // (ID 1, set by build-exe.cmd).  Falls back to the default app icon if
      // the resource is absent (e.g. during swift run without build-exe.cmd).
      let hInst   = GetModuleHandleW(nil)
      let iconId  = UnsafePointer<WCHAR>(bitPattern: 1)
      let bigSz   = GetSystemMetrics(SM_CXICON)
      let smSz    = GetSystemMetrics(SM_CXSMICON)

      var hIcon: HICON? = LoadImageW(hInst, iconId, UINT(IMAGE_ICON), bigSz, bigSz, 0) as HICON?
      if hIcon == nil { hIcon = LoadIconW(hInst, iconId) }
      if hIcon == nil { hIcon = _makeHIconFromPNG(size: bigSz) }
      if hIcon == nil { hIcon = LoadIconW(nil, IDI_APPLICATION) }

      var hIconSm: HICON? = LoadImageW(hInst, iconId, UINT(IMAGE_ICON), smSz, smSz, 0) as HICON?
      if hIconSm == nil { hIconSm = LoadIconW(hInst, iconId) }
      if hIconSm == nil { hIconSm = _makeHIconFromPNG(size: smSz) }
      if hIconSm == nil { hIconSm = LoadIconW(nil, IDI_APPLICATION) }

      var wc = WNDCLASSEXW()
      wc.cbSize        = UINT(MemoryLayout<WNDCLASSEXW>.size)
      wc.style         = UINT(CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS)
      wc.lpfnWndProc   = _win32WndProc
      wc.hInstance     = hInst
      wc.hIcon         = hIcon
      wc.hIconSm       = hIconSm
      wc.hCursor       = nil  // NULL: we manage cursor ourselves in WM_SETCURSOR / WM_MOUSEMOVE
      wc.hbrBackground = HBRUSH(bitPattern: UInt(COLOR_WINDOW + 1))
      wc.lpszClassName = clsBuf.baseAddress!
      RegisterClassExW(&wc)
    }
  }
}

// =============================================================================
// MARK: - PNG → HICON helper
// =============================================================================

/// Creates an `HICON` from the PNG embedded as RT_RCDATA resource ID 256.
///
/// Used as a fallback when `LoadIconW` / `LoadImageW` cannot find an
/// RT_GROUP_ICON entry (e.g. because the ICO DIB format was not accepted).
/// The PNG is loaded with `_PNGLoader`, scaled to `size × size`, and converted
/// to a premultiplied BGRA `HBITMAP` from which `CreateIconIndirect` builds the
/// `HICON`.
@discardableResult
func _makeHIconFromPNG(size: INT) -> HICON? {
  guard let img = _PNGLoader.loadFromResource(id: 256) else { return nil }

  let sw = img.getWidth(nil), sh = img.getHeight(nil)
  guard sw > 0, sh > 0 else { return nil }

  let sz = Int(size)

  // Build premultiplied BGRA pixel buffer, scaling from sw×sh to sz×sz
  var pixels = [UInt8](repeating: 0, count: sz * sz * 4)
  for row in 0..<sz {
    for col in 0..<sz {
      let srcCol = col * sw / sz
      let srcRow = row * sh / sz
      let argb   = img.getRGB(srcCol, srcRow)
      let i      = (row * sz + col) * 4
      let a      = UInt32((argb >> 24) & 0xFF)
      pixels[i+0] = UInt8((UInt32((argb >>  0) & 0xFF) * a + 127) / 255)  // B premul
      pixels[i+1] = UInt8((UInt32((argb >>  8) & 0xFF) * a + 127) / 255)  // G premul
      pixels[i+2] = UInt8((UInt32((argb >> 16) & 0xFF) * a + 127) / 255)  // R premul
      pixels[i+3] = UInt8(a)
    }
  }

  // Create a 32bpp DIB section for the XOR mask
  var bmi = BITMAPV5HEADER()
  bmi.bV5Size        = DWORD(MemoryLayout<BITMAPV5HEADER>.size)
  bmi.bV5Width       = LONG(sz)
  bmi.bV5Height      = -LONG(sz)   // top-down
  bmi.bV5Planes      = 1
  bmi.bV5BitCount    = 32
  bmi.bV5Compression = DWORD(BI_BITFIELDS)
  bmi.bV5RedMask     = 0x00FF0000
  bmi.bV5GreenMask   = 0x0000FF00
  bmi.bV5BlueMask    = 0x000000FF
  bmi.bV5AlphaMask   = 0xFF000000

  let hdc = GetDC(nil)
  defer { ReleaseDC(nil, hdc) }

  var bits: UnsafeMutableRawPointer? = nil
  let hColor = withUnsafeMutablePointer(to: &bmi) { ptr -> HBITMAP? in
    ptr.withMemoryRebound(to: BITMAPINFO.self, capacity: 1) { bmiPtr in
      CreateDIBSection(hdc, bmiPtr, UINT(DIB_RGB_COLORS), &bits, nil, 0)
    }
  }
  guard let hColor, let bits else { return nil }
  defer { DeleteObject(hColor) }

  pixels.withUnsafeBytes { raw in
    bits.copyMemory(from: raw.baseAddress!, byteCount: sz * sz * 4)
  }

  // AND mask: all zeros (alpha channel drives transparency via BITMAPV5HEADER)
  let hMask = CreateBitmap(INT(sz), INT(sz), 1, 1, nil)
  defer { if let m = hMask { DeleteObject(m) } }

  var ii = ICONINFO()
  ii.fIcon    = true
  ii.xHotspot = 0
  ii.yHotspot = 0
  ii.hbmMask  = hMask
  ii.hbmColor = hColor

  return CreateIconIndirect(&ii)
}

// =============================================================================
// MARK: Win32 WndProc
// =============================================================================

private func _win32WndProc(
  _ hwnd: HWND?, _ msg: UINT, _ wParam: WPARAM, _ lParam: LPARAM
) -> LRESULT {

  let rawPtr = GetWindowLongPtrW(hwnd, GWLP_USERDATA)
  guard rawPtr != 0 else { return DefWindowProcW(hwnd, msg, wParam, lParam) }
  let canvas = Unmanaged<_Win32Canvas>
    .fromOpaque(UnsafeRawPointer(bitPattern: Int(rawPtr))!)
    .takeUnretainedValue()

  switch msg {

  case UINT(WM_PAINT):
    MainActor.assumeIsolated { canvas.onPaint() }
    return 0

  case UINT(WM_SIZE):
    let w = Int(_LOWORD(DWORD_PTR(lParam)))
    let h = Int(_HIWORD(DWORD_PTR(lParam)))
    MainActor.assumeIsolated { canvas.onResize(width: w, height: h) }
    return 0

  case UINT(WM_SETCURSOR):
    // Only handle cursor in the client area (HTCLIENT = 1)
    if _LOWORD(DWORD_PTR(UInt64(bitPattern: Int64(lParam)))) == 1 {
      var pt = POINT()
      GetCursorPos(&pt)
      let ptX = Int(pt.x), ptY = Int(pt.y)
      // ScreenToClient needs mutable POINT — call via withUnsafeMutablePointer
      var pt2 = POINT(x: LONG(ptX), y: LONG(ptY))
      ScreenToClient(hwnd, &pt2)
      let cx = Int(pt2.x), cy = Int(pt2.y)
      let idcId: UInt = MainActor.assumeIsolated {
        canvas.cursorIDC(x: cx, y: cy)
      }
      SetCursor(LoadCursorW(nil, UnsafePointer<WCHAR>(bitPattern: idcId)))
      return 1
    }
    return DefWindowProcW(hwnd, msg, wParam, lParam)

  case UINT(WM_CLOSE):
    MainActor.assumeIsolated { canvas.onClose() }
    return 0

  case UINT(WM_DESTROY):
    let isDialog = MainActor.assumeIsolated { canvas.isDialog }
    Unmanaged<_Win32Canvas>
      .fromOpaque(UnsafeRawPointer(bitPattern: Int(rawPtr))!).release()
    SetWindowLongPtrW(hwnd, GWLP_USERDATA, 0)
    if !isDialog { PostQuitMessage(0) }
    return 0

  case UINT(WM_MOUSEMOVE):
    let mx = _GET_X_LPARAM(lParam), my = _GET_Y_LPARAM(lParam)
    let idcMove: UInt = MainActor.assumeIsolated { canvas.cursorIDC(x: mx, y: my) }
    SetCursor(LoadCursorW(nil, UnsafePointer<WCHAR>(bitPattern: idcMove)))
    MainActor.assumeIsolated { canvas.onMouseDrag(x: mx, y: my) }
    return DefWindowProcW(hwnd, msg, wParam, lParam)

  case UINT(WM_LBUTTONDOWN):
    MainActor.assumeIsolated {
      canvas.onMouseDown(x: _GET_X_LPARAM(lParam),
                          y: _GET_Y_LPARAM(lParam))
    }
    return 0

  case UINT(WM_LBUTTONUP):
    MainActor.assumeIsolated {
      canvas.onMouseUp(x: _GET_X_LPARAM(lParam),
                        y: _GET_Y_LPARAM(lParam))
    }
    return 0

  case UINT(WM_LBUTTONDBLCLK):
    MainActor.assumeIsolated {
      canvas.onDoubleClick(x: _GET_X_LPARAM(lParam),
                            y: _GET_Y_LPARAM(lParam))
    }
    return 0

  case UINT(WM_MOUSEWHEEL):
    let delta = Int(Int16(bitPattern: _HIWORD(DWORD_PTR(wParam))))
    var pt    = POINT(x: LONG(_GET_X_LPARAM(lParam)),
                      y: LONG(_GET_Y_LPARAM(lParam)))
    ScreenToClient(hwnd, &pt)
    MainActor.assumeIsolated {
      canvas.onMouseWheel(x: Int(pt.x), y: Int(pt.y), delta: delta)
    }
    return 0

  case UINT(WM_RBUTTONDOWN):
    MainActor.assumeIsolated {
      canvas.onRightMouseDown(x: _GET_X_LPARAM(lParam),
                               y: _GET_Y_LPARAM(lParam))
    }
    return 0

  case UINT(WM_CHAR):
    if let scalar = Unicode.Scalar(UInt32(wParam)) {
      MainActor.assumeIsolated { canvas.onChar(Character(scalar)) }
    }
    return 0

  case UINT(WM_KEYDOWN):
    let ctrl  = (GetKeyState(VK_CONTROL) & Int16(bitPattern: 0x8000)) != 0
    let shift = (GetKeyState(VK_SHIFT)   & Int16(bitPattern: 0x8000)) != 0
    MainActor.assumeIsolated {
      canvas.onKeyDown(vk: UINT(wParam), ctrl: ctrl, shift: shift)
    }
    return 0

  case UINT(WM_COMMAND):
    let itemId = UINT(_LOWORD(DWORD_PTR(wParam)))
    if itemId >= 1000 {
      MainActor.assumeIsolated { canvas.onCommand(itemId: itemId) }
    }
    return 0

  default:
    return DefWindowProcW(hwnd, msg, wParam, lParam)
  }
}

#endif  // os(Windows)
