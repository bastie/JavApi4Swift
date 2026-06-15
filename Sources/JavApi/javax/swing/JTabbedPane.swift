/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A component that lets the user switch between panels by clicking tabs.
  ///
  /// `JTabbedPane` manages a list of (title, component) pairs.  One tab is
  /// selected at a time; its associated component fills the content area below
  /// the tab strip.
  ///
  /// ## Tab placement constants (access via `JTabbedPane.TOP` etc.)
  ///
  /// | Constant | Value |
  /// |---|---|
  /// | `TOP`    | 1 |
  /// | `BOTTOM` | 3 |
  /// | `LEFT`   | 2 |
  /// | `RIGHT`  | 4 |
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let tabs = javax.swing.JTabbedPane()
  /// tabs.addTab("AWT",   awtPanel)
  /// tabs.addTab("Swing", swingPanel)
  /// frame.add(tabs, java.awt.BorderLayout.CENTER)
  /// ```
  ///
  @MainActor
  open class JTabbedPane: javax.swing.JComponent, javax.swing.SwingConstants {

    // -------------------------------------------------------------------------
    // MARK: Tab placement constants
    // -------------------------------------------------------------------------

    public static let TOP:    Int = JTabbedPane.TOP     // 1
    public static let BOTTOM: Int = JTabbedPane.BOTTOM  // 3
    public static let LEFT:   Int = JTabbedPane.LEFT    // 2
    public static let RIGHT:  Int = JTabbedPane.RIGHT   // 4

    // -------------------------------------------------------------------------
    // MARK: Tab model
    // -------------------------------------------------------------------------

    /// Internal representation of a single tab.
    public struct Tab {
      public var title:     String
      public var component: java.awt.Component
      public var icon:      javax.swing.Icon?
      public var toolTip:   String?
      public var enabled:   Bool = true
    }

    private var tabs: [Tab] = []
    private var _selectedIndex: Int = -1
    private var _tabPlacement: Int = JTabbedPane.TOP

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      setOpaque(true)
      updateUI()
    }

    public init(_ tabPlacement: Int) {
      super.init()
      _tabPlacement = tabPlacement
      setOpaque(true)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func updateUI() {
      ui = javax.swing.plaf.basic.BasicTabbedPaneUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Tab placement
    // -------------------------------------------------------------------------

    public func getTabPlacement() -> Int { _tabPlacement }
    public func setTabPlacement(_ placement: Int) {
      _tabPlacement = placement
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Adding / removing tabs
    // -------------------------------------------------------------------------

    /// Appends a tab with a title and component.
    public func addTab(_ title: String, _ component: java.awt.Component) {
      tabs.append(Tab(title: title, component: component))
      component.parent = self
      if _selectedIndex < 0 { _selectedIndex = 0 }
      invalidate()
    }

    /// Appends a tab with a title, icon, and component.
    public func addTab(_ title: String, _ icon: javax.swing.Icon?, _ component: java.awt.Component) {
      tabs.append(Tab(title: title, component: component, icon: icon))
      component.parent = self
      if _selectedIndex < 0 { _selectedIndex = 0 }
      invalidate()
    }

    /// Appends a tab with title, icon, component, and tooltip.
    public func addTab(_ title: String, _ icon: javax.swing.Icon?, _ component: java.awt.Component, _ tip: String?) {
      tabs.append(Tab(title: title, component: component, icon: icon, toolTip: tip))
      component.parent = self
      if _selectedIndex < 0 { _selectedIndex = 0 }
      invalidate()
    }

    /// Removes the tab at `index`.
    public func removeTabAt(_ index: Int) {
      guard index >= 0 && index < tabs.count else { return }
      tabs.remove(at: index)
      if _selectedIndex >= tabs.count { _selectedIndex = tabs.count - 1 }
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Selection
    // -------------------------------------------------------------------------

    public func getSelectedIndex() -> Int { _selectedIndex }

    public func setSelectedIndex(_ index: Int) {
      guard index >= -1 && index < tabs.count else { return }
      _selectedIndex = index
      invalidate()
    }

    public func getSelectedComponent() -> java.awt.Component? {
      guard _selectedIndex >= 0 && _selectedIndex < tabs.count else { return nil }
      return tabs[_selectedIndex].component
    }

    // -------------------------------------------------------------------------
    // MARK: Tab accessors
    // -------------------------------------------------------------------------

    public func getTabCount() -> Int { tabs.count }

    public func getTitleAt(_ index: Int) -> String {
      guard index >= 0 && index < tabs.count else { return "" }
      return tabs[index].title
    }

    public func setTitleAt(_ index: Int, _ title: String) {
      guard index >= 0 && index < tabs.count else { return }
      tabs[index].title = title
      invalidate()
    }

    public func getIconAt(_ index: Int) -> javax.swing.Icon? {
      guard index >= 0 && index < tabs.count else { return nil }
      return tabs[index].icon
    }

    public func setIconAt(_ index: Int, _ icon: javax.swing.Icon?) {
      guard index >= 0 && index < tabs.count else { return }
      tabs[index].icon = icon
      invalidate()
    }

    public func getComponentAt(_ index: Int) -> java.awt.Component? {
      guard index >= 0 && index < tabs.count else { return nil }
      return tabs[index].component
    }

    public func isEnabledAt(_ index: Int) -> Bool {
      guard index >= 0 && index < tabs.count else { return false }
      return tabs[index].enabled
    }

    public func setEnabledAt(_ index: Int, _ enabled: Bool) {
      guard index >= 0 && index < tabs.count else { return }
      tabs[index].enabled = enabled
      invalidate()
    }

    public func getToolTipTextAt(_ index: Int) -> String? {
      guard index >= 0 && index < tabs.count else { return nil }
      return tabs[index].toolTip
    }

    /// Returns index of tab whose bounds contain `(x, y)` in the tab strip,
    /// or -1 if none.  Called by `BasicTabbedPaneUI` for click-to-select.
    public func indexAtLocation(_ x: Int, _ y: Int) -> Int {
      (ui as? javax.swing.plaf.basic.BasicTabbedPaneUI)?.tabIndexAt(x, y, in: self) ?? -1
    }

    // -------------------------------------------------------------------------
    // MARK: Internal tab list access for UI delegate
    // -------------------------------------------------------------------------

    public func getTabs() -> [Tab] { tabs }

    // -------------------------------------------------------------------------
    // MARK: Mouse — tab selection on click
    // -------------------------------------------------------------------------

    override open func processMouseEvent(_ e: java.awt.event.MouseEvent) {
      // _AWTHitTest.dispatch sends MOUSE_CLICKED for unknown components.
      if e.getID() == java.awt.event.MouseEvent.MOUSE_CLICKED {
        let idx = indexAtLocation(e.getX(), e.getY())
        if idx >= 0 && isEnabledAt(idx) {
          setSelectedIndex(idx)
          repaint()
        }
      }
      super.processMouseEvent(e)
    }

    // -------------------------------------------------------------------------
    // MARK: Container — expose selected child for hit-testing
    // -------------------------------------------------------------------------

    override public func getComponents() -> [java.awt.Component] {
      guard let sel = getSelectedComponent() else { return [] }
      return [sel]
    }
  }
}
