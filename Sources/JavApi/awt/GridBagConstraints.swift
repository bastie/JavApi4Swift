/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - GridBagConstraints
  // ---------------------------------------------------------------------------

  /// Layout constraints for components managed by `GridBagLayout` —
  /// mirrors `java.awt.GridBagConstraints`.
  ///
  /// ```swift
  /// let c = java.awt.GridBagConstraints()
  /// c.gridx  = 0
  /// c.gridy  = 0
  /// c.fill   = java.awt.GridBagConstraints.HORIZONTAL
  /// c.weightx = 1.0
  /// layout.setConstraints(button, c)
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.0)
  public class GridBagConstraints {

    // -------------------------------------------------------------------------
    // MARK: fill constants
    // -------------------------------------------------------------------------

    /// Do not resize the component.
    public static let NONE       = 0
    /// Resize the component horizontally.
    public static let HORIZONTAL = 2
    /// Resize the component vertically.
    public static let VERTICAL   = 3
    /// Resize the component in both directions.
    public static let BOTH       = 1

    // -------------------------------------------------------------------------
    // MARK: anchor constants
    // -------------------------------------------------------------------------

    public static let CENTER    = 10
    public static let NORTH     = 11
    public static let NORTHEAST = 12
    public static let EAST      = 13
    public static let SOUTHEAST = 14
    public static let SOUTH     = 15
    public static let SOUTHWEST = 16
    public static let WEST      = 17
    public static let NORTHWEST = 18

    // -------------------------------------------------------------------------
    // MARK: gridx / gridy special values
    // -------------------------------------------------------------------------

    /// Place the component at the next cell relative to the last added component.
    public static let RELATIVE  = -1
    /// Indicates this component occupies all remaining space in the row/column.
    public static let REMAINDER = 0

    // -------------------------------------------------------------------------
    // MARK: Fields  (Java field names kept for porting fidelity)
    // -------------------------------------------------------------------------

    /// Column index of the component's leading edge cell (or RELATIVE).
    public var gridx:      Int    = RELATIVE
    /// Row index of the component's leading edge cell (or RELATIVE).
    public var gridy:      Int    = RELATIVE
    /// Number of columns the component spans.
    public var gridwidth:  Int    = 1
    /// Number of rows the component spans.
    public var gridheight: Int    = 1
    /// How to distribute extra horizontal space (0.0 = none).
    public var weightx:    Double = 0.0
    /// How to distribute extra vertical space (0.0 = none).
    public var weighty:    Double = 0.0
    /// Alignment of the component within its display area.
    public var anchor:     Int    = CENTER
    /// How to resize the component within its display area.
    public var fill:       Int    = NONE
    /// External padding around the component.
    public var insets:     java.awt.Insets = java.awt.Insets(0, 0, 0, 0)
    /// Internal horizontal padding added to the component's minimum width.
    public var ipadx:      Int    = 0
    /// Internal vertical padding added to the component's minimum height.
    public var ipady:      Int    = 0

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    /// Creates a `GridBagConstraints` with all fields at their default values.
    public init() {}

    /// Creates a fully specified `GridBagConstraints`.
    public init(gridx: Int, gridy: Int,
                gridwidth: Int = 1, gridheight: Int = 1,
                weightx: Double = 0.0, weighty: Double = 0.0,
                anchor: Int = CENTER, fill: Int = NONE,
                insets: java.awt.Insets = java.awt.Insets(0, 0, 0, 0),
                ipadx: Int = 0, ipady: Int = 0) {
      self.gridx      = gridx
      self.gridy      = gridy
      self.gridwidth  = gridwidth
      self.gridheight = gridheight
      self.weightx    = weightx
      self.weighty    = weighty
      self.anchor     = anchor
      self.fill       = fill
      self.insets     = insets
      self.ipadx      = ipadx
      self.ipady      = ipady
    }

    // -------------------------------------------------------------------------
    // MARK: Cloneable
    // -------------------------------------------------------------------------

    public func clone() -> GridBagConstraints {
      let copy = GridBagConstraints()
      copy.gridx      = gridx
      copy.gridy      = gridy
      copy.gridwidth  = gridwidth
      copy.gridheight = gridheight
      copy.weightx    = weightx
      copy.weighty    = weighty
      copy.anchor     = anchor
      copy.fill       = fill
      copy.insets     = java.awt.Insets(insets.top, insets.left, insets.bottom, insets.right)
      copy.ipadx      = ipadx
      copy.ipady      = ipady
      return copy
    }
  }
}
