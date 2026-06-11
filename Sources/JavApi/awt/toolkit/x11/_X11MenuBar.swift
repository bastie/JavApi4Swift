/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)

// =============================================================================
// MARK: _X11MenuBar
// =============================================================================

/// Renders a `java.awt.MenuBar` as a horizontal strip at the top of an X11
/// window and maps click coordinates to the corresponding `java.awt.Menu`.
///
/// All geometry is in **logical AWT coordinates** — the caller (`_X11WindowHost`)
/// applies the HiDPI `scaleFactor` when passing values to X11 drawing functions.
///
/// ### Layout
/// ```
/// ┌──────────────────────────────────────────┐  ← menuBarHeight (logical px)
/// │  File   Edit   Help                      │
/// └──────────────────────────────────────────┘
/// ```
@MainActor
final class _X11MenuBar {

  // ---------------------------------------------------------------------------
  // MARK: Constants
  // ---------------------------------------------------------------------------

  /// Height of the menu bar strip in logical pixels.
  static let menuBarHeight: Int = 24

  /// Horizontal padding on each side of a menu title.
  private static let titlePadX: Int = 8

  // ---------------------------------------------------------------------------
  // MARK: State
  // ---------------------------------------------------------------------------

  private let menuBar: java.awt.MenuBar

  /// Hit rectangles for each top-level menu — in logical coordinates,
  /// relative to the window origin (y starts at 0 = top of menu bar).
  private(set) var menuRects: [(menu: java.awt.Menu, rect: java.awt.Rectangle)] = []

  /// The menu currently shown as open (highlighted).
  var openMenu: java.awt.Menu? = nil

  // ---------------------------------------------------------------------------
  // MARK: Init
  // ---------------------------------------------------------------------------

  init(_ menuBar: java.awt.MenuBar) {
    self.menuBar = menuBar
  }

  // ---------------------------------------------------------------------------
  // MARK: Layout
  // ---------------------------------------------------------------------------

  /// Recomputes `menuRects` for the given window width.
  /// Call whenever the window is resized or the menu bar changes.
  func layout(windowWidth: Int, fontMetrics: java.awt.FontMetrics) {
    menuRects.removeAll()
    var x = 0
    let h = Self.menuBarHeight
    for menu in menuBar.getMenus() {
      let textW = fontMetrics.stringWidth(menu.getLabel())
      let w = textW + Self.titlePadX * 2
      menuRects.append((menu: menu,
                        rect: java.awt.Rectangle(x, 0, w, h)))
      x += w
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Hit test
  // ---------------------------------------------------------------------------

  /// Returns the `Menu` whose title rect contains the logical point `(x, y)`.
  /// `y` must be relative to the top of the window (i.e. within `[0, menuBarHeight)`).
  func menu(at x: Int, y: Int) -> java.awt.Menu? {
    guard y >= 0 && y < Self.menuBarHeight else { return nil }
    return menuRects.first { $0.rect.contains(x, y) }?.menu
  }

  // ---------------------------------------------------------------------------
  // MARK: Drawing
  // ---------------------------------------------------------------------------

  /// Draws the menu bar using the provided `_X11Graphics`.
  /// The graphics context's origin is assumed to be at the window's top-left.
  func draw(using g: java.awt.toolkit.x11._X11Graphics,
            windowWidth: Int) {
    let h  = Self.menuBarHeight
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let fm   = java.awt.FontMetrics.make(for: font)

    // Recompute layout whenever window width changes or items changed
    layout(windowWidth: windowWidth, fontMetrics: fm)

    // Background
    g.setColor(java.awt.SystemColor.menu)
    g.fillRect(0, 0, windowWidth, h)

    // Bottom border
    g.setColor(java.awt.SystemColor.controlShadow)
    g.drawLine(0, h - 1, windowWidth, h - 1)

    // Menu titles
    for (menu, rect) in menuRects {
      // Highlight open menu
      if let open = openMenu, open === menu {
        g.setColor(java.awt.SystemColor.textHighlight)
        g.fillRect(rect.x, rect.y, rect.width, rect.height - 1)
        g.setColor(java.awt.SystemColor.textHighlightText)
      } else {
        g.setColor(java.awt.SystemColor.menuText)
      }
      let textY = rect.y + (h - fm.getHeight()) / 2 + fm.getAscent()
      g.drawString(menu.getLabel(), rect.x + Self.titlePadX, textY)
    }
  }
}

#endif
