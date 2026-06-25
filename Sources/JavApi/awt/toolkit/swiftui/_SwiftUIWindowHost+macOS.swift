/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

#if os(macOS)
import AppKit

// ---------------------------------------------------------------------------
// MARK: NSWindowDelegate — erzwingt Mindest- und Höchstgröße aus AWT
// ---------------------------------------------------------------------------



extension _SwiftUIWindowHost {
  
  /// Öffnet ein `java.awt.Window` als eigenständiges `NSWindow`.
  ///
  /// Rufe dies statt `show(_:)` auf, wenn du echte separate Fenster
  /// mit nativem macOS-Chrome möchtest:
  /// ```swift
  /// _SwiftUIWindowHost.shared.openNewWindow(for: myFrame)
  /// ```
  @MainActor
  public func openNewWindow(for awtWindow: java.awt.Window) {
    // Komponentenbaum vollständig layouten
    awtWindow.validate()

    // Kein festes .frame() → NSHostingView füllt das NSWindow aus;
    // setFrameSize in _SwiftUINativeCanvas löst validate() aus, wenn sich die Größe ändert.
    let hostingView = NSHostingView(
      rootView: _SwiftUICanvasViewRepresentable(component: awtWindow)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea())
    hostingView.autoresizingMask = [.width, .height]

    var frameMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
    let isResizable = (awtWindow as? java.awt.Frame)?.isResizable() ?? true
    if isResizable { frameMask.insert(.resizable) }

    let nsWindow = NSWindow(
      contentRect: NSRect(
        x: awtWindow.bounds.x, y: awtWindow.bounds.y,
        width: awtWindow.bounds.width, height: awtWindow.bounds.height),
      styleMask: frameMask,
      backing: .buffered,
      defer: false)

    nsWindow.title = (awtWindow as? java.awt.Frame)?.title ?? ""
    nsWindow.contentView = hostingView
    nsWindow.isReleasedWhenClosed = false

    // Delegate erzwingt Mindest-/Höchstgröße zuverlässig über windowWillResize.
    // Der Delegate muss stark gehalten werden — wir hängen ihn ans NSWindow.
    let sizeDelegate = _SwiftUIWindowSizeDelegate(awtWindow)
    nsWindow.delegate = sizeDelegate
    // NSWindow hält delegate nur weak → wir speichern ihn als assoziiertes Objekt.
    objc_setAssociatedObject(nsWindow, &_SwiftUIWindowHost.delegateKey,
                             sizeDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    if awtWindow.bounds.x == 0 && awtWindow.bounds.y == 0 {
      nsWindow.center()
    }
    nsWindow.makeKeyAndOrderFront(nil)

    // Schließen-Button → Window.setVisible(false) / dispose()
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification,
      object: nsWindow,
      queue: .main) { [weak self] _ in
        guard let self else { return }
        Task { @MainActor in
          self.hide(awtWindow)
        }
      }
  }

  /// Schlüssel für `objc_setAssociatedObject` — hält den Delegate am Leben.
  private static var delegateKey: UInt8 = 0

  // ---------------------------------------------------------------------------
  // MARK: MenuBar
  // ---------------------------------------------------------------------------

  /// Bindet eine `java.awt.MenuBar` an das native NSWindow des gegebenen Frames.
  ///
  /// Die Menüleiste wird als `NSMenu` aufgebaut und in `NSApp.mainMenu` eingehängt,
  /// sobald das Fenster key wird. Wird `nil` übergeben, wird die Menüleiste entfernt.
  @MainActor
  public func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
    guard let menuBar else {
      // Menüleiste entfernen — macOS-Standard-Menü bleibt
      return
    }
    let nsMenu = buildNSMenu(from: menuBar)
    // SwiftUI überschreibt mainMenu beim App-Start — deshalb verzögert setzen
    // damit unser Menü nach SwiftUIs eigener Initialisierung greift.
    DispatchQueue.main.async {
      NSApp.mainMenu = nsMenu
    }
  }

  /// Wandelt eine `java.awt.MenuBar` in eine `NSMenu`-Hierarchie um.
  @MainActor
  private func buildNSMenu(from menuBar: java.awt.MenuBar) -> NSMenu {
    let mainMenu = NSMenu(title: "MainMenu")
    for menu in menuBar.getMenus() {
      let topItem = NSMenuItem(title: menu.getLabel(), action: nil, keyEquivalent: "")
      let submenu = buildNSSubmenu(from: menu)
      topItem.submenu = submenu
      mainMenu.addItem(topItem)
    }
    return mainMenu
  }

  /// Wandelt ein `java.awt.Menu` in ein `NSMenu` um (rekursiv für Untermenüs).
  @MainActor
  private func buildNSSubmenu(from menu: java.awt.Menu) -> NSMenu {
    let nsMenu = NSMenu(title: menu.getLabel())
    for item in menu.getItems() {
      nsMenu.addItem(makeNSMenuItem(from: item))
    }
    return nsMenu
  }

  /// Erzeugt ein einzelnes `NSMenuItem` aus einem `java.awt.MenuItem`.
  @MainActor
  func makeNSMenuItem(from item: java.awt.MenuItem) -> NSMenuItem {
    // Separator — typsicher über MenuItem.isSeparator geprüft.
    // AppKit rendert NSMenuItem.separator() als native Trennlinie,
    // Dark-Mode-aware ohne weiteres Zutun.
    if item.isSeparator {
      return NSMenuItem.separator()
    }

    let nsItem: NSMenuItem

    if let cbItem = item as? java.awt.CheckboxMenuItem {
      // CheckboxMenuItem
      let handler = _SwiftUIMenuItemTarget(menuItem: cbItem as java.awt.MenuItem)
      nsItem = NSMenuItem(title: cbItem.getLabel(),
                          action: #selector(_SwiftUIMenuItemTarget.trigger),
                          keyEquivalent: keyEquivalent(for: cbItem))
      nsItem.target = handler
      nsItem.state  = cbItem.getState() ? .on : .off
      objc_setAssociatedObject(nsItem, &_SwiftUIWindowHost.menuTargetKey,
                               handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    } else if let subMenu = item as? java.awt.Menu {
      // Untermenü
      nsItem = NSMenuItem(title: subMenu.getLabel(), action: nil, keyEquivalent: "")
      nsItem.submenu = buildNSSubmenu(from: subMenu)
    } else {
      // Normaler MenuItem
      let handler = _SwiftUIMenuItemTarget(menuItem: item)
      nsItem = NSMenuItem(title: item.getLabel(),
                          action: #selector(_SwiftUIMenuItemTarget.trigger),
                          keyEquivalent: keyEquivalent(for: item))
      nsItem.target = handler
      if let sc = item.shortcut {
        nsItem.keyEquivalentModifierMask = sc.usesShiftModifier() ? [.command, .shift] : [.command]
      }
      objc_setAssociatedObject(nsItem, &_SwiftUIWindowHost.menuTargetKey,
                               handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    nsItem.isEnabled = item.isEnabled()
    return nsItem
  }

  private static var menuTargetKey: UInt8 = 1

  /// Gibt das `keyEquivalent`-String für ein `MenuItem` zurück.
  private func keyEquivalent(for item: java.awt.MenuItem) -> String {
    guard let sc = item.shortcut else { return "" }
    // sc.key ist ein java.awt.event.KeyEvent-Konstant (ASCII-Wert für Buchstaben)
    let ch = sc.key
    if ch >= 65 && ch <= 90 {
      return String(UnicodeScalar(ch + 32)!)  // uppercase → lowercase
    } else if ch >= 97 && ch <= 122 {
      return String(UnicodeScalar(ch)!)
    }
    return ""
  }

  /// Rückwärtskompatible Überladung für bestehenden Code.
  @MainActor
  public func openNewWindow(for frame: java.awt.Frame) {
    openNewWindow(for: frame as java.awt.Window)
  }

  // ---------------------------------------------------------------------------
  // MARK: Dialog
  // ---------------------------------------------------------------------------

  /// Öffnet einen `java.awt.Dialog` als natives NSPanel.
  ///
  /// - Modaler Dialog (`modal == true`): wird als Sheet am Besitzerfenster
  ///   angehängt wenn ein Besitzer vorhanden ist, sonst als `runModal`-Block.
  /// - Nicht-modaler Dialog: verhält sich wie ein normales Fenster.
  @MainActor
  public func openDialog(_ dialog: java.awt.Dialog) {
    dialog.validate()

    let hostingView = NSHostingView(
      rootView: _SwiftUICanvasViewRepresentable(component: dialog)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea())
    hostingView.autoresizingMask = [.width, .height]

    var styleMask: NSWindow.StyleMask = [.titled, .closable]
    if dialog.resizable { styleMask.insert(.resizable) }

    let nsPanel = NSPanel(
      contentRect: NSRect(
        x: dialog.bounds.x, y: dialog.bounds.y,
        width:  max(dialog.bounds.width,  200),
        height: max(dialog.bounds.height, 100)),
      styleMask: styleMask,
      backing: .buffered,
      defer: false)

    nsPanel.title              = dialog.getTitle()
    nsPanel.contentView        = hostingView
    nsPanel.isReleasedWhenClosed = false
    nsPanel.becomesKeyOnlyIfNeeded = !dialog.isModal()

    // Größenconstraints
    let sizeDelegate = _SwiftUIWindowSizeDelegate(dialog)
    nsPanel.delegate = sizeDelegate
    objc_setAssociatedObject(nsPanel, &_SwiftUIWindowHost.delegateKey,
                             sizeDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    // nsPanel am Dialog-Objekt hängen — damit closeDialog(_:) es findet
    objc_setAssociatedObject(dialog, &_SwiftUIWindowHost.dialogPanelKey,
                             nsPanel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    // Schließen über nativen X-Button → modal loop beenden + AWT-Zustand aufräumen
    // [weak dialog]: verhindert Retain-Cycle Observer→dialog, da dialog ohnehin
    // über closeDialog() aufgeräumt wird.
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification,
      object: nsPanel,
      queue: .main) { [weak self, weak dialog] _ in
        guard let self, let dialog else { return }
        Task { @MainActor in
          if dialog.isModal() { NSApp.stopModal() }
          self.hide(dialog)
        }
      }

    if dialog.isModal() {
      // Besitzerfenster als Sheet, falls vorhanden
      let ownerNS = NSApp.windows.first { $0.title == (dialog.owner as? java.awt.Frame)?.title
                                       || $0.title == (dialog.owner as? java.awt.Dialog)?.getTitle() }
      // Java AWT dialogs are always independent windows with a title bar —
      // never sheets. Use runModal so they block like Java modal dialogs.
      _ = ownerNS  // owner found but unused; keep as standalone window
      if dialog.bounds.x == 0 && dialog.bounds.y == 0 { nsPanel.center() }
      nsPanel.makeKeyAndOrderFront(nil)
      NSApp.runModal(for: nsPanel)
    } else {
      if dialog.bounds.x == 0 && dialog.bounds.y == 0 { nsPanel.center() }
      nsPanel.makeKeyAndOrderFront(nil)
    }
  }

  /// Schließt einen Dialog programmatisch (z.B. vom Schließen-Button).
  /// Beendet `runModal`-Loop oder Sheet und schließt das NSPanel.
  @MainActor
  public func closeDialog(_ dialog: java.awt.Dialog) {
    guard let nsPanel = objc_getAssociatedObject(dialog, &_SwiftUIWindowHost.dialogPanelKey)
            as? NSPanel else {
      // Fallback: einfach hide
      hide(dialog)
      return
    }

    if dialog.isModal() {
      if let parent = nsPanel.sheetParent {
        parent.endSheet(nsPanel)
      } else {
        NSApp.stopModal()
      }
    }
    nsPanel.orderOut(nil)
    // Alle assoziierten Objekte am Panel freigeben (Delegate, ggf. menuTargetKey)
    nsPanel.delegate = nil
    objc_setAssociatedObject(nsPanel, &_SwiftUIWindowHost.delegateKey,
                             nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    // Retain-Cycle brechen: dialog → nsPanel → NSHostingView → dialog
    nsPanel.contentView = nil
    objc_setAssociatedObject(dialog, &_SwiftUIWindowHost.dialogPanelKey,
                             nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    // Synchron aus Registry entfernen (wir sind bereits auf dem Main-Thread)
    hideNow(dialog)
  }

  private static var dialogPanelKey: UInt8 = 2
}

#endif   // os(macOS)
#endif   // canImport(SwiftUI)
