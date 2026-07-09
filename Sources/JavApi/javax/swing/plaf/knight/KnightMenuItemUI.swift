/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.knight {

  /// Base UI delegate for `JMenuItem` and its subclasses.
  ///
  /// Handles dynamic size calculation (via `FontMetrics`) and painting of
  /// the item background, armed highlight, and text label.  Subclasses
  /// such as `BasicCheckBoxMenuItemUI` and `BasicRadioButtonMenuItemUI`
  /// override `indicatorWidth()` and `paintIndicator(_:in:selected:)` to
  /// draw the checkbox or radio indicator to the left of the text.
  ///
  /// ## Layout
  ///
  /// ```
  /// |<-- padX -->|<-- indicatorWidth + indicatorGap -->|<-- text -->|<-- padX -->|
  /// ```
  ///
  /// All dimensions derive from `FontMetrics` at paint time, so changing
  /// the component font automatically adjusts both preferred size and layout.
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  final public class KnightMenuItemUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Layout constants
    // -------------------------------------------------------------------------

    /// Horizontal padding on each side of the item.
    public static let padX: Int = 12
    /// Vertical padding added above and below the text.
    public static let padY: Int = 4
    /// Gap between the indicator (checkbox/radio) and the text label.
    public static let indicatorGap: Int = 6

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    public class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return KnightMenuItemUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Indicator — overridden by subclasses
    // -------------------------------------------------------------------------

    /// Width (in pixels) of the toggle indicator drawn to the left of the text.
    ///
    /// Returns `0` for plain `JMenuItem`; subclasses return the indicator size.
    public func indicatorWidth() -> Int { 0 }

    /// Paints the toggle indicator (checkbox square or radio circle) inside
    /// `rect` using graphics context `g`.
    ///
    /// - Parameters:
    ///   - g:        The graphics context.
    ///   - rect:     Bounding rectangle for the indicator, already offset to
    ///               its position within the component.
    ///   - selected: Whether the menu item is currently selected/checked.
    public func paintIndicator(_ g: java.awt.Graphics, in rect: java.awt.Rectangle, selected: Bool) {
      // Default: no indicator.
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override public func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let item = component as? javax.swing.JMenuItem else { return nil }
      let fm   = java.awt.FontMetrics.make(for: component.font)
      let indW = indicatorWidth()
      let indSection = indW > 0 ? indW + Self.indicatorGap : 0
      let w = Self.padX + indSection + fm.stringWidth(item.getText()) + Self.padX
      let h = Swift.max(indW, fm.getHeight()) + Self.padY * 2
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override public func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let item = component as? javax.swing.JMenuItem else { return }

      let bounds = component.bounds
      let w = bounds.width
      let h = bounds.height
      let fm = java.awt.FontMetrics.make(for: component.font)

      // Wenn der Menüeintrag ein "mouse" over bekommt (isArmed) setzen wir den Hintergrund auf ein dunkles Rot, ansonsten gibt es ein dunkles Schwarz
      if item.isArmed {
        g.setColor(KnightColor.DARKER_RED)
        g.fillRect(0, 0, w, h)
      } else {
        g.setColor(KnightColor.DARKER_BLACK)
        g.fillRect(0, 0, w, h)
      }

      var textX = Self.padX

      // --- Indicator (checkbox / radio) ---
      let indW = indicatorWidth()
      if indW > 0 {
        let indY = (h - indW) / 2
        let indRect = java.awt.Rectangle(Self.padX, indY, indW, indW)
        paintIndicator(g, in: indRect, selected: item.isSelected())
        textX = Self.padX + indW + Self.indicatorGap
      }

      // --- Text label ---
      let text = item.getText()
      if !text.isEmpty {
        let textY = (h - fm.getHeight()) / 2 + fm.getAscent()
        /// Wenn wir ein mouse over bekommen, setzen wir die Vordergrundfarbe auf ein helles Weiß, sonst ein abgedunkeltes Weiß
        g.setColor(item.isArmed ? KnightColor.ALL_WHITE : KnightColor.MOSTLY_WHITE)
        g.drawString(text, textX, textY)
      }
    }
  }
}
