/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Menubar of a `Frame`.
  ///
  @MainActor
  open class MenuBar: MenuComponent {

    private var menus:   [Menu] = []
    private var helpMenu: Menu? = nil

    public override init() {}

    // -------------------------------------------------------------------------
    // MARK: Menüs verwalten
    // -------------------------------------------------------------------------

    @discardableResult
    public func add(_ menu: Menu) -> Menu {
      menus.append(menu)
      return menu
    }

    public func remove(_ index: Int) {
      guard index >= 0, index < menus.count else { return }
      menus.remove(at: index)
    }

    public func remove(_ menu: Menu) {
      menus.removeAll { $0 === menu }
    }

    public func getMenu(_ index: Int) -> Menu {
      menus[index]
    }
    
    /// - Since: Java 1.1
    public func getMenuCount() -> Int {
      menus.count
    }
    
    public func getMenus() -> [Menu] {
      menus
    }
    
    @available(*, deprecated, renamed: "getMenuCount", message: "replaced by getMenuCount()")
    public func countMenus() -> Int {
      return self.getMenuCount()
    }

    // -------------------------------------------------------------------------
    // MARK: Help-Menü (erscheint rechts, Java-Konvention)
    // -------------------------------------------------------------------------

    public func setHelpMenu(_ menu: Menu?) {
      if let old = helpMenu {
        remove(old)
      }
      helpMenu = menu
      if let menu {
        menus.append(menu)
      }
    }

    public func getHelpMenu() -> Menu? {
      helpMenu
    }
  }
}
