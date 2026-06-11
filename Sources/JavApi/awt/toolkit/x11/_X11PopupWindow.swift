/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)

// =============================================================================
// MARK: _X11PopupWindow
// =============================================================================

/// Renders a dropdown menu list for a `java.awt.Menu` by painting it as an
/// overlay on the owner window.  A separate override-redirect X11 window would
/// require `XSetWindowAttributes` (CWOverrideRedirect) and grab handling —
/// this simpler approach keeps all rendering inside the existing window and GC.
///
/// ### Lifecycle
/// ```
/// _X11PopupWindow.show(menu:at:y:host:ownerXwin:ownerWindow:)
///    → stores activePopup
///    → host repaints (menu bar draw calls drawOverlay)
///
/// dismiss()
///    → clears activePopup, host repaints
/// ```
@MainActor
final class _X11PopupWindow {

  // ---------------------------------------------------------------------------
  // MARK: Shared active popup (at most one open at a time)
  // ---------------------------------------------------------------------------

  static var activePopup: _X11PopupWindow? = nil

  // ---------------------------------------------------------------------------
  // MARK: Geometry constants (logical px)
  // ---------------------------------------------------------------------------

  static let itemHeight:     Int = 20
  static let paddingX:       Int = 12
  static let separatorH:     Int = 5
  static let minWidth:       Int = 120

  // ---------------------------------------------------------------------------
  // MARK: State
  // ---------------------------------------------------------------------------

  private let menu:          java.awt.Menu
  /// X (logical) coordinate of the popup's left edge in window space
  let x:                     Int
  /// Y (logical) coordinate of the popup's top edge in window space
  let y:                     Int
  /// Cached item rects — (item, rect) in window-local logical coordinates
  private(set) var itemRects: [(item: java.awt.MenuItem, rect: java.awt.Rectangle)] = []
  /// Currently highlighted item index (-1 = none)
  var highlightedIndex:       Int = -1

  private weak var ownerWindow: java.awt.Window?
  private let ownerXwin: UInt
  private weak var host: _X11WindowHost?

  // ---------------------------------------------------------------------------
  // MARK: Factory
  // ---------------------------------------------------------------------------

  static func show(menu: java.awt.Menu,
                   at screenX: Int, y screenY: Int,
                   host: _X11WindowHost,
                   ownerXwin: UInt,
                   ownerWindow: java.awt.Window?) {
    // Dismiss any existing popup first
    activePopup?.dismiss(repaint: false)
    let popup = _X11PopupWindow(menu: menu,
                                 x: screenX, y: screenY,
                                 host: host,
                                 ownerXwin: ownerXwin,
                                 ownerWindow: ownerWindow)
    activePopup = popup
    // Trigger repaint so the popup gets drawn
    if let win = ownerWindow {
      host.repaintWindow(win)
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Init
  // ---------------------------------------------------------------------------

  private init(menu: java.awt.Menu,
               x: Int, y: Int,
               host: _X11WindowHost,
               ownerXwin: UInt,
               ownerWindow: java.awt.Window?) {
    self.menu        = menu
    self.x           = x
    self.y           = y
    self.host        = host
    self.ownerXwin   = ownerXwin
    self.ownerWindow = ownerWindow
    buildItemRects()
  }

  // ---------------------------------------------------------------------------
  // MARK: Layout
  // ---------------------------------------------------------------------------

  private func buildItemRects() {
    itemRects.removeAll()
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let fm   = java.awt.FontMetrics.make(for: font)

    // Compute width: widest label + padding
    var maxW = Self.minWidth
    for item in menu.getItems() {
      if !item.isSeparator {
        let w = fm.stringWidth(item.getLabel()) + Self.paddingX * 2
        if w > maxW { maxW = w }
      }
    }

    var iy = y
    for item in menu.getItems() {
      let h = item.isSeparator ? Self.separatorH : Self.itemHeight
      itemRects.append((item: item,
                        rect: java.awt.Rectangle(x, iy, maxW, h)))
      iy += h
    }
  }

  /// Total height of this popup in logical pixels.
  var height: Int {
    guard let last = itemRects.last else { return 0 }
    return last.rect.y + last.rect.height - y
  }

  /// Total width of this popup in logical pixels.
  var width: Int {
    itemRects.first?.rect.width ?? Self.minWidth
  }

  // ---------------------------------------------------------------------------
  // MARK: Hit test
  // ---------------------------------------------------------------------------

  /// Returns the item (and its index) at the given window-local logical point.
  func item(at px: Int, py: Int) -> (item: java.awt.MenuItem, index: Int)? {
    for (i, entry) in itemRects.enumerated() {
      if !entry.item.isSeparator && entry.rect.contains(px, py) {
        return (item: entry.item, index: i)
      }
    }
    return nil
  }

  /// Returns `true` if the logical point is inside the popup rectangle.
  func contains(_ px: Int, _ py: Int) -> Bool {
    guard !itemRects.isEmpty else { return false }
    return px >= x && px < x + width && py >= y && py < y + height
  }

  // ---------------------------------------------------------------------------
  // MARK: Drawing (called from _X11WindowHost.repaint via drawOverlay)
  // ---------------------------------------------------------------------------

  func draw(using g: java.awt.toolkit.x11._X11Graphics) {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let fm   = java.awt.FontMetrics.make(for: font)

    // Shadow / border
    g.setColor(java.awt.SystemColor.controlShadow)
    g.drawRect(x - 1, y - 1, width + 2, height + 2)

    // Background
    g.setColor(java.awt.SystemColor.menu)
    g.fillRect(x, y, width, height)

    for (i, entry) in itemRects.enumerated() {
      let item = entry.item
      let rect = entry.rect
      if item.isSeparator {
        g.setColor(java.awt.SystemColor.controlShadow)
        let midY = rect.y + rect.height / 2
        g.drawLine(rect.x + 2, midY, rect.x + rect.width - 2, midY)
      } else {
        // Highlight row
        if i == highlightedIndex {
          g.setColor(java.awt.SystemColor.textHighlight)
          g.fillRect(rect.x, rect.y, rect.width, rect.height)
          g.setColor(java.awt.SystemColor.textHighlightText)
        } else if !item.enabled {
          g.setColor(java.awt.SystemColor.controlShadow)
        } else {
          g.setColor(java.awt.SystemColor.menuText)
        }
        // Baseline: center vertically, clamp so text is never above rect.y
        let leading = max(0, rect.height - fm.getAscent() - fm.getDescent())
        let textY = rect.y + leading / 2 + fm.getAscent()
        g.drawString(item.getLabel(), rect.x + Self.paddingX, textY)
      }
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Dismiss
  // ---------------------------------------------------------------------------

  func dismiss(repaint: Bool = true) {
    _X11PopupWindow.activePopup = nil
    if repaint, let win = ownerWindow {
      host?.repaintWindow(win)
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Action dispatch
  // ---------------------------------------------------------------------------

  func activate(item: java.awt.MenuItem) {
    dismiss()
    item.doAction()
  }
}

#endif
