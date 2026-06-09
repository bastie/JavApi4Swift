/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Openable submenu.
  ///
  /// `Menu` extends `MenuItem`, becaue submenus are item of menu or menubars
  ///
  /// - Note: Native toolkits (AppKit, UIKit) draw separator lines using the
  ///   platform-native appearance (Dark-Mode-aware). TUI rendering uses
  ///   `_SEPARATOR_LINE` as a text fallback, which can be customised via the
  ///   `javapi.menu.separator` system property.
  @MainActor
  open class Menu: MenuItem {

    /// Text representation of a separator for TUI rendering.
    /// Override via system property `javapi.menu.separator`.
    public static let _SEPARATOR_LINE = System.getProperty("javapi.menu.separator", "--- ¯\\_(ツ)_/¯ ---")

    /// Menuitems
    private var items: [MenuItem] = []
    public var tearOff: Bool = false

    public init(_ label: String = "", tearOff: Bool = false) {
      self.tearOff = tearOff
      super.init(label)
    }

    /// Add a menuitem to this menu
    /// - Parameter item: menuitem
    public func add(_ item: MenuItem) {
      items.append(item)
    }

    /// Add separator
    public func addSeparator() {
      items.append(MenuItem(isSeparator: true))
    }

    /// Insert a menuitem to this menu at given index
    /// - Parameters:
    ///  - item: menuitem
    ///  - index: position of menu
    public func insert(_ item: MenuItem, _ index: Int) {
      let i = max(0, min(index, items.count))
      items.insert(item, at: i)
    }

    /// Insert a separator at given index
    /// - Parameter index: postion of menu
    public func insertSeparator(_ index: Int) {
      insert(MenuItem(isSeparator: true), index)
    }

    /// Remove menuitem at given index or do nothing
    /// - Parameter index: positon of menu
    public func remove(_ index: Int) {
      guard index >= 0, index < items.count else { return }
      items.remove(at: index)
    }

    /// Remove the given menuitem
    /// - Parameter item: the item to remove
    public func remove(_ item: MenuItem) {
      items.removeAll { $0 === item }
    }

    /// Remove all menuitems
    public func removeAll() {
      items.removeAll()
    }

    /// - Parameter index: of wanted menuitem
    /// - Returns: the menuitem at index
    /// - Throws: ArrayIndexOutOfBoundsException if is index is not valid (like Java does)
    public func getItem(_ index: Int) throws (ArrayIndexOutOfBoundsException) -> MenuItem {
      guard getItemCount() > index else {
        throw ArrayIndexOutOfBoundsException()
      }
      return items[index]
    }
    
    /// - Returns the cont of items in menu
    public func getItemCount() -> Int             {
      return items.count
    }
    
    /// - Returns: an array of all menuitems
    public func getItems() -> [MenuItem]          {
      items
    }

    /// - Returns: `true` if at index is an separator item
    public func isSeparator(at index: Int) -> Bool {
      guard index >= 0, index < items.count else { return false }
      return items[index].isSeparator
    }
  }
}
