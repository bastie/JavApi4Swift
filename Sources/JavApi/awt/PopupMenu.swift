/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Kontextmenü das an einer beliebigen Position eingeblendet wird —
  /// mirrors `java.awt.PopupMenu`.
  @MainActor
  open class PopupMenu: Menu {

    public override init(_ label: String = "", tearOff: Bool = false) {
      super.init(label, tearOff: tearOff)
    }

    /// Zeigt das PopupMenu an Position `(x, y)` relativ zu `origin`.
    /// Auf macOS wird ein `NSMenu` an dieser Stelle eingeblendet.
    open func show(_ origin: Component, _ x: Int, _ y: Int) {
#if canImport(AppKit)
      showNative(origin: origin, x: x, y: y)
#endif
    }
  }
}

// =============================================================================
// MARK: - macOS-Implementierung
// =============================================================================

#if canImport(AppKit)
import AppKit

extension java.awt.PopupMenu {

  @MainActor
  func showNative(origin: java.awt.Component, x: Int, y: Int) {
    // Fallback ohne NSEvent: Koordinaten über NSView umrechnen
    guard let view = NSApp.keyWindow?.contentView else { return }
    // AWT: Y von oben; NSView: Y von unten — im ContentView entspricht
    // AWT-Y dem NSView-Y gespiegelt an der Fensterhöhe
    let viewH = view.bounds.height
    let nsX = CGFloat(origin.bounds.x + x)
    let nsY = viewH - CGFloat(origin.bounds.y + y)
    let nsMenu = buildNSMenu()
    nsMenu.popUp(positioning: nil, at: NSPoint(x: nsX, y: nsY), in: view)
  }

  /// Zeigt das Menü exakt am Klickpunkt des NSEvent — präzise Koordinaten.
  @MainActor
  func showAtEvent(_ event: NSEvent, in view: NSView) {
    let nsMenu = buildNSMenu()
    // NSMenu.popUp(with:) positioniert das Menü korrekt am Mauszeiger
    nsMenu.popUp(positioning: nil,
                 at: view.convert(event.locationInWindow, from: nil),
                 in: view)
  }

  @MainActor
  private func buildNSMenu() -> NSMenu {
    let nsMenu = NSMenu(title: getLabel())
    for item in getItems() {
      nsMenu.addItem(nsMenuItem(from: item))
    }
    return nsMenu
  }

  /// Lokale Hilfsmethode — baut ein einfaches NSMenuItem ohne Ziel-Action-Verbindung.
  /// (Für vollständige Action-Anbindung wird AWTWindowHost.makeNSMenuItem verwendet,
  ///  das ist aber aus PopupMenu heraus nicht erreichbar ohne zirkuläre Abhängigkeit.)
  @MainActor
  private func nsMenuItem(from item: java.awt.MenuItem) -> NSMenuItem {
    if item.getLabel() == "-" { return NSMenuItem.separator() }

    if let subMenu = item as? java.awt.Menu {
      let nsItem = NSMenuItem(title: subMenu.getLabel(), action: nil, keyEquivalent: "")
      let sub = NSMenu(title: subMenu.getLabel())
      for child in subMenu.getItems() { sub.addItem(nsMenuItem(from: child)) }
      nsItem.submenu = sub
      return nsItem
    }

    // Target-Objekt zum Weiterleiten der Aktion
    let handler = _PopupMenuItemTarget(menuItem: item)
    let nsItem = NSMenuItem(
      title: item.getLabel(),
      action: #selector(_PopupMenuItemTarget.trigger),
      keyEquivalent: "")
    nsItem.target = handler
    nsItem.isEnabled = item.isEnabled()
    // Stark halten über assoziiertes Objekt
    objc_setAssociatedObject(nsItem, &_popupTargetKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return nsItem
  }
}

private nonisolated(unsafe) var _popupTargetKey: UInt8 = 0

@MainActor
@objc private final class _PopupMenuItemTarget: NSObject {
  private let menuItem: java.awt.MenuItem
  init(menuItem: java.awt.MenuItem) { self.menuItem = menuItem }
  @objc func trigger(_ sender: Any?) {
    menuItem.doAction()
  }
}

#endif
