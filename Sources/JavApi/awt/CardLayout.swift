/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - CardLayout
  // ---------------------------------------------------------------------------

  /// Shows one child at a time, like a stack of cards .
  ///
  /// Components are added with a string name. Use `show(_:_:)`, `next(_:)`,
  /// `previous(_:)`, `first(_:)`, and `last(_:)` to switch the visible card.
  ///
  /// ```swift
  /// let cards = java.awt.CardLayout()
  /// let panel = java.awt.Panel(cards)
  /// panel.add(pageA, "home")
  /// panel.add(pageB, "settings")
  /// cards.show(panel, "settings")
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.0)
  public final class CardLayout: LayoutManager {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    private var hgap: Int
    private var vgap: Int

    /// Ordered list of (name, component) pairs — order matches `addLayoutComponent` calls.
    private var cards: [(name: String, comp: java.awt.Component)] = []

    /// Index of the currently visible card.
    private var currentIndex: Int = 0

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a `CardLayout` with no gap.
    public init() {
      hgap = 0
      vgap = 0
    }

    /// Creates a `CardLayout` with the specified horizontal and vertical gaps.
    public init(_ hgap: Int, _ vgap: Int) {
      self.hgap = max(0, hgap)
      self.vgap = max(0, vgap)
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getHgap() -> Int { hgap }
    public func getVgap() -> Int { vgap }
    public func setHgap(_ h: Int) { hgap = max(0, h) }
    public func setVgap(_ v: Int) { vgap = max(0, v) }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager — registration
    // -------------------------------------------------------------------------

    /// Registers a component under the given name.
    ///
    /// Called automatically by `Container.add(_:_:)` when the layout is a
    /// `CardLayout`. The `name` is the string constraint passed to `add`.
    public func addLayoutComponent(_ name: String, _ comp: java.awt.Component) {
      // Avoid duplicates — replace if the component is re-added under a new name.
      cards.removeAll { $0.comp === comp }
      cards.append((name: name.isEmpty ? "\(cards.count)" : name, comp: comp))
      // Clamp currentIndex after removal
      if currentIndex >= cards.count { currentIndex = max(0, cards.count - 1) }
      updateVisibility()
    }

    public func removeLayoutComponent(_ comp: java.awt.Component) {
      guard let idx = cards.firstIndex(where: { $0.comp === comp }) else { return }
      cards.remove(at: idx)
      if currentIndex >= cards.count { currentIndex = max(0, cards.count - 1) }
      updateVisibility()
    }

    public func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      var maxW = 0, maxH = 0
      for card in cards {
        let ps = card.comp.getPreferredSize()
        maxW = max(maxW, ps.width  > 0 ? ps.width  : card.comp.bounds.width)
        maxH = max(maxH, ps.height > 0 ? ps.height : card.comp.bounds.height)
      }
      return java.awt.Dimension(maxW + 2 * hgap, maxH + 2 * vgap)
    }

    public func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(2 * hgap, 2 * vgap)
    }

    /// Sizes and positions all cards identically; only the current card is shown.
    public func layoutContainer(_ parent: java.awt.Container) {
      let x = parent.bounds.x + hgap
      let y = parent.bounds.y + vgap
      let w = max(0, parent.bounds.width  - 2 * hgap)
      let h = max(0, parent.bounds.height - 2 * vgap)
      for card in cards {
        card.comp.bounds = java.awt.Rectangle(x, y, w, h)
      }
      updateVisibility()
    }

    // -------------------------------------------------------------------------
    // MARK: Card navigation
    // -------------------------------------------------------------------------

    /// Shows the card registered under `name` in `parent`.
    public func show(_ parent: java.awt.Container, _ name: String) {
      guard let idx = cards.firstIndex(where: { $0.name == name }) else { return }
      currentIndex = idx
      updateVisibility()
    }

    /// Shows the first card in `parent`.
    public func first(_ parent: java.awt.Container) {
      guard !cards.isEmpty else { return }
      currentIndex = 0
      updateVisibility()
    }

    /// Shows the last card in `parent`.
    public func last(_ parent: java.awt.Container) {
      guard !cards.isEmpty else { return }
      currentIndex = cards.count - 1
      updateVisibility()
    }

    /// Shows the next card; wraps around to the first.
    public func next(_ parent: java.awt.Container) {
      guard !cards.isEmpty else { return }
      currentIndex = (currentIndex + 1) % cards.count
      updateVisibility()
    }

    /// Shows the previous card; wraps around to the last.
    public func previous(_ parent: java.awt.Container) {
      guard !cards.isEmpty else { return }
      currentIndex = (currentIndex - 1 + cards.count) % cards.count
      updateVisibility()
    }

    // -------------------------------------------------------------------------
    // MARK: Helpers
    // -------------------------------------------------------------------------

    /// Marks exactly one card visible; all others hidden.
    ///
    /// AWT's original CardLayout uses `Component.setVisible()`. We mirror that
    /// via the `isVisible` property on `Component`.
    private func updateVisibility() {
      for (i, card) in cards.enumerated() {
        card.comp.setVisible(i == currentIndex)
      }
    }
  }
}
