/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  // FIXME: BasicButtonUI (and other BasicXxxUI delegates) currently paint their borders directly via hard-coded Graphics calls instead of installing a default Border via setBorder() in installUI() and letting JComponent.paint() call getBorder().paintBorder(...).  As a result, calling setBorder() on a JButton (or other Swing components backed by a BasicXxxUI) has no visible effect — the UI-delegate border always wins.  The fix is to refactor every BasicXxxUI to install its visual border as a real Border object in installUI() and remove the direct drawing from paint().  Until then, setBorder() on those components is essentially a no-op for the visual output.

  /// Factory class for creating `Border` objects.
  ///
  /// Use these static factory methods rather than constructing border objects
  /// directly.  For borders that are immutable (e.g. `EmptyBorder` with
  /// zero insets, black `LineBorder`) the factory may return a shared instance.
  ///
  /// Corresponds to `javax.swing.BorderFactory`.
  @MainActor
  public final class BorderFactory {

    private init() {}

    // ── Empty ─────────────────────────────────────────────────────────────────

    /// Returns an empty border that takes up no space.
    public static func createEmptyBorder() -> any javax.swing.border.Border {
      javax.swing.border.EmptyBorder(0, 0, 0, 0)
    }

    /// Returns an empty border with uniform insets on all four sides.
    public static func createEmptyBorder(
      _ top: Int, _ left: Int, _ bottom: Int, _ right: Int
    ) -> any javax.swing.border.Border {
      javax.swing.border.EmptyBorder(top, left, bottom, right)
    }

    // ── Line ──────────────────────────────────────────────────────────────────

    /// Returns a 1-pixel-thick line border in the given color.
    public static func createLineBorder(_ color: java.awt.Color) -> any javax.swing.border.Border {
      javax.swing.border.LineBorder(color)
    }

    /// Returns a line border with the given color and thickness.
    public static func createLineBorder(
      _ color: java.awt.Color, _ thickness: Int
    ) -> any javax.swing.border.Border {
      javax.swing.border.LineBorder(color, thickness)
    }

    /// Returns a line border with optional rounded corners.
    public static func createLineBorder(
      _ color: java.awt.Color, _ thickness: Int, _ rounded: Bool
    ) -> any javax.swing.border.Border {
      javax.swing.border.LineBorder(color, thickness, rounded)
    }

    // ── Raised / Lowered Bevel ────────────────────────────────────────────────

    /// Returns a raised bevel border using the component's background color.
    public static func createRaisedBevelBorder() -> any javax.swing.border.Border {
      javax.swing.border.BevelBorder(javax.swing.border.BevelBorder.RAISED)
    }

    /// Returns a lowered bevel border using the component's background color.
    public static func createLoweredBevelBorder() -> any javax.swing.border.Border {
      javax.swing.border.BevelBorder(javax.swing.border.BevelBorder.LOWERED)
    }

    /// Returns a bevel border of the given type.
    public static func createBevelBorder(_ type: Int) -> any javax.swing.border.Border {
      javax.swing.border.BevelBorder(type)
    }

    /// Returns a bevel border with explicit highlight and shadow colors.
    public static func createBevelBorder(
      _ type: Int,
      _ highlight: java.awt.Color,
      _ shadow: java.awt.Color
    ) -> any javax.swing.border.Border {
      javax.swing.border.BevelBorder(type, highlight, shadow)
    }

    /// Returns a bevel border with all four colors specified.
    public static func createBevelBorder(
      _ type: Int,
      _ highlightOuter: java.awt.Color,
      _ highlightInner: java.awt.Color,
      _ shadowOuter: java.awt.Color,
      _ shadowInner: java.awt.Color
    ) -> any javax.swing.border.Border {
      javax.swing.border.BevelBorder(type, highlightOuter, highlightInner, shadowOuter, shadowInner)
    }

    // ── Etched ────────────────────────────────────────────────────────────────

    /// Returns a lowered etched border.
    public static func createEtchedBorder() -> any javax.swing.border.Border {
      javax.swing.border.EtchedBorder()
    }

    /// Returns an etched border of the given type (`EtchedBorder.LOWERED` or `.RAISED`).
    public static func createEtchedBorder(_ type: Int) -> any javax.swing.border.Border {
      javax.swing.border.EtchedBorder(type)
    }

    /// Returns an etched border with explicit highlight and shadow colors.
    public static func createEtchedBorder(
      _ highlight: java.awt.Color, _ shadow: java.awt.Color
    ) -> any javax.swing.border.Border {
      javax.swing.border.EtchedBorder(highlight, shadow)
    }

    /// Returns an etched border of the given type with explicit colors.
    public static func createEtchedBorder(
      _ type: Int, _ highlight: java.awt.Color, _ shadow: java.awt.Color
    ) -> any javax.swing.border.Border {
      javax.swing.border.EtchedBorder(type, highlight, shadow)
    }

    // ── Titled ────────────────────────────────────────────────────────────────

    /// Returns a titled border with a default etched inner border.
    public static func createTitledBorder(_ title: String) -> javax.swing.border.TitledBorder {
      javax.swing.border.TitledBorder(title)
    }

    /// Returns a titled border wrapping the given border.
    public static func createTitledBorder(
      _ border: any javax.swing.border.Border
    ) -> javax.swing.border.TitledBorder {
      javax.swing.border.TitledBorder(border)
    }

    /// Returns a titled border wrapping the given border with a title string.
    public static func createTitledBorder(
      _ border: (any javax.swing.border.Border)?,
      _ title: String
    ) -> javax.swing.border.TitledBorder {
      javax.swing.border.TitledBorder(border, title)
    }

    /// Returns a fully configured titled border.
    public static func createTitledBorder(
      _ border: (any javax.swing.border.Border)?,
      _ title: String,
      _ titleJustification: Int,
      _ titlePosition: Int
    ) -> javax.swing.border.TitledBorder {
      javax.swing.border.TitledBorder(border, title, titleJustification, titlePosition)
    }

    /// Returns a fully configured titled border with a custom font.
    public static func createTitledBorder(
      _ border: (any javax.swing.border.Border)?,
      _ title: String,
      _ titleJustification: Int,
      _ titlePosition: Int,
      _ titleFont: java.awt.Font
    ) -> javax.swing.border.TitledBorder {
      javax.swing.border.TitledBorder(border, title, titleJustification, titlePosition, titleFont)
    }

    /// Returns a fully configured titled border with a custom font and color.
    public static func createTitledBorder(
      _ border: (any javax.swing.border.Border)?,
      _ title: String,
      _ titleJustification: Int,
      _ titlePosition: Int,
      _ titleFont: java.awt.Font,
      _ titleColor: java.awt.Color
    ) -> javax.swing.border.TitledBorder {
      javax.swing.border.TitledBorder(border, title, titleJustification, titlePosition, titleFont, titleColor)
    }

    // ── Compound ──────────────────────────────────────────────────────────────

    /// Returns a compound border composed of the given outer and inner borders.
    public static func createCompoundBorder(
      _ outsideBorder: (any javax.swing.border.Border)?,
      _ insideBorder:  (any javax.swing.border.Border)?
    ) -> javax.swing.border.CompoundBorder {
      javax.swing.border.CompoundBorder(outsideBorder, insideBorder)
    }

    // ── Matte ─────────────────────────────────────────────────────────────────

    /// Returns a matte border with a solid color and uniform inset.
    public static func createMatteBorder(
      _ top: Int, _ left: Int, _ bottom: Int, _ right: Int,
      _ color: java.awt.Color
    ) -> any javax.swing.border.Border {
      javax.swing.border.MatteBorder(top, left, bottom, right, color)
    }

    /// Returns a matte border tiled with an icon.
    public static func createMatteBorder(
      _ top: Int, _ left: Int, _ bottom: Int, _ right: Int,
      _ tileIcon: any javax.swing.Icon
    ) -> any javax.swing.border.Border {
      javax.swing.border.MatteBorder(top, left, bottom, right, tileIcon)
    }
  }
}
