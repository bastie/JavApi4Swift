/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Ein aufklappbares Untermenü — mirrors `java.awt.Menu`.
  ///
  /// `Menu` erbt von `MenuItem`, da Untermenüs selbst als Eintrag in einer
  /// Menüleiste oder einem anderen Menü erscheinen.
  @MainActor
  open class Menu: MenuItem {

    private var items: [MenuItem] = []
    public var tearOff: Bool = false

    public init(_ label: String = "", tearOff: Bool = false) {
      self.tearOff = tearOff
      super.init(label)
    }

    // -------------------------------------------------------------------------
    // MARK: Items
    // -------------------------------------------------------------------------

    public func add(_ item: MenuItem) {
      items.append(item)
    }

    /// Fügt einen Trennstrich hinzu.
    public func addSeparator() {
      items.append(MenuItem("-"))
    }

    public func insert(_ item: MenuItem, _ index: Int) {
      let i = max(0, min(index, items.count))
      items.insert(item, at: i)
    }

    public func insertSeparator(_ index: Int) {
      insert(MenuItem("-"), index)
    }

    public func remove(_ index: Int) {
      guard index >= 0, index < items.count else { return }
      items.remove(at: index)
    }

    public func remove(_ item: MenuItem) {
      items.removeAll { $0 === item }
    }

    public func removeAll() { items.removeAll() }

    public func getItem(_ index: Int) -> MenuItem { items[index] }
    public func getItemCount() -> Int             { items.count }
    public func getItems() -> [MenuItem]          { items }

    public func isSeparator(at index: Int) -> Bool {
      guard index >= 0, index < items.count else { return false }
      return items[index].getLabel() == "-"
    }
  }
}
